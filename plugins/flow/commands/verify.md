---
description: La porte — checks automatisés puis revue par les agents. Rien ne part tant que c'est rouge.
---

C'est l'étape qui décide si le travail est livrable. Elle a le droit de dire non.

Deux règles absolues : **tu ne déclares jamais vert quelque chose que tu n'as pas lancé**, et **tu ne contournes jamais un check qui échoue** — ni en le désactivant, ni en modifiant le test pour qu'il passe, ni en le déclarant « hors périmètre ». Si un check est cassé pour une raison indépendante de la tâche, dis-le explicitement au lieu de le masquer.

## 0. Deux contrôles à deux secondes, avant tout

**Y a-t-il quelque chose à vérifier ?** Lance `git status --short`, puis `git rev-list --count HEAD --not main`. Si les deux sont vides, **arrête-toi immédiatement — sans lancer un seul check ni un seul agent.** Dis exactement ceci :

> Rien à vérifier : aucun fichier modifié, aucun commit sur cette branche. Je n'ai lancé ni test ni agent, donc ça n'a rien coûté. Si je viens de te montrer un plan et que j'attends ton feu vert, réponds simplement « ok » ici, dans la discussion — c'est ça qui me fait écrire le code.

Ce contrôle est la contrepartie mécanique du message de `/flow:new-feature` : un message peut être manqué, ce contrôle non. Il évite de lancer une suite de tests complète et quatre agents sur du vide.

**Sur quelle branche va-t-on écrire ?** Lancer les checks ne modifie rien : commence-les sans rien demander. Mais si `git branch --show-current` renvoie la branche par défaut, **arrête-toi avant ta première correction de code** et dis-le-moi : corriger ici déposerait le travail directement sur la branche dont tout le reste dépend. Propose `git switch -c fix/<slug>` — les modifications suivent la nouvelle branche, rien n'est perdu.

## 1. Checks automatisés

Lis le bloc « Profil projet » du `CLAUDE.md` pour connaître les commandes exactes. S'il est absent, détecte-les et signale-moi que `/flow:init-project` n'a jamais été passé.

Lance dans cet ordre, en t'arrêtant de corriger seulement quand tout est vert : **format → lint → typecheck → tests → build**.

**`format` vérifie, elle n'écrit pas.** C'est la forme qui contrôle (`prettier --check`, `ruff format --check`) qui est déclarée dans le Profil projet — et c'est elle qui rend vraie la phrase du dessus, « lancer les checks ne modifie rien ». C'est cette phrase qui t'autorise à démarrer sans rien demander, avant même d'avoir tranché la question de la branche : un formateur qui écrirait déposerait des modifications sur la branche par défaut sans mon accord, à l'étape 1 de la porte censée l'interdire. Et il ne rendrait jamais rouge — il occuperait une ligne du tableau en étant vert par construction.

Si `format` est rouge, la correction est de lancer la variante qui écrit (`prettier --write`, `ruff format`). C'est une **correction**, pas un check : elle tombe sous la règle de branche ci-dessus, et elle doit apparaître comme telle dans ton tableau.

Présente le résultat sous forme de tableau, une ligne par check, avec la commande réellement exécutée et son état. Une commande absente du projet se note « non configuré » — jamais « OK ».

**Si un check échoue après tes corrections : verdict BLOQUÉ, tu t'arrêtes là.** Inutile de lancer les agents sur du code qui ne compile pas.

## 2. Revue par les agents

Une fois les checks verts, lance en parallèle ceux qui s'appliquent :

- **`code-reviewer`** — toujours
- **`test-engineer`** — dès que du code de logique a changé
- **`architect`** — dès qu'un fichier a été créé, déplacé, ou a nettement grossi ; il travaille alors en mode dérive structurelle
- **`ux-reviewer`** — si l'interface visible a changé, **ou si ce qui construit l'exécutable a changé** : script d'empaquetage, dépendance embarquée, assets livrés. Un logiciel qui ne démarre plus sur une machine nue est un défaut d'interface avant d'être un défaut de build. Il doit lancer le logiciel pour de vrai.

Lance aussi `/security-review` si le diff touche à des entrées utilisateur, des fichiers, du réseau, des permissions ou des secrets — **ou si `code-reviewer` te tend la main** : il signale ce qui se voit dans le diff et s'arrête là, l'analyse approfondie lui appartient. Une main tendue sans receveur ne protège de rien.

## 3. Verdict

Rassemble tout et tranche, sans diplomatie :

- **Bloquants** — ce qui doit être corrigé avant `/flow:ship`. Corrige-les, puis relance les checks concernés.
- **À traiter plus tard** — liste-les-moi ; ne les corrige pas silencieusement, ça brouille le diff. **Puis écris-les dans `docs/reste-a-faire.md`**, sous un titre daté portant le nom de la tâche (crée le fichier s'il n'existe pas, ajoute à la suite s'il existe). Une liste qui ne vit que dans cette conversation disparaîtra avec elle — et je te demanderai le lendemain si le projet est fini, sans que personne puisse répondre.
- **Non vérifié** — ce que tu n'as pas pu contrôler et pourquoi. Cette section est obligatoire : une porte qui cache ses angles morts ne protège de rien.

  **`ux-reviewer` y a sa place réservée.** Il est le seul dont un rapport court peut vouloir dire « je n'ai pas pu lancer le logiciel » et non « je n'ai rien trouvé ». S'il dit qu'il n'a pas pu, recopie-le ici : ne le compte jamais comme un feu vert.

Si le diff a ajouté beaucoup de tests — plus d'une dizaine —, signale-le en une ligne et propose `/flow:mutation` **pour plus tard**, une fois ce travail livré : des tests neufs n'ont encore jamais prouvé qu'ils détectent quoi que ce soit. Ne bloque jamais là-dessus, et ne le lance pas maintenant — il exige un dossier de travail propre, ce qui n'est pas le cas ici.

Termine par une seule ligne : **PASSE** ou **BLOQUÉ**, suivie du nombre de bloquants restants.

---

## Arrêts et attentes

**Chaque fois que tu t'arrêtes pour attendre ma réponse**, commence par « **J'attends ta réponse.** » Puis la question en clair, la conséquence de chaque réponse possible, et les options quand il y en a. N'enchaîne jamais sur la suite sans avoir la réponse. Et ne me dis pas que rien n'a été écrit si des fichiers l'ont déjà été — dis exactement où on en est.

**Avant tout passage long et muet** — agents de revue, suite de tests, surveillance de la CI —, annonce-le en une ligne, avec sa durée approximative. Un silence long ressemble à un plantage, et ma réaction sera de taper une autre commande.

## Fin de réponse — obligatoire

Termine toujours ta dernière réponse par ces trois lignes. Les titres ne changent jamais ; le contenu décrit ce qui s'est réellement passé. **Si tu t'es arrêté en route, dis-le ici** — n'annonce jamais un travail qui n'a pas eu lieu.

**Où on en est** — un fait constaté, puis sa conséquence. Deux lignes maximum.
**Ensuite** — UNE seule chose : une commande à lancer, ou une phrase à me répondre. Jamais deux options que tu pourrais trancher toi-même en regardant le projet — tu l'as lu, moi non. En revanche, quand la réponse ne dépend que de moi (« est-ce que je considère ce travail comme fini ? », « laquelle de ces deux formes je préfère ? »), demande — mais constate d'abord, et présente ce que tu as vu en même temps que ta question.
**Si tu hésites** — `/flow:guide` : il regarde où j'en suis et me donne la seule chose à faire ensuite. Il ne modifie rien, ne lance aucun test, et coûte trois secondes.

Aucun terme technique sans sa traduction dans la même phrase. Je ne suis pas développeur : « branche », « commit », « CI », « pull request », « diff » demandent trois mots d'explication au passage, pas un renvoi à la documentation.
