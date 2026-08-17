---
description: Livre — exige une vérification verte, puis commit atomique, push, PR et surveillance de la CI
---

Livraison du travail en cours sur cette branche.

1. **Vérifie la branche, avant tout le reste.** Si `git branch --show-current` renvoie la branche par défaut (`main` ou `master`), **arrête-toi avant le moindre commit** et propose-moi `git switch -c <type>/<slug>`. Les modifications non commitées suivent la nouvelle branche, rien n'est perdu. N'enchaîne qu'après mon accord explicite.

   La raison n'est pas l'élégance de l'historique. La CI ne parle qu'**après** le push : livrer depuis la branche par défaut, c'est y déposer du code dont les vérifications les plus révélatrices — autres systèmes d'exploitation, environnement propre, machine plus lente — n'ont pas encore rendu leur verdict. Si elles cassent, c'est la branche par défaut qui est cassée, et avec elle tout ce qui en dépend : releases, déploiements, paquets construits depuis elle. Sur une branche dédiée, le même échec ne coûte qu'un commit de plus.

2. **Exige la porte.** Si `/flow:verify` n'a pas été passé sur l'état actuel du code, lance-le maintenant. **S'il rend BLOQUÉ, arrête-toi.** Ne livre jamais en promettant de corriger après : c'est précisément comme ça qu'un bug part en production.

3. **Diff.** `git status` et `git diff` complets. Retire tout ce qui n'a rien à voir avec la tâche — fichiers de test personnels, traces de débogage, réglages d'éditeur. Un diff qui ne contient que la tâche est un diff qu'on peut relire.

4. **Secrets.** Vérifie qu'aucun secret, `.env`, jeton, clé ou identifiant ne part dans le commit. En cas de doute, montre-moi la ligne.

5. **Commit.** Un commit atomique, dont le message explique **le pourquoi** — le quoi se lit dans le diff. Plusieurs commits uniquement si le travail couvre des changements réellement distincts.

6. **Push**, puis ouvre une pull request avec `gh pr create` :
   - l'objectif, et le lien vers la spec si elle existe
   - les changements, en trois points maximum
   - **les vérifications réellement effectuées** — reprends le tableau de `/flow:verify`, sans embellir
   - les risques et ce qui reste à surveiller

   Donne-moi le lien. Si `gh` n'est pas disponible, pousse quand même et donne-moi l'URL à ouvrir pour créer la PR à la main.

7. **Surveille la CI** jusqu'à son verdict.

   **Ne fonde jamais un verdict sur du texte découpé.** Les noms de jobs contiennent des espaces, les colonnes se décalent d'une ligne à l'autre, et un moniteur bancal annonce « tout vert, zéro échec » alors qu'un job est encore en cours. Fonde-toi sur le **code de sortie** de `gh pr checks` — `0` tout vert, `8` en attente, autre chose un échec — ou sur sa sortie JSON. Jamais sur un découpage de colonnes.

   Si un outil de surveillance te paraît douteux, ne le crois pas même quand il annonce une bonne nouvelle : vérifie directement avant de conclure. La règle de la porte — ne jamais déclarer vert ce qu'on n'a pas vérifié — vaut aussi pour ton propre outillage.

   Si la CI casse, ne referme pas le sujet : montre-moi quel job échoue et pourquoi. Elle attrape ce qui est invisible en local — machine différente, environnement propre, timing plus lent.

8. **Conclus** en une ligne : ce qui est parti, où c'en est, et ce qu'il me reste à faire.
