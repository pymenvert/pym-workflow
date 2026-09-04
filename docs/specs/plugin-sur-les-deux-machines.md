# Le plugin doit tenir ses promesses sur les deux machines

Cadré le 4 septembre 2026. Suite de `plugin-sur-ubuntu.md`, qui a rendu le
plugin *installable* sous Linux ; celle-ci le rend *utilisable*.

## Problème

La portabilité du plugin n'a jamais été vérifiée ailleurs que sur Windows. Sur
la tour Ubuntu, `/flow:visibilite` échoue dans les deux sens : le `gh` livré par
les dépôts Ubuntu (2.45.0) ne connaît pas le drapeau
`--accept-visibility-change-consequences` que la commande emploie aux lignes 36
et 48. Le dépôt `pym-workflow` est public à cet instant précis, et la commande
censée le refermer est justement celle qui ne fonctionne pas ici.

## Usage

Un développeur solo, non spécialiste, qui travaille tantôt depuis sa machine
Windows, tantôt depuis la tour Ubuntu, sur les mêmes dépôts. Il attend des onze
commandes `/flow:*` le même comportement des deux côtés — et surtout qu'aucune
ne lui annonce un succès qu'elle n'a pas obtenu.

## Critères d'acceptation

1. Étant donné la tour Ubuntu et un dépôt privé, quand je lance
   `/flow:visibilite ouvrir` puis `/flow:visibilite fermer`, alors
   `gh repo view --json visibility` rend `PUBLIC` puis `PRIVATE`, et la sortie
   brute m'est montrée à chaque fois.
2. Étant donné une machine dont le `gh` est trop ancien pour une opération
   demandée, quand une commande `/flow:*` en a besoin, alors elle s'arrête et
   me dit la version trouvée, la version nécessaire et la marche à suivre —
   elle ne prétend jamais avoir réussi.
3. Étant donné un dépôt ouvert au public depuis la machine Windows, quand je
   lance `/flow:guide` depuis la tour, alors il m'annonce le dépôt ouvert avant
   toute autre chose, bien qu'aucun témoin local n'existe de ce côté.
4. Étant donné ce dépôt-ci, fait de markdown et sans stack, quand je lance
   `/flow:guide` dessus, alors il ne me conseille pas `/flow:init-project`.
5. Étant donné une session démarrée sur la tour avec le plugin installé, quand
   j'écris ou modifie un fichier, alors aucun avertissement n'apparaît.
6. Étant donné les commandes modifiées par cette tâche, quand je les relance
   depuis la machine Windows, alors leur comportement y est inchangé.

## Hors périmètre

- **Le hook de formatage.** La décision `0001` l'a retiré ; on ne le remet pas.
- **Les défauts indépendants de la machine**, déjà consignés dans
  `reste-a-faire.md` : la vérification du plugin sur lui-même, le README qui
  paraphrase les commandes, le recouvrement `/flow:audit` ↔ `architect`, la
  ligne `tools:` manquante d'`ux-reviewer`, la commande `format` non spécifiée.
  Réels, mais ils ne concernent ni Ubuntu ni Windows. Dis-moi « élargis » si tu
  veux les prendre dans le même lot.
- **Installer une stack sur la tour** — Node, un formateur, un lanceur de tests.
- **macOS**, et toute machine autre que ces deux-là.

## Cas limites

- **`gh` absent de la machine** : la commande le dit et donne la commande
  d'installation, elle ne tente rien.
- **`gh` présent mais non authentifié**, ou **sans réseau** : arrêt net, message
  qui distingue les deux cas — un dépôt dont on ignore l'état n'est pas un
  dépôt fermé.
- **Dépôt déjà dans l'état demandé** : ne rien faire, et le dire.
- **Interruption entre l'ouverture et la fermeture** (conversation fermée,
  machine éteinte) : la reprise, depuis n'importe laquelle des deux machines,
  doit retrouver que le dépôt est ouvert.
- **Deux clones du même dépôt sur la même machine** : un témoin posé dans l'un
  ne doit pas faire croire à l'autre que tout va bien.

## Risques et inconnues

- **Le comportement de `gh repo edit --visibility` sans le drapeau, en 2.45.0,
  n'est pas connu.** Il peut réclamer une confirmation au clavier, qu'une
  commande automatisée ne saura pas donner. À mesurer avant toute décision :
  c'est l'inconnue qui peut changer entièrement la forme du travail.
- **La version de `gh` sur la machine Windows n'a pas été relevée.** Le même
  défaut peut y dormir.
- **Mettre `gh` à jour sur la tour demande `sudo`** et modifie les sources de
  paquets du système. Ce n'est pas un changement de code, c'est un changement
  de machine — avec ce qu'il implique de dépendance silencieuse.
- **Ce dépôt n'a pas de `CLAUDE.md`.** Toutes les commandes qui lisent le bloc
  « Profil projet » travaillent à l'aveugle quand on les lance sur lui.
