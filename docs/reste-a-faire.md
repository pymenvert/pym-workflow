# Reste à faire

Ce que l'on sait imparfait, et qui n'a pas encore été corrigé.

Ce fichier fait autorité sur ce qui est **ouvert**. Les décisions de structure
vivent dans `docs/decisions/`, les cadrages dans `docs/specs/`, et ce qui s'est
passé — portes, livraisons, incidents, versions — dans `docs/journal.md`. Ne rien
dupliquer entre les quatre.

Dernière mise à jour : 5 septembre 2026, après le bilan de santé de la 0.16.0 — le
premier ; il a fermé l'angle mort du critère 4 (le guide lancé le 4 septembre n'a
pas conseillé `/flow:init-project`), réécrit trois items, et ajouté quatre points
à corriger.

---

## Bilan de santé du 5 septembre 2026 (version 0.16.0)

Premier bilan sous cette forme, lancé par la publication de la 0.16.0.
Relecteurs convoqués : `architect` en dérive sur tout le dépôt, `test-engineer`
sur les deux scripts ; `ux-reviewer` sans objet, ni interface ni exécutable.
Journal lu : deux portes, deux livraisons, une version. Indicateurs : code-reviewer
10 bloquants sur 2 convocations, architect 5 sur 2, 0 incident depuis la v0.15.0.
Ce qui se répète : « non vérifié : Windows » et « la chaîne avec la version
installée » à chaque porte ; l'architecte trouve à chaque convocation.
Dépendances : aucune, sans objet.

### À corriger avant la prochaine version

1. ~~fait le 5 septembre (0.16.1)~~ **Remplir les « ? » d'une ligne d'incident la réécrit**, et `merge=union` en
   fait un doublon silencieux à la fusion — mesuré dans une copie : deux
   incidents comptés pour un, et le guide propose pour toujours une panne déjà
   corrigée. Corriger : on n'édite jamais, on **ajoute** une ligne pour le même
   objet ; l'audit compte par objet ; le guide cherche l'objet dont la dernière
   ligne porte « cause : ? ».
2. ~~fait le 5 septembre (0.16.1)~~ **Un bilan périmé reste au registre pour toujours** : à la troisième version,
   trois bilans rayés, soit les relevés que la décision `0005` voulait sortir
   d'ici. Corriger : un bilan neuf remplace le précédent ; ses « à corriger »
   non rayés remontent dans « Défauts constatés ».
3. ~~fait le 5 septembre (0.16.1)~~ **La commande de calcul compte zéro en silence** sur une ligne mal formée —
   mesuré : `code-reviewer : 5` avec deux-points, « ; » au lieu de « , »,
   « aucun », une puce « • » — et c'est ce zéro qui rend un relecteur rare.
   Corriger : signaler « illisible » au lieu de compter, et l'éprouver au banc.
4. ~~fait le 5 septembre (0.16.1)~~ **Deux trous mesurés dans la porte** : un en-tête de commande jamais refermé
   passe le contrôle 3 (PASSE, mesuré) ; une liste de relecteurs illisible dans
   `verify.md` vide la liste attendue du contrôle 4, et un agent supprimé passe
   (mesuré). Corriger : une garde d'une ligne chacun, un cas au banc chacun —
   le gel interdit un contrôle neuf, pas de boucher un trou mesuré.

### Dette assumable

- `README.md`:21 affirmait cinq appels `gh` vérifiés sur la tour ; les commandes
  en emploient huit sous-commandes. Le README le dit désormais ; les trois autres
  restent à constater au premier `/flow:ship` réel sur la tour.
- ~~fait~~ La Boussole (`CLAUDE.md`, `init-project.md`) ne voit pas une panne ouverte,
  le guide oui : alignée avec le point 1 le 5 septembre.
- Le banc : ~~ses réciproques n'ont pas la garde « rien changé »~~ (fait) ; sept cas
  visent par numéro de ligne ; ~~la réciproque « cinquième agent » ne prouve pas
  son titre~~ (renommée) ; ~~un tuyau coupé laisse une copie dans le dossier
  temporaire~~ (PIPE piégé). Et le contrôle 6 attend le réseau sans limite de temps.
- `release.md` : une liste numérotée où cinq lots inséreront une étape ; à
  réorganiser en sections fixes, comme `audit.md`.
- La forme de la ligne de journal vit à douze endroits, et son premier champ —
  la date, sans heure — est le seul sans étiquette : le changer migrera tous les
  journaux. C'est, selon l'architecte, la partie la plus pénible à modifier.
- Renvois par numéro de ligne déjà faux : la décision `0004` cite `guide.md`:44
  pour une précédence qui est à :69.

### Ce que ce bilan n'a pas pu voir

Windows et Git Bash — rien depuis la 0.12.0 —, gawk, `gh` appelé par un script,
ce que Claude Code fait d'un en-tête mal formé, `merge=union` sur deux branches
réelles, et une ligne de journal écrite par une commande installée.

## Défauts constatés

### Le bloc partagé a grossi de 83 % dans le lot qui devait le garder court

Mesuré par la porte du 5 septembre : 1 887 → 3 451 octets (après une première
coupe depuis 3 752), chargé jusqu'à cinq fois par chaîne. Le contrôle 1 garantit
son identité, rien ne tient sa taille. Piste de l'architecte : ne garder que ce
qui fait foi, vers 2 300 octets. Laissé ouvert pour mesurer d'abord une chaîne
réelle plutôt que couper au jugé.

### Les quatre raisons sont paraphrasées à six endroits que rien ne garde

README, `guide.md` (deux fois), `init-project.md`, le plan, la décision `0004`.
Le bloc partagé fait foi ; une paraphrase qui dérive ne rougit pas. À relire à
chaque lot qui les touche — le lot 4 en premier, si une convocation de l'expert
sécurité exige une décision.

### « La tâche en cours » n'a pas de fin définie

Un mot de l'auteur (« attends », « enchaîne ») l'emporte sur le profil « pour la
tâche en cours », mais rien ne dit où finit une tâche dans une conversation, donc
combien de temps dure ce frein. Constaté par l'architecte le 5 septembre ; à
trancher après une tâche réelle, pas avant.

### La forme du cycle est écrite à sept endroits

Le README (trois fois), la section « cycle » de `guide.md`, le plan (deux fois),
la décision `0004` — mesuré par le bilan du 5 septembre ; le `CLAUDE.md` de ce
dépôt, lui, ne la porte pas. Le mode incident (lot 2) et `/flow:studio`, s'il vient, les changeront
tous à la main.

### Laissé ouvert par la porte du 5 septembre 2026, lot 2 (0.16.0)

- **Les incidents se comptent au jour près.** Un incident noté le jour d'une
  étiquette compte pour la période suivante ; sur ce dépôt, quatre versions en
  deux jours, l'indicateur sera flou tant que les lignes n'ont pas d'heure.
- **La forme d'une ligne de journal vit à sept endroits** (quatre commandes,
  l'en-tête, le README, la décision `0005`), rien ne la garde. L'en-tête de
  chaque journal fait foi ; les autres copies sont tenues à la relecture.
- **Un conflit sur `docs/journal.md` dans l'interface web de GitHub** n'est pas
  réglé par `merge=union`, qui ne vaut qu'en local ; `/flow:ship` dit alors à
  l'assistant de ramener la branche par défaut et de trier par date.
- **Le banc vise `audit.md` par numéros de ligne** (24 et 28) : le prochain lot
  qui touche le haut du fichier déplace les cibles sans que rien ne le dise.
- **`release.md` est la partie la plus pénible à modifier** selon l'architecte :
  une liste numérotée où cinq lots insèreront une étape, la seule commande qui
  écrit sur la branche par défaut, et un CHANGELOG qu'elle lit sans exister ici.
- ~~fait~~ **Une case `bloquants : ?` entière** produisait un relecteur fantôme ;
  la commande la dit désormais « illisible ».

### Laissé ouvert par la porte du 5 septembre 2026, corrections du bilan (0.16.1)

- **Une case « Bloquants : » en majuscule ou « bloquants: » sans espace** n'est
  pas reconnue par la commande de calcul, en silence : une porte sans relecteur
  étant légitime, elle ne peut pas crier sur l'absence. À surveiller sur les
  journaux écrits à la main.
- **Un en-tête YAML avec une ligne vide à l'intérieur** ne rougit plus (la garde
  du contrôle 3 cherche un titre de section, pas la première ligne vide) ; mais
  `--- ` avec une espace finale reste « jamais refermé ». Acceptable, à connaître.
- **Les cas de banc par numéro de ligne** sont désormais neuf ; la garde « rien
  changé » les fait échouer bruyamment le jour où la mise en page bouge.


Son glossaire dit « un jeton d'accès est un secret » et nomme test-engineer sans
accents graves — exprès, pour que le guide ne devienne pas une commande arbitre
du contrôle 11. Le jour où « secret » entre dans la table du contrôle et où
`guide.md` cite un agent entre accents graves, ces deux lignes rougissent.
Mesuré par l'architecte le 5 septembre. Même chose pour `audit.md` : sa phrase sur
les « failles connues » et `npm audit` rougira dès que « faille » ou « secret »
entrera dans la table sans citer `securite` — `audit.md` est déjà arbitre.

### Trois écritures contournent encore la garde des préoccupations

Mesurées par la porte du 4 septembre, laissées ouvertes : le terme **coupé par un
retour à la ligne**, écrit avec une **espace insécable**, ou portant du **gras à
l'intérieur** (`code **mort**`) passe tous les trois. La normalisation de la
ligne — insécables et astérisques retirés avant la recherche — les fermerait ;
elle n'a pas été faite dans ce lot pour ne pas empiler une quatrième
transformation sur une garde déjà refaite deux fois le même jour.

### La garde du contrôle 11 ne rattrape ni une paraphrase, ni les deux préoccupations neuves

Deux limites assumées, écrites dans la décision `0003`.

`audit.md` disait « code exporté jamais utilisé » là où `architect` dit « code
mort » : aucun grep par termes n'attrape une reformulation. Le compte honnête est
que la garde couvre **quatre recouvrements sur cinq** — le cinquième ne se voit
qu'à la relecture.

Et la table ne protège que des sujets anciens : « tenue en conditions réelles » et
« première exécution » n'ont pas de terme gardé. Elles peuvent se dédoubler demain
sans que rien ne le dise.

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
2. ~~fait le 5 septembre (0.16.1)~~ **Une sortie envoyée dans `head` ou `less` laisse une copie du dépôt dans le
   dossier temporaire.** Le nettoyage passe par un piège sur la sortie du
   script ; interrompu par un tuyau fermé, il peut ne pas s'exécuter. Sans
   conséquence sur le verdict, mais ça encombre.

### `/flow:guide` propose de concevoir un cadrage déjà réalisé

Il apparie cadrages et décisions par leurs noms de fichiers, sans lire leur
contenu (`guide.md`:10 et :43). Un cadrage absorbé par une décision qui ne porte
pas son nom, comme `audit-et-architect-en-double.md` par la `0003`, lui paraît
donc sans décision, et il propose `/flow:design` dessus : constaté le 4 septembre
2026 au soir. La mention « Réalisé » posée en tête du cadrage ne le corrige pas,
puisqu'il ne l'ouvre pas. Correctif prévu au lot 3 de `docs/plan-studio.md` ;
d'ici là, ne pas suivre cette proposition. Le bilan du 5 septembre 2026 mesure
qu'**aucun des six cadrages** ne partage un nom avec sa décision : lancé ici, le
guide proposerait `/flow:design` six fois.

---

## Chantiers en pause

Aucun.

---

## Angles morts

### L'enchaînement des commandes n'a jamais été constaté

Le lot 1 (0.15.0) fait se suivre les commandes du cycle sans attendre : chacune
charge la suivante par l'outil qui invoque une compétence. Mesuré le 5 septembre,
avec les commandes de la 0.14.1 encore installées : cet outil est disponible à
l'assistant en cours de conversation, et une commande en a chargé une autre depuis
l'intérieur de la chaîne — l'implémentation a lancé la porte, qui a lancé la
livraison. **Pas** mesuré : la même chaîne avec les commandes de la 0.15.0, ce que
devient une chaîne après résumé de la conversation, et son coût en jetons contre
une tâche pas à pas. Les trois se constatent à la première tâche réelle en rythme
enchaîné, dans une conversation neuve avec le plugin mis à jour ; d'ici là, le
lot 1 est « à constater », pas « constaté ». Même chose pour le lot 2 : les trois
premières lignes du journal sont reconstituées, les suivantes écrites à la main
dans la forme, puisque les commandes installées sont encore celles d'avant.

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

### Rien n'a tourné sous Windows depuis la 0.12.0

Les deux lots ont été écrits et vérifiés sur la tour Ubuntu, et les quatre
versions suivantes, jusqu'à la 0.16.0, de même. La version de `gh` du
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

### Le critère 2 de la spec est satisfait par élimination, pas par construction

Il demandait qu'une commande s'arrête proprement sur un `gh` trop ancien. Plus
aucune commande n'emploie de capacité récente : le cas n'existe plus, et le
contrôle 8 du vérificateur en garde la porte. Mais la première commande qui
emploiera une capacité récente fera renaître le besoin intact.

---

## Relevés datés — clos à la 0.15.0

Depuis la 0.16.0, ce qui s'est passé s'écrit au journal, `docs/journal.md`, une
ligne par événement (décision `0005`). Les relevés ci-dessous restent tels quels.

### 5 septembre 2026 — le rythme et la pédagogie (0.15.0)

Lot 1 du plan studio, cadré, conçu, implémenté et livré en une seule conversation,
en autonomie, à la demande de l'auteur. Le bloc partagé des dix commandes définit
le rythme, les quatre raisons de s'arrêter et le point de passage ; les six
commandes du cycle portent un paragraphe « Arrêts et suite » ; `/flow:design`
pose ses choix dans la forme « Décision » ; les quatre agents ouvrent par
« Pour toi » ; `/flow:new-feature`, `/flow:verify` et `/flow:ship` finissent par
un « Compte-rendu » d'une seule forme ; `/flow:guide <mot>` explique dix-sept
mots. Décision `0004`. Aucun contrôle ni cas de banc ajouté : le vérificateur est
gelé par le plan.

**Ce que la conception a perdu à l'attaque.** L'architecte a fait tomber deux
pans : la règle « charge la suivante » dans le bloc partagé (dans `visibilite.md`,
son seul candidat plausible aurait été `/flow:release`, la commande irréversible)
et l'affirmation du plan que le lot « fait économiser des jetons » — une chaîne
fait relire la conversation à chaque appel ; il économise des relances.

**Ce que la porte a trouvé.** Deux relecteurs, `code-reviewer` et `architect` en
mode dérive ; sept bloquants, tous corrigés avant la livraison : la conception
disait qu'un acte irréversible me revient mais son paragraphe d'arrêts ne le
listait pas · la livraison lançait la porte, ce que le bloc interdisait (« jamais
vers l'amont ») — c'est désormais la seule remontée admise, écrite dans
`/flow:ship` · l'implémentation ordonnait de ne rien demander sur les fichiers
modifiés, ce qui aurait fait suivre un fichier étranger dans la branche · le
compte-rendu de la porte n'avait pas la forme des deux autres · « des trois »
resté dans le README, « refactoring » non traduit dans la décision · et le bloc
partagé avait doublé (1 887 → 3 752 octets) dans le lot qui exigeait qu'il reste
court — coupé à 3 451, le reste est dans les défauts constatés. Les six
paragraphes « Arrêts et suite » avaient quatre formes ; ils en ont une.

**Le mécanisme d'enchaînement a tourné une fois**, avec les commandes de la
0.14.1 : l'implémentation a chargé la porte, la porte a chargé la livraison. Ce
n'est pas le constat du plan — il faut la 0.15.0 installée et une conversation
neuve —, mais c'est la première preuve que l'outil le permet.

**Coût, chiffré.** Trois convocations d'agents : l'architecte à la conception
(143 000 jetons), le relecteur de code (175 000) et l'architecte en dérive
(139 000), soit environ 457 000 jetons d'agents pour un lot de markdown. Le
budget de la conversation entière n'a pas été relevé.

**Non vérifié.** La chaîne avec les commandes de la 0.15.0 ; rien sous Windows ;
`/flow:guide <mot>` jamais lancé.

### 4 septembre 2026 — le plan studio (0.14.1)

Lot de documentation : `docs/plan-studio.md` (le cap du plugin, douze lots, sept
choix qui reviennent à l'auteur), le renvoi du README, la Boussole qui lit le
tableau d'avancement, le cadrage audit/architect marqué réalisé, ce registre
corrigé. Aucune commande ni agent modifié ; la version passe à 0.14.1 parce que
le contrôle 6 l'exige dès qu'un fichier diffère de la branche par défaut.

**Ce que la porte a trouvé.** Deux relecteurs, `code-reviewer` et `architect`
en mode dérive (un fichier créé) ; cinq bloquants, tous corrigés avant la
livraison : le registre affirmait un effet sur `/flow:guide` qui n'existe pas
(il ne lit pas les cadrages) ; le plan disait « ajouter » à l'audit une
délégation en place depuis la 0.14.0 ; un terme anglais non traduit ; la
Boussole lisait le plan par un numéro de ligne (`head -40`), cassé à la première
insertion, remplacé par une lecture des lignes du tableau par leur forme ; et le
défaut du guide vivait dans le plan au lieu de ce registre. Retenu aussi de
l'architecte : plus de numéros de version écrits d'avance dans le plan, un seul
état par lot, `/flow:studio` seulement après un manque constaté, le modèle par
agent après dix portes mesurées, et les conflits précis des lots futurs avec les
contrôles 4, 8, 9 et 11, écrits dans le plan pour ne pas être découverts en
route.

**Coût, et une leçon.** Les deux relecteurs ont été coupés par la limite
mensuelle d'utilisation au milieu de leur lecture, puis repris là où ils en
étaient : environ 530 000 jetons pour la porte d'un lot de markdown, dont deux
lectures interrompues. C'est le chiffre qui motive la section 4 du plan.

**Non vérifié.** Rien n'a tourné sous Windows ; la Boussole modifiée n'a pas
encore été exercée dans une conversation neuve.

### 4 septembre 2026 — un propriétaire par préoccupation (0.14.0)

Conception attaquée par cinq angles, dix-huit objections passées à la réfutation
adverse, **dix retenues** — dont trois qui ont démoli des pans entiers de la
proposition initiale.

**Ce lot règle aussi le recouvrement `/flow:audit` ↔ `architect`**, cadré dans
`audit-et-architect-en-double.md` : le détail est dans la décision `0003`, pas
ici. Ce registre l'a pourtant listé comme ouvert jusqu'au 4 septembre 2026 au
soir, où le plan studio l'a retiré ; le défaut du guide qui en découle est dans
les défauts constatés.

**Ce qui est tombé, et pourquoi c'est le plus utile de ce lot :**

- *Répartir par terme* — chaque mot à un seul agent. Mesuré : `code-reviewer` est
  le **seul agent convoqué à chaque porte**, les trois autres sont
  conditionnels. Lui retirer « duplication » aurait supprimé toute détection sur
  la majorité des passages. Le partage se fait donc **par objet** : le lot en
  cours pour lui, le dépôt entier pour `architect`.
- *La garde limitée aux agents* — elle ratait **trois doublons sur cinq**, dont
  celui d'`audit.md` qui a motivé la spec. Mesuré : agents seuls → 2 rouges,
  agents + commandes → 5.
- *Le renvoi reconnu à la co-occurrence* — « duplication d'une **architecture**
  inutile » passait pour un renvoi à `architect`. Il faut les accents graves,
  exactement la parade déjà inventée pour `/flow:mutationX`.
- *Le motif « un cinquième agent coûte des tokens »* — écarté comme argument
  principal : le dépôt ne s'est jamais donné de budget en tokens, et le brandir
  ici aurait été un critère inventé pour l'occasion. Le vrai motif est que les
  deux préoccupations neuves sont de **même nature** que ce que possèdent déjà
  `test-engineer` et `ux-reviewer`.

**Un trou trouvé par le banc, dans le contrôle neuf lui-même :** `architect`
gardait le mot « duplication » dans son propre bloc « Ce que tu ne fais pas », ce
qui suffisait à faire croire qu'il possédait encore la préoccupation. La règle de
présence ignore désormais ce bloc.

**Coût, chiffré comme le critère 7 l'exige.** Toujours actif : **strictement
inchangé** — aucune description de frontmatter modifiée, pas de cinquième agent.
À la convocation : **+36 %** si les quatre tirent (13 133 → 17 865 octets ;
architect +17 %, code-reviewer +37 %, test-engineer +51 %, ux-reviewer +37 %).
`ux-reviewer` tirera un peu plus souvent, sa convocation s'étendant à ce qui
construit l'exécutable.

Le banc passe de 32 à **44 cas**, dont dix neufs sur les deux gardes et deux
réciproques : un renvoi légitime écrit depuis une commande, et un terme employé
en prose ordinaire par une commande qui ne convoque aucun relecteur.

**Ce que la porte a trouvé, et fait corriger avant la livraison.** Cinq
relecteurs — les quatre agents jugeant leur propre refonte, plus un critique de
complétude — ont rendu 45 constats ; 18 sont passés à une réfutation adverse,
dont 10 ont été réfutés. Les sept retenus sont tous corrigés. Les trois qui
comptent :

- **Le banc était structurellement incapable de signaler un trou dans le contrôle
  11.** Sa fonction de lecture suivait le numéro de section, et le récapitulatif
  final (« PASSE avec réserves… 1 IGNORÉ ») était attribué au **dernier**
  contrôle. Tout cas visant le 11 et resté vert ressortait « non concluant », avec
  un motif inventé (« outil absent »), et le banc sortait 0. C'est la **deuxième
  fois** que cette même fonction ment par sa lecture.
- **La garde exemptait la ligne entière.** `audit.md` écrit un paragraphe par
  ligne, et sa ligne 24 cite légitimement `architect` : tout ce qu'on y greffait
  devenait invisible. La maille est devenue la **phrase** — ce qui a fermé du
  même coup l'angle mort qu'on croyait irréductible, celui d'une phrase citant le
  propriétaire pour ordonner le contraire.
- **La règle de présence reposait sur un titre que rien ne protégeait.** Renommer
  « ## Ce que tu ne fais pas » rendait l'exclusion inopérante, et le mot laissé
  dans un renvoi suffisait alors à prouver une couverture disparue. D'où le
  contrôle 12.

Deux faux positifs introduits par ces corrections ont été trouvés par le banc
lui-même et réparés : un renvoi de `code-reviewer` coupé entre deux phrases, et
une commande sans relecteur rougie pour un emploi innocent — d'où un périmètre
désormais **calculé** plutôt qu'écrit en dur.

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
