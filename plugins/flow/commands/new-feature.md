---
description: Démarre une tâche — branche dédiée, exploration, plan court validé, puis implémentation
argument-hint: description de la feature ou du bug
---

Nouvelle tâche : $ARGUMENTS

Suis ce déroulé dans l'ordre :

1. **État des lieux.** `git status` — si le worktree n'est pas propre, montre-moi ce qui traîne et demande-moi quoi en faire avant de continuer.
2. **Branche.** Mets `main` à jour, puis crée une branche `feature/<slug>` ou `fix/<slug>` selon la nature de la tâche. Si je demande explicitement du travail en parallèle, crée plutôt un worktree `../wt-<slug>` avec sa propre branche.
3. **Exploration.** Lis le CLAUDE.md du projet et le code concerné avant de proposer quoi que ce soit. Ne suppose pas l'architecture : vérifie-la.
4. **Plan court.** Propose : fichiers touchés, approche, risques, validations prévues. Attends ma validation explicite avant d'implémenter.
5. **Implémentation.** Par petits lots cohérents, en respectant les conventions existantes. Lance les checks disponibles au fil de l'eau.

Ne conclus pas par un commit : c'est le rôle de `/flow:ship`.
