---
description: Livre — exige une vérification verte, puis commit atomique, push, PR et surveillance de la CI
---

Livraison du travail en cours sur cette branche.

1. **Vérifie la branche, avant tout le reste.** Si `git branch --show-current` renvoie la branche par défaut (`main` ou `master`), **arrête-toi avant le moindre commit** et propose-moi `git switch -c <type>/<slug>`. Les modifications non commitées suivent la nouvelle branche, rien n'est perdu. N'enchaîne qu'après mon accord explicite.

   La raison n'est pas l'élégance de l'historique. La CI ne parle qu'**après** le push : livrer depuis la branche par défaut, c'est y déposer du code dont les vérifications les plus révélatrices — autres systèmes d'exploitation, environnement propre, machine plus lente — n'ont pas encore rendu leur verdict. Si elles cassent, c'est la branche par défaut qui est cassée, et avec elle tout ce qui en dépend : releases, déploiements, paquets construits depuis elle. Sur une branche dédiée, le même échec ne coûte qu'un commit de plus.

2. **Exige la porte.** Si `/flow:verify` vient de rendre PASSE dans cette conversation, sur cet état exact du code, ne le relance pas. Sinon, lance-le maintenant — c'est la seule remontée vers l'amont que le plugin admet : il rend son verdict, et tu reprends à l'étape 3. **S'il rend BLOQUÉ, arrête-toi.** Ne livre jamais en promettant de corriger après : c'est précisément comme ça qu'un bug part en production.

3. **Diff.** `git status` et `git diff` complets. Retire tout ce qui n'a rien à voir avec la tâche — fichiers de test personnels, traces de débogage, réglages d'éditeur. Un diff qui ne contient que la tâche est un diff qu'on peut relire. La ligne que la porte a ajoutée à `docs/journal.md` fait partie de la tâche.

4. **Secrets.** Vérifie qu'aucun secret, `.env`, jeton, clé ou identifiant ne part dans le commit. En cas de doute, montre-moi la ligne.

5. **Ligne de journal, avant le commit.** Ajoute à `docs/journal.md`, par `cat >>` — jamais en réécrivant le fichier —, une ligne `livraison` : `- <AAAA-MM-JJ> · livraison · <tâche> · branche : <branche> · change : <ce que ça change, la première partie du Compte-rendu>`. L'en-tête fait foi sur la forme : ni « · » ni retour à la ligne dans une case — un « ; » les remplace —, « ? » pour ce qu'on ne sait pas, jamais « aucun » ; une ligne ne se réécrit jamais, on en ajoute une pour le même objet. Le fichier existe : la porte l'a créé. Le lien de la pull request n'y va pas : GitHub le garde, et l'écrire après coup coûterait un second commit et une CI de plus.

6. **Commit.** Un commit atomique, dont le message explique **le pourquoi** — le quoi se lit dans le diff. Plusieurs commits uniquement si le travail couvre des changements réellement distincts.

7. **Push.** Vérifie d'abord si une pull request est déjà ouverte sur cette branche (`gh pr list --head <branche>`). Si oui, **n'en crée pas une seconde** : le push la met à jour tout seul. Dis-le-moi, ajoute en commentaire ce que ce nouveau commit change, et passe directement à la surveillance de la CI.

   Sinon, ouvre-la avec `gh pr create` :
   - l'objectif, et le lien vers la spec si elle existe
   - le **Compte-rendu**, écrit pour quelqu'un qui n'a pas suivi, toujours dans cet ordre : ce que le logiciel fait maintenant qu'il ne faisait pas · ce qui a été vérifié, ou n'a pas pu l'être · ce qui reste
   - les changements, en trois points maximum
   - **les vérifications réellement effectuées** — reprends le tableau de `/flow:verify`, sans embellir
   - les risques et ce qui reste à surveiller

   Donne-moi le lien. Si `gh` n'est pas disponible, pousse quand même et donne-moi l'URL à ouvrir pour créer la PR à la main.

8. **Surveille la CI** jusqu'à son verdict.

   **Ne fonde jamais un verdict sur du texte découpé.** Les noms de jobs contiennent des espaces, les colonnes se décalent d'une ligne à l'autre, et un moniteur bancal annonce « tout vert, zéro échec » alors qu'un job est encore en cours. Fonde-toi sur le **code de sortie** de `gh pr checks` — `0` tout vert, `8` en attente, autre chose un échec — ou sur sa sortie JSON. Jamais sur un découpage de colonnes.

   Si un outil de surveillance te paraît douteux, ne le crois pas même quand il annonce une bonne nouvelle : vérifie directement avant de conclure. La règle de la porte — ne jamais déclarer vert ce qu'on n'a pas vérifié — vaut aussi pour ton propre outillage.

   Si la CI casse, ne referme pas le sujet : montre-moi quel job échoue et pourquoi. Elle attrape ce qui est invisible en local — machine différente, environnement propre, timing plus lent.

9. **Conclus** par le **Compte-rendu**, le même que dans la pull request, puis ce qui est parti et où c'en est.

   Si la CI est verte, donne-moi la suite exactement, dans l'ordre — sinon je reste bloqué là : fusionner la pull request sur GitHub en choisissant « Create a merge commit » ou « Rebase and merge », **jamais « Squash and merge »** qui écraserait les commits séparés ; supprimer la branche (GitHub le propose juste après) ; puis revenir sur la branche par défaut et récupérer la fusion sur ma machine — le bouton *Pull* de mon outil git, ou `git pull`. Sans ce dernier geste, mon dossier reste sur l'ancienne branche et ignore la fusion. Si GitHub signale un conflit sur `docs/journal.md`, je te réponds « conflit journal » et c'est toi qui le règles : tu ramènes la branche par défaut dans la branche, tu gardes les deux côtés, tu tries les lignes par date — la date en tête rend le tri juste —, tu pousses.

## Arrêts et suite

- **Arrêts** : la branche par défaut, avant le moindre commit → raison 3 · la fusion, que je fais moi-même sur GitHub → raison 3. Une pull request sur un dépôt public est visible de tous, mais elle se ferme : ce n'est pas un arrêt.
- **En pas à pas** : aucun arrêt de plus.
- **Suite** : aucune commande — la chaîne finit ici, sur le lien et le compte-rendu ; après la fusion, `/flow:guide` me dit la suite. La seule remontée admise du plugin est ici : une porte non passée sur cet état, tu la lances toi-même (étape 2), et à son PASSE tu reprends à l'étape 3.

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
