# pym — workflow Claude Code (dev solo)

Marketplace perso. Un plugin : **flow** — le cycle *spec → design → implémentation → vérification → livraison*, disponible dans tous les projets.

Le principe : ce qui rend un logiciel robuste, ce ne sont pas des avis d'experts, ce sont des **portes** — des étapes qu'on ne franchit pas tant que quelque chose de mesurable est rouge. `/flow:verify` est cette porte, et elle a le droit de dire non.

## Installation (une fois)

```bash
claude plugin marketplace add pymenvert/pym-workflow
claude plugin install flow@pym --scope user
```

`--scope user` = disponible dans tous les projets. Le repo est privé : Claude Code réutilise les identifiants git déjà en place. Sous Windows, le gestionnaire d'identifiants installé par GitHub Desktop suffit — rien à configurer, et `gh` n'est pas nécessaire pour cette étape.

## Le cycle

| Commande | Rôle | Ce qu'elle empêche |
|---|---|---|
| `/flow:init-project` | Détecte la stack, écrit le **profil projet**, pose tests et CI | Un projet sans filet automatique |
| `/flow:spec <idée>` | Critères d'acceptation testables, hors-périmètre, cas limites | Construire la mauvaise chose |
| `/flow:design <spec>` | Architecture, **attaquée** par l'agent `architect`, tracée en ADR | Le code qui devient intouchable |
| `/flow:new-feature <desc>` | Branche, plan validé, petits lots, tests d'abord sur le critique | Le grand diff illisible |
| `/flow:verify` | **La porte** : checks + quatre agents. Verdict PASSE ou BLOQUÉ | Livrer du cassé |
| `/flow:ship` | Commit atomique, push, PR, surveillance de la CI | Le « je corrigerai après » |

Les étapes intermédiaires savent s'effacer : sur une faute de frappe, `/flow:spec` te dira d'aller directement à `/flow:new-feature` plutôt que de produire de la paperasse.

## Hors cycle — plus rare, plus cher

Deux commandes ne servent pas à une tâche mais à une version :

| Commande | Rôle | Quand |
|---|---|---|
| `/flow:audit` | Audit de fond de **tout** le programme : dérive lente, angles morts, ce que l'app dit d'elle-même qui est devenu faux | Entre deux versions |
| `/flow:mutation` | Casse le code exprès et exige que la suite tombe. La seule commande qui met en doute **les tests** plutôt que le code | Après une grosse vague de tests |
| `/flow:release` | Cohérence de tous les numéros de version, CI verte exigée, puis le tag qui publie | Au moment de livrer une version |

`/flow:mutation` mérite un mot : toutes les autres commandes font confiance à la suite de tests. Une suite verte n'est pourtant pas une preuve, c'est une affirmation. Casser le code délibérément est le seul moyen de la vérifier — et sur un projet où cette épreuve a été passée, elle a révélé que la suite était **aveugle à quatre cassages réels**. Comme la commande modifie du code source, git sert de filet : dossier propre exigé au départ, restauration par `git checkout`, et preuve par `git status` à l'arrivée.

Fusionner une pull request **ne publie rien**. Dans ce type de projet, c'est le tag `vX.Y.Z` qui déclenche la publication — et le workflow qui publie ne rejoue généralement pas les tests. Le tag est donc le point de non-retour : `/flow:release` existe pour que rien ne le franchisse sans avoir été vérifié.

## Ne jamais rester sans savoir quoi faire

Le cycle ne sert à rien si on ne sait pas où on en est. Trois mécanismes s'en occupent, et aucun ne coûte cher :

**Chaque commande finit par trois lignes** — *Où on en est*, *Ensuite*, *Si tu hésites*. Une seule action proposée, jamais deux options, jamais de « si » à arbitrer soi-même. Et si la commande s'est arrêtée en route, elle le dit là plutôt que d'annoncer un travail qui n'a pas eu lieu.

**`/flow:guide`** fait le point quand on est perdu ou qu'on reprend un projet trois semaines plus tard. Il lit l'état du dépôt en un seul appel groupé et nomme la seule commande à lancer. Il lui est interdit de lancer un test, un agent, un lint ou un build — c'est la commande gratuite du lot. Là où git ne permet pas de trancher, il pose une question au lieu de deviner : deviner enverrait relancer la porte, qui est la commande chère.

**Le bloc « Boussole »**, écrit par `/flow:init-project` dans le `CLAUDE.md` du projet, capte les questions posées en français — « et maintenant ? », « je fais quoi ? », « c'est fini ? » — et y répond comme `/flow:guide`. C'est le mécanisme le plus utile des trois, parce que c'est ainsi qu'on demande son chemin en vrai : pas en tapant le nom d'une septième commande.

Deux règles complètent l'ensemble : chaque arrêt commence par « **J'attends ta réponse** », et tout passage long et muet — agents, tests, surveillance de la CI — est annoncé avec sa durée. Un silence long ressemble à un plantage, et le réflexe est alors de taper une autre commande.

## Le profil projet — comment flow s'adapte

`/flow:init-project` écrit dans le `CLAUDE.md` du projet un bloc que toutes les autres commandes lisent :

```markdown
## Profil projet
- type : cli | desktop | web | service | script
- stack : <langage + framework>
- format / lint / typecheck / test / build / run : <commandes réelles>
- critique : <modules à couvrir en priorité>
```

L'adaptation est donc **écrite une fois**, pas redevinée à chaque session. C'est ce bloc qui dit à `/flow:verify` quoi lancer, et à `ux-reviewer` s'il doit juger un `--help`, une fenêtre ou une page web.

Règle d'or : chaque commande du profil doit avoir été **exécutée avec succès** au moment où elle y est inscrite. Une commande écrite au jugé rendrait la porte mensongère.

## Les quatre agents

| Agent | Angle | Quand |
|---|---|---|
| `architect` | Point de rupture, couplage, dérive structurelle | `/flow:design`, puis dès qu'un fichier grossit |
| `code-reviewer` | Correction, sécurité, conventions du diff | Toujours |
| `test-engineer` | Cas limites non couverts, tests fragiles | Dès que de la logique change |
| `ux-reviewer` | L'interface réelle, logiciel lancé et regardé | Si l'interface visible a changé |

Chacun a l'ordre explicite de ne rien dire quand il ne trouve rien. Un rapport vide est un résultat.

`/flow:verify` appelle aussi `/security-review`, livré avec Claude Code, quand le diff touche à des entrées, des fichiers, du réseau ou des secrets.

## Le hook de formatage

Un hook PostToolUse formate chaque fichier modifié — `ruff` ou `black` pour le Python, `prettier` pour le reste. Si aucun formateur n'est installé, le hook ne fait rien et ne bloque jamais.

**Il ne se déclenche que si le projet a adopté le formateur** — `.prettierrc` (ou une clé `prettier` dans `package.json`), `ruff.toml` ou `[tool.ruff]` dans `pyproject.toml`. Sans configuration, il ne touche à rien.

C'est délibéré : ce hook est installé en scope utilisateur, donc actif dans *tous* tes projets, y compris ceux écrits avant lui. Reformater aux réglages par défaut un projet qui n'a jamais demandé prettier produirait un diff énorme et parasite. Le style d'un projet appartient au projet.

Pour l'activer quelque part : `npm install -g prettier` (une fois sur la machine), puis un `.prettierrc` dans le projet concerné.

Deux autres choix volontaires :

- **Les `.md` sont exclus.** Reformater de la prose (`CLAUDE.md`, `README`) à chaque écriture réaligne les tableaux et rebrasse les puces : plus pénible qu'utile.
- **Le script est en PowerShell**, pas en bash ni en Python. Sous Windows le `bash` du PATH est le lanceur WSL (souvent cassé), `jq` est absent, et le Python de l'alias WindowsApps tourne en conteneur applicatif avec `%APPDATA%` virtualisé — il ne voit donc pas les outils installés par `npm install -g`. Sur un poste non-Windows, remplacer la commande de `hooks/hooks.json` par un équivalent shell.

## Cycle type

Nouveau projet : `/flow:init-project` une fois.

Puis, par tâche : `/flow:spec` → `/flow:design` → `/flow:new-feature` → `/flow:verify` → `/flow:ship`.

Entre deux tâches sans rapport : `/clear`.

Ce que ce cycle ne promet pas : « zéro bug ». Ça n'existe pas. Ce qu'il change, c'est *quand* les bugs apparaissent — attrapés par une machine en trente secondes plutôt que par toi trois semaines plus tard.

## Mettre à jour le workflow

Quatre étapes, dans cet ordre. Les deux premières sont contre-intuitives et sautent silencieusement si on les oublie.

1. **Modifier le repo, puis bumper `version` dans `plugins/flow/.claude-plugin/plugin.json`.** Ce champ **épingle** le plugin : tant qu'il ne change pas, aucune mise à jour n'est proposée, même si le dépôt distant a changé. Sans bump, tout le reste est sans effet.
2. **Commit et push.**
3. **`/plugin marketplace update pym`**, puis `/plugin update flow@pym`. (L'auto-update en arrière-plan peut échouer sur un dépôt privé en HTTPS ; la mise à jour manuelle utilise tes identifiants et fonctionne toujours.)
4. **Ouvrir une NOUVELLE conversation.** Les plugins sont lus au démarrage d'une conversation, une fois pour toutes. Une discussion déjà ouverte gardera pour toujours la liste de commandes qu'elle avait à sa naissance — redémarrer l'application n'y change rien, elle reste accrochée à sa session d'origine.

Pour vérifier qu'une mise à jour a bien pris, taper `/flow:` dans une conversation neuve : les six commandes doivent apparaître dans l'autocomplétion.

## Réglages globaux recommandés (une fois)

`~/.claude/settings.json` — bloquer les fichiers sensibles partout :

```json
{
  "permissions": {
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Edit(**/.env)",
      "Edit(**/.env.*)"
    ]
  }
}
```

Trois précisions qui comptent :

- Écrire `Read(./.env)` serait une erreur : la forme `./` est ancrée au dossier courant et ne bloquerait ni `config/.env` ni `packages/api/.env`. La forme `**/.env` suit la syntaxe gitignore et couvre toutes les profondeurs.
- Une règle `deny` sur `Read` bloque aussi `Edit` et `Write` sur le même chemin. Les règles `Edit` restent utiles : elles couvrent `NotebookEdit`, que `Read` ne couvre pas.
- Ces règles s'appliquent aux outils fichiers de Claude et aux commandes Bash reconnues (`cat`, `head`, `sed`…). Elles ne bloquent pas un script Python ou Node qui ouvrirait le fichier lui-même.

`~/.claude/CLAUDE.md` — règles universelles :

```markdown
## Git
- Jamais de travail direct sur main : une branche dédiée par tâche.
- Commits atomiques et descriptifs.
- Jamais de secrets, .env ou tokens dans le code, les commits ou les prompts.

## Méthode
- Comprendre l'existant avant de modifier ; plan court avant toute grosse modification.
- Lancer format / lint / typecheck / tests avant de livrer.
- Préférer la solution la plus simple qui respecte l'architecture.
```

## Optionnel : Entire (traçabilité des sessions)

Par repo : `entire enable --agent claude-code`. Les sessions (prompts, transcripts, appels d'outils) sont stockées dans une branche cachée et poussées avec le repo → à réserver aux repos privés.
