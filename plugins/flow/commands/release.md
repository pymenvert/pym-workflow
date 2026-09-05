---
description: Publie une version — CI verte exigée, bilan de santé, numéros cohérents, ligne au journal, puis le tag qui déclenche la publication
argument-hint: le numéro de version, ou rien pour que je le propose
---

Publication de version : $ARGUMENTS

**Le tag est le point de non-retour.** Le workflow de publication construit et publie — dans la plupart des projets, **il ne rejoue pas les tests**. Vérifie-le en le lisant. Tout ce qui n'a pas été contrôlé avant le tag ne le sera jamais.

1. **Point de départ.** Sur la branche par défaut, à jour, aucun fichier modifié. Sinon c'est une fin, pas un arrêt : dis-moi quoi faire et termine par « Ensuite » — on ne publie ni depuis une branche de travail, ni depuis un dossier encombré.

2. **La CI de la branche par défaut est-elle verte ?** `gh run list --branch <défaut> --limit 3`, en te fondant sur le code de sortie ou la sortie JSON — jamais sur du texte découpé en colonnes. **Rouge ou en cours : c'est une fin** — dis-le, et termine par « Ensuite ».

   **Une sortie vide n'est pas une CI verte.** Sur un dépôt sans intégration continue, ou dont la branche n'a jamais été construite, `gh run list` rend **zéro ligne et un code de sortie 0** — mesuré. Lu comme « pas de rouge », ça fait franchir la porte à une version que rien n'a testée. Compte les exécutions : **aucune exécution = une fin, dis-le-moi**, exactement comme un rouge. « Non configuré » n'est jamais « OK ».

3. **Numéro de version.** Si je ne l'ai pas donné, propose-le en lisant le CHANGELOG — si le projet en a un ; sinon, dis-le — et `git log <dernier-tag>..HEAD --oneline` : corrections seules → version corrective, ajouts → version mineure, rupture d'usage → version majeure. Annonce-le avec ce sur quoi tu te fondes — c'est un choix du studio, pas une question ; si je t'ai donné un numéro, c'est lui.

4. **Le bilan de santé.** Lance `/flow:audit` — charge-le toi-même, comme dans le cycle — et annonce sa durée : c'est ce qui rend une version chère, et c'est voulu. Sauf si le registre porte déjà un bilan daté d'après la dernière étiquette dont tous les « à corriger » sont rayés : l'audit confronte alors sans convoquer personne. **S'il liste quelque chose à corriger avant la version, c'est une fin**, pas un arrêt : « Ensuite : `/flow:new-feature <item>` », sur une branche ; après la fusion, `/flow:release` se relance, dans une conversation neuve. Puis, si la suite de tests a nettement grossi depuis la dernière étiquette (`git diff --stat <étiquette>..HEAD` sur les dossiers de tests), propose `/flow:mutation` **pour après** — elle exige un dossier propre et ses propres accords.

5. **Cohérence des numéros — l'erreur la plus fréquente.** Cherche **tous** les endroits où la version est inscrite : `package.json`, mais aussi les fichiers de plateforme (`Info.plist`, manifestes, en-têtes, scripts d'installation). Un projet en a souvent plusieurs, et ils doivent être identiques. Un seul oublié produit un paquet qui s'annonce sous un mauvais numéro — et le workflow de publication ne le verra pas. Liste-les-moi avant de les modifier.

6. **CHANGELOG — l'erreur la plus coûteuse de toutes.** Une section pour cette version, écrite pour quelqu'un qui l'installe : ce qui change **pour lui**. Ce qui est corrigé, ce qui est ajouté, ce qui casse. Pas la liste des commits.

   **Vérifie que cette section décrit bien TOUT ce que le tag va contenir.** S'il reste une section « Non publié » ou « Unreleased », son contenu appartient à cette version : intègre-le, ne le laisse pas de côté. Quand la description de la release est générée depuis le CHANGELOG — c'est fréquent —, ce qui n'y figure pas devient invisible pour ceux qui installent. Compare la section à `git log <dernier-tag>..HEAD` et dis-moi ce que tu as dû rapatrier.

7. **La ligne de journal, puis le commit.** Ajoute à `docs/journal.md`, par `cat >>` — jamais en réécrivant le fichier —, `- <AAAA-MM-JJ> · version · <numéro> · bilan : <le bilan de santé en une phrase>`. L'en-tête fait foi sur la forme : ni « · » ni retour à la ligne dans une case — un « ; » les remplace —, « ? » pour ce qu'on ne sait pas, jamais « aucun ». Puis commit et pousse ces changements — c'est le seul commit qui se fait directement sur la branche par défaut, et il ne porte que ça : numéros, changelog, journal. **Attends que la CI redevienne verte** sur ce commit précis. C'est le dernier filet avant le tag, et le seul qui teste vraiment ce qui va être publié.

8. **Le tag.** `git tag vX.Y.Z` puis `git push origin vX.Y.Z`. Avant de le faire, dis-moi en une ligne que c'est irréversible et **attends mon accord explicite** — raison 3.

9. **Surveille la publication** jusqu'à son verdict, et donne-moi le lien de la release. Si elle échoue, le tag existe déjà sur le dépôt distant : dis-moi exactement quoi supprimer avant de recommencer, sinon je serai bloqué.

10. **Le dépôt est-il resté ouvert ?** Demande-le à GitHub, pas à un fichier : `gh repo view --json visibility -q .visibility`, sans argument de dépôt — il se déduit du dossier courant. Si la réponse est `PUBLIC` alors que le dépôt est censé être privé, dis-le-moi **en premier, avant le bilan**, et propose `/flow:visibilite fermer`.

   **Ne te fie pas au seul témoin `.git/flow-depot-ouvert`** : il vit dans un clone, donc il ne traverse pas les machines. Un dépôt ouvert depuis un poste puis repris depuis un autre n'a aucun témoin de ce côté-là — et le seul endroit qui détient la vérité est GitHub. Le témoin reste utile, il dit *pourquoi* et *depuis quand* ; mais c'est la réponse de GitHub qui tranche.

   C'est le moment exact où on oublie : la release est publiée, le travail semble fini, et le dépôt reste ouvert pour la nuit.

## Arrêts et suite

- **Arrêts** : l'étiquette → raison 3, la seule chose irréversible ici. Un dossier encombré, une CI rouge ou absente, un bilan qui trouve à corriger : des fins, pas des arrêts — tu dis quoi faire, et tu t'arrêtes là.
- **En pas à pas** : les mêmes.
- **Suite** : aucune commande ; après la publication, `/flow:guide` me dit la suite.

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
