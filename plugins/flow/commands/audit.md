---
description: Audit de fond de tout le programme — la dérive, les angles morts, ce qui est devenu faux. Rare et cher.
argument-hint: (rien), ou un périmètre à examiner
---

Audit de fond : $ARGUMENTS

Ce n'est pas `/flow:verify`. La porte examine **ce qui vient de changer** ; toi tu examines **tout le programme**, et tu cherches ce qu'aucun diff ne peut révéler : la dérive lente, les angles morts, et les affirmations devenues fausses.

Commande **chère et rare** : à lancer entre deux versions, jamais à chaque tâche. Annonce-moi sa durée avant de commencer.

## S'il existe déjà un rapport d'audit, confronte-le

Cherche-le avant toute chose : `docs/`, un dossier d'audits gardé hors du dépôt, tout fichier nommé `*AUDIT*` ou `*reste*`. S'il en existe un, **ne recommence pas de zéro : confronte-le.**

Pour chaque constat encore listé comme non traité, va voir dans le code s'il est toujours vrai, et classe-le en trois piles : **toujours ouvert**, **déjà corrigé**, ou **devenu faux** (le code a changé de forme, le constat ne décrit plus rien).

C'est beaucoup moins cher qu'un audit neuf, et bien plus utile : **un constat périmé est pire qu'aucun constat**, parce qu'il fait croire qu'on connaît ses risques. Un rapport de plusieurs semaines sur un projet qui a publié une version depuis est périmé par défaut.

Commence par les constats les plus graves, et ne confronte pas les cosmétiques tant que les majeurs ne sont pas tranchés. Rends d'abord le décompte : combien encore ouverts, combien déjà réglés.

## Mesure avant de juger

Un audit qui commence par une opinion ne vaut rien. Mais ne refais pas la mesure structurelle toi-même : la duplication, le code mort et les dépendances circulaires sont mesurés par `architect`. Tu lis son rapport, tu ne le doubles pas.

**Lance donc les agents maintenant** — section « Les agents, sur le fond » plus bas — et attends leurs rapports avant de répondre aux questions : trois des cinq en dépendent. Préviens-moi de la durée.

## Les cinq questions

1. **Qu'est-ce qui n'a jamais rencontré la réalité ?** L'inventaire des doublures est établi par `test-engineer` — ne le refais pas. Ta question à toi est celle qu'il ne peut pas poser : ce que son inventaire révèle du **projet entier**. Un projet peut avoir trois cents tests verts et n'avoir jamais rien fait fonctionner pour de vrai ; si c'est le cas, c'est le premier constat du rapport, avant tous les autres.

2. **Quels tests ne protègent rien ?** Ne l'éprouve pas ici : `/flow:mutation` est écrit pour ça, avec les garde-fous qu'exige une commande qui casse du code exprès — cet audit, lui, ne modifie rien. Regarde simplement si cette épreuve a déjà été passée sur ce projet (un outil de mutation, une trace dans `docs/reste-a-faire.md`). Si non, dis-le et propose-la : un audit qui fait confiance à une suite de tests jamais éprouvée repose sur du sable.

3. **Qu'est-ce que le programme dit de lui-même qui est devenu faux ?** Textes d'interface, messages d'erreur, README, aide en ligne, notice. Une explication vieillit sans qu'aucun test ne s'en aperçoive — et c'est précisément ce que l'utilisateur lit.

4. **Quelle partie sera la plus pénible à modifier ?** Ne réponds pas toi-même : c'est la question centrale d'`architect`, avec son horizon à lui. Reprends sa réponse et dis si tu la partages. Deux horizons différents pour la même question ne donnent pas deux avis, ils donnent un doute.

5. **Qu'est-ce qui a été corrigé sans que la cause soit écrite ?** Un défaut réglé dont la leçon n'est consignée nulle part reviendra sous une autre forme.

## Les agents, sur le fond

Lance `architect` en mode dérive structurelle, `test-engineer` sur les chemins critiques du projet entier, et `ux-reviewer` sur l'interface complète — pas seulement les écrans récemment touchés. Préviens-moi : plusieurs minutes.

## Rendu

Trois sections, hiérarchisées :

- **À corriger avant la prochaine version** — avec la conséquence concrète si on ne le fait pas
- **Dette assumable** — à noter, à supporter sciemment
- **Ce que cet audit n'a pas pu voir** — obligatoire, en citant nommément les conditions réelles qui manquent

Puis **écris tout dans `docs/reste-a-faire.md`**, sous un titre daté. Un audit qui ne survit pas à la conversation n'a servi à rien.

Et si l'audit dégage une leçon générale — pas un défaut, une règle —, propose-moi de l'ajouter au `CLAUDE.md` du projet. C'est ce qui évite de la réapprendre au prix fort.

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
