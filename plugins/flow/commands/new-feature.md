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
