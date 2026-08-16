---
description: Décide l'architecture et la fait attaquer par l'agent architect avant d'écrire du code
argument-hint: nom de la spec, ou description si elle n'existe pas
---

Architecture à décider : $ARGUMENTS

Cette étape existe parce qu'une erreur de structure corrigée maintenant coûte cinq minutes, et trois semaines une fois le code écrit autour.

1. **Lis la spec** correspondante dans `docs/specs/`, ainsi que le `CLAUDE.md` du projet. S'il n'y a pas de spec et que le sujet n'est pas trivial, propose `/flow:spec` d'abord.

2. **Étudie l'existant avant de proposer.** Quels modules seront touchés ? Quelles conventions sont déjà en place ? La meilleure architecture est le plus souvent celle qui ressemble à ce qui existe déjà — sauf si l'existant est précisément le problème.

3. **Propose une conception**, courte et concrète :
   - les modules ou fichiers concernés, et la responsabilité de chacun en une phrase
   - le flux de données : d'où vient l'information, où elle est transformée, où elle est stockée
   - les types ou structures centraux
   - **la stratégie d'erreur** : ce qui peut échouer et ce qui se passe alors
   - ce qui sera testé, et comment (si une partie est difficile à tester, dis-le maintenant)

4. **Fais attaquer la proposition par l'agent `architect`.** C'est le cœur de cette commande, pas une formalité. Transmets-lui la spec et la conception.

5. **Traite ses objections une par une.** Pour chaque point bloquant : corrige la conception, ou explique pourquoi tu l'assumes. Ne balaie rien en silence.

6. **Trace la décision** dans `docs/decisions/NNNN-<slug>.md` (numérotation à quatre chiffres, incrémentale) :
   - **Contexte** — le problème et les contraintes
   - **Options envisagées** — au moins deux, avec ce que chacune coûte
   - **Décision** — celle retenue, et pourquoi
   - **Conséquences** — ce que ça facilite, ce que ça rend plus difficile, ce qu'on s'interdit

   Ce fichier est ce qui te permettra, dans six mois, de comprendre pourquoi le code est comme il est — et de savoir si la raison tient toujours.

7. **Montre-moi la conception finale et attends ma validation** avant toute implémentation.

Si la tâche ne touche à aucune structure — corriger une condition, ajuster un libellé —, dis-le et passe directement à `/flow:new-feature`. Cette commande sert aux décisions qu'on regrette, pas aux modifications qu'on oublie.
