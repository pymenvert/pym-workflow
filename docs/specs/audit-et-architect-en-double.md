# `/flow:audit` et `architect` mesurent deux fois la même chose

**Réalisé** le 4 septembre 2026 par la décision `0003`, qui a absorbé ce cadrage
et en porte le détail. Conservé pour l'historique ; ne pas relancer `/flow:design`
dessus.

Cadré le 4 septembre 2026, après deux reports assumés : ce défaut demande une décision, pas une retouche.

## Problème

`/flow:audit` établit lui-même une liste de mesures structurelles
(`audit.md`:24), puis lance l'agent `architect` en mode dérive
(`audit.md`:40) — qui refait la même. Mesuré : **19 termes communs sur 29**,
soit 65 % de la liste, entre `audit.md`:24 et `architect.md`:26-33. Et la
question centrale existe en double avec **deux horizons contradictoires** :
« dans six mois » (`audit.md`:34), « dans trois mois » (`architect.md`:35).

## Usage

Un développeur solo lance `/flow:audit` entre deux versions. C'est la commande
la plus chère du plugin : plusieurs minutes, trois agents. Il en attend un
rapport hiérarchisé — pas deux réponses à la même question, ni la même mesure
facturée deux fois.

## Critères d'acceptation

1. Étant donné le dépôt, quand on cherche la liste des mesures structurelles
   (fichiers les plus gros, duplication, code mort, dépendances circulaires),
   alors elle n'apparaît **qu'à un seul endroit** ; l'autre fichier y renvoie
   au lieu de la recopier.
2. Étant donné le dépôt, quand on cherche la question « quelle partie sera la
   plus pénible à modifier », alors elle apparaît avec **un seul horizon**, dans
   un seul fichier.
3. Étant donné `/flow:audit` lancé sur un projet, quand il rend son rapport,
   alors chaque mesure structurelle n'a été établie **qu'une fois**.
4. Étant donné que `/flow:verify` lance lui aussi `architect` en mode dérive
   (`verify.md`:39), quand on le lance après ce lot, alors son comportement est
   **inchangé** : l'agent reste autonome, sans rien attendre de `/flow:audit`.
5. Étant donné les cinq questions de l'audit et les six axes du contexte B,
   quand on les relit après le lot, alors **aucune n'a disparu** : ce qui quitte
   un fichier se retrouve dans l'autre.
6. Étant donné les deux scripts du dépôt, quand on les lance, alors ils restent
   verts — et quelque chose empêche désormais **mécaniquement** cette liste de
   réapparaître en double.

## Hors périmètre

- **Les deux autres agents.** Vérifié, il n'y a pas de doublon :
  `test-engineer` cherche les cas limites non couverts, `ux-reviewer` juge
  l'interface lancée. Seul `architect` fait double emploi.
- **Le contexte A d'`architect`** (attaquer une architecture proposée) : il
  n'est en double avec rien, on n'y touche pas.
- **Ce que `/flow:audit` produit et ce qu'il coûte** — ses trois sections de
  rendu, son écriture dans `docs/reste-a-faire.md`, sa confrontation d'un
  rapport préexistant, et ses trois agents lancés sans condition. Pas de « mode
  pauvre » ici, et pas de lancement réel : ce lot corrige sa structure, pas son
  résultat.

## Cas limites

- **Projet sans `CLAUDE.md`** : `architect` mesure « les écarts au CLAUDE.md »,
  `/flow:audit` non. Le fichier absent ne doit faire échouer ni l'un ni l'autre.
- **Projet sans code exécutable** — ce dépôt lui-même : « fonctions les plus
  longues » ou « dépendances circulaires » n'ont aucun sens sur du markdown. La
  mesure doit rendre « sans objet », jamais une erreur ni une liste vide muette.
- **`architect` convoqué seul par `/flow:verify`** : il doit continuer à savoir
  quoi mesurer, sans que `/flow:audit` le lui ait dit.
- **Un des trois agents qui ne rend rien** : l'audit doit le signaler, pas
  l'omettre — c'est sa section « ce que cet audit n'a pas pu voir ».

## Risques et inconnues

- **La décision de fond n'est pas prise, et c'est elle qui coûte.**
  `/flow:audit` mesure lui-même, ou il délègue à `architect`. Déléguer allège la
  commande mais la rend dépendante d'un agent ; mesurer soi-même garde la main
  mais duplique. À `/flow:design` de trancher — c'est le vrai travail du lot.
- **`/flow:audit` n'a jamais été lancé, sur aucun projet** — aucun rapport
  d'audit nulle part. On corrige une commande dont personne n'a constaté le
  comportement réel : ce qui paraît en double sur le papier pourrait servir.
- **`architect` sert trois commandes** — `/flow:design` (contexte A),
  `/flow:verify` et `/flow:audit` (contexte B). Toute modification le touche des
  trois côtés, dont deux hors sujet ici.
- **Hypothèse retenue :** un seul horizon suffit, sa valeur — trois mois ou six
  — étant fixée à la conception. Si tu tiens à l'un des deux, dis-le.
