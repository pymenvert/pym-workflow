# Hook PostToolUse : formate le fichier que Claude vient de modifier.
#
# Règle de prudence : ce hook ne formate QUE si le projet a explicitement
# choisi un formateur, c'est-à-dire s'il contient un fichier de
# configuration correspondant. Sans ça, il ne touche à rien.
#
# Pourquoi : ce hook est installé en scope utilisateur, donc actif dans
# TOUS les projets, y compris ceux qui existaient avant lui. Reformater
# aux réglages par défaut un projet qui n'a jamais demandé prettier
# produirait un diff énorme et parasite. Le style d'un projet appartient
# au projet.
#
# Ne bloque jamais : quoi qu'il arrive le script sort en 0, sans rien
# écrire sur la sortie standard.
#
# Pourquoi PowerShell et non bash ou Python : sous Windows le `bash` du
# PATH est le lanceur WSL (souvent cassé), `jq` n'est pas installé, et le
# Python de l'alias WindowsApps tourne en conteneur applicatif avec
# %APPDATA% virtualisé — il ne voit donc pas les outils posés par
# `npm install -g`. PowerShell est natif et non virtualisé.

$ErrorActionPreference = 'SilentlyContinue'

# Extensions confiées à prettier. Volontairement sans .md : reformater la
# prose (CLAUDE.md, README) à chaque écriture fait plus de dégâts que de bien.
$prettierExts = @(
    '.js', '.jsx', '.ts', '.tsx', '.json',
    '.css', '.scss', '.html', '.yml', '.yaml'
)

function Invoke-Quiet {
    param([string]$Exe, [string[]]$Arguments)
    try { & $Exe @Arguments *> $null } catch { }
}

function Test-Tool {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# Racine du projet : la variable fournie par Claude Code, sinon on remonte
# depuis le fichier jusqu'au premier dossier contenant .git.
function Get-ProjectRoot {
    param([string]$FromFile)
    if ($env:CLAUDE_PROJECT_DIR -and (Test-Path -LiteralPath $env:CLAUDE_PROJECT_DIR)) {
        return $env:CLAUDE_PROJECT_DIR
    }
    $dir = Split-Path -Parent $FromFile
    while ($dir -and (Test-Path -LiteralPath $dir)) {
        if (Test-Path -LiteralPath (Join-Path $dir '.git')) { return $dir }
        $parent = Split-Path -Parent $dir
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

# Le projet a-t-il choisi prettier ? Fichier de config dédié, ou clé
# "prettier" dans package.json.
function Test-PrettierAdopte {
    param([string]$Root)
    if (-not $Root) { return $false }
    $configs = @(
        '.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml',
        '.prettierrc.json5', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.mjs',
        '.prettierrc.toml', 'prettier.config.js', 'prettier.config.cjs',
        'prettier.config.mjs'
    )
    foreach ($c in $configs) {
        if (Test-Path -LiteralPath (Join-Path $Root $c)) { return $true }
    }
    $pkg = Join-Path $Root 'package.json'
    if (Test-Path -LiteralPath $pkg) {
        try {
            $json = Get-Content -LiteralPath $pkg -Raw | ConvertFrom-Json
            if ($null -ne $json.prettier) { return $true }
            if ($json.devDependencies -and $json.devDependencies.PSObject.Properties.Name -contains 'prettier') { return $true }
        } catch { }
    }
    return $false
}

# Le projet a-t-il choisi ruff ou black ? Config dédiée, ou section
# correspondante dans pyproject.toml.
function Test-PythonFormateurAdopte {
    param([string]$Root, [string]$Outil)
    if (-not $Root) { return $false }
    if ($Outil -eq 'ruff') {
        foreach ($c in @('ruff.toml', '.ruff.toml')) {
            if (Test-Path -LiteralPath (Join-Path $Root $c)) { return $true }
        }
    }
    $pyproject = Join-Path $Root 'pyproject.toml'
    if (Test-Path -LiteralPath $pyproject) {
        try {
            $contenu = Get-Content -LiteralPath $pyproject -Raw
            if ($contenu -match "(?m)^\s*\[tool\.$Outil") { return $true }
        } catch { }
    }
    return $false
}

# --- Lecture du JSON envoyé par Claude Code sur stdin ---
try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
    $file = ($raw | ConvertFrom-Json).tool_input.file_path
} catch {
    exit 0
}

if ([string]::IsNullOrWhiteSpace($file)) { exit 0 }
if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { exit 0 }

$ext = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
$root = Get-ProjectRoot -FromFile $file

# --- Dispatch vers le formateur adapté, si et seulement si le projet l'a adopté ---
if ($ext -eq '.py') {
    if ((Test-PythonFormateurAdopte -Root $root -Outil 'ruff') -and (Test-Tool 'ruff')) {
        Invoke-Quiet 'ruff' @('format', $file)
    } elseif ((Test-PythonFormateurAdopte -Root $root -Outil 'black') -and (Test-Tool 'black')) {
        Invoke-Quiet 'black' @('-q', $file)
    }
} elseif ($prettierExts -contains $ext) {
    if (Test-PrettierAdopte -Root $root) {
        if (Test-Tool 'prettier') {
            Invoke-Quiet 'prettier' @('--write', $file)
        } elseif (Test-Tool 'npx') {
            Invoke-Quiet 'npx' @('--no-install', 'prettier', '--write', $file)
        }
    }
}

exit 0
