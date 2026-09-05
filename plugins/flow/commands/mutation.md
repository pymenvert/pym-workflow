---
description: Vérifie que les tests protègent vraiment — casse le code exprès et exige que la suite tombe
argument-hint: un module à éprouver, ou rien pour les chemins critiques du profil
---

Épreuve des tests : $ARGUMENTS

Toutes les autres commandes font confiance à la suite de tests. Celle-ci la met en doute.

Le principe : **casser le code exprès, un cassage à la fois, et exiger que la suite tombe.** Un test qui reste vert alors que le code qu'il couvre est cassé ne protège rien — et c'est pire qu'une absence de test, parce qu'on s'y fie. Une suite verte n'est pas une preuve : c'est une affirmation à vérifier.

## Quand la lancer — et quand surtout pas

**Pas avant `/flow:ship`.** Trois raisons, dont une rédhibitoire :

- Cette commande exige un dossier de travail propre. Avant de livrer, il ne l'est jamais : le travail attend d'être enregistré. Les deux ne peuvent pas coexister.
- Elle éprouve **la suite de tests**, qui appartient au projet entier — pas au changement en cours. La relancer à chaque tâche revient à réexaminer chaque fois la même chose.
- Elle est lente : cinq à dix cassages, chacun relançant des tests.

**Le bon déclencheur est une vague de tests, pas une vague de code.** Lance-la quand la suite vient de grossir nettement — après une tâche qui a ajouté trente tests, ou avant une version. Ce sont ces tests-là qui n'ont encore jamais prouvé qu'ils détectent quoi que ce soit.

Elle appartient à la famille des commandes rares, avec `/flow:audit` et `/flow:release` — pas au cycle d'une tâche.

## Sécurité — la partie qui compte le plus

Cette commande **modifie délibérément du code source**. Trois règles non négociables :

1. **Exige un dossier de travail propre avant de commencer.** `git status --short` doit être vide. Si ce n'est pas le cas, arrête-toi : tes modifications en cours seraient indiscernables des cassages volontaires.
2. **Git est le filet, pas ta mémoire.** Restaure chaque cassage par `git checkout -- <fichier>`, jamais en réécrivant ce que tu crois avoir lu. Un fichier restauré de mémoire peut différer d'un espace ou d'une fin de ligne.
3. **Termine par une preuve.** Relance `git status --short` en fin de commande et montre-moi le résultat. S'il n'est pas vide, dis-le en toutes lettres et **n'affirme pas que tout est restauré** — c'est le seul moment où cette commande peut faire des dégâts.

### Campagne complète : travaille dans une copie

Une campagne de plusieurs dizaines de cassages peut durer **une heure**. Pendant tout ce temps, le code source est modifié en place — et un commit parti à ce moment-là emporterait un mutant. C'est arrivé sur un projet réel : commit passé, suite verte, une fonctionnalité morte en silence pendant des jours.

Donc : au-delà d'une dizaine de cassages, **clone le dépôt dans un dossier temporaire, lance la campagne là-bas, et ne me rapporte que les résultats.** Le dépôt de travail n'est jamais touché. Pour une campagne ciblée de cinq à dix cassages, la règle du dossier propre suffit.

Et si le projet possède un test qui vérifie qu'**aucun mutant n'est resté** dans le code source, dis-le-moi : c'est le meilleur filet qui existe contre cette erreur, et il mérite d'être recopié dans les projets qui n'en ont pas.

## Si le projet a déjà un outil

Cherche-le d'abord (`tests/mutation.js`, `npm run test:mutation`, un outil déclaré dans le profil). S'il existe, lance-le au lieu de réinventer : il connaît les particularités du projet. Contente-toi d'interpréter son résultat et de vérifier qu'il a bien restauré.

## Méthode, si tu dois le faire à la main

**Choisis les cibles.** Le champ `critique` du bloc « Profil projet » les nomme. À défaut, prends ce qui manipule des fichiers, des données utilisateur, des permissions, ou ce dont l'échec est silencieux. **Cinq à dix cassages, pas cinquante** — c'est une commande lente, chaque cassage relance des tests.

**Montre-moi la liste avant de commencer**, et attends mon accord. Annonce aussi la durée : sur un projet dont la suite prend une minute, dix cassages font dix minutes.

**Les cassages qui trouvent réellement quelque chose :**

- inverser une condition (`if (x)` → `if (!x)`)
- déplacer une borne (`<` → `<=`, `0` → `1`)
- faire rendre une constante à une fonction de calcul
- supprimer un appel dont l'effet est attendu ailleurs
- échanger deux arguments de même type
- neutraliser une gestion d'erreur — remplacer le traitement par un silence

**Un cassage à la fois.** Applique, lance **seulement la suite concernée** si le projet permet de la cibler (pas toute la suite : c'est là que part le temps), note si elle tombe, restaure par git, passe au suivant.

**Prouve d'abord que ton dispositif fonctionne.** Avant de conclure que « tous les cassages sont attrapés », vérifie qu'un cassage manifestement fatal fait bien tomber la suite. Un dispositif qui ne lance pas vraiment les tests rapporte un sans-faute parfait et mensonger.

## Interpréter un cassage qui survit

Un cassage non détecté a exactement trois causes possibles, et il faut dire laquelle :

- **un test manque** — le cas le plus fréquent, et le résultat utile : écris-le
- **le code est mort** — personne ne l'exécute, donc rien ne le protège : propose-moi de le supprimer
- **le cassage ne change rien** — deux écritures équivalentes ; ce n'est pas un défaut, dis-le et écarte-le

Ne compte jamais un cassage survivant comme un échec des tests sans avoir tranché entre ces trois.

## Rendu

- **Cassages non détectés** — pour chacun : le fichier, la ligne, ce que tu as cassé, laquelle des trois causes, et le test à écrire (donne le code, pas une description)
- **Cassages détectés** — un décompte suffit, avec les tests qui les ont attrapés
- **Preuve de restauration** — la sortie de `git status --short`

Puis écris les cassages non détectés dans `docs/reste-a-faire.md`, sous un titre daté. Ce sont des trous de couverture prouvés, pas des soupçons : ils méritent de survivre à la conversation.

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
