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

4. **Montre-moi la spec et attends ma validation.** Ne passe pas à `/flow:design` de toi-même.

Reste court : une spec d'une page qu'on lit vaut mieux que cinq pages qu'on survole. Si la demande est vraiment triviale — une faute de frappe, un libellé —, dis-le et propose d'aller directement à `/flow:new-feature` plutôt que de produire de la paperasse.
