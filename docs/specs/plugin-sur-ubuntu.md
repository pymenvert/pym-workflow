# Faire tourner le plugin sur la tour Ubuntu

## Problème

Le plugin suppose Windows à trois endroits : le hook de formatage lance
`powershell`, son unique script est écrit en PowerShell, et onze fichiers de
commandes affirment « je travaille dans GitHub Desktop ». Installé tel quel sur
la tour Ubuntu, le hook échouerait à chaque écriture de fichier, et les
commandes décriraient un environnement qui n'existe pas là-bas.

## Usage

Pym travaille sur sa tour Ubuntu comme sur son PC Windows : mêmes dépôts, mêmes
commandes `/flow:*`, même comportement attendu. Il ne veut pas maintenir deux
versions du plugin qui divergeraient au premier correctif.

La tour a un **bureau graphique** et fait tourner **Claude Desktop**, dont la
version Linux existe officiellement depuis juin 2026. Ce qui manque là-bas :
PowerShell, GitHub Desktop — que GitHub ne publie pas pour Linux — et la
fonction qui permet de regarder une **fenêtre d'application native**, absente
de la version Linux. Les interfaces web, elles, restent observables.

## Critères d'acceptation

1. Étant donné la tour Ubuntu où le plugin vient d'être installé, quand
   j'utilise une commande `/flow:*` qui modifie des fichiers, alors aucune
   erreur ni aucun avertissement n'apparaît dans la conversation.
2. Étant donné le plugin installé sur les deux machines, quand on compare les
   numéros de version, alors ils sont identiques : un seul plugin publié, pas
   une variante par système.
3. Étant donné une commande `/flow:*` lancée sur Ubuntu, quand elle m'explique
   une manipulation, alors elle ne me renvoie jamais vers un outil absent de
   cette machine.
4. Étant donné le dépôt `pym-workflow`, qui est privé, quand j'installe la
   marketplace sur la tour, alors la marche à suivre pour l'identification est
   écrite dans le README — le gestionnaire d'identifiants de GitHub Desktop
   n'existant pas sur Ubuntu.
5. Étant donné une modification du plugin faite depuis l'une des deux machines,
   quand elle est publiée, alors l'autre machine la reçoit par la procédure de
   mise à jour habituelle, sans geste particulier.

*Les trois premiers critères portaient sur le comportement du hook de formatage
selon qu'un projet avait adopté ou non un formateur. La décision `0001` retire ce
hook : ils sont devenus invérifiables et se réduisent au critère 1 ci-dessus.*

## Hors périmètre

- **macOS.** La question ne se pose pas aujourd'hui ; l'y étendre serait une
  autre tâche.
- **Installer des formateurs sur la tour.** C'est un geste d'administration, pas
  le travail du plugin.
- **Le `CLAUDE.md` global de la tour.** Il est propre à chaque machine et ne
  voyage pas avec le plugin : celui de Windows y serait faux presque partout. Il
  faudra en écrire un pour Ubuntu, séparément.
- **Synchroniser les projets** entre les deux machines.

## Cas limites

- ~~**`pwsh` installé sur la tour**~~ et ~~**aucun interpréteur adapté**~~ —
  sans objet depuis la décision `0001` : il n'y a plus de hook, donc plus
  d'interpréteur à choisir.
- **Un dépôt partagé entre les deux machines** : fins de ligne différentes, avec
  le risque de faire apparaître des modifications qui n'en sont pas.
- **La tour sans accès à GitHub** : `/flow:ship` et `/flow:release` doivent le
  dire clairement plutôt que d'échouer obscurément.
- **Un projet de type `desktop` jugé depuis la tour** : l'agent d'interface ne
  peut pas y regarder une fenêtre native. Il doit le dire au lieu de se rabattre
  sur la lecture du code — ce que son prompt lui interdit déjà. Les projets de
  type `web` ne sont pas concernés.

## Risques et inconnues

- ~~L'exécution des hooks sous Linux~~ — sans objet depuis la décision `0001`.
- `/flow:guide` et `/flow:visibilite` utilisent déjà de la syntaxe POSIX. Ils
  devraient mieux fonctionner sur Ubuntu — mais personne ne l'a constaté.
- La phrase « GitHub Desktop » est à **16 endroits dans 12 fichiers**, sous cinq
  formulations différentes. La remplacer doit rester juste sur Windows aussi :
  le risque n'est pas la quantité, c'est d'écrire une formulation vraie nulle
  part.
