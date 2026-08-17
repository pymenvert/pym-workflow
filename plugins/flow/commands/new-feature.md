---
description: Implémente une tâche — branche dédiée, plan court validé, petits lots vérifiés au fil de l'eau
argument-hint: description de la feature ou du bug, ou nom d'une spec
---

Tâche : $ARGUMENTS

1. **État des lieux.** `git status` — si le worktree n'est pas propre, montre-moi ce qui traîne et demande quoi en faire avant de continuer.

2. **Contexte.** Lis le `CLAUDE.md` du projet, en particulier son bloc « Profil projet ». Si une spec (`docs/specs/`) ou une décision d'architecture (`docs/decisions/`) correspond à cette tâche, lis-la : elle fait autorité sur ce qu'il faut construire.

   Si la tâche est structurante et qu'aucune spec n'existe, dis-le et propose `/flow:spec`. Ne cadre pas toi-même en douce ce qui mérite d'être décidé explicitement.

3. **Branche.** Mets `main` à jour, puis crée `feature/<slug>` ou `fix/<slug>` selon la nature de la tâche. Si je demande du travail en parallèle, crée plutôt un worktree `../wt-<slug>`.

4. **Exploration.** Lis le code concerné avant de proposer quoi que ce soit. Ne suppose pas l'architecture : vérifie-la. Si ce que tu découvres contredit la spec, arrête-toi et signale-le — c'est exactement le moment où ça coûte le moins cher.

5. **Plan court.** Fichiers touchés, approche, risques, ce que tu comptes tester. **Attends ma validation** avant d'implémenter.

6. **Implémentation, par petits lots cohérents.**
   - Sur un **chemin critique** (données utilisateur, fichiers, argent, permissions, concurrence) : écris le test d'abord, vérifie qu'il échoue, puis fais-le passer. C'est la seule façon de savoir que le test teste vraiment quelque chose.
   - Ailleurs : code puis test, tant que le test existe à la fin du lot.
   - Lance les checks du profil au fil de l'eau, pas seulement à la fin.
   - Respecte les conventions existantes, même si tu les trouves discutables. On en discute dans `/flow:design`, pas au détour d'un diff.

7. **Traite les cas limites de la spec** — entrées vides, échecs, interruptions. S'ils ne sont pas gérés, la tâche n'est pas finie.

Ne conclus pas par un commit : la suite est `/flow:verify`, puis `/flow:ship`.

---

## Arrêts et attentes

**Chaque fois que tu t'arrêtes pour attendre ma réponse**, commence par « **J'attends ta réponse.** » Puis la question en clair, la conséquence de chaque réponse possible, et les options quand il y en a. N'enchaîne jamais sur la suite sans avoir la réponse. Et ne me dis pas que rien n'a été écrit si des fichiers l'ont déjà été — dis exactement où on en est.

**Avant tout passage long et muet** — agents de revue, suite de tests, surveillance de la CI —, annonce-le en une ligne, avec sa durée approximative. Un silence long ressemble à un plantage, et ma réaction sera de taper une autre commande.

## Fin de réponse — obligatoire

Termine toujours ta dernière réponse par ces trois lignes. Les titres ne changent jamais ; le contenu décrit ce qui s'est réellement passé. **Si tu t'es arrêté en route, dis-le ici** — n'annonce jamais un travail qui n'a pas eu lieu.

**Où on en est** — un fait constaté, puis sa conséquence. Deux lignes maximum.
**Ensuite** — UNE seule chose : une commande à lancer, ou une phrase à me répondre. Jamais deux options, jamais de « si » : tu as lu le projet, moi non — tranche.
**Si tu hésites** — `/flow:guide` : il regarde où j'en suis et me donne la seule chose à faire ensuite. Il ne modifie rien, ne lance aucun test, et coûte trois secondes.

Aucun terme technique sans sa traduction dans la même phrase. Je travaille dans GitHub Desktop : « branche », « commit », « CI », « pull request », « diff » demandent trois mots d'explication au passage, pas un renvoi à la documentation.
