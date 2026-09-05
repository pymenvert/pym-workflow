# pym — workflow Claude Code (dev solo)

Marketplace perso. Un plugin : **flow** — le cycle *spec → design → implémentation → vérification → livraison*, disponible dans tous les projets.

Le principe : ce qui rend un logiciel robuste, ce ne sont pas des avis d'experts, ce sont des **portes** — des étapes qu'on ne franchit pas tant que quelque chose de mesurable est rouge. `/flow:verify` est cette porte, et elle a le droit de dire non.

## Installation (une fois)

```bash
claude plugin marketplace add pymenvert/pym-workflow
claude plugin install flow@pym --scope user
```

`--scope user` = disponible dans tous les projets.

Quand le dépôt est privé, git doit savoir s'identifier sur la machine :

- **Windows** — le gestionnaire d'identifiants installé par GitHub Desktop suffit. Rien à configurer.
- **Ubuntu** — GitHub Desktop n'existe pas pour Linux. Installer `gh` (`sudo apt install gh`), puis lancer `gh auth login` et `gh auth setup-git`. Git réutilisera ces identifiants pour les dépôts privés, sans autre réglage.

**La version de `gh` livrée par Ubuntu suffit.** Vérifié le 4 septembre 2026 sur la tour : paquet `noble/universe`, `gh` 2.45.0, et les cinq appels que le plugin utilise fonctionnent — `repo view`, `api`, `pr list`, `pr create`, `run list`. Depuis la version 0.12.0, plus aucune commande n'emploie de capacité apparue dans une version récente ; c'est l'objet de `docs/decisions/0002-visibilite-par-api-et-porte-du-plugin.md`.

## Le cycle

| Commande | Rôle | Ce qu'elle empêche |
|---|---|---|
| `/flow:init-project` | Détecte la stack, écrit le **profil projet**, pose tests et CI | Un projet sans filet automatique |
| `/flow:spec <idée>` | Critères d'acceptation testables, hors-périmètre, cas limites | Construire la mauvaise chose |
| `/flow:design <spec>` | Architecture, **attaquée** par l'agent `architect`, tracée en ADR | Le code qui devient intouchable |
| `/flow:new-feature <desc>` | Branche, plan court, petits lots, tests d'abord sur le critique | Le grand diff illisible |
| `/flow:verify` | **La porte** : checks + quatre agents. Verdict PASSE ou BLOQUÉ | Livrer du cassé |
| `/flow:ship` | Commit atomique, push, PR, surveillance de la CI | Le « je corrigerai après » |

Les étapes intermédiaires savent s'effacer : sur une faute de frappe, `/flow:spec` va directement à `/flow:new-feature` — ou te le dit, en pas à pas — plutôt que de produire de la paperasse.

## Le déroulé d'une tâche, concrètement

**La règle de base : les commandes marquent des moments, elles ne remplacent pas la conversation.** Entre deux commandes, on parle normalement — c'est même là que se prennent les décisions.

| # | Tu tapes | Ce qui se passe | Tes fichiers | Il s'arrête ? |
|---|---|---|---|---|
| 1 | `/flow:spec <ton idée>` | Il lit ton code, pose **trois questions maximum**, écrit un document dans `docs/specs/` | 1 fichier créé | seulement s'il a une question pour toi |
| 2 | *il enchaîne* `/flow:design` | Il propose une architecture et la fait **attaquer** par l'agent `architect`, puis écrit la décision dans `docs/decisions/` | 1 fichier créé | seulement si un choix te revient — il te le pose alors dans une forme fixe, recommandation d'abord |
| 3 | *il enchaîne* `/flow:new-feature` | Il crée la branche tout seul, explore le code, annonce un plan court, implémente par petits lots | **il écrit ton code** | seulement si le code contredit le cadrage |
| 4 | *il enchaîne* `/flow:verify` | Tests, puis les quatre agents. Corrige les bloquants. Rend **PASSE** ou **BLOQUÉ**, puis un compte-rendu pour toi | il peut corriger | sur **BLOQUÉ** |
| 5 | *il enchaîne* `/flow:ship` | Enregistre, envoie, ouvre la pull request avec le compte-rendu, surveille la CI, te donne le lien | il enregistre | non |
| 6 | *sur GitHub* | Tu fusionnes, tu supprimes la branche, tu récupères la fusion sur ta machine | — | c'est toi qui fusionnes |

Entre deux étapes, un **point de passage** de trois lignes — fait, décidé ou constaté, commence — pour relire un fil de deux heures en trente secondes.

### Les quatre raisons de s'arrêter

En rythme **enchaîné** — le défaut —, une commande ne s'arrête que pour l'une de ces quatre raisons, et elle la nomme :

1. **une réponse qui n'appartient qu'à toi** : le besoin, la priorité, l'apparence, « est-ce fini ? » ;
2. **de l'argent ou un engagement** : un service payant, un abonnement, un compte à ouvrir ;
3. **un acte irréversible ou public** : la fusion sur la branche par défaut, l'étiquette de version, la mise en ligne, la visibilité, une suppression ;
4. **une porte rouge** qu'elle ne sait pas rendre verte sans changer le besoin.

Chaque arrêt commence par « **J'attends ta réponse.** » et **tu réponds dans la discussion, en français.** Tu ne relances pas une commande. Un mot de toi dans le fil — « attends », « pas à pas » — l'emporte sur le profil pour la tâche en cours.

En **pas à pas** (ligne `rythme` du profil projet), les trois arrêts d'avant sont de retour : après les questions de `/flow:spec`, après la proposition de `/flow:design`, après le plan de `/flow:new-feature` — et c'est toi qui tapes la commande suivante. Un projet qu'on découvre peut le mériter ; un projet qu'on connaît ne le mérite plus. Le raisonnement est dans `docs/decisions/0004-rythme-enchaine-et-quatre-raisons.md`.

### Ce qui coûte cher, ce qui ne coûte rien

`/flow:verify` est **la seule commande chère du cycle** : elle lance toute la suite de tests et jusqu'à quatre relecteurs automatiques. Plusieurs minutes. En rythme enchaîné, elle tourne sans te demander : c'est le prix de ne pas attendre, et « attends » la retient. À la version, `/flow:release` lance le bilan de santé avec ses relecteurs : la version est chère, et c'est voulu.

Tout le reste répond en quelques secondes. `/flow:guide` est gratuit — il ne lance ni test ni agent — et c'est le bon réflexe quand on ne sait pas où on en est.

### Quand sauter des étapes

Le cycle complet sert aux tâches qui comptent. Pour le reste :

- **Une faute de frappe, un libellé** → directement `/flow:new-feature`. `/flow:spec` y va lui-même plutôt que de produire de la paperasse.
- **Un défaut dont la définition de « terminé » est évidente** → `/flow:new-feature` suffit. Une spec ne sert qu'à écrire ce qu'on ne sait pas encore.
- **Rien ne touche à la structure** → saute `/flow:design`. Il sert aux décisions qu'on regrette, pas aux modifications qu'on oublie.
- **« Ça plante quand… », un comportement qui a cessé** → `/flow:new-feature` en **mode incident** : il écrit la panne au journal, reproduit d'abord par un test qui échoue, corrige, garde le test, puis note la cause et la leçon.

En revanche, `/flow:verify` et `/flow:ship` ne se sautent jamais : ce sont eux qui empêchent de livrer du cassé.

### Où vit ton travail

Rien de ton travail ne vit dans la conversation. Le code est sur ton disque, la branche et la pull request sont sur GitHub. Ouvrir une conversation neuve ne perd que **le fil de la discussion** — jamais le travail. Il suffit de redire le contexte en trois lignes, ou de lancer `/flow:guide`, qui le reconstitue tout seul.

## Hors cycle — plus rare, plus cher

Quatre commandes ne servent pas à une tâche mais à une version, ou à la machine :

| Commande | Rôle | Quand |
|---|---|---|
| `/flow:audit` | Le bilan de santé de **tout** le programme : ce qui se répète au journal, la dérive lente, les dépendances en retard, ce que l'app dit d'elle-même qui est devenu faux | À chaque version, lancé par `/flow:release` |
| `/flow:mutation` | Casse le code exprès et exige que la suite tombe. La seule commande qui met en doute **les tests** plutôt que le code | Après une grosse vague de tests |
| `/flow:release` | CI verte exigée, bilan de santé, numéro annoncé, ligne au journal, numéros cohérents, puis le tag qui publie — son seul arrêt | Au moment de livrer une version |
| `/flow:visibilite` | Ouvre un dépôt privé le temps d'une campagne de CI coûteuse, puis le referme **et le vérifie** | Rare — et jamais sans lire ce qu'elle expose |

`/flow:visibilite` mérite un avertissement : rendre un dépôt public expose **tout son historique**, pas seulement son état actuel, et repasser en privé n'annule ni un clone, ni un fork, ni une mise en cache. La commande fouille l'historique à la recherche de secrets avant d'ouvrir, et refuse de considérer le travail fini tant qu'elle n'a pas vérifié la fermeture.

`/flow:mutation` mérite un mot : toutes les autres commandes font confiance à la suite de tests. Une suite verte n'est pourtant pas une preuve, c'est une affirmation. Casser le code délibérément est le seul moyen de la vérifier — et sur un projet où cette épreuve a été passée, elle a révélé que la suite était **aveugle à quatre cassages réels**. Comme la commande modifie du code source, git sert de filet : dossier propre exigé au départ, restauration par `git checkout`, et preuve par `git status` à l'arrivée.

Fusionner une pull request **ne publie rien**. Dans ce type de projet, c'est le tag `vX.Y.Z` qui déclenche la publication — et le workflow qui publie ne rejoue généralement pas les tests. Le tag est donc le point de non-retour : `/flow:release` existe pour que rien ne le franchisse sans avoir été vérifié.

## Ne jamais rester sans savoir quoi faire

Le cycle ne sert à rien si on ne sait pas où on en est. Quatre mécanismes s'en occupent, et aucun ne coûte cher :

**Chaque commande — ou chaque chaîne de commandes — finit par trois lignes** — *Où on en est*, *Ensuite*, *Si tu hésites*. Sauf `/flow:guide`, qui *est* le recours et ne peut pas se citer lui-même. Une seule action proposée, jamais deux options, jamais de « si » à arbitrer soi-même. Et si la commande s'est arrêtée en route, elle le dit là plutôt que d'annoncer un travail qui n'a pas eu lieu.

**`/flow:guide`** fait le point quand on est perdu ou qu'on reprend un projet trois semaines plus tard. Il lit l'état du dépôt en un seul appel groupé et nomme la seule commande à lancer. Il lui est interdit de lancer un test, un agent, un lint ou un build — c'est la commande gratuite du lot. Là où git ne permet pas de trancher, il pose une question au lieu de deviner : deviner enverrait relancer la porte, qui est la commande chère.

**`/flow:guide <mot>`** explique un mot en trois lignes et un exemple tiré de ton projet — « ça veut dire quoi ? », le même recours que « je fais quoi ? ». Dix-neuf mots y ont le sens précis que `flow` leur donne ; les autres s'expliquent en termes généraux.

**Le bloc « Boussole »**, écrit par `/flow:init-project` dans le `CLAUDE.md` du projet, capte les questions posées en français — « et maintenant ? », « je fais quoi ? », « c'est fini ? » — et y répond comme `/flow:guide`. C'est le mécanisme le plus utile des quatre, parce que c'est ainsi qu'on demande son chemin en vrai : pas en tapant le nom d'une septième commande.

Deux règles complètent l'ensemble : chaque arrêt commence par « **J'attends ta réponse** », et tout passage long et muet — agents, tests, surveillance de la CI — est annoncé avec sa durée. Un silence long ressemble à un plantage, et le réflexe est alors de taper une autre commande.

## Le journal — ce qui s'est passé, compté

`docs/journal.md`, dans chaque projet : une ligne par événement, ajoutée par les commandes, jamais réécrite. Quatre types — `porte` (checks, bloquants réels par relecteur, non vérifié, durée, jetons), `livraison` (branche, ce que ça change), `incident` (quoi, cause, leçon), `version` (numéro, bilan). Tu n'as rien à taper : `/flow:verify`, `/flow:ship`, `/flow:new-feature` et `/flow:release` l'écrivent. `/flow:audit` le lit et en tire deux chiffres, par une seule commande : le rendement de chaque relecteur, et les incidents par version — le seul chiffre qui dit si la porte protège. Un relecteur à zéro sur dix portes devient rare ; on ne le supprime pas. Ces chiffres sont déclarés par la porte elle-même : ils mesurent son accord avec ses relecteurs, pas la vérité (`docs/decisions/0005-le-journal-et-le-bilan-de-sante.md`). Le registre `docs/reste-a-faire.md` ne garde plus que ce qui est ouvert.

## Le profil projet — comment flow s'adapte

`/flow:init-project` écrit dans le `CLAUDE.md` du projet un bloc que toutes les autres commandes lisent :

```markdown
## Profil projet
- type : cli | desktop | web | service | script
- stack : <langage + framework>
- format / lint / typecheck / test / build / run : <commandes réelles>
- rythme : enchaîné | pas à pas
- critique : <modules à couvrir en priorité>
```

L'adaptation est donc **écrite une fois**, pas redevinée à chaque session. C'est ce bloc qui dit à `/flow:verify` quoi lancer, et à `ux-reviewer` s'il doit juger un `--help`, une fenêtre ou une page web.

Règle d'or : chaque commande du profil doit avoir été **exécutée avec succès** au moment où elle y est inscrite. Une commande écrite au jugé rendrait la porte mensongère. `rythme` est la seule ligne sans vérité extérieure : rien ne la lance, elle se lit — et absente, c'est enchaîné.

## Les quatre agents

| Agent | Son objet | Quand |
|---|---|---|
| `architect` | **Le dépôt entier** : point de rupture, couplage, dérive | `/flow:design`, puis dès qu'un fichier grossit |
| `code-reviewer` | **Ce que ce lot introduit** : correction, textes, secrets visibles | Toujours |
| `test-engineer` | **Ce qui n'est pas couvert**, et la tenue en conditions réelles | Dès que de la logique change |
| `ux-reviewer` | **L'interface rendue**, celle qui n'existe qu'une fois lancée | Si l'interface ou ce qui construit l'exécutable a changé |

**Ils se partagent le travail par objet, pas par vocabulaire.** Deux agents peuvent regarder la duplication sans faire doublon : `code-reviewer` celle que ce lot ajoute, `architect` celle du dépôt. Chacun porte un bloc « Ce que tu ne fais pas » qui nomme le propriétaire des sujets voisins, et deux contrôles du vérificateur les tiennent : l'un exige que ce bloc existe, l'autre refuse qu'un sujet réservé soit repris ailleurs **sans citer son propriétaire dans la même phrase**. C'est une vérification de forme, pas de sens : elle attrape le doublon qui revient par distraction, pas celui qu'on écrirait exprès. C'est l'objet de `docs/decisions/0003-un-proprietaire-par-preoccupation.md`.

**Chaque rapport s'ouvre par trois lignes pour toi**, sans terme non traduit — ce que l'agent a regardé, ce que ça change pour ton logiciel, ce qu'il recommande —, avant ses constats écrits pour le studio, avec fichiers et lignes. `/flow:verify` recopie ces lignes dans son compte-rendu.

Chacun a l'ordre explicite de ne rien dire quand il ne trouve rien. Un rapport vide est un résultat — **sauf pour `ux-reviewer`**, seul dont un rapport court peut vouloir dire « je n'ai pas pu lancer le logiciel ». Il doit alors le dire en toutes lettres, et `/flow:verify` le porte dans sa section « non vérifié » plutôt que de le prendre pour un feu vert.

Deux choses que personne ne regardait, et que la version 0.14.0 a rattachées à leur propriétaire naturel : la **tenue en conditions réelles** (l'appareil qui disparaît en cours de route, la reprise sans redémarrage, l'arrêt d'urgence) va à `test-engineer` · la **première exécution sur une machine nue** et **ce que l'opérateur voit quand ça casse en direct** vont à `ux-reviewer`. Sans agent supplémentaire : le coût par session est inchangé.

`/flow:verify` appelle aussi `/security-review`, livré avec Claude Code, quand le diff touche à des entrées, des fichiers, du réseau ou des secrets — **ou quand `code-reviewer` lui tend la main**. Une main tendue sans receveur ne protège de rien.

## Le formatage

Ce plugin n'installe **aucun hook**. Le formatage se fait au passage de la porte : `/flow:verify` lance la commande `format` déclarée dans le bloc « Profil projet » du projet, et le résultat apparaît dans son tableau de vérification.

**La commande `format` du profil est celle qui _vérifie_** (`prettier --check`), jamais celle qui écrit. C'est ce qui permet à `/flow:verify` de démarrer ses checks sans rien te demander : un check ne modifie rien. Si elle est rouge, la porte lance alors la variante qui écrit — mais en tant que **correction**, annoncée comme telle, et soumise à la règle « jamais directement sur la branche par défaut ».

Un hook de formatage a existé jusqu'à la 0.10.1. Il a été retiré pour deux raisons : aucun projet n'avait adopté de formateur, donc il n'avait **jamais rien produit** — et il était la seule pièce du plugin qui ne fonctionnait pas sous Linux. Le raisonnement complet, avec les quatre impasses d'implémentation qu'il aura coûtées, est dans `docs/decisions/0001-hook-de-formatage-portable.md`.

Pour formater un projet : pose-lui un `.prettierrc` (ou l'équivalent de sa stack) et déclare la commande `format` dans son Profil projet. `/flow:verify` s'en chargera, sur toutes tes machines. Le style d'un projet appartient au projet — c'est aussi pour ça qu'il n'a rien à faire dans un plugin installé pour tous.

## Cycle type

Nouveau projet : `/flow:init-project` une fois.

Puis, par tâche : `/flow:spec` → `/flow:design` → `/flow:new-feature` → `/flow:verify` → `/flow:ship`.

Entre deux tâches sans rapport : `/clear`.

Ce que ce cycle ne promet pas : « zéro bug ». Ça n'existe pas. Ce qu'il change, c'est *quand* les bugs apparaissent — attrapés par une machine en trente secondes plutôt que par toi trois semaines plus tard.

## Le plugin se vérifie lui-même

Un plugin qui prêche « une porte qui a le droit de dire non » et n'en a aucune sur lui-même finit par dériver — il est passé de 3 à 11 commandes en huit jours, et **tous** les défauts trouvés à la main jusqu'ici étaient détectables mécaniquement.

```bash
sh scripts/verifier-le-plugin.sh
```

Quelques secondes, aucun réseau sauf pour comparer la version. Ce qu'il contrôle : le bloc de fin partagé, présent et identique dans les dix commandes qui le portent · chaque commande citée par le README **et** par la description de la marketplace, et réciproquement · le frontmatter de chaque commande (sans lui, elle disparaît de l'autocomplétion) · chaque agent avec ses outils déclarés, sans `Edit` ni `Write`, et tous ceux que `/flow:verify` convoque bien présents · les deux manifestes valides, cohérents, et pointant vers un plugin qui existe · la version bumpée — jamais égale, jamais en recul · les chemins du dépôt cités par le README · aucun appel `gh` dépendant d'une version · aucun reste PowerShell · les scripts forcés en LF, sans quoi Windows refuse de les lancer.

Il ne dit jamais « vert » d'un contrôle qu'il n'a pas pu lancer : ceux-là ressortent **IGNORÉ**, comptés à part. Et il les lance tous avant de conclure, plutôt que de s'arrêter au premier rouge — découvrir un seul défaut par exécution est le meilleur moyen de faire abandonner à la troisième.

### Qui garde le gardien

```bash
sh scripts/eprouver-le-verificateur.sh
```

Une porte verte n'est pas une preuve, c'est une affirmation. Ce banc casse le dépôt exprès — un défaut à la fois, chacun dans une copie jetable — et exige que le bon contrôle tombe à chaque fois. Il pose aussi la **réciproque**, sans laquelle un contrôle qui rougirait sur tout passerait chaque cas avec les félicitations : un changement légitime doit laisser la porte verte.

C'est `/flow:mutation` appliqué d'avance, et il a déjà servi deux fois. Écrit **avant** les corrections qu'il justifiait, six de ses cas passaient alors au vert. Puis ses propres relecteurs y ont trouvé qu'une variable non initialisée le faisait répondre « attrapé » à tout : ses vingt-quatre cas ne prouvaient rien. Il refuse désormais de compter un cas qui n'a pas tourné, distingue un contrôle **IGNORÉ** d'un trou, vérifie que la mutation a bien changé quelque chose, et lit le **code de sortie** de la porte autant que son texte.

Les deux scripts forment ensemble la commande `test` du Profil projet — donc ce que lance `/flow:verify` — **et** exactement ce que rejoue `.github/workflows/ci.yml` à chaque poussée. Deux définitions du mot « vert » finissent toujours par diverger.


## Le cap

Le plugin a un cap écrit : `docs/plan-studio.md`. Son tableau d'avancement, en tête, dit quel lot vient ensuite ; sa section 13 liste les choix qui reviennent à l'auteur. La règle qui va avec : aucun lot sur ce dépôt sans un item de ce plan ou une app réelle qui le justifie. Le lot 1 — le rythme enchaîné et la pédagogie — est dans la 0.15.0, le lot 2 — le journal, le mode incident, le bilan de santé — dans la 0.16.0 ; aucun des deux n'est « constaté » tant qu'une tâche réelle n'a pas traversé la chaîne.

## Mettre à jour le workflow

Quatre étapes, dans cet ordre. Les deux premières sont contre-intuitives et sautent silencieusement si on les oublie.

1. **Modifier le repo, puis bumper `version` dans `plugins/flow/.claude-plugin/plugin.json`.** Ce champ **épingle** le plugin : tant qu'il ne change pas, aucune mise à jour n'est proposée, même si le dépôt distant a changé. Sans bump, tout le reste est sans effet.
2. **Commit et push.**
3. **`/plugin marketplace update pym`**, puis `/plugin update flow@pym`. (L'auto-update en arrière-plan peut échouer sur un dépôt privé en HTTPS ; la mise à jour manuelle utilise tes identifiants et fonctionne toujours.)
4. **Ouvrir une NOUVELLE conversation.** Les plugins sont lus au démarrage d'une conversation, une fois pour toutes. Une discussion déjà ouverte gardera pour toujours la liste de commandes qu'elle avait à sa naissance — redémarrer l'application n'y change rien, elle reste accrochée à sa session d'origine.

Pour vérifier qu'une mise à jour a bien pris, taper `/flow:` dans une conversation neuve : les onze commandes doivent apparaître dans l'autocomplétion.

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
