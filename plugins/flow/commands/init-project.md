---
description: Initialise le projet — détecte la stack, écrit le profil que toutes les commandes /flow:* liront, pose tests et CI
---

Mets ce projet au standard. L'objectif n'est pas de créer des fichiers, c'est qu'à la fin **une machine vérifie le code à ma place** et que les autres commandes `/flow:*` sachent comment travailler ici.

## Règle absolue : ne rien écraser

Cette commande sera souvent lancée sur un projet qui existe déjà et qui marche. **Tu n'écrases aucun fichier existant.** Pour chacun de ceux que tu voudrais créer — `CLAUDE.md`, `.gitignore`, `.github/workflows/ci.yml`, configuration de tests —, s'il est déjà là :

1. lis-le,
2. montre-moi le diff exact de ce que tu ajouterais,
3. attends mon accord.

Un `CLAUDE.md` écrit à la main contient des choses que tu ne peux pas deviner. Complète-le, ne le remplace pas. En cas de doute, demande — c'est moins coûteux que de reconstituer un fichier perdu.

Vérifie aussi `git status` en début de commande : si le worktree n'est pas propre, signale-le-moi et attends avant d'écrire quoi que ce soit. Un dépôt propre, c'est ma garantie de pouvoir tout annuler.

1. **Explore et constate.** Langages, frameworks, gestionnaire de paquets, scripts déjà définis, tests existants. Ne suppose rien : ouvre les fichiers de configuration. Détermine le **type de projet** — `cli`, `desktop`, `web`, `service` ou `script` — car c'est lui qui décidera plus tard s'il faut juger une interface, et laquelle.

2. **Git.** `git init` et commit initial si ce n'est pas déjà un dépôt.

3. **`.gitignore`** adapté à la stack. Toujours : `.env`, `.env.*`, clés et certificats, caches, dossiers de build.

4. **`CLAUDE.md`**, court (moins de 60 lignes), avec **ce bloc en premier** — c'est le contrat lu par `/flow:design`, `/flow:new-feature` et `/flow:verify` :

   ```markdown
   ## Profil projet
   - type : cli | desktop | web | service | script
   - stack : <langage + framework principal>
   - format : <commande, ou "aucun">
   - lint : <commande, ou "aucun">
   - typecheck : <commande, ou "aucun">
   - test : <commande, ou "aucun">
   - build : <commande, ou "aucun">
   - run : <commande pour lancer le logiciel>
   - critique : <modules dont une panne fait mal ; à couvrir en priorité par les tests>
   ```

   **Chaque commande listée doit avoir été lancée par toi et fonctionner.** Une commande écrite au jugé rend le profil nuisible : `/flow:verify` déclarerait vert quelque chose qui n'a jamais tourné. Si un outil manque, écris « aucun » et propose-moi de l'installer.

   **Ajoute aussi ce bloc, juste après le profil.** Il capte les questions que je pose en français plutôt qu'en commande — c'est ma façon réelle de demander mon chemin :

   ```markdown
   ## Boussole
   Quand je demande « et maintenant ? », « je fais quoi ? », « par quoi je commence ? »
   ou « c'est fini ? » : réponds comme la commande `/flow:guide` — le constat, ce qu'il
   reste à faire, et une seule action à lancer. Sans lancer de test, d'agent, de lint
   ni de build. Si `docs/reste-a-faire.md` existe, lis-le avant d'affirmer que rien
   n'attend.
   ```

   Complète ensuite par : architecture en 3 à 5 points, conventions de code, et la règle git (jamais directement sur `main`, commits atomiques, aucun secret).

5. **Tests.** S'il n'y a aucune infrastructure de test, installe-la et écris **un premier test qui passe** sur un chemin réellement critique. Un projet sans le moindre test ne peut pas avoir de porte de vérification — c'est le point le plus important de cette commande.

6. **CI.** `.github/workflows/ci.yml`, déclenché sur push et pull request, qui lance exactement les commandes du profil. La CI et `/flow:verify` doivent lancer la même chose : deux définitions du mot « vert » finissent toujours par diverger.

7. **`docs/`** — crée `docs/specs/` et `docs/decisions/` avec un court `README.md` expliquant à quoi ils servent.

8. **GitHub.** Propose-moi ensuite `gh repo create` (privé par défaut), le push, et la protection de `main` avec les checks CI requis — sans review obligatoire, je travaille seul. **N'exécute cette étape qu'après mon accord explicite.**

9. **Résumé** : ce qui a été mis en place, ce qui a été détecté, et ce que tu n'as pas pu faire.

---

## Arrêts et attentes

**Chaque fois que tu t'arrêtes pour attendre ma réponse**, commence par « **J'attends ta réponse.** » Puis la question en clair, la conséquence de chaque réponse possible, et les options quand il y en a. N'enchaîne jamais sur la suite sans avoir la réponse. Et ne me dis pas que rien n'a été écrit si des fichiers l'ont déjà été — dis exactement où on en est.

**Avant tout passage long et muet** — agents de revue, suite de tests, surveillance de la CI —, annonce-le en une ligne, avec sa durée approximative. Un silence long ressemble à un plantage, et ma réaction sera de taper une autre commande.

## Fin de réponse — obligatoire

Termine toujours ta dernière réponse par ces trois lignes. Les titres ne changent jamais ; le contenu décrit ce qui s'est réellement passé. **Si tu t'es arrêté en route, dis-le ici** — n'annonce jamais un travail qui n'a pas eu lieu.

**Où on en est** — un fait constaté, puis sa conséquence. Deux lignes maximum.
**Ensuite** — UNE seule chose : une commande à lancer, ou une phrase à me répondre. Jamais deux options, jamais de « si » : tu as lu le projet, moi non — tranche.
**Si tu hésites** — `/flow:guide` : il regarde où j'en suis et me donne la seule chose à faire ensuite. Il ne modifie rien, ne lance aucun test, et coûte trois secondes.

Aucun terme technique sans sa traduction dans la même phrase. Je travaille dans GitHub Desktop : « branche », « commit », « CI », « pull request », « diff » demandent trois mots d'explication au passage, pas un renvoi à la documentation.
