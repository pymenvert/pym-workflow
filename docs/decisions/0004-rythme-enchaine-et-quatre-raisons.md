# 0004 — Le rythme enchaîné par défaut, et les quatre raisons de s'arrêter

Décidé le 5 septembre 2026. Spec : `docs/specs/rythme-et-pedagogie.md`, lot 1
de `docs/plan-studio.md`.

Conception attaquée par l'agent `architect` : quatre bloquants, six dettes, une
réorganisation à faire. Tout a été retenu, et deux pans de la proposition initiale sont
tombés — c'est le plus utile de ce fichier.

## Contexte

Trois commandes s'arrêtent à chaque tâche : `/flow:spec` après ses questions,
`/flow:design` après sa proposition, `/flow:new-feature` après son plan. Trois
attentes pour des réponses qui, le plus souvent, ne dépendent pas de l'auteur.
Le plan (choix 4) demande le rythme enchaîné par défaut. Et la pédagogie vit
dans les commandes, pas dans les rapports des agents, qui parlent à un
développeur.

Contraintes : dix commandes partagent un bloc de fin identique à l'octet
(contrôle 1) · les termes gardés par le contrôle 11 ne s'écrivent qu'avec leur
propriétaire · le vérificateur est gelé, aucun contrôle neuf sans panne mesurée
(plan, section 12) · aucune commande ne lit un fichier du plugin lui-même · le
seul état commun à toutes les commandes est le `CLAUDE.md` du projet.

## Options envisagées

**La règle d'enchaînement dans le bloc partagé des dix commandes.** Écartée.
Quatre commandes hors du cycle ont des arrêts qui ne sont aucune des quatre
raisons — `mutation.md`:28 et :48, `release.md`:10 et :16 — et le même fichier
aurait dit « ne t'arrête que pour quatre raisons » puis « arrête-toi ici » sans
en nommer une. Pire, dans `visibilite.md`, « charge la suivante » n'aurait eu
qu'un candidat plausible : `/flow:release`, la commande aux effets
irréversibles. Coût de l'alternative retenue : quatre commandes portent un
vocabulaire qu'elles n'emploient qu'en partie.

**Un état de chaîne persistant** — un fichier qui dit où en est la chaîne.
Écarté : ce serait une seconde vérité à côté de git et des fichiers, exactement
le témoin `.git/flow-depot-ouvert` dont il a fallu écrire la précédence
(`guide.md`:44). Coût : une chaîne coupée se reprend par `/flow:guide`, et une
conversation résumée en route redevient du pas à pas de fait.

**Un contrôle mécanique pour « Pour toi » et pour le paragraphe d'arrêts.**
Écarté par le gel du vérificateur. Ces deux formes se tiennent à la relecture.

**`/flow:studio` dès maintenant.** Écarté par le plan : après un constat.

**Retenue :** le vocabulaire dans le bloc partagé, un paragraphe « Arrêts et
suite » propre à chaque commande du cycle, le réglage dans le Profil projet,
aucun état.

## Décision

**1. Le rythme est enchaîné par défaut.** `- rythme : enchaîné | pas à pas`
dans le bloc « Profil projet ». Ligne absente ou valeur inconnue : enchaîné,
dit une fois par conversation. Un mot de l'auteur dans la discussion —
« attends », « pas à pas » — l'emporte sur le profil pour la tâche en cours :
c'est le frein par tâche, sans fichier ni état.

**2. Les quatre raisons de s'arrêter**, seules admises en rythme enchaîné, et
nommées à chaque arrêt : (1) une réponse qui n'appartient qu'à l'auteur — le
besoin, la priorité, l'apparence, « est-ce fini ? » · (2) de l'argent ou un
engagement · (3) un acte irréversible ou public — fusion sur la branche par
défaut, étiquette de version, mise en ligne, visibilité, suppression · (4) une
porte rouge qu'on ne sait pas rendre verte sans changer le besoin. **Le bloc
partagé fait foi** : c'est lui qui s'exécute sur onze dépôts. Ce fichier garde
le pourquoi ; le README paraphrase.

**3. Le bloc partagé définit, chaque commande décide.** Le bloc dit ce que sont
le rythme, les quatre raisons, le point de passage et « lancer la suivante ».
Chaque commande du cycle — spec, design, new-feature, verify, ship, et
init-project pour ses seuls arrêts — porte un paragraphe « Arrêts et suite » :
ses arrêts, chacun avec sa raison numérotée, et la commande qu'elle lance
après. C'est là que les lots 2 à 4 ajouteront une ligne, au lieu de glisser des
conditionnelles entre les étapes.

**4. L'enchaînement ne va que vers l'aval.** Une commande ne charge jamais celle
qui l'a chargée, ni une étape amont : elle la propose. `/flow:ship` ne relance
pas `/flow:verify` s'il vient de rendre PASSE dans la conversation.
`/flow:new-feature` ne demande rien sur le cadrage et la décision que la chaîne
vient d'écrire : il les constate, et ils suivent la branche. Sans ces trois
phrases, la première tâche réelle bouclait ou s'arrêtait sur une question que
la chaîne avait créée elle-même.

**5. Un seul nom pour les trois paragraphes.** « Compte-rendu » — ce que le
logiciel fait maintenant · ce qui a été vérifié ou n'a pas pu l'être · ce qui
reste — clôt `/flow:new-feature`, `/flow:verify` et `/flow:ship`. Le journal du
lot 2 lira une forme, pas trois.

**6. Une pull request sur un dépôt public est un acte public, mais réversible :**
elle se ferme. La chaîne l'ouvre ; la fusion, irréversible, reste à l'auteur.

**7. `/flow:guide <mot>`** : le glossaire de `guide.md` fait foi sur celui du
plan. Dix-sept mots où `flow` a sa doctrine ; les autres s'expliquent en
termes généraux. « Inconnu » veut dire : un mot que le guide ne sait pas
illustrer par un exemple de ce projet — il le dit, et explique quand même.

**8. Aucune économie de jetons n'est affirmée.** Une chaîne fait relire la
conversation à chaque appel d'outil ; le lot économise des relances, pas des
jetons. Le constat du critère 10 relèvera le coût d'une chaîne contre la
dernière tâche pas à pas.

## Conséquences

**Ce que ça facilite.** Une commande, puis lire : le lien de la demande de
fusion arrive avec son compte-rendu. Chaque arrêt dit sa raison. Les lots
suivants étendent un paragraphe par commande.

**Ce que ça rend plus difficile.** « Arrêts et suite » et « Pour toi » sont des
formes tenues à la relecture, pas par un contrôle. Le bloc partagé est chargé
jusqu'à cinq fois par chaîne : il doit rester court.

**Ce qu'on s'interdit.** Enchaîner vers l'amont · un état de chaîne hors git et
fichiers · un contrôle pour une forme de prose · affirmer une économie sans
mesure.

## Ce qui n'est pas prouvé

L'enchaînement lui-même : l'outil qui charge une commande est disponible à
l'assistant en cours de conversation (ce lot a été cadré ainsi), mais aucune
commande n'en a encore lancé une autre. Ni ce que devient une chaîne après
résumé de la conversation, ni son coût. Les trois attendent la première tâche
réelle en rythme enchaîné.
