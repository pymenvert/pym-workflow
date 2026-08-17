---
description: Transforme une idée floue en critères d'acceptation testables, avant qu'une ligne soit écrite
argument-hint: ce que tu veux construire ou corriger
---

Idée à cadrer : $ARGUMENTS

Ton rôle ici n'est pas de coder ni de proposer une solution technique. C'est d'obtenir une définition de « terminé » sur laquelle on ne pourra pas se disputer plus tard. La plupart des bugs coûteux ne sont pas des erreurs de code : ce sont des malentendus sur ce qu'il fallait faire.

1. **Explore d'abord.** Regarde le code existant et le `CLAUDE.md` du projet. Une partie des réponses y est déjà — ne me demande pas ce que tu peux constater.

2. **Pose au maximum trois questions**, et uniquement celles dont la réponse change réellement le travail. Si aucune ne remplit ce critère, n'en pose aucune. Une question dont tu peux deviner la réponse raisonnable n'en est pas une : prends l'hypothèse et signale-la.

3. **Écris `docs/specs/<slug>.md`** avec exactement ces sections :

   - **Problème** — ce qui ne va pas aujourd'hui, en deux phrases. Pas la solution.
   - **Usage** — qui s'en sert, dans quelle situation, pour obtenir quoi.
   - **Critères d'acceptation** — numérotés, observables, vérifiables. Formule chacun ainsi : *étant donné <situation>, quand <action>, alors <résultat constatable>*. Si un critère ne peut pas devenir un test, il est mal écrit : réécris-le.
   - **Hors périmètre** — ce qu'on ne fait délibérément pas cette fois. Cette section évite plus de dérive que toutes les autres réunies.
   - **Cas limites** — entrées vides, valeurs extrêmes, échecs, interruptions. Ce que le logiciel doit faire dans chacun.
   - **Risques et inconnues** — ce qui pourrait rendre le travail beaucoup plus long que prévu.

4. **Montre-moi la spec et attends ma validation.** Ne passe pas à `/flow:design` de toi-même. Je réponds dans la discussion, en français — je n'ai aucune commande à relancer pour valider.

   Si c'est ma première tâche sur ce projet, précise-moi au passage que `/flow:new-feature` créera la branche de travail tout seul : je n'ai rien à préparer avant.

**Vise 60 lignes, plafond 80.** Une spec qu'on lit en entier vaut mieux que trois pages qu'on survole. Si tu dépasses, relis-toi avant de me la montrer : c'est presque toujours que du *comment* a glissé dans les critères — le choix d'une bibliothèque, la forme d'un module, la façon d'écrire un format. Ça appartient à `/flow:design`. Ici, les critères disent **quoi**, et à quoi on reconnaîtra que c'est fait.

Si la demande est vraiment triviale — une faute de frappe, un libellé —, dis-le et propose d'aller directement à `/flow:new-feature` plutôt que de produire de la paperasse.

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
