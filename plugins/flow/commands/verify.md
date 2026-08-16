---
description: La porte — checks automatisés puis revue par les agents. Rien ne part tant que c'est rouge.
---

C'est l'étape qui décide si le travail est livrable. Elle a le droit de dire non.

Deux règles absolues : **tu ne déclares jamais vert quelque chose que tu n'as pas lancé**, et **tu ne contournes jamais un check qui échoue** — ni en le désactivant, ni en modifiant le test pour qu'il passe, ni en le déclarant « hors périmètre ». Si un check est cassé pour une raison indépendante de la tâche, dis-le explicitement au lieu de le masquer.

## 1. Checks automatisés

Lis le bloc « Profil projet » du `CLAUDE.md` pour connaître les commandes exactes. S'il est absent, détecte-les et signale-moi que `/flow:init-project` n'a jamais été passé.

Lance dans cet ordre, en t'arrêtant de corriger seulement quand tout est vert : **format → lint → typecheck → tests → build**.

Présente le résultat sous forme de tableau, une ligne par check, avec la commande réellement exécutée et son état. Une commande absente du projet se note « non configuré » — jamais « OK ».

**Si un check échoue après tes corrections : verdict BLOQUÉ, tu t'arrêtes là.** Inutile de lancer les agents sur du code qui ne compile pas.

## 2. Revue par les agents

Une fois les checks verts, lance en parallèle ceux qui s'appliquent :

- **`code-reviewer`** — toujours
- **`test-engineer`** — dès que du code de logique a changé
- **`architect`** — dès qu'un fichier a été créé, déplacé, ou a nettement grossi ; il travaille alors en mode dérive structurelle
- **`ux-reviewer`** — uniquement si l'interface visible a changé. Il doit lancer le logiciel pour de vrai.

Lance aussi `/security-review` si le diff touche à des entrées utilisateur, des fichiers, du réseau, des permissions ou des secrets.

## 3. Verdict

Rassemble tout et tranche, sans diplomatie :

- **Bloquants** — ce qui doit être corrigé avant `/flow:ship`. Corrige-les, puis relance les checks concernés.
- **À traiter plus tard** — liste-les-moi ; ne les corrige pas silencieusement, ça brouille le diff.
- **Non vérifié** — ce que tu n'as pas pu contrôler et pourquoi. Cette section est obligatoire : une porte qui cache ses angles morts ne protège de rien.

Termine par une seule ligne : **PASSE** ou **BLOQUÉ**, suivie du nombre de bloquants restants.
