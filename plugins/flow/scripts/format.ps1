# Hook PostToolUse : formate le fichier que Claude vient de modifier,
# si un formateur est disponible sur la machine ou dans le projet.
#
# Ne bloque jamais : quoi qu'il arrive le script sort en 0, sans rien
# écrire sur la sortie standard. Si aucun formateur n'est installé, il ne
# fait rien.
#
# Pourquoi PowerShell et non bash ou Python :
#   - le `bash` du PATH sous Windows est le lanceur WSL, souvent cassé ;
#   - `jq` n'est pas installé par défaut ;
#   - le Python distribué via l'alias WindowsApps tourne en conteneur
#     applicatif avec %APPDATA% virtualisé : il ne voit PAS les outils
#     installés par `npm install -g` (prettier, etc.).
# PowerShell est natif, non virtualisé, et présent partout sous Windows.

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

# --- Dispatch vers le formateur adapté ---
if ($ext -eq '.py') {
    if (Test-Tool 'ruff') {
        Invoke-Quiet 'ruff' @('format', $file)
    } elseif (Test-Tool 'black') {
        Invoke-Quiet 'black' @('-q', $file)
    }
} elseif ($prettierExts -contains $ext) {
    if (Test-Tool 'prettier') {
        Invoke-Quiet 'prettier' @('--write', $file)
    } elseif (Test-Tool 'npx') {
        Invoke-Quiet 'npx' @('--no-install', 'prettier', '--write', $file)
    }
}

exit 0
