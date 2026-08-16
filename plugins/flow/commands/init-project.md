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

   Complète ensuite par : architecture en 3 à 5 points, conventions de code, et la règle git (jamais directement sur `main`, commits atomiques, aucun secret).

5. **Tests.** S'il n'y a aucune infrastructure de test, installe-la et écris **un premier test qui passe** sur un chemin réellement critique. Un projet sans le moindre test ne peut pas avoir de porte de vérification — c'est le point le plus important de cette commande.

6. **CI.** `.github/workflows/ci.yml`, déclenché sur push et pull request, qui lance exactement les commandes du profil. La CI et `/flow:verify` doivent lancer la même chose : deux définitions du mot « vert » finissent toujours par diverger.

7. **`docs/`** — crée `docs/specs/` et `docs/decisions/` avec un court `README.md` expliquant à quoi ils servent.

8. **GitHub.** Propose-moi ensuite `gh repo create` (privé par défaut), le push, et la protection de `main` avec les checks CI requis — sans review obligatoire, je travaille seul. **N'exécute cette étape qu'après mon accord explicite.**

9. **Résumé** : ce qui a été mis en place, ce qui a été détecté, et ce que tu n'as pas pu faire.
