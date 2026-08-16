---
description: Finalise la tâche en cours — checks, review du diff, commit atomique, push, PR
---

Finalise le travail en cours sur cette branche :

1. **Checks.** Lance ce qui existe dans le projet : format, lint, typecheck, tests. Corrige jusqu'à ce que tout passe. S'il n'y a aucun check configuré, signale-le-moi.
2. **Diff.** `git status` + `git diff` complets. Retire tout changement parasite ou fichier sans rapport avec la tâche.
3. **Secrets.** Vérifie qu'aucun secret, `.env`, token ou credential ne part dans le commit.
4. **Review.** Lance l'agent `code-reviewer` sur le diff. Corrige les bloquants ; liste-moi les suggestions que tu n'as pas traitées.
5. **Commit.** Un commit atomique et descriptif (le pourquoi, pas seulement le quoi). Plusieurs commits uniquement si le diff couvre des changements réellement distincts.
6. **PR.** Push, puis ouvre une PR avec `gh pr create` : objectif, changements, tests effectués, risques. Donne-moi le lien. Si le repo n'a pas de remote, propose d'abord `gh repo create` (privé par défaut).
