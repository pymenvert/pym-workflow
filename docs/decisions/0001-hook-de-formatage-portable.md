# 0001 — Retirer le hook de formatage plutôt que le rendre portable

Décidé le 4 septembre 2026. Spec : `docs/specs/plugin-sur-ubuntu.md`.

## Contexte

Le hook de formatage lance `powershell -NoProfile -ExecutionPolicy Bypass -File
.../format.ps1`. Sous Linux, `powershell` n'existe pas : le hook ne démarre pas,
sort en 127, et **l'erreur est visible dans le transcript à chaque écriture de
fichier**. C'est la seule pièce du plugin qui empêche de l'installer sur la tour
Ubuntu — tout le reste est déjà portable.

La question posée était donc : en quel langage le réécrire ?

Deux mesures ont changé la question elle-même.

**Aucun projet n'a jamais adopté de formateur.** Vérifié le 4 septembre sur les
cinq dépôts — Zotijean, Cascade, PixelPusherBridge, Toolbox, pym-workflow :
aucun fichier `.prettierrc`, aucune clé `prettier`, aucun `ruff.toml`, aucune
section `[tool.ruff]` ou `[tool.black]`. Or depuis la v0.4.0, le hook ne
s'exécute **que** si le projet a adopté un formateur. **Il n'a donc jamais
formaté quoi que ce soit, sur aucune machine.**

**Node est absent de la tour.** `command -v node` n'y renvoie rien. Le seul
interpréteur qui restait crédible n'est pas là.

## Options envisagées

**Réécrire en Node.** C'était la proposition initiale. Elle a été attaquée et
elle est tombée sur trois points, dont un mesuré : sur Windows, les exécutables
posés par npm sont des shims sans `.exe`. `spawnSync('prettier')` rend `ENOENT`
car Node n'applique pas `PATHEXT` ; `spawnSync('prettier.cmd')` rend `EINVAL`
depuis la CVE-2024-27980 ; et `shell: true` laisse le fichier **inchangé**, Node
concaténant les arguments sans les échapper et prettier traitant les `\` du
chemin comme des échappements de motif. La version Node aurait cessé de formater
sous Windows — en silence, puisque le script sort toujours en 0.

**Installer Node sur la tour, puis réécrire en Node.** Tenable, mais c'est payer
une installation, la résolution des shims npm, un mode diagnostic, une chaîne
d'intégration sur deux systèmes et une suite de tests — pour une fonctionnalité
qui n'a jamais tourné.

**Garder PowerShell et installer `pwsh` sur la tour.** `pwsh` est absent des
deux machines : la version Windows est PowerShell 5.1, qui n'existe pas sous
Linux. Il faudrait l'installer des deux côtés et changer quand même la commande.

**Deux scripts, un par système.** Le choix entre les deux dépendrait du shell que
Claude Code sélectionne sous Windows — Git Bash s'il est installé, PowerShell
sinon. On remplacerait une fragilité par une autre, et deux implémentations
divergeraient au premier correctif.

**Python.** Écarté par une mesure antérieure : l'alias WindowsApps lance
l'interpréteur dans un conteneur applicatif où `%APPDATA%` est virtualisé. Il
déclare `%APPDATA%\npm` inexistant, et devient aveugle à prettier installé
globalement.

## Décision

**Retirer le hook.** `plugins/flow/hooks/hooks.json` et
`plugins/flow/scripts/format.ps1` sont supprimés.

Le formatage n'est pas abandonné pour autant : il reste où il a toujours eu sa
place, c'est-à-dire dans `/flow:verify`, qui lance la commande `format` déclarée
dans le bloc « Profil projet » du projet. Décidée par le projet, lancée à la
porte, visible dans le tableau de vérification.

Trois raisons, dans l'ordre de leur poids.

**Le hook n'a jamais rien produit.** Retirer une fonctionnalité qui dort ne coûte
rien de mesurable.

**C'est le seul obstacle au déploiement sur Ubuntu.** Le retirer rend le plugin
portable immédiatement : plus d'interpréteur à choisir, rien à installer sur la
tour, aucune résolution de shims, aucune chaîne d'intégration à deux systèmes.

**Sa propre règle disait déjà de le faire.** La v0.4.0 avait ajouté l'adoption
obligatoire avec ce motif : *« le style d'un projet appartient au projet »*. Un
hook installé en scope utilisateur, qui se déclenche dans tous les projets, est
la mauvaise forme pour une politique qui appartient à chacun d'eux. Le supprimer,
c'est aller au bout d'un principe déjà écrit.

## Conséquences

**Ce que ça facilite** — le plugin devient portable sans condition. Les critères
1 à 3 de la spec deviennent sans objet : il n'y a plus de hook à faire échouer.
Quatre tentatives d'implémentation — bash, Python, PowerShell, Node — cessent
d'être une dette.

**Ce que ça rend plus difficile** — le formatage ne se fait plus au fil de
l'eau, mais au passage de la porte. Sur un gros lot de modifications, le
reformatage arrivera d'un bloc au lieu d'être réparti. C'est assumé.

**Ce qu'on s'interdit** — remettre un hook de formatage dans ce plugin. Si un
projet veut du formatage automatique par écriture, le hook se pose **dans ce
projet-là**, avec ses réglages, et non dans un plugin qui s'exécute partout.

## À ne pas repayer si l'idée revient

Ces quatre impasses sont mesurées, pas supposées. Elles sont la vraie valeur de
ce fichier.

- **bash** — le `bash` du PATH sous Windows est le lanceur WSL, distribution
  cassée : sortie 1, `execvpe(/bin/bash) failed`.
- **Python** — alias WindowsApps en conteneur applicatif, aveugle à
  `%APPDATA%\npm`, donc incapable de trouver un outil installé par npm.
- **PowerShell** — fonctionne parfaitement sous Windows, n'existe pas sous
  Linux ; `pwsh` est absent des deux machines.
- **Node** — les shims npm sous Windows ne sont pas lançables depuis Node sans
  résoudre le point d'entrée réel du paquet. Et Node n'est pas installé sur la
  tour.

Le motif commun des quatre : **un hook qui sort toujours en 0 ne permet pas de
distinguer « rien à faire » de « cassé ».** Il ment par construction. Toute
tentative future devrait commencer par lui donner un mode diagnostic
observable — avant d'écrire la moindre ligne de logique.
