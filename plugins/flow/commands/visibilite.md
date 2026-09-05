---
description: Ouvre temporairement un dépôt privé pour que la CI coûteuse tourne gratuitement, puis le referme et le vérifie
argument-hint: ouvrir, ou fermer
---

Visibilité du dépôt : $ARGUMENTS

Sur un dépôt **privé**, les minutes GitHub Actions sont facturées, et les runners macOS comptent **dix fois** le tarif Linux. Sur un dépôt **public**, elles sont gratuites. Ouvrir le dépôt le temps d'une campagne de construction est une technique légitime — à condition de le refermer.

**Le risque n'est pas d'ouvrir : c'est d'oublier de refermer.** Cette commande possède les deux bouts pour cette seule raison.

## Ce que « public » expose réellement

Dis-moi ces quatre points **avant** de me demander quoi que ce soit. Ils ne sont pas négociables et je dois les avoir lus :

1. **Tout l'historique devient public**, pas seulement l'état actuel. Un secret commité il y a six mois puis retiré est toujours dans l'historique, et il devient lisible.
2. **Repasser en privé n'annule rien de ce qui a été pris.** Un clone, un fork, une mise en cache par un moteur de recherche survivent au changement. C'est irréversible dans les faits, même si le bouton, lui, se rebascule.
3. **Les fichiers joints aux releases deviennent téléchargeables sans compte**, y compris ceux des versions précédentes.
4. **Un fork créé pendant la fenêtre reste public** et hors de ton contrôle.

## Les appels, à écrire exactement ainsi

Cette commande bascule la visibilité par l'**API REST**, jamais par la sous-commande d'édition de dépôt de `gh`. Raison mesurée : celle-ci exige, depuis `gh` 2.61.0, un drapeau de confirmation qui **n'existait pas** avant — donc elle échoue des deux côtés, pour deux raisons opposées, selon la version installée. Les deux machines ne portent pas la même. L'API, elle, se comporte pareil partout.

```
gh repo view --json visibility -q .visibility
gh api --method PATCH "repos/{owner}/{repo}" -f visibility=public  -q .visibility
gh api --method PATCH "repos/{owner}/{repo}" -f visibility=private -q .visibility
```

Quatre règles qui vont avec, et dont chacune a déjà produit une panne :

- **`{owner}` et `{repo}` sont littéraux.** Ne les remplace par rien : `gh` les substitue lui-même depuis le dépôt du dossier courant. Un nom court comme `pym-workflow` donnerait un `404 Not Found` sur un dépôt qui existe — le pire message possible pendant que le dépôt est resté ouvert.
- **N'ajoute aucun argument de dépôt** aux commandes ci-dessus, pour la même raison.
- **`-q .visibility` n'est pas cosmétique.** Sans lui, l'API déverse 6 000 octets de JSON dans la conversation, à l'endroit précis où je dois lire un seul mot.
- **L'API répond en minuscules (`public`, `private`), `gh repo view` en majuscules (`PUBLIC`, `PRIVATE`).** Ne compare jamais les deux directement.

Et une règle d'échec : **`gh api` écrit son message d'erreur sur la sortie standard, sous une forme qui ressemble à une réponse normale.** Le seul juge est le code de sortie : non nul = échec, quoi qu'il y ait été affiché. Un droit insuffisant remonte d'ailleurs en `404 Not Found`, pas en « accès refusé ».

## Ouvrir

1. **Vérifie l'état actuel** : `gh repo view --json visibility -q .visibility`. S'il est déjà public, arrête-toi et dis-le-moi — il n'y a rien à faire, et surtout rien à refermer.

   **S'il rend `INTERNAL`, arrête-toi aussi** et dis-le-moi : refermer écrirait `private` et retirerait l'accès à toute l'organisation, sans que rien ne le signale. Ce cas se règle à la main, pas par cette commande.

2. **Fouille l'historique complet, pas seulement les fichiers actuels.** C'est l'étape qui justifie la commande :

   - fichiers sensibles ajoutés un jour, même supprimés depuis :
     `git log --all --diff-filter=A --name-only --pretty=format: | sort -u | grep -Ei '\.env|\.pem|\.key|\.p12|credential|secret'`
   - contenu, sur toutes les révisions (lent sur un gros dépôt — annonce la durée) :
     `git grep -I -nE 'ghp_|github_pat_|BEGIN [A-Z ]*PRIVATE KEY|api[_-]?key\s*[:=]\s*\S{16}' $(git rev-list --all)`

   **Montre-moi ce que tu trouves, même si ça te paraît anodin.** Si quoi que ce soit ressemble à un secret, arrête-toi : on ne fait pas le ménage dans l'historique en passant, et un dépôt privé est le bon endroit pour le garder en attendant.

3. **Demande-moi confirmation explicite**, en une phrase qui nomme le dépôt et la raison de l'ouverture. N'ouvre jamais sans ma réponse.

4. **Ouvre** : `gh api --method PATCH "repos/{owner}/{repo}" -f visibility=public -q .visibility`. Code de sortie non nul, ou réponse autre que `public` : **tu n'as rien ouvert** — dis-le-moi et arrête-toi. Sinon **vérifie** avec `gh repo view --json visibility -q .visibility`, qui doit rendre `PUBLIC`.

5. **Pose le témoin.** Écris `.git/flow-depot-ouvert` contenant la date d'ouverture et la raison, en une ligne. Ce fichier est le seul mécanisme qui survit à la fermeture de la conversation : `.git/` n'est jamais suivi par git, donc rien ne peut partir dans un commit, et le témoin disparaît avec le dossier.

   Une phrase de rappel dans une réponse peut être manquée ou oubliée d'un jour à l'autre. Un fichier, non — c'est lui que `/flow:guide` et `/flow:release` iront lire.

6. **Rappelle-moi** dans ta réponse que le dépôt est ouvert, et répète-le tant qu'il l'est. Un dépôt ouvert et oublié est le seul vrai échec possible de cette commande.

## Fermer

C'est la partie qui compte, et elle n'est jamais optionnelle.

1. **Regarde d'abord où on en est** : `gh repo view --json visibility -q .visibility`. S'il rend déjà `PRIVATE`, ne bascule rien — passe directement à l'étape 4 pour nettoyer un éventuel témoin périmé, et dis-moi que le dépôt était déjà fermé. Envoyer une écriture inutile sur un dépôt déjà privé, c'est m'apprendre à me méfier de cette commande.
2. **Ferme** : `gh api --method PATCH "repos/{owner}/{repo}" -f visibility=private -q .visibility`.
3. **Vérifie** : `gh repo view --json visibility -q .visibility` doit rendre `PRIVATE`. Montre-moi la sortie brute, ne me dis pas simplement que c'est fait.
4. **Retire le témoin `.git/flow-depot-ouvert`** — et seulement après que la vérification a rendu `PRIVATE`. Dans cet ordre : un témoin retiré alors que le dépôt est resté ouvert serait pire que pas de témoin du tout.
5. Si la commande échoue, **dis-le en gros, laisse le témoin en place, et donne-moi le lien du réglage à basculer à la main** : Settings → General → Danger Zone. Ne passe à aucune autre tâche tant que ce n'est pas réglé.

   Trois pannes se ressemblent à l'écran et ne se réparent pas pareil, alors nomme celle que tu constates : **`gh` absent** (installe-le), **jeton sans le droit d'écriture** (`gh auth refresh -s repo`, et l'API répond `404` et non « refusé »), **réseau muet** (réessaie). Dans les trois cas, le dépôt est **resté ouvert** : ne dis jamais autre chose.

**Si quoi que ce soit échoue pendant la fenêtre ouverte — une construction, un test, une release —, refermer passe avant de comprendre pourquoi.** On diagnostique sur un dépôt privé.

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
