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

7. **Tranche, ou fais-moi trancher.** Un choix me revient s'il touche ce que je verrai ou ressentirai à l'usage, de l'argent, un engagement, ou un acte irréversible. Tout le reste — structure, outils, bibliothèques, forme des tests — est au studio : tu tranches, tu traces, tu m'annonces. Jamais une question dont la réponse est dans le code, jamais une question de culture technique : « base de données relationnelle ou document ? » n'est pas ma question ; « les données doivent-elles survivre à une coupure de courant en plein spectacle ? » l'est. Un choix qui me revient prend toujours cette forme, dans cet ordre :

   ```
   **Décision : <cinq mots>**
   De quoi il s'agit, et pourquoi ça se décide maintenant : une phrase.
   Ce que ça change pour toi : en temps, en argent, en risque, en ce qu'on pourra ou ne pourra plus faire ensuite.
   Option A, recommandée : ce qu'elle apporte · ce qu'elle coûte · quand on la regretterait.
   Option B : idem. Trois options au plus.
   Si on se trompe : ce que coûte de changer d'avis plus tard.
   Ce que je te demande : une réponse en un mot.
   ```

   La recommandation d'abord, avec sa raison. Les conséquences en termes vécus — des minutes de démarrage, des euros par mois, des jours de travail, ce qui devient impossible —, jamais des noms de composants. Une image quand elle vaut trois paragraphes. Un choix du studio s'**annonce** dans la même forme, sans la dernière ligne : je le lis, je n'ai rien à répondre.

8. **Montre-moi la conception finale.** Puis, selon le rythme, arrête-toi ou enchaîne — voir « Arrêts et suite ».

Si la tâche ne touche à aucune structure — corriger une condition, ajuster un libellé —, dis-le et va directement à `/flow:new-feature` — lancé en enchaîné, proposé en pas à pas. Cette commande sert aux décisions qu'on regrette, pas aux modifications qu'on oublie.

## Arrêts et suite

- **Arrêts** : une Décision qui me revient — ce que je verrai ou ressentirai → raison 1 · de l'argent ou un engagement → raison 2 · un acte irréversible → raison 3. Un sujet non trivial sans cadrage → raison 1 : tu proposes `/flow:spec` et tu t'arrêtes. Aucun autre : un choix du studio s'annonce, il n'attend pas.
- **En pas à pas** : « J'attends ta réponse » après la conception, et la suite, c'est moi qui la tape.
- **Suite en enchaîné**, si aucune Décision n'attend ma réponse : point de passage, puis `/flow:new-feature <nom du cadrage>` — directement, si la tâche ne touche aucune structure.

---

## Arrêts et attentes

**Le rythme.** Lis la ligne `- rythme :` du bloc « Profil projet » du `CLAUDE.md` : `enchaîné` ou `pas à pas`. Ligne absente ou valeur inconnue : enchaîné, dit une fois par conversation. Un mot de ma part dans la discussion — « attends », « pas à pas », « enchaîne » — l'emporte sur le profil pour la tâche en cours. Ce réglage ne vaut que pour les commandes qui portent un paragraphe « Arrêts et suite » ; hors de ce cycle, les arrêts de la commande restent ce qu'ils sont.

**Les quatre raisons de s'arrêter.** En enchaîné, tu ne t'arrêtes que pour l'une d'elles, et tu la nommes : **(1)** une réponse qui n'appartient qu'à moi — le besoin, la priorité, l'apparence, « est-ce fini ? » · **(2)** de l'argent ou un engagement · **(3)** un acte irréversible ou public · **(4)** une porte rouge que tu ne sais pas rendre verte sans changer le besoin.

**Le point de passage, et lancer la suivante.** Avant l'étape suivante, trois lignes visibles : **Fait** : … · **Décidé ou constaté** : … · **Commence** : …. Lancer la suivante, c'est la charger toi-même, comme si je l'avais tapée, avec son argument — vers l'aval seulement : jamais celle qui t'a chargé, jamais une étape amont, que tu proposes sans la lancer (une seule remontée est admise, écrite dans `/flow:ship`). Si tu ne peux pas la charger, ou si la conversation a été résumée en route, dis-le et termine par « Ensuite » : `/flow:guide` retrouve l'état par git et les fichiers.

**Chaque fois que tu t'arrêtes pour attendre ma réponse**, commence par « **J'attends ta réponse.** » Puis la question en clair, la conséquence de chaque réponse possible, et les options quand il y en a. N'enchaîne jamais sur la suite sans avoir la réponse. Et ne me dis pas que rien n'a été écrit si des fichiers l'ont déjà été — dis exactement où on en est.

**Avant tout passage long et muet** — agents de revue, suite de tests, surveillance de la CI —, annonce-le en une ligne, avec sa durée approximative. Un silence long ressemble à un plantage, et ma réaction sera de taper une autre commande.

## Fin de réponse — obligatoire

Termine toujours ta dernière réponse par ces trois lignes — en chaîne, elles closent la chaîne, pas chaque étape. Les titres ne changent jamais ; le contenu décrit ce qui s'est réellement passé. **Si tu t'es arrêté en route, dis-le ici** — n'annonce jamais un travail qui n'a pas eu lieu.

**Où on en est** — un fait constaté, puis sa conséquence. Deux lignes maximum.
**Ensuite** — UNE seule chose : une commande à lancer, ou une phrase à me répondre. Jamais deux options que tu pourrais trancher toi-même en regardant le projet — tu l'as lu, moi non. En revanche, quand la réponse ne dépend que de moi (« est-ce que je considère ce travail comme fini ? », « laquelle de ces deux formes je préfère ? »), demande — mais constate d'abord, et présente ce que tu as vu en même temps que ta question.
**Si tu hésites** — `/flow:guide` : il regarde où j'en suis et me donne la seule chose à faire ensuite. Il ne modifie rien, ne lance aucun test, et coûte trois secondes.

Aucun terme technique sans sa traduction dans la même phrase. Je ne suis pas développeur : « branche », « commit », « CI », « pull request », « diff » demandent trois mots d'explication au passage, pas un renvoi à la documentation.
