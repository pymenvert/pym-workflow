# pym — workflow Claude Code (dev solo)

Marketplace perso. Un plugin : **flow** — le cycle standard *branche → plan → implémentation → review → PR*, disponible dans tous les projets.

## Installation (une fois)

```bash
claude plugin marketplace add pymenvert/pym-workflow
claude plugin install flow@pym --scope user
```

`--scope user` = disponible dans tous les projets. Le repo étant privé, vérifier une fois que `gh auth setup-git` a été exécuté (Claude Code utilise les credentials git existants).

## Utilisation

| Commande | Rôle |
|---|---|
| `/flow:init-project` | Initialise un projet : CLAUDE.md adapté à la stack, .gitignore, CI GitHub Actions, repo GitHub privé + protection de main |
| `/flow:new-feature <desc>` | Branche dédiée (ou worktree sur demande), exploration du code, plan court à valider, puis implémentation |
| `/flow:ship` | Checks (format/lint/typecheck/tests), review du diff par l'agent `code-reviewer`, commit atomique, push, PR |

S'y ajoutent : l'agent `code-reviewer` (review indépendante du diff) et un hook PostToolUse qui formate chaque fichier modifié (ruff/black/prettier s'ils sont présents, sinon il ne fait rien).

Cycle type : `/flow:init-project` → `/flow:new-feature …` → dev → `/flow:ship`. Entre deux tâches sans rapport : `/clear`.

## Mettre à jour le workflow

Modifier ce repo, commit, push. Puis dans Claude Code : `/plugin marketplace update pym`, et `/reload-plugins` si les hooks ont changé. (L'auto-update en arrière-plan peut échouer sur un repo privé en HTTPS ; la mise à jour manuelle utilise tes credentials et fonctionne toujours.)

## Réglages globaux recommandés (une fois)

`~/.claude/settings.json` — bloquer les fichiers sensibles partout :

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Edit(./.env)",
      "Edit(./.env.*)"
    ]
  }
}
```

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
