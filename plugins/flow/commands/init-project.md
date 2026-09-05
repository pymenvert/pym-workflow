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

Vérifie aussi `git status` en début de commande : si des fichiers sont déjà modifiés et pas encore enregistrés, signale-le-moi et attends avant d'écrire quoi que ce soit. Un dossier propre — aucune modification en attente — c'est ma garantie de pouvoir tout annuler.

1. **Explore et constate.** Langages, frameworks, gestionnaire de paquets, scripts déjà définis, tests existants. Ne suppose rien : ouvre les fichiers de configuration. Détermine le **type de projet** — `cli`, `desktop`, `web`, `service` ou `script` — car c'est lui qui décidera plus tard s'il faut juger une interface, et laquelle.

2. **Git.** `git init` et commit initial si ce n'est pas déjà un dépôt.

3. **`.gitignore`** adapté à la stack. Toujours : `.env`, `.env.*`, clés et certificats, caches, dossiers de build.

4. **`CLAUDE.md`**, court (moins de 60 lignes), avec **ce bloc en premier** — c'est le contrat que lisent toutes les commandes `/flow:*` :

   ```markdown
   ## Profil projet
   - type : cli | desktop | web | service | script
   - stack : <langage + framework principal>
   - format : <commande qui **vérifie** le format sans écrire, ou "aucun">
   - lint : <commande, ou "aucun">
   - typecheck : <commande, ou "aucun">
   - test : <commande, ou "aucun">
   - build : <commande, ou "aucun">
   - run : <commande pour lancer le logiciel>
   - rythme : enchaîné | pas à pas
   - critique : <modules dont une panne fait mal ; à couvrir en priorité par les tests>
   ```

   **`format` est la seule ligne où la forme compte** : écris la variante qui **contrôle** (`prettier --check`, `ruff format --check`), jamais celle qui écrit. `/flow:verify` la lance en tête de sa chaîne de checks, et il le fait avant d'avoir tranché la question de la branche — parce qu'un check ne modifie rien. Une commande qui écrirait déposerait des modifications sur la branche par défaut sans accord, et ne rendrait jamais rouge.

   **`rythme` est le seul réglage du profil sans vérité extérieure**, et il le dit : rien ne le lance, il se lit. `enchaîné` — le défaut — fait se suivre les commandes du cycle sans attendre, sauf pour les quatre raisons du bloc « Arrêts et attentes » ; `pas à pas` les arrête après le cadrage, la conception et le plan. Écris `enchaîné`, sauf si je demande le pas à pas : un projet qu'on découvre peut le mériter, un projet qu'on connaît ne le mérite plus.

   **Chaque commande listée doit avoir été lancée par toi et fonctionner.** Une commande écrite au jugé rend le profil nuisible : `/flow:verify` déclarerait vert quelque chose qui n'a jamais tourné. Si un outil manque, écris « aucun » et propose-moi de l'installer.

   **Ajoute aussi ce bloc, juste après le profil.** Il capte les questions que je pose en français plutôt qu'en commande — c'est ma façon réelle de demander mon chemin :

   ```markdown
   ## Boussole
   Quand je demande « et maintenant ? », « je fais quoi ? », « par quoi je commence ? »
   ou « c'est fini ? » : réponds comme la commande `/flow:guide` — le constat, ce qu'il
   reste à faire, et une seule action à lancer. Sans lancer de test, d'agent, de lint
   ni de build. Si `docs/reste-a-faire.md` existe, lis-le avant d'affirmer que rien
   n'attend. Si `docs/journal.md` a une panne dont la dernière ligne d'incident
   porte « cause : ? », propose-la avant tout.
   ```

   Complète ensuite par : architecture en 3 à 5 points, conventions de code, et la règle git (jamais directement sur `main`, commits atomiques, aucun secret).

5. **Tests.** S'il n'y a aucune infrastructure de test, installe-la et écris **un premier test qui passe** sur un chemin réellement critique. Un projet sans le moindre test ne peut pas avoir de porte de vérification — c'est le point le plus important de cette commande.

6. **CI.** `.github/workflows/ci.yml`, déclenché sur push et pull request, qui lance exactement les commandes du profil. La CI et `/flow:verify` doivent lancer la même chose : deux définitions du mot « vert » finissent toujours par diverger.

7. **`docs/`** — crée `docs/specs/` et `docs/decisions/` avec un court `README.md` expliquant à quoi ils servent.

8. **GitHub.** Propose-moi ensuite `gh repo create` (privé par défaut), le push, et la protection de `main` avec les checks CI requis — sans review obligatoire, je travaille seul. **N'exécute cette étape qu'après mon accord explicite.**

9. **Résumé** : ce qui a été mis en place, ce qui a été détecté, et ce que tu n'as pas pu faire.

## Arrêts et suite

- **Arrêts** : compléter un fichier qui existe déjà → raison 3, on ne le reconstitue pas · des modifications en attente au départ → raison 1, moi seul sais ce qu'elles valent · créer le dépôt GitHub et pousser → raison 3, c'est public. Aucun autre.
- **En pas à pas** : les mêmes.
- **Suite** : aucune commande — le cycle commence quand je tape `/flow:spec`.

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
