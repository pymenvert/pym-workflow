---
description: Livre — exige une vérification verte, puis commit atomique, push, PR et surveillance de la CI
---

Livraison du travail en cours sur cette branche.

1. **Exige la porte.** Si `/flow:verify` n'a pas été passé sur l'état actuel du code, lance-le maintenant. **S'il rend BLOQUÉ, arrête-toi.** Ne livre jamais en promettant de corriger après : c'est précisément comme ça qu'un bug part en production.

2. **Diff.** `git status` et `git diff` complets. Retire tout ce qui n'a rien à voir avec la tâche — fichiers de test personnels, traces de débogage, réglages d'éditeur. Un diff qui ne contient que la tâche est un diff qu'on peut relire.

3. **Secrets.** Vérifie qu'aucun secret, `.env`, jeton, clé ou identifiant ne part dans le commit. En cas de doute, montre-moi la ligne.

4. **Commit.** Un commit atomique, dont le message explique **le pourquoi** — le quoi se lit dans le diff. Plusieurs commits uniquement si le travail couvre des changements réellement distincts.

5. **Push**, puis ouvre une pull request avec `gh pr create` :
   - l'objectif, et le lien vers la spec si elle existe
   - les changements, en trois points maximum
   - **les vérifications réellement effectuées** — reprends le tableau de `/flow:verify`, sans embellir
   - les risques et ce qui reste à surveiller

   Donne-moi le lien. Si `gh` n'est pas disponible, pousse quand même et donne-moi l'URL à ouvrir pour créer la PR à la main.

6. **Surveille la CI** jusqu'à son verdict. Si elle casse, ne referme pas le sujet : montre-moi quel job échoue et pourquoi. La CI attrape ce qui est invisible en local — machine différente, environnement propre, timing plus lent.

7. **Conclus** en une ligne : ce qui est parti, où c'en est, et ce qu'il me reste à faire.
