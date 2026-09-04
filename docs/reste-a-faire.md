# Reste à faire

Ce que l'on sait imparfait, et qui n'a pas encore été corrigé.

Ce fichier fait autorité sur ce qui est **ouvert**. Les décisions de structure
vivent dans `docs/decisions/`, les cadrages dans `docs/specs/`. Ne rien
dupliquer entre les trois.

Dernière mise à jour : 4 septembre 2026, après la porte de la tâche
« trous du vérificateur ».

---

## Défauts constatés

### Trois affirmations du README que rien ne vérifie

Signalées par la porte du 4 septembre, non corrigées faute de mécanisme : le
README décrit des comportements du plugin qu'aucun contrôle ne relie au contenu
réel des commandes. Le contrôle 2 couvre les **noms** des commandes, pas ce que
le README dit qu'elles font.

### Deux limites connues du banc de mutation

Mesurées par la porte du 4 septembre, laissées ouvertes parce que leur portée
est bornée et qu'aucune ne produit de faux vert :

1. **Un cas n'exige que le rouge du contrôle visé**, jamais que les autres
   restent verts. Une mutation qui ferait rougir toute la porte serait comptée
   « ok ». Les quatre cas réciproques couvrent l'essentiel du risque — un
   contrôle qui rougit sur un changement légitime est attrapé — mais pas le cas
   d'un défaut qui déborde sur un contrôle voisin.
2. **Une sortie envoyée dans `head` ou `less` laisse une copie du dépôt dans le
   dossier temporaire.** Le nettoyage passe par un piège sur la sortie du
   script ; interrompu par un tuyau fermé, il peut ne pas s'exécuter. Sans
   conséquence sur le verdict, mais ça encombre.

### `/flow:audit` et l'agent `architect` se recouvrent

`audit.md`:24 recopie presque mot pour mot la liste de mesures de
`architect.md`:26-33, puis `audit.md`:40 lance `architect` pour refaire la même
mesure — sur la commande la plus chère du lot. Et la question centrale existe en
double avec **deux horizons contradictoires** : « dans six mois » côté audit,
« dans trois mois » côté architecte.

Reporté sciemment le 4 septembre. Les deux horizons se corrigent en un mot, mais
la duplication de fond demande une **décision** : `/flow:audit` mesure lui-même,
ou il délègue — il ne peut pas faire les deux. Ça mérite son propre cadrage, pas
un coin d'un autre lot. Et le défaut ne facture que lorsque `/flow:audit` tourne,
c'est-à-dire « rare, entre deux versions ».

**Règle de tri appliquée ce jour, et qui vaut d'être retenue :** on prend dans un
lot ouvert ce qui vit dans un fichier que le lot ouvre déjà **et** qui se corrige
sans décision nouvelle. Ce point échoue au second critère.

---

## Chantiers en pause

Aucun.

---

## Angles morts

### La bascule de visibilité n'a jamais été constatée de bout en bout

Seul point où la 0.12.0 repose sur une mesure partielle. Détaillé dans
`docs/decisions/0002-visibilite-par-api-et-porte-du-plugin.md`, section « Ce qui
n'est pas prouvé ».

Mesuré : l'appel `PATCH` atteint le bon endpoint, le champ `visibility` est
accepté, l'écriture aboutit, aucun effet de bord. **Pas** mesuré : une
transition réelle — l'essai a écrit `public` sur un dépôt déjà public, donc une
transition nulle.

Le constat manquant se fera au premier usage réel de `/flow:visibilite` ; il
faudra alors recopier les sorties brutes dans la décision `0002`. À ne pas
provoquer exprès : rouvrir un dépôt est l'acte irréversible que la commande
existe pour encadrer.

### Rien de la 0.12.0 ni de la 0.13.0 n'a tourné sous Windows

Les deux lots ont été écrits et vérifiés sur la tour Ubuntu. La version de `gh` du
poste Windows reste **inconnue** — c'est précisément pour ça que plus rien ne
dépend d'une version. Restent deux choses à constater là-bas : que
`sh scripts/verifier-le-plugin.sh` tourne sous Git Bash, et que `.gitattributes`
fait bien arriver le script en LF.

### `/flow:guide` dira « ce dépôt est public » sur un dépôt volontairement public

Cinq des onze dépôts le sont. Choix assumé, argumenté dans la décision `0002` :
une ligne de texte de temps en temps, contre une mécanique déclarative d'un ordre
de grandeur plus chère. Si elle agace à l'usage, la ligne `visibilité attendue`
du Profil projet reviendra comme **silencieux d'alerte** — avec le droit de
rétrograder une alarme en mention, jamais celui d'empêcher la question d'être
posée.

### Le critère 4 de la spec est satisfait par construction, jamais constaté

Il demandait que `/flow:guide`, lancé sur ce dépôt de markdown, ne conseille pas
`/flow:init-project`. Le `CLAUDE.md` écrit par ce lot contient un bloc « Profil
projet », donc la ligne du tableau qui déclenchait ce conseil ne s'active plus.
C'est mécaniquement vrai — mais `/flow:guide` n'a pas été lancé sur ce dépôt
après le lot pour le voir. Une conversation neuve suffira à le constater.

### Le critère 2 de la spec est satisfait par élimination, pas par construction

Il demandait qu'une commande s'arrête proprement sur un `gh` trop ancien. Plus
aucune commande n'emploie de capacité récente : le cas n'existe plus, et le
contrôle 8 du vérificateur en garde la porte. Mais la première commande qui
emploiera une capacité récente fera renaître le besoin intact.

---

## Relevés datés

### 4 septembre 2026 — les trous du vérificateur (0.13.0)

Les cinq trous mesurés par la porte de la 0.12.0 sont bouchés, et le
vérificateur a désormais son propre banc d'essai.

**Le test a été écrit avant la correction, et il échouait.**
`scripts/eprouver-le-verificateur.sh` injecte les défauts un par un dans des
copies jetables du dépôt, et exige que le bon contrôle passe au rouge. Au
premier lancement — avant toute correction — **six cas sur vingt-deux passaient
au vert**, exactement les trous consignés.

**Puis la porte a trouvé que ce test-là était creux, et c'est la leçon du lot.**
Dans la fonction qui lit le verdict d'un contrôle, une variable awk n'était pas
initialisée. En awk, une variable jamais affectée vaut la chaîne vide — qui est
**égale à zéro** dans une comparaison numérique. La fonction répondait donc
« rouge » à tout : les vingt-quatre cas passaient au vert sans rien prouver, y
compris sur une porte cassée. Le banc a été refait, puis soumis à sa propre
contre-épreuve : quatre affaiblissements délibérés de la porte — contrôle des
fins de ligne réécrit naïvement, contrôle des agents rendu aveugle à la forme
liste, garde anti-retour retirée, compteur de rouges débranché — le font
désormais échouer, chacun d'une façon distincte.

Quatre disciplines en sont sorties, chacune apprise d'un faux verdict constaté :
un cas qui n'a pas **tourné** n'est jamais compté réussi (ni une copie ratée, ni
un Ctrl-C) · une mutation qui n'a rien **changé** est signalée, pas comptée · un
contrôle **IGNORÉ** n'est ni un rouge ni un trou, mais un cas non concluant —
sans quoi le banc devenait rouge sur un dépôt sain dès que `python3` manque,
c'est-à-dire sur le poste Windows · et le banc lit le **code de sortie** de la
porte autant que son texte, parce que c'est lui, et lui seul, que la CI regarde.

Il pose enfin la **réciproque** : un changement légitime doit laisser la porte
verte. Sans ces contre-exemples, un contrôle qui rougirait sur tout passerait
chaque cas avec les félicitations.

Ce qui a été bouché : la citation d'une commande est vérifiée **entière**
(`/flow:mutationX` ne vaut plus `/flow:mutation`) · les agents sont contrôlés
comme les commandes — frontmatter renseigné —, et **ceux que `/flow:verify`
convoque doivent exister**, ce qu'une suppression pure et simple ne déclenchait
pas · la clé `source` de `marketplace.json` doit pointer vers un plugin réel ·
un dixième contrôle interroge **git** sur la fin de ligne effective des scripts,
plutôt que de lire `.gitattributes` — la propriété survit ainsi à toute
réécriture du fichier · le décompte des contrôles est **compté à l'exécution**,
plus jamais écrit en dur, ni dans le script, ni dans le README, ni dans le nom
du job d'intégration continue.

Deux vrais défauts de la porte ont aussi été trouvés par cette revue, et
corrigés : le contrôle des agents ne connaissait qu'une écriture de la ligne
`tools:` — un agent qui réclamait `Edit` sous la forme d'une liste à tirets
passait au vert · et le contrôle de version, qui compare le dossier de travail à
la branche par défaut, ne voyait **pas les fichiers non suivis**, c'est-à-dire
précisément l'ajout d'un fichier neuf, au moment précis où `/flow:verify` tourne
— avant le commit de `/flow:ship`.

Au passage : les deux scripts acceptent `--aide` et refusent un argument inconnu
avec un code de sortie distinct, au lieu de l'ignorer en silence.

Le banc tourne aussi dans l'intégration continue, à côté de la porte. Sans lui,
« tous les contrôles sont verts » ne dit rien de ce que ces contrôles savent
détecter.

### 4 septembre 2026 — portabilité double machine (0.12.0)

Conception attaquée par six angles indépendants, puis douze objections passées à
une réfutation adverse : six retenues, six réfutées. Renversement principal : la
décision « déclarer la visibilité attendue dans le Profil projet » a été
**abandonnée** — quatre angles ont montré que le compromis de coût qui la
justifiait n'existait pas (le budget de `/flow:guide` se compte en appels
d'outils, et l'appel se replie dans la ligne groupée existante : zéro appel de
plus).

Livré : bascule de visibilité par l'API REST · `/flow:guide` interroge GitHub ·
`format` spécifiée comme commande de vérification · `scripts/verifier-le-plugin.sh`
(neuf contrôles) et sa CI · `.gitattributes` · le `CLAUDE.md` du dépôt ·
`ux-reviewer` doté d'une ligne `tools:`.

**Cinq défauts du registre fermés :**

- *La commande `format` n'est spécifiée nulle part* → elle **vérifie**.
  `verify.md`, `init-project.md` et le README le disent désormais.
- *`/flow:guide` ne voit pas un dépôt laissé ouvert depuis une autre machine* →
  il le demande à GitHub, et la précédence GitHub / témoin est écrite noir sur
  blanc.
- *Le plugin n'a aucune vérification sur lui-même* → neuf contrôles, soit deux de
  plus que les cinq envisagés : le frontmatter de chaque commande (sans lui, la
  commande disparaît de l'autocomplétion — panne totale, invisible, et qui
  n'était couverte par rien) et l'interdiction de la sous-commande d'édition de
  dépôt de `gh`.
- *`ux-reviewer` peut écrire dans le code* → **le défaut était mal formulé.** Les
  quatre agents peuvent écrire : `Bash` y suffit (`sed -i`, une redirection), et
  les prompts des trois autres leur **ordonnent** de s'en servir. Une ligne
  `tools:` déclare une intention, elle ne construit pas de barrière. Corrigé
  quand même — `ux-reviewer` a sa ligne, sans `Edit` ni `Write`, et le contrôle 4
  l'exige des quatre — mais la vraie garantie est ailleurs, et elle est
  maintenant écrite dans l'agent : le travail se fait sur une branche dédiée, et
  `git status` à la porte montre tout ce qui a bougé.
- *Le README paraphrase les onze commandes à la main* → **fermé sans toucher au
  README.** Le diagnostic était faux : ce qui avait été mesuré, ce sont quatre
  **écarts** entre le README et les commandes — un problème de cohérence, que le
  contrôle 2 attrape mécaniquement dans les deux sens pour trois lignes de
  script. La longueur, elle, n'a jamais rien cassé. Et le registre écrivait
  lui-même l'argument qui condamnait sa conclusion : « c'est le seul endroit où
  un non-développeur relit comment fonctionne son propre outil ; quand il est
  faux, il n'y a pas de seconde source. » Un document dont on dépend à ce point
  doit être redondant — la redondance y est une fonctionnalité, pas une dette.

**Ce que la porte a trouvé et fait corriger avant la livraison.** Six relecteurs
— les quatre agents du plugin plus un angle sécurité et un critique de
complétude — ont rendu 63 constats ; 24 sont passés à une réfutation adverse,
dont 11 ont été réfutés. Les quatre corrections qui comptent, toutes reproduites
sur des copies avant et après :

- **Le vérificateur mentait à chaque exécution.** `ignore()` ne comptait rien,
  donc la conclusion annonçait « les neuf contrôles sont verts » alors que le
  contrôle 6 était IGNORÉ. Et il l'était **à chaque passage de la porte** : le
  contrôle comparait `HEAD` à `origin/main`, or `/flow:verify` tourne avant le
  commit de `/flow:ship`. Le contrôle qui garde la panne silencieuse du bump
  était donc inerte exactement quand on le lançait. Corrigé deux fois : la
  question devient « le dépôt diffère-t-il de la branche par défaut ? », et un
  contrôle ignoré est désormais dit comme tel (« PASSE avec réserves »).
- **Le vérificateur amputait l'historique.** `git fetch --depth=1`, dans la
  commande `test` que `/flow:verify` lance « parce qu'un check ne modifie
  rien », posait `.git/shallow` sur un clone privé de la ref `origin/main` :
  24 commits ramenés à 1. Mesuré, corrigé, revérifié (23 avant, 23 après).
- **Le contrôle 1 était auto-réalisateur** : il comparait les dix blocs entre
  eux, jamais à un contenu. Vider les dix de la même façon passait au vert.
- **Le contrôle 6 acceptait une version qui recule** — `0.10.0` face à `0.11.0`
  sur la branche par défaut passait au vert, alors que l'effet est identique à
  une absence de bump.

**Les neuf contrôles ont ensuite été éprouvés par mutation** : treize défauts
injectés un par un dans des copies du dépôt, treize attrapés par le bon
contrôle — dont les deux qui passaient au vert avant les corrections ci-dessus.
Plus le recul de version, l'ignoré compté, et l'historique préservé, vérifiés
séparément. C'est l'épreuve que `/flow:mutation` exige, appliquée d'avance.

**Corrigé en passant, hors registre :** `/flow:release` étape 2 traitait une
sortie vide de `gh run list` comme une CI verte — mesuré : zéro ligne, code de
sortie 0. Sur un dépôt sans intégration continue, la porte de publication
laissait passer une version que rien n'avait testée. Ce lot publiant justement
depuis ce dépôt-là, le défaut allait être rencontré immédiatement.
