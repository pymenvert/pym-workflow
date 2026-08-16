# pym — workflow Claude Code (dev solo)

Marketplace perso. Un plugin : **flow** — le cycle standard *branche → plan → implémentation → review → PR*, disponible dans tous les projets.

## Installation (une fois)

```bash
claude plugin marketplace add pymenvert/pym-workflow
claude plugin install flow@pym --scope user
```

`--scope user` = disponible dans tous les projets. Le repo est privé : Claude Code réutilise les identifiants git déjà en place. Sous Windows, le gestionnaire d'identifiants installé par GitHub Desktop suffit — rien à configurer, et `gh` n'est pas nécessaire pour cette étape.

## Utilisation

| Commande | Rôle |
|---|---|
| `/flow:init-project` | Initialise un projet : CLAUDE.md adapté à la stack, .gitignore, CI GitHub Actions, repo GitHub privé + protection de main |
| `/flow:new-feature <desc>` | Branche dédiée (ou worktree sur demande), exploration du code, plan court à valider, puis implémentation |
| `/flow:ship` | Checks (format/lint/typecheck/tests), review du diff par l'agent `code-reviewer`, commit atomique, push, PR |

S'y ajoutent : l'agent `code-reviewer` (review indépendante du diff) et un hook PostToolUse qui formate chaque fichier modifié — `ruff` ou `black` pour le Python, `prettier` pour le reste. Si aucun formateur n'est installé, le hook ne fait rien et ne bloque jamais.

Pour le rendre actif : `npm install -g prettier`, et `pip install ruff` si tu fais du Python.

Deux choix volontaires dans ce hook :

- **Les `.md` sont exclus.** Reformater de la prose (`CLAUDE.md`, `README`) à chaque écriture réaligne les tableaux et rebrasse les puces : plus pénible qu'utile.
- **Le script est en PowerShell**, pas en bash ni en Python. Sous Windows le `bash` du PATH est le lanceur WSL (souvent cassé), `jq` est absent, et le Python de l'alias WindowsApps tourne en conteneur applicatif avec `%APPDATA%` virtualisé — il ne voit donc pas les outils installés par `npm install -g`. Sur un poste non-Windows, remplacer la commande de `hooks/hooks.json` par un équivalent shell.

Cycle type : `/flow:init-project` → `/flow:new-feature …` → dev → `/flow:ship`. Entre deux tâches sans rapport : `/clear`.

## Mettre à jour le workflow

Modifier ce repo, commit, push. Puis dans Claude Code : `/plugin marketplace update pym`, et `/reload-plugins` si les hooks ont changé. (L'auto-update en arrière-plan peut échouer sur un repo privé en HTTPS ; la mise à jour manuelle utilise tes credentials et fonctionne toujours.)

## Réglages globaux recommandés (une fois)

`~/.claude/settings.json` — bloquer les fichiers sensibles partout :

```json
{
  "permissions": {
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Edit(**/.env)",
      "Edit(**/.env.*)"
    ]
  }
}
```

Trois précisions qui comptent :

- Écrire `Read(./.env)` serait une erreur : la forme `./` est ancrée au dossier courant et ne bloquerait ni `config/.env` ni `packages/api/.env`. La forme `**/.env` suit la syntaxe gitignore et couvre toutes les profondeurs.
- Une règle `deny` sur `Read` bloque aussi `Edit` et `Write` sur le même chemin. Les règles `Edit` restent utiles : elles couvrent `NotebookEdit`, que `Read` ne couvre pas.
- Ces règles s'appliquent aux outils fichiers de Claude et aux commandes Bash reconnues (`cat`, `head`, `sed`…). Elles ne bloquent pas un script Python ou Node qui ouvrirait le fichier lui-même.

`~/.claude/CLAUDE.md` — règles universelles :

```markdown
## Git
- Jamais de travail direct sur main : une branche dédiée par tâche.
- Commits atomiques et descriptifs.
- Jamais de secrets, .env ou tokens dans le code, les commits ou les prompts.

## Méthode
- Comprendre l'existant avant de modifier ; plan court avant toute grosse modification.
- Lancer format / lint / typecheck / tests avant de livrer.
- Préférer la solution la plus simple qui respecte l'architecture.
```

## Optionnel : Entire (traçabilité des sessions)

Par repo : `entire enable --agent claude-code`. Les sessions (prompts, transcripts, appels d'outils) sont stockées dans une branche cachée et poussées avec le repo → à réserver aux repos privés.
