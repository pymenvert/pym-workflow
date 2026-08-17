---
description: Publie une version — cohérence des numéros, CI verte exigée, puis le tag qui déclenche la publication
argument-hint: le numéro de version, ou rien pour que je le propose
---

Publication de version : $ARGUMENTS

**Le tag est le point de non-retour.** Le workflow de publication construit et publie — dans la plupart des projets, **il ne rejoue pas les tests**. Vérifie-le en le lisant. Tout ce qui n'a pas été contrôlé avant le tag ne le sera jamais.

1. **Point de départ.** Sur la branche par défaut, à jour, aucun fichier modifié. Sinon arrête-toi : on ne publie ni depuis une branche de travail, ni depuis un dossier encombré.

2. **La CI de la branche par défaut est-elle verte ?** `gh run list --branch <défaut> --limit 3`, en te fondant sur le code de sortie ou la sortie JSON — jamais sur du texte découpé en colonnes. **Rouge ou en cours : tu t'arrêtes.**

3. **Numéro de version.** Si je ne l'ai pas donné, propose-le en lisant le CHANGELOG et `git log <dernier-tag>..HEAD --oneline` : corrections seules → version corrective, ajouts → version mineure, rupture d'usage → version majeure. Dis-moi sur quoi tu te fondes, et attends mon accord.

4. **Cohérence des numéros — l'erreur la plus fréquente.** Cherche **tous** les endroits où la version est inscrite : `package.json`, mais aussi les fichiers de plateforme (`Info.plist`, manifestes, en-têtes, scripts d'installation). Un projet en a souvent plusieurs, et ils doivent être identiques. Un seul oublié produit un paquet qui s'annonce sous un mauvais numéro — et le workflow de publication ne le verra pas. Liste-les-moi avant de les modifier.

5. **CHANGELOG.** Une section pour cette version, écrite pour quelqu'un qui l'installe : ce qui change **pour lui**. Ce qui est corrigé, ce qui est ajouté, ce qui casse. Pas la liste des commits.

6. **Commit et pousse ces changements. Puis attends que la CI redevienne verte** sur ce commit précis. C'est le dernier filet avant le tag, et le seul qui teste vraiment ce qui va être publié.

7. **Le tag.** `git tag vX.Y.Z` puis `git push origin vX.Y.Z`. Avant de le faire, dis-moi en une ligne que c'est irréversible et **attends mon accord explicite**.

8. **Surveille la publication** jusqu'à son verdict, et donne-moi le lien de la release. Si elle échoue, le tag existe déjà sur le dépôt distant : dis-moi exactement quoi supprimer avant de recommencer, sinon je serai bloqué.

---

## Arrêts et attentes

**Chaque fois que tu t'arrêtes pour attendre ma réponse**, commence par « **J'attends ta réponse.** » Puis la question en clair, la conséquence de chaque réponse possible, et les options quand il y en a. N'enchaîne jamais sur la suite sans avoir la réponse. Et ne me dis pas que rien n'a été écrit si des fichiers l'ont déjà été — dis exactement où on en est.

**Avant tout passage long et muet** — agents de revue, suite de tests, surveillance de la CI —, annonce-le en une ligne, avec sa durée approximative. Un silence long ressemble à un plantage, et ma réaction sera de taper une autre commande.

## Fin de réponse — obligatoire

Termine toujours ta dernière réponse par ces trois lignes. Les titres ne changent jamais ; le contenu décrit ce qui s'est réellement passé. **Si tu t'es arrêté en route, dis-le ici** — n'annonce jamais un travail qui n'a pas eu lieu.

**Où on en est** — un fait constaté, puis sa conséquence. Deux lignes maximum.
**Ensuite** — UNE seule chose : une commande à lancer, ou une phrase à me répondre. Jamais deux options que tu pourrais trancher toi-même en regardant le projet — tu l'as lu, moi non. En revanche, quand la réponse ne dépend que de moi (« est-ce que je considère ce travail comme fini ? », « laquelle de ces deux formes je préfère ? »), demande — mais constate d'abord, et présente ce que tu as vu en même temps que ta question.
**Si tu hésites** — `/flow:guide` : il regarde où j'en suis et me donne la seule chose à faire ensuite. Il ne modifie rien, ne lance aucun test, et coûte trois secondes.

Aucun terme technique sans sa traduction dans la même phrase. Je travaille dans GitHub Desktop : « branche », « commit », « CI », « pull request », « diff » demandent trois mots d'explication au passage, pas un renvoi à la documentation.
