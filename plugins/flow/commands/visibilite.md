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

## Ouvrir

1. **Vérifie l'état actuel** : `gh repo view <dépôt> --json visibility`. S'il est déjà public, arrête-toi et dis-le-moi — il n'y a rien à faire, et surtout rien à refermer.

2. **Fouille l'historique complet, pas seulement les fichiers actuels.** C'est l'étape qui justifie la commande :

   - fichiers sensibles ajoutés un jour, même supprimés depuis :
     `git log --all --diff-filter=A --name-only --pretty=format: | sort -u | grep -Ei '\.env|\.pem|\.key|\.p12|credential|secret'`
   - contenu, sur toutes les révisions (lent sur un gros dépôt — annonce la durée) :
     `git grep -I -nE 'ghp_|github_pat_|BEGIN [A-Z ]*PRIVATE KEY|api[_-]?key\s*[:=]\s*\S{16}' $(git rev-list --all)`

   **Montre-moi ce que tu trouves, même si ça te paraît anodin.** Si quoi que ce soit ressemble à un secret, arrête-toi : on ne fait pas le ménage dans l'historique en passant, et un dépôt privé est le bon endroit pour le garder en attendant.

3. **Demande-moi confirmation explicite**, en une phrase qui nomme le dépôt et la raison de l'ouverture. N'ouvre jamais sans ma réponse.

4. **Ouvre** : `gh repo edit <dépôt> --visibility public --accept-visibility-change-consequences`, puis **vérifie** que c'est bien fait.

5. **Pose le témoin.** Écris `.git/flow-depot-ouvert` contenant la date d'ouverture et la raison, en une ligne. Ce fichier est le seul mécanisme qui survit à la fermeture de la conversation : `.git/` n'est jamais suivi par git, donc rien ne peut partir dans un commit, et le témoin disparaît avec le dossier.

   Une phrase de rappel dans une réponse peut être manquée ou oubliée d'un jour à l'autre. Un fichier, non — c'est lui que `/flow:guide` et `/flow:release` iront lire.

6. **Rappelle-moi** dans ta réponse que le dépôt est ouvert, et répète-le tant qu'il l'est. Un dépôt ouvert et oublié est le seul vrai échec possible de cette commande.

## Fermer

C'est la partie qui compte, et elle n'est jamais optionnelle.

1. `gh repo edit <dépôt> --visibility private --accept-visibility-change-consequences`
2. **Vérifie** : `gh repo view <dépôt> --json visibility` doit rendre `PRIVATE`. Montre-moi la sortie brute, ne me dis pas simplement que c'est fait.
3. **Retire le témoin `.git/flow-depot-ouvert`** — et seulement après que la vérification a rendu `PRIVATE`. Dans cet ordre : un témoin retiré alors que le dépôt est resté ouvert serait pire que pas de témoin du tout.
4. Si la commande échoue, **dis-le en gros, laisse le témoin en place, et donne-moi le lien du réglage à basculer à la main** : Settings → General → Danger Zone. Ne passe à aucune autre tâche tant que ce n'est pas réglé.

**Si quoi que ce soit échoue pendant la fenêtre ouverte — une construction, un test, une release —, refermer passe avant de comprendre pourquoi.** On diagnostique sur un dépôt privé.

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
