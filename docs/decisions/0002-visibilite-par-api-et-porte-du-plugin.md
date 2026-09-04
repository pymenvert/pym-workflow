# 0002 — Basculer la visibilité par l'API, interroger GitHub dans `/flow:guide`, et donner une porte au plugin

Décidé le 4 septembre 2026. Spec : `docs/specs/plugin-sur-les-deux-machines.md`.
Conception attaquée par six angles indépendants, dont l'agent `architect` ;
douze objections passées ensuite à une réfutation adverse. Ce fichier ne garde
que ce qui a survécu.

## Contexte

La décision `0001` a rendu le plugin *installable* sous Linux. Elle ne l'a pas
rendu *utilisable* : la portabilité n'a jamais été vérifiée ailleurs que sur
Windows, et le premier essai réel sur la tour Ubuntu a fait tomber
`/flow:visibilite` — la seule commande du plugin aux effets irréversibles.

Trois faits mesurés le 4 septembre, sur la tour (`gh` 2.45.0, paquet
`noble/universe`) :

1. La sous-commande d'édition de dépôt de `gh` exige, **depuis la v2.61.0**
   (7 novembre 2024, PR `cli/cli#9845` fusionnée le 30 octobre), un drapeau de
   confirmation pour changer la visibilité en mode non interactif. Vérifié par
   `git compare` : `v2.60.1` est *ahead* du commit, `v2.61.0` est *behind*.
2. **Avant** la v2.61.0, ce drapeau n'existe pas et fait échouer l'appel sur un
   drapeau inconnu. Les deux versions exigent donc des appels **différents**.
3. Il n'y a pas d'invite à craindre sur l'ancienne version : le code de
   `edit.go` en v2.45.0 n'active le mode interactif que si **aucun** drapeau
   n'est passé (`cmd.Flags().NFlag() == 0`).

La question n'était donc pas « faut-il mettre `gh` à jour » : aucune version
unique ne satisfait les deux machines, et celle du poste Windows reste inconnue.

## Options envisagées

**Détecter la capacité et construire l'appel.** `gh repo edit --help | grep -c`
le nom du drapeau, puis deux chemins d'appel. Coûte un appel local de plus et
laisse deux chemins à maintenir, dont un ne sera jamais exercé sur la machine
où l'on travaille.

**Épingler une version minimale de `gh` et l'exiger.** Reporte le problème sur
l'utilisateur, sur les deux machines, pour une commande qu'il lance trois fois
par an. Et n'empêche pas la panne : elle se déplace vers un message d'erreur.

**Passer par l'API REST.** Un seul appel, identique partout, sans drapeau de
confirmation. C'est l'option retenue — voir ci-dessous.

Pour la détection d'un dépôt resté ouvert depuis l'autre machine, deux options
se sont opposées :

**Déclarer l'intention dans le Profil projet** (`- visibilité attendue :
privée`), pour ne payer l'appel réseau que sur les dépôts censés être privés.
**Écartée**, et c'est le renversement le plus net de cette conception. Quatre
angles l'ont attaquée séparément et le compromis qui la justifiait n'existe
pas : le budget de `/flow:guide` se compte en **appels d'outils**, pas en
secondes — « chaque appel relit toute la conversation, c'est là que part
l'argent » — et l'appel à GitHub se replie dans la ligne groupée **déjà
présente**. Coût marginal réel : **zéro appel d'outil**, un tiers de seconde de
latence. En face, la ligne déclarative achetait : une source de vérité non
vérifiée, absente de 100 % des dépôts existants, désynchronisable, en retard
d'une fusion — précisément pendant la fenêtre de travail qu'elle devait
couvrir —, et une troisième copie du bloc « Profil projet » dans le dépôt.

**Interroger GitHub à chaque fois, sans condition.** Retenue.

## Décision

**1. `/flow:visibilite` bascule par l'API REST**, sous une forme littérale :

    gh api --method PATCH "repos/{owner}/{repo}" -f visibility=private -q .visibility

`{owner}` et `{repo}` ne sont pas des gabarits : `gh` les substitue lui-même
depuis le dépôt courant. C'est ce qui répare le défaut le plus vicieux trouvé
par l'attaque — un nom court passé à `gh api` rend `404 Not Found` sur un dépôt
qui existe, c'est-à-dire le pire message possible pendant que le dépôt est
resté public. `-q .visibility` n'est pas cosmétique : sans lui, l'API déverse
6 000 octets de JSON à l'endroit exact où l'auteur doit lire un seul mot.

Trois règles écrites dans la commande, chacune pour une panne constatée : l'API
répond en minuscules quand `gh repo view` répond en majuscules · `gh api` écrit
ses erreurs sur la sortie standard sous une forme qui ressemble à une réponse
normale, donc **seul le code de sortie fait foi** · un droit insuffisant remonte
en `404`, pas en « accès refusé ». La branche « Fermer » gagne la sortie
anticipée « déjà privé » que « Ouvrir » avait déjà, et un refus explicite sur
un dépôt `internal`, qu'un aller-retour transformerait silencieusement en privé.

**2. `/flow:guide` demande la visibilité à GitHub, dans sa ligne groupée
existante**, et applique trois règles : `PRIVATE` → silence · `PUBLIC` avec
témoin → alarme en tête, avec le motif et la date que porte le témoin ·
`PUBLIC` sans témoin → **mention neutre**, pas alarme. Le témoin
`.git/flow-depot-ouvert` est rétrogradé par écrit : il dit *pourquoi* et
*depuis quand*, GitHub dit *si*. En cas de contradiction, GitHub tranche. Et si
l'appel ne rend rien — pas de dépôt distant, `gh` absent, pas de réseau —,
`/flow:guide` **continue** : il est le recours de dernière instance, il n'a
jamais le droit de s'arrêter en erreur.

**3. La commande `format` du Profil projet vérifie, elle n'écrit pas.** Trois
angles sur quatre, et l'argument est mécanique : `verify.md` autorise à lancer
les checks sans rien demander *parce qu'ils ne modifient rien*, et cette
autorisation vaut **avant** que la question de la branche soit tranchée. Un
formateur qui écrit déposerait des modifications sur la branche par défaut sans
accord, à l'étape 1 de la porte censée l'interdire — et ne rendrait jamais
rouge, occupant une ligne du tableau en étant vert par construction. La variante
qui écrit reste lancée quand `format` est rouge, mais en tant que **correction**.

**4. Le plugin reçoit sa propre porte** : `scripts/verifier-le-plugin.sh`, neuf
contrôles en sh POSIX, déclaré comme commande `test` du Profil projet et rejoué
à l'identique par `.github/workflows/ci.yml`. Il lance les neuf avant de
conclure plutôt que de s'arrêter au premier rouge, et distingue `IGNORÉ` de
vert et de rouge — un contrôle qui crie faux dès sa naissance est désactivé dans
la semaine.

`.gitattributes` impose LF aux `.sh`, `.md`, `.json` et `.yml`. Sans lui,
l'installeur Git for Windows convertit à la récupération et le script ne
démarre pas sous Git Bash — sur la seule machine qu'il est censé prouver.

## Conséquences

**Ce que ça facilite.** Un seul appel de bascule, valable sur toute version de
`gh` : la matrice de versions disparaît au lieu d'être gérée. Un dépôt ouvert
depuis un poste est vu depuis l'autre, sans configuration, sur **tous** les
dépôts et pas seulement ceux qu'on aurait pensé à annoter. Et huit des défauts
listés dans `reste-a-faire.md` deviennent détectables mécaniquement.

**Ce que ça rend plus difficile.** `/flow:guide` dira « ce dépôt est public »
sur un dépôt volontairement public — cinq des onze le sont. C'est une ligne de
texte, assumée contre une mécanique déclarative d'un ordre de grandeur plus
chère. Si elle agace à l'usage, la ligne du Profil projet reviendra comme
**silencieux d'alerte** : elle aura le droit de rétrograder une alarme en
mention, jamais d'empêcher la question d'être posée.

**Ce qu'on s'interdit.** Employer, dans une commande, une capacité de `gh`
apparue dans une version récente sans l'avoir vérifiée sur les deux machines.
Le contrôle 8 du vérificateur interdit désormais la sous-commande d'édition de
dépôt dans `plugins/flow/commands/`, dans les deux formes cassées à la fois.

**Le critère 2 de la spec devient sans objet, et il faut le dire.** Il
demandait qu'une commande s'arrête proprement sur un `gh` trop ancien. La
décision 1 supprime le cas au lieu de le gérer : il n'y a plus de capacité
récente employée nulle part. Le critère est satisfait **par élimination**, pas
par construction — et la prochaine commande qui emploiera une capacité récente
le fera renaître intact.

## Ce qui n'est pas prouvé, et qu'il ne faut pas prétendre l'être

**La transition de visibilité elle-même n'a pas été constatée.** Ce qui a été
mesuré, le 4 septembre sur la tour, en `gh` 2.45.0 :

- `gh api --method PATCH "repos/{owner}/{repo}"` sans corps rend `400 Body
  should be a JSON object` — donc la substitution des accolades, l'authentifi-
  cation et la portée du jeton fonctionnent, et l'endpoint est le bon ;
- `gh api --method PATCH "repos/{owner}/{repo}" -f visibility=public
  -q .visibility` rend `public`, code de sortie 0 — donc le champ `visibility`
  est accepté et l'écriture aboutit ;
- l'état du dépôt est **strictement identique** avant et après cet appel
  (visibilité, description, sujets, archivage, wiki, tickets, forks, branche
  par défaut) : aucun effet de bord.

Cette dernière mesure n'est concluante que parce que le dépôt était **déjà
public** : c'est une écriture de la même valeur, donc une transition nulle. Un
aller-retour réel `public → private → public` n'a pas été fait, délibérément —
rouvrir un dépôt est l'acte irréversible que cette commande existe pour
encadrer, et il n'appartient pas à un assistant de le déclencher seul.

**Reste donc à constater** : que `visibility=private` bascule effectivement, et
que la protection de branche survit à l'aller-retour. Sur ce dépôt la question
de la protection ne se pose pas aujourd'hui — `main` n'en a aucune (`404 Branch
not protected`) — mais elle se posera sur un dépôt qui en a une.

**Le comportement sous Windows n'est pas constaté non plus.** Aucun des
changements ci-dessus n'a tourné sur le poste Windows, et sa version de `gh`
reste inconnue. C'est précisément pour ça que rien, désormais, ne dépend d'une
version.

## À ne pas repayer si l'idée revient

- **`gh repo edit --visibility`** — cassé des deux côtés, pour deux raisons
  opposées : drapeau inexistant avant 2.61.0, drapeau obligatoire à partir de
  2.61.0. Ce n'est pas un problème de version à corriger, c'est une commande à
  ne pas employer.
- **Un nom court, ou une URL, passé à `gh api`** — `gh repo view` les résout,
  `gh api` non : `404` sur un dépôt qui existe.
- **Déclarer l'intention de visibilité dans un fichier du dépôt** — mesuré :
  aucune ligne dans aucun des dépôts, cinq dépôts sur onze légitimement
  publics, et un retard d'une fusion exactement pendant la fenêtre utile.
  L'appel réseau qu'elle voulait éviter coûte zéro appel d'outil.
- **Une matrice CI Windows** — coûte le double de minutes sur un dépôt privé et
  prouve le shell d'un runner GitHub, pas celui de la machine de l'auteur.
  `.gitattributes` donne la même garantie, en trois lignes lisibles.
- **Un contrôle qui interdit un drapeau plutôt qu'une commande** — laisse
  passer la moitié des régressions, dont la plus probable : quelqu'un qui
  « simplifie » en retirant le drapeau.

Le motif commun des cinq : **on avait mesuré que l'appel partait, pas qu'il
faisait ce qu'on croyait.** Toute décision future sur cette commande devrait
commencer par distinguer les deux.
