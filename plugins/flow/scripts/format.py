#!/usr/bin/env python3
"""Hook PostToolUse : formate le fichier que Claude vient de modifier,
si un formateur est disponible sur la machine ou dans le projet.

Ne bloque jamais : quoi qu'il arrive, le script sort en 0 et reste
silencieux. Si aucun formateur n'est installé, il ne fait rien.
"""

import json
import os
import shutil
import subprocess
import sys

# Extensions confiées à prettier. Volontairement sans .md : reformater
# la prose (CLAUDE.md, README) à chaque écriture fait plus de dégâts
# que de bien.
PRETTIER_EXTS = {
    ".js", ".jsx", ".ts", ".tsx", ".json",
    ".css", ".scss", ".html", ".yml", ".yaml",
}


def run(cmd):
    """Lance une commande en silence. Toute erreur est ignorée."""
    try:
        subprocess.run(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=30,
        )
    except Exception:
        pass


def target_file():
    """Extrait le chemin du fichier modifié depuis le JSON reçu sur stdin."""
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return None

    path = (payload.get("tool_input") or {}).get("file_path") or ""
    return path if path and os.path.isfile(path) else None


def main():
    path = target_file()
    if not path:
        return

    ext = os.path.splitext(path)[1].lower()

    if ext == ".py":
        if shutil.which("ruff"):
            run(["ruff", "format", path])
        elif shutil.which("black"):
            run(["black", "-q", path])
        return

    if ext in PRETTIER_EXTS:
        prettier = shutil.which("prettier")
        if prettier:
            run([prettier, "--write", path])
            return
        npx = shutil.which("npx")
        if npx:
            run([npx, "--no-install", "prettier", "--write", path])


if __name__ == "__main__":
    main()
    sys.exit(0)
