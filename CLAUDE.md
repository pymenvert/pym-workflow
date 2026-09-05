# pym-workflow

Ce dépôt **est** le plugin `flow` : onze commandes et quatre agents, écrits en
markdown. Il n'a pas de code applicatif — ce qu'on y modifie, ce sont des
instructions lues par Claude Code au démarrage d'une conversation.

## Profil projet
- type : script
- stack : markdown, plus un script de vérification en sh POSIX
- format : aucun
- lint : aucun
- typecheck : aucun
- test : sh scripts/verifier-le-plugin.sh && sh scripts/eprouver-le-verificateur.sh
- build : aucun
- run : aucun — le plugin s'exécute dans Claude Code, pas en ligne de commande. Pour l'essayer : `claude plugin marketplace update pym`, `claude plugin update flow@pym`, puis **une conversation neuve**.
- rythme : enchaîné
- critique : `plugins/flow/commands/visibilite.md` (seule commande aux effets irréversibles) · les deux manifestes `.claude-plugin/*.json` (une erreur y rend le plugin ininstallable) · le frontmatter de chaque commande (sans `description:`, la commande disparaît de l'autocomplétion)

## Boussole
Quand je demande « et maintenant ? », « je fais quoi ? », « par quoi je commence ? »
ou « c'est fini ? » : réponds comme la commande `/flow:guide` — le constat, ce qu'il
reste à faire, et une seule action à lancer. Sans lancer de test, d'agent, de lint
ni de build. Si `docs/reste-a-faire.md` existe, lis-le avant d'affirmer que rien
n'attend. Si `docs/plan-studio.md` existe, lis seulement les lignes de son
tableau « Avancement », par leur forme et non par un numéro de ligne :
`grep '^| [0-9]' docs/plan-studio.md`, ajouté à l'appel groupé du guide, jamais un
appel de plus. Au repos, si un lot est « à constater », la seule action à proposer est la tâche
réelle qui le constate ; sinon, le premier lot « à faire » — à la place de
« `/flow:spec` ton idée ».

## Architecture

1. `.claude-plugin/marketplace.json` déclare la marketplace `pym` et pointe vers `plugins/flow`.
2. `plugins/flow/.claude-plugin/plugin.json` porte la **version**, qui épingle le plugin : sans bump, aucune mise à jour n'est proposée, même si le dépôt distant a changé.
3. `plugins/flow/commands/*.md` — une commande par fichier, le nom du fichier fait le nom de la commande. Dix d'entre elles se terminent par un **bloc partagé identique à l'octet** (« Arrêts et attentes » + « Fin de réponse »). `guide.md` en est la seule exception assumée : c'est le recours, il ne peut pas se citer lui-même. Les six commandes du cycle portent, juste avant ce bloc, un paragraphe « Arrêts et suite » : leurs arrêts avec la raison numérotée, et la commande qu'elles lancent après (décision `0004`).
4. `plugins/flow/agents/*.md` — les quatre relecteurs convoqués par `/flow:verify`.
5. `scripts/verifier-le-plugin.sh` — la porte du plugin sur lui-même. C'est la commande `test` du profil, et c'est exactement ce que lance la CI : deux définitions du mot « vert » finissent toujours par diverger.

## Conventions

- **Tout est en français**, y compris les commentaires du script et les messages d'enregistrement.
- **Aucun terme technique sans sa traduction dans la même phrase.** L'auteur n'est pas développeur.
- **Une modification d'une commande se répercute dans le README**, qui est le seul endroit où l'auteur relit comment fonctionne son propre outil. Le contrôle 2 du vérificateur l'exige mécaniquement, dans les deux sens.
- **Deux machines** : une tour Ubuntu (`gh` 2.45.0, ni Node ni PowerShell) et un poste Windows (version de `gh` inconnue). Rien ne doit dépendre d'une capacité présente d'un seul côté — c'est l'objet de la décision `0002`.

## Git

- Jamais de travail direct sur `main` : une branche dédiée par tâche, créée par `/flow:new-feature`.
- Commits atomiques et descriptifs.
- Jamais de secrets, `.env` ou jetons dans le code, les commits ou les prompts.
