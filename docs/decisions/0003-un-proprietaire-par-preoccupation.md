# 0003 — Un propriétaire par préoccupation, réparti par objet et non par terme

Décidé le 4 septembre 2026. Spec : `docs/specs/passe-sur-les-quatre-agents.md`,
qui absorbe `docs/specs/audit-et-architect-en-double.md`.

Conception attaquée par cinq angles indépendants, dont l'agent `architect` ;
dix-huit objections passées ensuite à une réfutation adverse, dix retenues. Ce
fichier ne garde que ce qui a survécu — trois pans de la conception initiale
sont tombés, et c'est le plus utile de ce qui est écrit ici.

## Contexte

Cinq préoccupations n'avaient pas de propriétaire. Mesuré : « duplication » dans
`code-reviewer`:17, `architect`:30 **et** `audit`:24 · « code mort » dans deux
fichiers, plus une paraphrase dans le troisième · « doublure » dans
`test-engineer`:22 et `audit`:28 · les cas limites dans deux agents · la sécurité
dans `code-reviewer`:14 **et** dans `/security-review` que `verify.md`:42 lance
à côté.

Symétriquement, rien ne couvrait ce qui fait la qualité des logiciels de
l'auteur : des outils de spectacle vivant, livrés en exécutables, qui tournent
en régie **pendant** une représentation.

Coût de départ, relevé avant toute modification : **~794 tokens toujours actifs**
pour le plugin, dont **~320 pour les quatre agents** ; ~4,95k de plus si les
quatre sont convoqués.

## Options envisagées

**Un cinquième agent** pour la tenue en conditions réelles et la distribution.
Écarté : les deux préoccupations sont de **même nature** que ce que possèdent
déjà `test-engineer` (interruption en plein milieu, appels répétés, ordre
inattendu → panne matérielle en direct) et `ux-reviewer` (ce que l'utilisateur
rencontre → ce que l'opérateur voit quand ça casse). Un agent de plus aurait
séparé des choses qui se pensent ensemble. Le coût en tokens est un argument
d'appoint, pas le motif — l'attaque a montré à juste titre que le dépôt ne s'est
jamais donné de budget en tokens, et le brandir ici aurait été un critère inventé
pour l'occasion.

**Répartir par terme** — chaque mot appartient à un agent, les autres n'y
touchent plus. Écarté après mesure : `code-reviewer` est le **seul agent convoqué
à chaque porte** (`verify.md`:37, « toujours ») ; les trois autres sont
conditionnels. Lui retirer « duplication » et « code mort » aurait supprimé toute
détection de duplication sur la majorité des passages, au profit d'un agent qui
ne tire que « dès qu'un fichier a été créé, déplacé, ou a nettement grossi ».

**Répartir par objet.** Retenue.

## Décision

**1. Le partage se fait par objet, pas par vocabulaire.** Deux agents peuvent
regarder la duplication : ils ne regardent pas la même.

| Préoccupation | Objet | Propriétaire |
|---|---|---|
| duplication, code mort | **ce que ce diff introduit** | `code-reviewer` |
| duplication, code mort, couplage, dérive | **le dépôt entier** | `architect` |
| catalogue des cas limites | la couverture de tests | `test-engineer` |
| doublures / jamais confronté au réel | idem | `test-engineer` |
| l'interface **rendue** — qui n'existe qu'une fois le logiciel lancé | — | `ux-reviewer` |
| les **textes** que le diff introduit (messages, libellés) | le diff | `code-reviewer` |
| secrets et injections **visibles dans le diff** | le diff | `code-reviewer` |
| analyse de sécurité **approfondie** | à la demande | `/security-review` |

`/flow:audit` cesse de recopier la liste de mesures (`audit`:24) et renvoie à
`architect`, dont l'horizon — trois mois — devient le seul.

**2. Quatre agents, deux couvertures nouvelles.** `test-engineer` gagne la tenue
en conditions réelles : appareil qui disparaît en cours de route, latence, rejeu,
reprise **sans redémarrage**. `ux-reviewer` gagne ce que l'opérateur voit et peut
faire quand ça casse en direct — arrêt d'urgence, lisibilité en pénombre, reprise
sans relancer — et la première exécution sur une machine où rien n'est installé.

**3. `ux-reviewer` a le droit de ne pas pouvoir.** Il est le seul dont un rapport
court signifie « je n'ai pas pu regarder » et non « je n'ai rien trouvé ». Ce
n'est plus un silence : c'est un verdict à rendre explicitement, et `/flow:verify`
doit le porter dans sa section « non vérifié ». Sa convocation s'étend à ce qui
**construit** l'exécutable (script d'empaquetage, assets embarqués), pas
seulement à l'interface visible.

**4. Deux gardes mécaniques, les contrôles 11 et 12.** Table
`terme → propriétaire` dans le script. Le terme doit exister chez son
propriétaire, hors de son bloc « Ce que tu ne fais pas » ; ailleurs, il n'est
toléré que dans une **phrase** qui cite le propriétaire entre accents graves. Le
contrôle 12 exige que ce bloc existe chez chaque agent — sans lui, la règle de
présence du 11 n'aurait plus rien à exclure et redeviendrait une passoire.

**La maille est la phrase, pas la ligne.** Exempter la ligne entière laissait
greffer un doublon sur la ligne même du renvoi — mesuré sur `audit.md`:24 — et
laissait passer une phrase qui cite le propriétaire pour ordonner le contraire.
Découper sur les points ferme les deux.

**Le périmètre se calcule.** Il couvre les agents et les seules commandes qui
convoquent un relecteur — sept fichiers sur quinze. Les autres emploient ces mots
en prose ordinaire : `mutation.md` parle de code « mort » tout à fait
légitimement, et un périmètre écrit en dur l'aurait rougi.

Deux corrections que l'attaque a rendues obligatoires, chacune mesurée :

- **Le périmètre est `agents/` ET `commands/`.** Aveugle aux commandes, la garde
  ratait trois doublons sur cinq — dont celui d'`audit.md` qui a motivé la spec.
  Mesuré : agents seuls → 2 rouges, agents + commandes → 5. `docs/` est exclu, et
  doit l'être : la spec et ce fichier emploient les quatre termes en prose. Même
  motif que le contrôle 8, déjà écrit dans le script.
- **Le renvoi se reconnaît aux accents graves.** Sans eux, « duplication d'une
  **architecture** inutile » passe pour un renvoi à `architect` — reproduit. La
  parade existe déjà dans le script (`cite_entier`, né du cas `/flow:mutationX`).

## Conséquences

**Ce que ça facilite.** Une préoccupation ne peut plus se dédoubler en silence :
la garde le refuse, et le banc de mutation le prouve. Les deux préoccupations qui
décident de la qualité d'un logiciel de scène entrent dans la porte sans agent
supplémentaire ni convocation de plus.

**Ce que ça rend plus difficile.** Écrire un renvoi demande désormais une forme :
le nom du propriétaire, entre accents graves, **sur la même ligne** que le terme.
Un renvoi coupé sur deux lignes ne compte pas — c'est la limite assumée d'une
garde qui lit des lignes, et la rédaction du dépôt doit s'y plier.

**Ce qu'on s'interdit.** Reprendre un terme possédé sans nommer son propriétaire.
Et ajouter un cinquième agent sans avoir montré que la préoccupation n'est de la
nature d'aucun des quatre.

## Ce que cette garde ne rattrapera pas

**Une reformulation.** `audit.md` paraphrase déjà « code mort » en « code exporté
jamais utilisé » : aucun grep par termes ne l'attrape, ni dans le périmètre des
agents, ni dans celui des commandes. Le compte honnête est que la garde couvre
**quatre des cinq recouvrements**, pas cinq. Un contrôle de plus ne réglerait pas
ça — seule une relecture le peut.

**Ce qui reste vrai malgré la maille phrase.** La garde vérifie une **forme** —
le propriétaire cité entre accents graves dans la phrase — pas un sens. Elle
attrape le doublon qui revient par distraction, pas celui qu'on écrirait exprès
en glissant le nom du propriétaire dans la bonne phrase. Ne pas la prendre pour
une relecture.

**Un renvoi coupé sur deux lignes.** Sondé : rouge. La rédaction du dépôt doit
tenir le terme et le nom du propriétaire dans la même phrase, sur une ligne.

**Les deux préoccupations neuves.** La table ne garde que des sujets anciens ;
« tenue en conditions réelles » et « première exécution » n'ont pas de terme
protégé. Elles peuvent donc se dédoubler demain sans que rien ne le dise.

**Et surtout : aucun de ces agents n'a jamais été mesuré à l'usage.** On répartit
des rôles sans savoir lequel trouve réellement des défauts. C'est l'inconnue la
plus sérieuse de cette décision, et elle ne se lèvera qu'après plusieurs tâches
réelles.
