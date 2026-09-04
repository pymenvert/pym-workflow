# Reste à faire

Ce que l'on sait imparfait, et qui n'a pas encore été corrigé.

Ce fichier fait autorité sur ce qui est **ouvert**. Les décisions de structure
vivent dans `docs/decisions/`, les cadrages dans `docs/specs/`. Ne rien
dupliquer entre les trois.

Dernière mise à jour : 4 septembre 2026, après la porte de la tâche
« portabilité Ubuntu ».

---

## Défauts constatés

### Le plugin n'a aucune vérification sur lui-même

C'est le point de rupture, et l'agent `architect` a tranché sans hésiter : ce
dépôt est passé de 3 à 11 commandes en huit jours, et **100 % des défauts
relevés aujourd'hui étaient détectables mécaniquement**. Un plugin qui prêche
« une porte qui a le droit de dire non » et n'en a aucune sur lui-même.

Cinq contrôles suffiraient, dans un script et un workflow d'une soixantaine de
lignes : le bloc partagé identique à l'octet dans les dix fichiers qui le
portent · chaque commande citée dans le README · chaque agent doté d'une ligne
`tools:` · les deux JSON valides et la version bumpée par rapport à `main` ·
chaque chemin relatif du README existant réellement.

Mesuré : ces cinq contrôles attrapent **six des huit défauts** trouvés ce jour.

### `ux-reviewer` peut écrire dans le code

`plugins/flow/agents/ux-reviewer.md` est le seul agent sans ligne `tools:`.
`architect`, `code-reviewer` et `test-engineer` déclarent tous
`tools: Read, Grep, Glob, Bash`. Sans cette ligne, l'agent hérite de tout,
`Edit` et `Write` compris — donc **le seul agent à qui son propre prompt
interdit de commenter le code source est le seul qui peut le réécrire**.

### La commande `format` du Profil projet n'est spécifiée nulle part

Aucun fichier ne dit si `format` **écrit** ou **vérifie**, et les deux lectures
cassent une règle :

- si elle écrit, `verify.md:17` devient faux (« lancer les checks ne modifie
  rien ») et un formateur qui écrit ne rend jamais d'échec — il sera toujours
  vert, donc jamais contraignant ;
- si elle vérifie, rien n'est formaté et le README promet plus qu'il ne tient.

C'est le défaut que la décision `0001` reproche au hook supprimé — déplacé, pas
résolu. Correction estimée : deux phrases, dans `init-project.md:31` et
`verify.md:17-23`.

### `/flow:guide` ne voit pas un dépôt laissé ouvert depuis une autre machine

Le témoin `.git/flow-depot-ouvert` vit dans un clone. Ouvrir le dépôt depuis
Windows puis reprendre depuis la tour Ubuntu rend `guide` aveugle : il dira
« rien en cours » alors que le dépôt est public.

`/flow:release` a été corrigé le 4 septembre — il interroge désormais GitHub, la
seule source qui détienne la vérité. `guide`, lui, ne le fait pas encore : un
appel `gh repo view --json visibility` fermerait le trou, au prix d'un appel
réseau dans une commande vendue comme gratuite. À arbitrer.

### `/flow:audit` et l'agent `architect` se recouvrent

`audit.md:24` recopie presque mot pour mot la liste de mesures de
`architect.md:26-33`, puis `audit.md:40` lance `architect` pour refaire la même
mesure — sur la commande la plus chère du lot. Et la question centrale existe en
double avec **deux horizons contradictoires** : « dans six mois » côté audit,
« dans trois mois » côté architecte.

### Le README paraphrase les onze commandes à la main

197 lignes qui redonnent le bloc « Profil projet » dans une seconde forme,
redécrivent les trois arrêts, les quatre agents, le coût de `/flow:verify`.
Chaque modification d'une commande exige une retouche du README que rien
n'impose — et quatre écarts avaient déjà été mesurés après huit jours.

C'est le fichier le plus coûteux à maintenir, parce que c'est le seul endroit où
un non-développeur relit comment fonctionne son propre outil : quand il est
faux, il n'y a pas de seconde source.

---

## Chantiers en pause

Aucun.

---

## Angles morts

### Le plugin n'a jamais tourné sur Ubuntu

Tout ce qui a été fait pour la portabilité est vérifié **sur Windows
uniquement**. Le critère 1 de `docs/specs/plugin-sur-ubuntu.md` — aucune erreur
ni avertissement à l'usage — ne peut être constaté que sur la tour.

### `sudo apt install gh` n'a pas été vérifié

Le README recommande cette commande pour l'installation sur Ubuntu. Ni la
disponibilité ni la fraîcheur du paquet dans les dépôts de la version d'Ubuntu
de la tour n'ont été contrôlées. Le dépôt apt officiel de GitHub est le recours
documenté si le paquet manque ou est trop ancien.

### Ce dépôt n'a ni `CLAUDE.md` ni bloc « Profil projet »

Conséquence directe et fâcheuse : `/flow:guide` lancé ici conseillera
`/flow:init-project`, qui tentera d'installer une infrastructure de tests et une
chaîne d'intégration de stack sur un dépôt fait de markdown. À traiter en même
temps que la vérification du plugin sur lui-même.

---

## Relevés datés

### 4 septembre 2026 — portabilité Ubuntu

Retrait du hook de formatage (décision `0001`), 16 reformulations dans 12
fichiers, README et `marketplace.json` remis à jour, version `0.11.0`.

Corrigé pendant la porte, à la demande des agents : `docs/` n'était pas suivi
par git alors que le README y renvoie · quatre décomptes faux dans le README
(« six commandes » pour onze, « deux commandes » pour quatre) ·
`/flow:visibilite` n'était documentée nulle part alors que c'est la seule
commande qui expose irréversiblement un historique · `/flow:init-project`
manquait à la description de la marketplace · `/flow:release` se fiait à un
témoin local pour juger si un dépôt était resté public.
