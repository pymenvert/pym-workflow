# 0005 — Le journal, une ligne par événement ; le bilan de santé à la version

Décidé le 5 septembre 2026. Spec : `docs/specs/journal-incident-et-bilan-de-sante.md`,
lot 2 de `docs/plan-studio.md`.

Conception attaquée par l'agent `architect` : cinq bloquants, neuf dettes, une
réorganisation à faire. Tout a été retenu. Les cinq bloquants ne changent pas le
cap ; ils changent ce que le journal saura dire de vrai.

## Contexte

Aucune décision sur les relecteurs n'a été prise avec des données, et les relevés
datés du registre en font déjà un journal en prose. Un défaut corrigé n'a nulle
part où laisser sa cause, et rien ne compte ce qui se répète. Le plan (section
11) veut un journal à coût nul, écrit par les commandes, lu par l'audit ; et
l'audit redéfini en bilan de santé, à la version (section 7).

Contraintes : le vérificateur est gelé · `audit.md` et `verify.md` sont des
commandes arbitres du contrôle 11 · les commandes ne partagent que le bloc de
fin, identique dans dix fichiers · deux machines, dont une sous Git Bash, avec
l'awk d'Ubuntu (mawk) d'un côté.

## Options envisagées

**Un journal structuré (JSON, une base).** Écarté : personne ne le lirait à
l'œil, et une commande de plus à installer. Une ligne Markdown par événement se
lit sur GitHub et se compte avec `awk`.

**Le lien de la pull request dans la ligne `livraison`.** Écarté. Le lien
n'existe qu'après le premier push ; l'écrire ensuite exige un second commit et
fait tourner la CI deux fois par tâche — des minutes doublées, payantes, sur les
apps du lot 7. GitHub garde le lien à vie (`gh pr list --head <branche>`), et ce
dépôt a déjà tranché que GitHub est la vérité pour ce qui vit chez lui (décision
`0002`). La ligne s'écrit **avant le commit** : branche, tâche, ce que ça change.
Coût : le journal n'est pas cliquable ; le plan (section 11) disait « lien ».

**La ligne `incident` seulement à la correction.** Écarté : sur les apps de
régie, sans simulateur avant le lot 8, « non reproductible » sera le cas courant,
et l'indicateur qui compte — incidents par version — aurait sous-compté
exactement les pannes graves.

**Relancer le bilan complet à chaque version.** Écarté : un bilan qui trouve
quelque chose à corriger renvoie à une tâche, une fusion, une conversation neuve
— et un second bilan complet, trois relecteurs sur le projet entier.

## Décision

**1. Le journal : `docs/journal.md`, une ligne par événement, ajoutée en fin de
fichier par `cat >>`, jamais réécrite.** Champs séparés par « · » ; à l'intérieur
d'une case, ni « · » ni retour à la ligne — un « ; » les remplace. La date d'abord
(AAAA-MM-JJ), le type ensuite, puis l'objet ; les cases suivantes portent une
étiquette (« checks : », « bloquants : », « cause : »). **Une case neuve s'ajoute
en fin de ligne avec son étiquette ; une étiquette inconnue est ignorée ; les
types ne font que croître.** C'est la règle qui évite de migrer onze journaux au
lot 4 ou au lot 8. Un champ inconnu s'écrit « ? » : une case vide, pas une valeur
— ~~la remplir n'est pas réécrire~~ (amendé le 5 septembre, voir plus bas : on
ajoute une ligne, on ne remplit pas).

**2. Quatre types.** `porte` (checks, bloquants réels par relecteur, non vérifié,
durée, jetons) · `livraison` (branche, tâche, ce que ça change) · `incident`
(quoi, cause, leçon) · `version` (numéro, bilan en une phrase). Un relecteur
convoqué vaut `N`, `0` ou `?` — « ? » quand il n'a pas pu regarder, jamais
confondu avec 0 ; un relecteur non convoqué est absent de la case.

**3. L'incident s'écrit au premier arrêt**, sur la branche `fix/` déjà créée,
avec « ? » pour la cause et la leçon ; ~~la correction remplit les « ? »~~ (amendé
le 5 septembre, voir plus bas : la correction ajoute une seconde ligne). Le mode
incident se déclenche sur un critère tranché après lecture — un comportement qui
existait a cessé, ou un plantage —, pas sur la forme de la phrase. Sur un projet
sans tests, il pose l'infrastructure minimale lui-même, comme
`/flow:init-project`, plutôt que de renvoyer l'auteur la veille d'un spectacle.

**4. L'audit calcule par case étiquetée, avec une seule commande écrite dans
`audit.md`**, qui tourne sous mawk et gawk ; les noms de relecteurs sont lus
dans les lignes, jamais écrits en dur. Les incidents d'une version se comptent
**par date** — depuis la date de la dernière étiquette —, pas par position dans
le fichier : une branche fusionnée après la version y déposerait sa ligne après.
Un « 0 » ne se lit qu'avec les incidents de la même période. `audit.md` est
réorganisé en trois sections fixes — ce qu'il lit, ce qu'il calcule, qui il
convoque — où les lots 3, 4 et 10 ajouteront chacun une ligne.

**5. À la version, `/flow:release` lance le bilan ; s'il trouve à corriger,
c'est une fin, pas un arrêt** : « Ensuite : `/flow:new-feature <item> »`. À la
version suivante, si le registre porte un bilan daté d'après la dernière
étiquette et que ses « à corriger » sont fermés, release ne convoque pas les
relecteurs : l'audit confronte seulement. La ligne `version` s'écrit avant
l'étiquette, dans le commit de version. Le numéro est annoncé, pas demandé.
`/flow:mutation` est proposée pour après, pas lancée : ses arrêts ne sont
aucune des quatre raisons, et elle exige un dossier propre — le plan disait
« à la version », ceci le renverse sciemment.

**6. `release` entre dans « Arrêts et suite »**, ce que la `0004` lui refusait :
son seul arrêt est l'étiquette (raison 3) ; dossier encombré, CI rouge ou absente
sont des fins. Le commit de version est la seule exception écrite à « jamais
directement sur la branche par défaut ».

**7. Le registre ne reçoit plus de relevé daté.** Les relevés existants restent
lisibles là où ils sont ; ce qui s'est passé va au journal.

## Conséquences

**Ce que ça facilite.** Le rendement des relecteurs et les incidents par version
se comptent en une commande ; la cause d'un défaut a un endroit ; le bilan de
santé a une source ; le registre cesse de grossir.

**Ce que ça rend plus difficile.** La règle d'écriture vit en quatre copies
(verify, ship, new-feature, release) plus un en-tête par dépôt — tenues à la
relecture. Sur `docs/journal.md`, un conflit de fusion entre deux branches est
probable : garder les deux côtés puis trier par date, la date en tête rend le tri
juste. La version coûte un bilan à trois relecteurs, sauf confrontation.

**Ce qu'on s'interdit.** Réécrire le journal · un séparateur dans une case · un
nom de relecteur en dur dans un calcul · compter un « n'a pas pu » comme un 0.

## Amendé le 5 septembre 2026, par le premier bilan de santé

Le §1 disait qu'un « ? » se remplit ; le §3, que la correction remplit la ligne
d'incident. Mesuré dans une copie : une ligne modifiée sur une branche pendant
que la branche par défaut en ajoute une devient, à la fusion, **un doublon** —
deux incidents comptés pour un, et une panne corrigée proposée pour toujours par
le guide. La règle devient : **on n'édite jamais une ligne, on en ajoute une
pour le même objet, et la dernière fait foi** ; l'audit compte les incidents par
objet, à la date de leur première apparition. Et un bilan de santé neuf
**remplace** le précédent au registre, ses « à corriger » non rayés remontant
dans « Défauts constatés » : sans ça, le registre aurait regardé s'accumuler les
relevés que ce fichier voulait en sortir.

## Ce que ces chiffres ne disent pas

Ils sont **auto-déclarés** : le modèle qui accepte, corrige et compte les
bloquants est le même. Ils mesurent l'accord entre la porte et ses relecteurs,
pas la vérité ; et l'attribution est arbitraire quand deux relecteurs signalent
la même chose, recouvrement voulu par objet (décision `0003`). Dix portes
journalisées ne sont pas dix mesures indépendantes — assez pour rendre un
relecteur rare, pas pour le supprimer.
