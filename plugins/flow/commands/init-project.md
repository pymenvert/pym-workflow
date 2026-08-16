---
description: Initialise le projet courant avec le workflow standard — CLAUDE.md, .gitignore, CI, repo GitHub
---

Initialise ce projet avec mon workflow standard :

1. **Explore d'abord.** Identifie la stack réelle : langages, frameworks, gestionnaire de paquets, scripts et commandes existants.
2. **Git.** `git init` + commit initial si ce n'est pas déjà un repo.
3. **.gitignore** adapté à la stack, si absent ou incomplet. Toujours inclure : `.env`, `.env.*`, credentials, caches, dossiers de build.
4. **CLAUDE.md** court (moins de 60 lignes), adapté à la stack constatée, sur ce modèle :

   ```markdown
   # <Nom du projet>
   <Stack en une ligne>

   ## Architecture
   - <3 à 5 points essentiels>

   ## Code
   - <conventions clés : typage strict, taille des fonctions, validation des entrées…>

   ## Commandes de validation
   - format : <cmd> · lint : <cmd> · typecheck : <cmd> · tests : <cmd>

   ## Git
   - Jamais directement sur main. Commits atomiques. Jamais de secrets, .env ou tokens.
   ```

5. **CI.** Crée `.github/workflows/ci.yml` minimal adapté à la stack : install, lint, typecheck, tests, sur push et pull request.
6. **GitHub.** Propose-moi ensuite : `gh repo create` (privé par défaut) + push + protection de la branche `main` (checks CI requis ; pas de review obligatoire puisque je travaille seul). N'exécute cette étape qu'après mon accord explicite.
7. **Résumé.** Termine par la liste exacte de ce qui a été mis en place.
