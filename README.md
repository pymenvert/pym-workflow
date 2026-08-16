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

Modifier ce repo, commit, push. Puis dans Claude Code : `/plugin marketplace update pym`, et `/reload-plugins` si les hooks ont changé. (L'auto-update en arrière-plan peut échouer sur un repo privé en HTTPS ; la mise à jour manuelle utilise tes credentials et fonctionne toujours.)

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
