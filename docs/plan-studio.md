# Plan studio : ce que `flow` doit devenir

Écrit le 4 septembre 2026 à la demande de Pym, après lecture complète du plugin : onze commandes, quatre agents, quatre cadrages, trois décisions, deux scripts.

**Ce que ce document est.** Le cap. Il dit ce que le plugin doit devenir pour jouer le rôle d'un studio d'experts qui conseille et développe, pour tout type de programme (outil de régie, script, serveur, site), et dans quel ordre y aller.

**Ce qu'il n'est pas.** Il ne remplace ni `docs/reste-a-faire.md` (ce qui est cassé aujourd'hui), ni `docs/specs/` (le cadrage d'un lot), ni `docs/decisions/` (les choix tranchés et leurs raisons). Il les ordonne, il ne les duplique pas.

**Comment il s'emploie.** Un lot qui s'ouvre sur ce dépôt nomme l'item de ce plan qu'il réalise, ou l'app réelle dont le besoin l'a fait naître. Sans l'un des deux, il attend. Un lot n'est terminé que lorsqu'il a été **constaté sur une vraie app**, pas seulement écrit dans le plugin.

## Avancement

| Lot | Objet | État |
|---|---|---|
| 0 | Ce plan, le cap dans la Boussole, le registre corrigé | livré avec la 0.14.1, le 4 septembre 2026 |
| 1 | Le rythme enchaîné, la décision expliquée, les rapports « pour toi » ; `/flow:studio` seulement si le manque se constate | livré dans la 0.15.0 le 5 septembre 2026 (décision `0004`), à constater sur une app |
| 2 | Le journal, le mode incident, l'audit redéfini en bilan de santé à la version | à faire |
| 3 | Le profil étendu, la fiche produit, la liste à faire | à faire |
| 4 | L'expert sécurité `securite` et ses automates | à faire |
| 5 | La conception d'interface avant le code | à faire |
| 6 | Le socle par type : bureau, ligne de commande, script, temps réel | à faire |
| 7 | Livrer un exécutable comme un pro | à faire |
| 8 | Endurance et simulateurs | à faire |
| 9 | Le socle web et serveur, et la mise en ligne | quand un projet web ou serveur l'appelle |
| 10 | Le rédacteur et l'entretien | à faire |
| 11 | Les tests de GitHub sur la tour, le retrait de `/flow:visibilite` | après le choix 2 (section 13) |
| 12 | Bilan chiffré sur dix tâches réelles, roster ajusté, README réécrit | quand le journal le permet |

États possibles : à faire · livré, à constater sur une app · constaté. Les numéros de version ne sont pas écrits ici : seul `plugin.json` en fait foi, et ils se décident à chaque livraison.

Règle de cadence : entre deux lots de plugin, au moins une tâche réelle sur une app, faite avec le plugin. C'est elle qui constate le lot précédent.

---

## 1. La promesse

Ce que tu dois ressentir : « Je passe la porte d'un studio. Il prend mon projet, me pose les seules questions qui m'appartiennent, tranche le reste en m'expliquant, construit, prouve, livre. À chaque instant je sais où on en est, pourquoi, et à quoi ça sert. Le résultat est premium, robuste, testé. »

Trois engagements en découlent, et tout le reste du plan les sert :

1. **Le studio conseille avant de construire.** Il comprend le besoin, propose, attaque sa propre proposition, puis décide ou fait décider.
2. **Le studio construit et prouve.** Rien n'est déclaré fait sans une preuve lancée : un test, une mesure, une capture, une commande exécutée. Ce que la porte n'a pas pu voir est écrit noir sur blanc.
3. **Le studio explique tout, tout le temps, sans jargon.** Chaque étape dit pourquoi elle existe ; chaque rapport commence par ce que ça change pour toi ; chaque choix qui te revient est présenté de façon à être tranché sans culture technique.

Ce qui existe déjà et tient cette promesse : le cycle spec → design → new-feature → verify → ship, la porte qui a le droit de dire non, les décisions tracées, le registre de ce qui reste à faire, `/flow:guide` et la Boussole. On ne le refait pas. On le complète.

## 2. Qui décide quoi, et comment le studio explique

### Le partage des décisions

| Décision | Qui tranche | Comment |
|---|---|---|
| Le besoin, l'usage, ce qui ne doit jamais arriver | **Toi** | Le studio pose la question, au plus trois par cadrage, uniquement celles dont la réponse change le travail |
| Les priorités : quoi d'abord | **Toi**, sur proposition | Le studio propose un ordre avec ses raisons (valeur, risque, dépendance) ; tu confirmes ou tu changes |
| L'apparence et l'expérience : ce qu'on voit, ce qu'on ressent | **Toi**, sur proposition | Le studio conçoit les écrans et les états, les fait attaquer, puis te montre ; tu tranches le goût, il tranche la cohérence |
| L'argent, les abonnements, les engagements | **Toi** | Toujours une décision expliquée, jamais une surprise sur une facture |
| Les actes irréversibles ou publics | **Toi** | Tag de version, mise en ligne, visibilité, suppression : accord explicite à chaque fois |
| L'architecture, les outils, les bibliothèques, la structure des tests, la sécurité | **Le studio** | Il tranche, écrit la décision et ses raisons, et te l'annonce dans la forme ci-dessous. Tu peux poser ton veto, mais il n'attend pas ta réponse pour avancer |

La ligne qui change tout est la dernière. Aujourd'hui `/flow:design` te montre la conception et attend. Demain il **annonce** les choix d'architecture au lieu de les **demander**, sauf quand le choix touche une ligne qui t'appartient : de l'argent, un engagement, une conséquence que tu sentiras à l'usage. Un choix technique pur ne t'est jamais posé comme une question, parce que tu n'as pas à en porter la charge : il t'est expliqué, tracé dans `docs/decisions/`, et réversible.

### La décision expliquée

Quand un choix doit passer par toi, il prend toujours cette forme, dans cet ordre :

```
**Décision : <cinq mots>**
De quoi il s'agit, et pourquoi ça se décide maintenant : une phrase.
Ce que ça change pour toi : en temps, en argent, en risque, en ce qu'on pourra ou ne pourra plus faire ensuite.
Option A, recommandée : ce qu'elle apporte · ce qu'elle coûte · quand on la regretterait.
Option B : idem. Trois options au plus.
Si on se trompe : ce que coûte de changer d'avis plus tard.
Ce que je te demande : une réponse en un mot.
```

Cinq règles l'accompagnent :

- **Jamais une question dont la réponse est dans le code.** Le studio lit ; il ne te fait pas lire.
- **Jamais une question de culture technique.** « Base de données relationnelle ou document ? » n'est pas ta question. La tienne est « les données doivent-elles survivre à une coupure de courant en plein spectacle ? ». Le studio traduit l'une en l'autre.
- **La recommandation d'abord**, avec sa raison. Un studio qui présente trois options à plat n'a pas fait son travail.
- **Les conséquences en termes vécus** : des minutes de démarrage, des euros par mois, des jours de travail, ce qui devient impossible. Pas des noms de composants.
- **Une image quand ça aide.** Une analogie juste vaut trois paragraphes.

La même forme, sans la dernière ligne, sert à **annoncer** une décision du studio. Tu la lis ; tu n'as rien à répondre.

### Les rapports « pour toi »

Chaque rapport d'expert (les agents) s'ouvre par trois lignes sans aucun terme non traduit :

```
**Pour toi.** Ce que j'ai regardé : … · Ce que ça change pour ton logiciel : … · Ce que je recommande : …
```

Puis viennent les constats hiérarchisés, écrits pour le studio, avec fichiers et lignes. Aujourd'hui la pédagogie vit dans les commandes (les trois lignes de fin, les arrêts annoncés) et pas dans les rapports des agents, qui parlent à un développeur. C'est là qu'elle manque.

### Le point de passage, le compte-rendu, le journal, le glossaire

- **Le point de passage.** À chaque transition entre deux étapes enchaînées, trois lignes visibles : ce qui vient d'être fait, ce qui a été décidé ou constaté, ce qui commence. C'est ce qui permet de relire un fil de deux heures en trente secondes.
- **Le compte-rendu de livraison.** À la fin de `/flow:ship`, un paragraphe écrit pour toi : ce que ton logiciel fait maintenant qu'il ne faisait pas, ce qui a été vérifié, ce qui reste. Recopié dans la pull request (la demande de fusion sur GitHub) et dans le journal.
- **Le journal** (`docs/journal.md`), écrit par les commandes, lu par l'audit et par toi. Section 11.
- **Le glossaire.** `/flow:guide <mot>` explique un mot du métier en trois lignes et un exemple tiré de ton projet. C'est le même recours que « je fais quoi ? », étendu à « ça veut dire quoi ? ». Le glossaire en fin de document en est la première version.

## 3. Le rythme : enchaîner, et ne s'arrêter que pour de vraies questions

Aujourd'hui trois commandes s'arrêtent systématiquement : `/flow:spec` après ses questions, `/flow:design` après sa proposition, `/flow:new-feature` après son plan. C'est prudent, et c'est trois attentes par tâche pour des réponses qui, la plupart du temps, ne dépendent pas de toi.

### Les quatre raisons de s'arrêter

Le studio ne s'arrête que pour l'une d'elles :

1. **Une question dont la réponse n'appartient qu'à toi** : le besoin, la priorité, l'apparence, l'expérience, « est-ce que je considère ce travail comme fini ? ».
2. **De l'argent ou un engagement** : un service payant, un abonnement, un certificat, un compte à ouvrir.
3. **Un acte irréversible ou public** : le tag de version, la mise en ligne, la fusion sur la branche par défaut, un changement de visibilité, une suppression.
4. **Une porte rouge qu'il ne sait pas rendre verte sans changer le besoin.**

Tout le reste s'enchaîne, avec un point de passage à chaque transition. Le cadrage est écrit et, s'il n'a soulevé aucune question de type 1, la conception commence. La conception est attaquée et, si aucune décision de type 1 ou 2 n'en sort, le plan d'implémentation s'écrit et le code suit. La porte passe, la livraison part, et tu reçois le lien de la pull request avec le compte-rendu. Tu interviens en lisant, pas en débloquant.

Ce qui rend ça sûr : tout se passe sur une branche dédiée, rien n'est fusionné ni publié sans toi, et la porte garde le droit de dire non.

### La porte d'entrée : `/flow:studio <idée>`

Le rythme enchaîné dans les commandes existantes suffit à enchaîner : c'est lui que le lot 1 livre d'abord. La commande d'entrée n'est ajoutée que si, après une tâche réelle en rythme enchaîné, l'entrée unique manque encore, et si le mécanisme d'appel décrit plus bas est confirmé. Douze commandes au lieu de onze, ça se mérite par un manque constaté, pas par une envie.

Une seule commande pour « je passe la porte du studio ». Elle lit la fiche produit, le profil et la liste à faire, classe la demande en quatre tailles, et déroule la chaîne qui convient :

| Taille | Exemple | Chaîne |
|---|---|---|
| Retouche | une faute, un libellé, une couleur | new-feature → verify → ship |
| Correction | « ça plante quand… » | new-feature en mode incident (reproduire d'abord) → verify → ship |
| Fonctionnalité | « je veux pouvoir… » | spec → design → new-feature → verify → ship |
| Structurante | nouveau projet, nouveau format de fichier, dépendance lourde | idem, avec au moins une décision annoncée dans design |

Les onze commandes restent utilisables une à une : `/flow:studio` les appelle, il ne les recopie pas. Claude Code expose chaque commande du plugin comme une compétence que l'assistant peut invoquer lui-même ; c'est le mécanisme à confirmer au lot 1, et s'il ne tient pas, `/flow:studio` reprend les étapes en renvoyant à chaque fichier. Une seule source de vérité par étape : c'est déjà la règle du dépôt.

### Le réglage `rythme` du profil

Une ligne dans le Profil projet : `- rythme : enchaîné` (par défaut) ou `pas à pas` (les trois arrêts d'aujourd'hui). Écrite une fois, lue par toutes les commandes. Un projet qu'on découvre peut mériter le pas à pas ; un projet qu'on connaît ne le mérite plus.

## 4. L'économie : qui paie quand

Le coût du studio se compte en jetons d'IA (les « tokens », l'unité de texte facturée) et en minutes de machine. Le principe : **le cher va au rare, et ce qu'une machine peut vérifier, aucun expert ne le relit.**

| Cadence | Ce qui tourne | Qui paie |
|---|---|---|
| À chaque petit lot de code, plusieurs fois par tâche | format, lint, types, tests ciblés | la machine locale, zéro jeton d'expert |
| À chaque tâche : `/flow:verify` | tous les checks du profil, puis les seuls experts dont l'objet a changé, puis une ligne de journal | le gros du coût courant, borné par la pertinence |
| À chaque version : `/flow:release` | l'audit (bilan de santé), la mutation si la suite de tests a grossi, l'endurance si temps réel ou serveur, la grille sécurité complète, la construction sur trois systèmes, l'essai sur machine vierge, les docs | cher, mais quatre à dix fois par an |
| En continu, sans jetons | la CI (les tests rejoués par GitHub à chaque envoi), les failles connues des dépendances, la détection de secrets, les licences, le robot de mise à jour, la surveillance en ligne, les sauvegardes | des minutes de machine, gratuites ou presque |
| Jamais | un audit par tâche · un expert relancé sur du vide · un expert qui relit ce qu'un automate a déjà vérifié · un rapport qui paraphrase | rien |

Cinq règles d'économie, dont deux existent déjà :

1. **Ce qu'une machine peut vérifier, aucun expert ne le relit.** Formatage, types, failles connues, secrets, licences, poids d'une page, démarrage d'un exécutable : des automates. Les experts cherchent ce que les automates ne savent pas voir.
2. **Le cher va au rare.** Audit, mutation, endurance, grille sécurité complète, construction multi-systèmes : à la version, jamais à la tâche.
3. **Un expert ne tire que si son objet a changé**, et ne lit que ce qui a changé plus le strict contexte. Règle existante de `/flow:verify`, étendue à l'expert sécurité.
4. **La mémoire est dans les fichiers, pas dans la conversation.** Profil, fiche produit, décisions, journal : on ne redemande pas, on ne redétecte pas. `/clear` entre deux tâches reste la règle.
5. **Les rapports sont courts par contrat.** Trois lignes pour toi, puis les constats hiérarchisés, rien de paraphrasé ; rien trouvé tient en une ligne. Un rapport long est un défaut de l'expert, pas une preuve de travail.

Et un levier de plus, qui sert la qualité autant que l'économie : chaque agent peut déclarer, dans son en-tête, le modèle qui le fait tourner. Le plus capable pour ce qui demande du jugement (l'architecte, la sécurité) ; un modèle plus rapide et moins cher pour ce qui est mécanique. Réglage d'une ligne par agent, à fixer seulement après dix portes journalisées : une optimisation sans mesure serait le reproche que la décision `0003` s'est fait à elle-même.

## 5. Les experts du studio

### Le roster

| Rôle | Ce qu'il fait | Dans flow | Lot |
|---|---|---|---|
| Directeur de projet | Tient le fil, explique, arrête pour les vraies questions, rend compte | les commandes elles-mêmes, `/flow:studio`, `/flow:guide`, la Boussole, le journal | lots 1, 2 |
| Analyste produit | Fiche produit, liste à faire priorisée, critères d'acceptation | `/flow:spec`, `docs/produit.md`, `docs/a-faire.md` | lot 3 |
| Architecte | Structure, choix de pile, décisions tracées, dérive | agent `architect`, `/flow:design` | existe ; lot 1 |
| Designer d'interface | Écrans, parcours, états, cohérence, accessibilité, avant le code | agent `ux-reviewer` en contexte A, `/flow:design`, `docs/ecrans/` | lot 5 |
| Développeurs seniors | Branche, plan, petits lots, tests d'abord sur le critique, mode incident | `/flow:new-feature` | existe ; lot 2 |
| Relecteur de code | Bugs, cas limites, textes, conventions, ce que le lot laisse derrière lui | agent `code-reviewer` | existe |
| Expert sécurité | Modèle de menace, durcissement, failles des dépendances, secrets, posture | agent `securite` (nouveau) et des automates de CI | lot 4 |
| Ingénieur qualité | Couverture, doublures, conditions réelles, endurance, mutation, budgets de performance | agent `test-engineer`, `/flow:mutation`, `/flow:endurance` | existe ; lot 8 |
| Ingénieur de livraison et d'exploitation | CI, construction, signature, installeur, mise en ligne, santé, retour arrière, sauvegardes, surveillance | `/flow:init-project`, `/flow:release`, les socles | lots 6, 7, 9 |
| Rédacteur | Manuel, prise en main, dépannage, notes de version | `/flow:release`, `/flow:init-project` | lot 10 |
| Performance, accessibilité, conformité | Budgets mesurés, clavier et contraste, licences et données personnelles | des chapeaux portés par `test-engineer`, `ux-reviewer`, `securite` et l'audit, pas des agents | lots 3, 5, 6, 10 |

Cinq agents, pas plus. La règle de la décision `0003` tient : un agent de plus doit porter une préoccupation qui n'est de la nature d'aucun des autres. La sécurité en est une, la seule : elle pense comme un attaquant quand tous les autres pensent comme une panne.

### Ce qui fait un « meilleur expert »

Huit exigences, communes aux cinq agents, vérifiées à la relecture de chaque prompt (le texte d'instruction d'un agent) :

1. **Il mesure avant de juger.** Commandes lancées, fichiers lus, chiffres : un avis sans mesure n'entre pas dans le rapport.
2. **Il connaît le projet.** Il lit le profil, la fiche produit et les décisions avant d'ouvrir sa grille. Une grille générique appliquée sans contexte donne des remarques justes et inutiles.
3. **Chaque constat a un scénario et une gravité.** Quelles entrées, quel état, quel résultat faux, quelle conséquence. Un doute sans scénario est une suggestion, et il le dit.
4. **Il ne parle que de son objet** et nomme le propriétaire du reste. Règle existante, gardée par le contrôle 11.
5. **Il dit ce qu'il n'a pas pu voir.** La section « non vérifié » n'est pas optionnelle.
6. **Il s'ouvre par « pour toi »**, trois lignes sans jargon. Le reste s'adresse au studio.
7. **Il donne le correctif quand il le peut** : le code du test, le patch, la ligne à changer. Pas une description.
8. **Rien trouvé tient en une ligne.** Un rapport vide est un résultat, sauf pour `ux-reviewer` et `securite`, qui doivent dire s'ils n'ont pas pu regarder.

### Fiche : l'expert sécurité, `securite`

Le rôle que tu as nommé « protection, intrusion ». Il intervient à trois moments.

**À la conception (contexte A), le modèle de menace en langage clair.** Quatre questions : qu'est-ce qui a de la valeur ici (des données, un accès, la machine elle-même, la salle) ; qui pourrait vouloir y toucher (un curieux sur le réseau du théâtre, un robot qui balaie internet, un utilisateur maladroit, un ancien collaborateur avec un mot de passe) ; par où (le réseau, les fichiers ouverts, les formulaires, la mise à jour, les dépendances) ; et quelles trois mesures coûtent le moins pour le plus. Le résultat tient en quinze lignes dans la décision d'architecture, section « Menaces ». Obligatoire pour une page web ou un serveur ; obligatoire pour un outil de régie dès qu'il écoute le réseau.

**À la porte (contexte B), une grille par type de projet**, appliquée à ce qui a changé :

- *Site et application web* : les injections (une entrée qui devient une commande : SQL, HTML, JavaScript), les sessions et l'authentification, la falsification de requête (CSRF), les fichiers envoyés, les en-têtes de sécurité, les secrets, les dépendances.
- *Serveur et service* : qui peut appeler quoi (authentification, autorisation), la limitation de débit, les appels sortants forgés (SSRF), les journaux sans données sensibles, le chiffrement en transit, les secrets hors du code, les délais d'attente.
- *Bureau et ligne de commande* : les chemins de fichiers construits depuis une entrée, la lecture de fichiers au format complexe, les privilèges demandés, l'intégrité des mises à jour, le stockage des secrets dans le trousseau du système, les fichiers temporaires.
- *Script* : l'injection par les arguments, les défauts destructeurs, les variables non protégées dans une commande.
- *Réseau temps réel* : les paquets malformés (un pont Art-Net ou sACN lit des octets venus de n'importe qui), la saturation, l'écoute sur toutes les interfaces quand une seule suffit.

Il ne tire à la porte que si la surface a changé : entrées, fichiers, réseau, permissions, secrets, dépendances. Toujours pour les types web et service, parce que tout y est exposé.

**À la version (contexte C, via l'audit), la posture.** Le rapport des failles connues des dépendances, l'historique de la détection de secrets, l'inventaire de ce qui est exposé, les permissions, ce qui a changé depuis la version précédente.

**Ses automates**, posés par `/flow:init-project` dans la CI, qui ne coûtent aucun jeton :

- l'analyse des failles connues des dépendances, avec l'outil de la pile : `npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `dotnet list package --vulnerable` ;
- la détection de secrets à chaque envoi (`gitleaks`), et la protection de GitHub sur les dépôts publics ;
- le robot de mise à jour des dépendances (Dependabot), gratuit partout ;
- l'analyse statique de GitHub (CodeQL) quand le dépôt est public ; payante en privé, donc une décision.

`/security-review`, la revue livrée avec Claude Code, reste un instrument que `/flow:verify` lance sur les changements sensibles ; `securite` lit son résultat, il ne le double pas.

**Quand ça fuit.** Un secret parti dans un commit : le révoquer d'abord (le rendre inutilisable), le remplacer, puis seulement nettoyer ; noter l'incident au journal avec la leçon. La commande le sait ; toi tu n'as qu'à dire « il y a un secret dans le dépôt ».

**Ce qu'il ne fait pas.** Les bugs ordinaires appartiennent à `code-reviewer`, la couverture à `test-engineer`, la structure à `architect`, l'écran à `ux-reviewer`. La table du contrôle 11 change : « sécurité », « secret », « injection » ont désormais un propriétaire, `securite` ; `code-reviewer` peut signaler ce qu'il voit en nommant ce propriétaire. Cela déplace une ligne tranchée par la décision `0003` (secrets et injections visibles dans le diff → `code-reviewer`) : le lot 4 écrit la décision qui la remplace, il ne la contourne pas. Cette décision doit aussi **montrer**, et non affirmer, que la sécurité n'est de la nature d'aucun des quatre agents, comme la `0003` l'exige d'un cinquième ; et écrire la frontière entre `securite` et `/security-review`, qui regarde quoi et quand, sans quoi la sécurité aurait trois propriétaires au lieu d'un.

### Fiche : le designer d'interface, `ux-reviewer` en contexte A

Aujourd'hui `ux-reviewer` juge l'interface après coup, et sans référence : il applique une grille. Un studio dessine avant de coder. Le designer, c'est `/flow:design` qui produit et `ux-reviewer` qui attaque, exactement comme `architect` attaque l'architecture.

Pour toute tâche qui touche un écran, `/flow:design` écrit `docs/ecrans/<slug>.md` : les écrans concernés (zones, éléments, textes exacts), le parcours (d'où on vient, où on va, combien de gestes), les trois états de chaque écran (vide, en cours, en erreur), le clavier, et pour un outil de régie : sombre, gros, lisible à deux mètres, un geste pour tout couper. `ux-reviewer` l'attaque en contexte A : ce qui manquera, ce qui confondra, ce qui ne se lira pas à taille réelle, ce qui exclut quelqu'un (contraste, clavier, taille de texte). Puis en contexte B, une fois codé, il juge le rendu **contre cette référence** : « l'état vide prévu au point 3 n'existe pas » vaut mieux que « il manque un état vide ».

Une **charte légère par projet**, écrite une fois : une échelle d'espacements, trois tailles de texte, des couleurs dont le contraste est mesuré, l'apparence des états d'un bouton. La cohérence fait « pro » avant tout le reste, et c'est le studio qui la tient. Le goût, lui, t'appartient : la charte t'est proposée, pas imposée.

### Fiche : l'analyste produit

Deux fichiers courts, écrits par `/flow:init-project` avec toi, tenus par `/flow:spec` et l'audit :

- **`docs/produit.md`**, vingt à trente lignes : pour qui, dans quelle situation, ce que le logiciel doit faire de mieux que ce qui existe, **ce qui ne doit jamais arriver** (les non-négociables : « jamais de boîte de dialogue qui bloque pendant un spectacle »), les plateformes, les contraintes. `/flow:spec`, `/flow:design` et `ux-reviewer` le lisent avant tout.
- **`docs/a-faire.md`**, la liste à faire priorisée en trois paliers : maintenant, ensuite, un jour. Une ligne par item avec son pourquoi. Le studio propose l'ordre avec ses raisons ; tu le confirmes. `/flow:guide`, au repos, propose le premier item de « maintenant » au lieu de « /flow:spec ton idée ». `docs/reste-a-faire.md` garde son rôle : ce qui est cassé, pas ce qui est à construire.

### Fiche : l'architecte

`architect` existe et fait bien son travail. Trois ajouts.

- **Le choix de pile** pour un projet neuf : le studio choisit le langage, le cadre et les bibliothèques d'après la fiche produit, les machines dont tu disposes et la maturité des outils, et il l'annonce en décision expliquée. C'est le premier choix que tu ne dois pas porter seul. Sa règle : de la technologie ennuyeuse, éprouvée, bien documentée ; un seul langage par projet sauf nécessité ; la solution la plus simple qui tienne le besoin.
- **La décision expliquée** pour tout choix qui te touche : hébergement, coût, dépendance à un fournisseur.
- **Le respect de l'existant** sur un projet repris : la meilleure architecture est celle qui ressemble à ce qui existe, sauf si l'existant est le problème, et alors on le dit.

### Fiche : les développeurs

`/flow:new-feature` existe et est solide. Deux ajouts.

- **Le mode incident**, pour « ça a cassé chez l'utilisateur » : lire le diagnostic ou les journaux, reproduire d'abord par un test qui échoue, corriger, garder le test comme non-régression, écrire la ligne du changelog, noter au journal la cause et la leçon. Un défaut réglé dont la cause n'est écrite nulle part revient sous une autre forme : c'est la question 5 de l'audit, qui a enfin une source.
- **Le compte-rendu de lot**, trois lignes pour toi à la fin de chaque petit lot, au lieu d'un silence ou d'une liste de fichiers.

### Fiche : l'ingénieur qualité

`test-engineer` et `/flow:mutation` existent et sont bons. Trois ajouts.

- **Un simulateur ou un enregistrement rejouable pour chaque appareil ou service externe** : un faux nœud Art-Net, un récepteur sACN, un jeu de trames LiDAR enregistrées, un service distant enregistré puis rejoué. Sans lui, `test-engineer` ne peut que constater que « ça n'a jamais été rencontré pour de vrai » ; avec lui, le projet peut répondre oui. `/flow:init-project` le propose quand le profil déclare du matériel, `/flow:design` le prévoit, `test-engineer` exige son existence.
- **L'endurance**, `/flow:endurance`, section 7.
- **Les budgets de performance**, déclarés dans le profil (temps de démarrage, latence, plafond de mémoire, poids d'une page) et mesurés à la porte quand le changement les concerne.

### Fiche : l'ingénieur de livraison et d'exploitation

Le rôle le plus absent aujourd'hui, et celui qui sépare « ça marche chez moi » de « ça marche chez l'utilisateur ». Il n'a pas d'agent : il vit dans `/flow:init-project` (la CI et le socle), dans `/flow:release` (la livraison par type) et dans le profil (déploiement, surveillance, sauvegardes). Sections 8 et 10.

### Fiche : le rédacteur

Un logiciel sans manuel n'est pas fini, il est seulement compilé. `/flow:init-project` pose le squelette : installation, première exécution, cinq minutes de découverte, dépannage. `/flow:release` refuse le tag si une fonctionnalité visible du changelog n'a pas sa ligne dans le manuel, et écrit les notes de version pour l'utilisateur, pas pour le développeur. `ux-reviewer` vérifie que l'aide intégrée (`--help`, « À propos », l'aide en ligne) dit la même chose que le manuel. Option pour plus tard : la CI exécute les commandes d'installation du README sur une machine vierge, ce qui rend le manuel testé.

## 6. Le cycle d'une tâche, commande par commande

Ce que chaque commande devient. « Existe » signifie qu'on n'y touche pas ; les ajouts portent le numéro de leur lot.

**`/flow:studio <idée>`** (nouveau, après le lot 1, si le manque se constate). La porte d'entrée, section 3. Classe, enchaîne, s'arrête pour les quatre raisons seulement, rend le compte-rendu et le lien.

**`/flow:init-project`** devient l'accueil au studio. Existe : détecter, écrire le profil, tests, CI, docs, GitHub, sans rien écraser. Ajouts : le profil étendu, lot 3 (`rythme`, `cibles`, `distribution`, `déploiement`, `journaux`, `temps réel`, `matériel`, `sauvegardes`, `performance`) · la fiche produit et la liste à faire, écrites avec toi, lot 3 · les automates de sécurité dans la CI, lot 4 · le bilan de socle sur un projet existant, avec les manques proposés en lots, lots 6 et 9 · le squelette de manuel, lot 10. Sur un projet repris, il propose `/flow:audit` comme bilan d'entrée : c'est ce qu'un studio fait quand il hérite d'un code.

Une règle pour le profil étendu, héritée de la décision `0002`, qui a écarté une ligne déclarative que rien ne vérifiait : **chaque clé neuve dit comment elle se vérifie, sinon elle n'entre pas.** `déploiement` et `sauvegardes` sont des commandes lancées avec succès, comme les lignes existantes, ou « aucun » ; `performance` se mesure à la porte ; `cibles` et `distribution` se constatent à la construction ; `matériel` et `temps réel` conditionnent des grilles et se constatent à l'endurance ; `rythme` est le seul réglage sans vérité externe, et il le dit. Le lot 3 écrit cette règle clé par clé.

**`/flow:spec`** existe. Ajouts : lit la fiche produit et positionne la tâche dans la liste à faire, lot 3 · une section « Conditions réelles et performance » quand le profil déclare du temps réel ou un budget, lot 3 · en rythme enchaîné, ne s'arrête que si l'une de ses trois questions est de type 1, lot 1.

**`/flow:design`** existe. Ajouts : la décision expliquée pour tout choix qui te revient, l'annonce pour les autres, lot 1 · le modèle de menace par `securite` quand la surface l'exige, lot 4 · les écrans et leur attaque par `ux-reviewer` quand la tâche touche un écran, lot 5 · le simulateur prévu quand un appareil ou un service externe entre en jeu, lot 8 · en rythme enchaîné, ne s'arrête que pour les raisons 1 et 2, lot 1.

**`/flow:new-feature`** existe. Ajouts : le mode incident, lot 2 · le compte-rendu de lot, lot 1 · en rythme enchaîné, le plan est annoncé, pas attendu, lot 1.

**`/flow:verify`** existe et reste la porte. Ajouts : `securite` parmi les experts convoqués, selon la surface, lot 4 · les budgets de performance mesurés quand le changement les concerne, lot 3 · la ligne de journal, lot 2 · le bilan de porte écrit pour toi (ce qui a été vérifié, trouvé, pas pu l'être, et ce que ça veut dire), lot 1 · les socles lus pour le type du projet, lot 6.

**`/flow:ship`** existe. Ajouts : le compte-rendu de livraison dans la pull request et au journal, lots 1 et 2.

**`/flow:guide`** existe. Ajouts : au repos, propose le premier item de « maintenant » dans `docs/a-faire.md`, lu dans la ligne groupée existante, lot 3 · ne propose plus `/flow:design` pour un cadrage marqué « Réalisé » en tête, lot 3 (le 4 septembre 2026, il a proposé de concevoir un cadrage déjà réalisé par la décision `0003`) · `/flow:guide <mot>` explique un mot, lot 1. Son budget ne change pas : deux appels d'outils au plus.

## 7. Le cycle d'une version

**`/flow:release`** existe pour les numéros, le changelog et le tag. Il devient la livraison par type, section 10, et le moment où tourne tout ce qui est cher : l'audit, la mutation si la suite a grossi, l'endurance si temps réel ou serveur, la grille sécurité complète, la construction, la machine vierge, les docs. Il annonce sa durée avant de commencer, et il reste le seul endroit du cycle avec un acte irréversible, donc un arrêt de type 3.

**`/flow:audit`** est redéfini : le bilan de santé du produit, à la version. Il délègue déjà la structure à `architect` (décision `0003`), la couverture à `test-engineer` et l'écran à `ux-reviewer` : il les convoque et lit leurs rapports. Ce plan ajoute la sécurité (`securite`) à cette liste, et surtout donne à l'audit ce que personne ne fait :

- lire le **journal** et dire ce qui se répète ;
- lister les dépendances en retard et leurs failles connues ;
- confronter ce que le programme dit de lui-même (textes, aide, manuel) à ce qu'il fait ;
- vérifier que la liste à faire décrit encore le produit ;
- relever les indicateurs de la section 11.

Trois sections de rendu, inchangées : à corriger avant la version, dette assumable, ce que l'audit n'a pas pu voir. Puis tout au registre. Sur un projet repris, c'est aussi le bilan d'entrée.

**`/flow:mutation`** existe et ne change pas. Déclenchée par `/flow:release` quand la suite a nettement grossi depuis la version précédente.

**`/flow:endurance`** (nouveau, lot 8). Fait tourner longtemps ou sous charge, et regarde ce qui dérive. Pour un outil de régie : le logiciel lancé une heure avec un simulateur qui l'alimente, la mémoire relevée toutes les minutes, la dérive du temps mesurée, le comportement à la perte puis au retour de l'appareil. Pour un serveur : une charge soutenue, les délais de réponse, les erreurs, la mémoire. Verdict : stable, dérive lente, fuite. C'est la classe de tests qui tue ou sauve une représentation de trois heures, et aucune porte par tâche ne peut la payer. Elle appartient à la famille rare, avec la mutation et l'audit.

## 8. Le socle par type de projet

Le socle est ce qu'un projet reçoit d'office pour partir au niveau d'un studio, et ce qu'un projet repris se voit proposer en lots. C'est la source principale de **vitesse** : on ne rediscute jamais ce qui est dans le socle. Il vit dans le plugin, un fichier par type (`plugins/flow/socles/<type>.md`), lu par `/flow:init-project` qui le pose ou le compare, par `/flow:verify` qui en vérifie sa part, par `/flow:release` qui le relit avant de livrer. Chaque item dit ce qu'il est, pourquoi, et comment on le vérifie.

Deux précautions au lot 6. Les socles vivent dans l'arbre du plugin, que le contrôle 9 balaie à la recherche de restes Windows : un socle qui nommerait PowerShell rougirait, il écrira « l'interpréteur de commandes de Windows ». Et aucune commande ne lit aujourd'hui un fichier du plugin lui-même : ce mécanisme, la variable qui donne le dossier du plugin, se vérifie sur les deux machines avant qu'une commande en dépende.

Ce plan élargit sciemment le périmètre que le cadrage `passe-sur-les-quatre-agents.md` avait fermé (« taillé pour un auteur et ses projets ») : Pym l'a demandé le 4 septembre 2026 pour les scripts, serveurs et sites à venir. Les parties web et serveur sont écrites d'avance pour ne pas être oubliées ; elles ne coûtent rien tant que le lot 9 n'est pas ouvert, et seront relues à ce moment-là.

**Commun à tous les types**

- La version visible : `--version`, « À propos », un pied de page. Sans elle, aucun rapport de bug n'est exploitable.
- Un journal sur disque (les « logs »), avec rotation, à un emplacement documenté, sans secret ni donnée personnelle.
- Des messages d'erreur qui disent ce qui s'est passé, où, et quoi faire maintenant.
- Un emplacement documenté pour la configuration, et un comportement défini quand elle est absente ou corrompue.
- `.gitignore`, un `README` pour l'utilisateur, un `CHANGELOG`, une `LICENSE` (choix 6).
- Des tests, et une CI qui lance exactement les commandes du profil, plus les automates de sécurité et de licences.
- « Exporter le diagnostic » : journaux, configuration, version, machine, sans secret, en un geste. C'est ce que le studio te demandera à chaque incident.

**Ligne de commande et script**

- `--help` avec un exemple concret ; des codes de sortie corrects ; une sortie lisible par un humain et, en option, structurée pour une machine.
- Aucune action destructrice par défaut ; `--dry-run` (montrer sans faire) pour ce qui modifie ou supprime ; rejouable sans dégât.
- Les couleurs coupées quand la sortie va dans un fichier ; un signe de vie sur les opérations longues ; l'interruption propre.

**Bureau**

- Les trois états de chaque écran : vide, en cours, en erreur.
- Un traitement des plantages : un message lisible, le rapport écrit sur disque, la possibilité de repartir.
- La sauvegarde automatique et la récupération après un arrêt brutal ; le format de fichier projet versionné, avec migration de l'ancien.
- Les raccourcis clavier des actions principales ; le mode sombre ; les écrans haute densité.
- Un installeur, la signature (choix 1), une vérification de mise à jour ou une mise à jour automatique.
- La première exécution : ce que voit quelqu'un qui n'a rien installé, prévu et testé.

**Site et application web**

- Adaptatif jusqu'à 375 pixels de large ; clavier utilisable et focus visible (l'élément qui a la main au clavier) ; contraste mesuré ; un libellé sur chaque champ.
- HTTPS ; les en-têtes de sécurité ; les formulaires validés côté serveur avec des erreurs rattachées au bon champ.
- Des pages d'erreur avec un identifiant à citer ; un budget de poids et de temps d'affichage mesuré en CI (Lighthouse, gratuit).
- Si des données personnelles sont collectées : ce qu'on collecte, pourquoi, combien de temps, écrit avant le code ; le consentement s'il en faut.

**Serveur et service**

- Une adresse de santé qui répond « je vais bien », celle que la surveillance appelle.
- Des journaux structurés avec un identifiant par requête ; des métriques de base ; des délais d'attente et des nouvelles tentatives sur tout appel sortant.
- La configuration par variables d'environnement, les secrets hors du code, l'authentification et la limitation de débit dès le premier jour.
- Les migrations de base de données rejouables, une sauvegarde avant chacune, et une **restauration testée** : une sauvegarde jamais restaurée n'existe pas.
- L'arrêt propre (finir les requêtes en cours), les dépendances épinglées, une image reproductible si le déploiement le demande.
- Trois environnements : local, préproduction, production ; personne ne teste en production.

**Surcouche temps réel et matériel** (quand le profil le déclare)

- Un budget de latence écrit, et mesuré.
- La reconnexion sans redémarrage quand l'appareil disparaît puis revient ; un chien de garde qui relance ce qui meurt.
- Un geste pour tout couper (« blackout »), testé, qui marche quand tout le reste est cassé.
- Aucune boîte de dialogue qui bloque pendant l'exploitation ; un état lisible à deux mètres en pénombre.
- Un simulateur de l'appareil pour tester sans la scène ; l'endurance passée avant chaque version.
- L'écoute réseau sur l'interface choisie, pas sur toutes ; les paquets malformés ignorés sans planter.

## 9. La sécurité de bout en bout

Résumé de ce que porte `securite` avec ses automates, pour voir la chaîne entière :

| Moment | Ce qui se passe | Coût |
|---|---|---|
| Conception | le modèle de menace en quinze lignes, dans la décision | un appel d'agent, sur les tâches exposées |
| Chaque envoi de code | détection de secrets, failles connues des dépendances, licences | machine, zéro jeton |
| Chaque semaine | le robot propose les mises à jour de dépendances ; on les prend à la tâche suivante | machine |
| Porte | la grille par type sur ce qui a changé ; `/security-review` sur les changements sensibles | un agent, quand la surface a changé |
| Version | la posture : failles, exposition, permissions, ce qui a changé | via l'audit |
| Incident | révoquer, remplacer, nettoyer, écrire la leçon | à la demande |

Ce que ça ne promet pas : un test d'intrusion humain. Pour une application web qui manipule de l'argent ou des données sensibles, un studio le commande à un tiers avant la mise en ligne ; le plugin te le dira, il ne le remplacera pas.

## 10. Livrer et faire tourner

### Exécutables (bureau, ligne de commande)

`/flow:release` pour ce type : la construction sur les trois systèmes par la CI · le **lancement de l'exécutable construit sur une machine vierge de GitHub** (elle n'a rien d'installé : c'est la « première exécution sur machine nue » enfin mécanisée, avec `--version` et un auto-test sans écran) · les empreintes (sommes de contrôle) publiées avec les fichiers · l'installeur · la signature selon le choix 1, et sans elle, l'avertissement documenté dans le manuel · les notes de version écrites pour l'utilisateur · la vérification que le manuel couvre ce que le changelog annonce · puis le tag, avec ton accord, et la surveillance de la publication.

Ce que la machine vierge ne prouve pas : les pilotes, l'antivirus et les réglages d'une machine d'opérateur. Le manuel a une section « avant le spectacle » pour ça.

### Sites, applications web et serveurs

`/flow:release` pour ce type : le déploiement en préproduction par la CI · la fumée (la page d'accueil répond, la connexion s'affiche, la santé dit oui) · la sauvegarde avant toute migration · la mise en production avec ton accord · la vérification de santé après · le **retour arrière** documenté et essayé une fois (redéployer la version précédente) · la surveillance : un contrôle de disponibilité et un suivi des erreurs, avec alerte · la note de version.

L'hébergement est une décision expliquée au premier projet web (choix 5). La recommandation du studio pour un auteur seul : une plateforme gérée d'abord, un serveur nu seulement si le besoin l'exige, parce que le temps d'exploitation est le coût caché qu'un non-développeur ne voit pas venir.

### Diagnostic et support

Chaque application sait produire son diagnostic en un geste (socle commun). Le mode incident de `/flow:new-feature` sait le lire. Le journal garde la cause et la leçon. L'audit compte les incidents par version : c'est l'indicateur qui dit si le studio tient sa promesse.

## 11. Mesurer le studio

Aucune décision récente sur les agents n'a été prise avec des données, et le dépôt l'écrit lui-même. Le journal y remédie à coût nul.

**`docs/journal.md`**, une ligne par événement, écrite par les commandes :

- `porte` : date, tâche, checks verts ou rouges, bloquants réels par expert, non vérifié, durée.
- `livraison` : date, tâche, lien, ce que ça change pour l'utilisateur.
- `incident` : date, quoi, cause, leçon.
- `version` : date, numéro, résumé du bilan de santé.

**Le journal remplace les « Relevés datés » du registre.** Ces relevés font aujourd'hui les deux tiers de `docs/reste-a-faire.md` : c'est déjà un journal, en prose. À partir du lot 2, les relevés s'écrivent au journal, et le registre ne garde que ce qui est ouvert : défauts constatés, chantiers en pause, angles morts. Un journal de plus ferait deux journaux.

**Les indicateurs**, relevés par l'audit à chaque version. Deux comptent d'abord ; les autres n'entrent que s'ils ne coûtent rien de plus :

- Le rendement de chaque expert : bloquants réels par convocation. Un expert à zéro sur dix convocations passe à la version seulement ; on ne le supprime pas, on le rend rare.
- Les défauts échappés : incidents par version. Le seul chiffre qui dit si la porte protège.
- Ensuite seulement, s'ils ne coûtent rien de plus : la CI rouge après une porte verte, le score de mutation, les verdicts d'endurance, l'âge des dépendances, la fraîcheur du manuel. Un programme de métriques pour une personne seule serait de la sur-ingénierie ; une ligne par porte suffit à lever l'inconnue de la décision `0003`.

**Ce qu'on décide avec.** Un défaut qui revient deux fois devient un item de socle ou un automate, jamais un troisième rappel dans un prompt. Un expert sans rendement devient rare. Une préoccupation sans propriétaire qui apparaît deux fois au journal en reçoit un. C'est ainsi que le roster évolue : par ce que le journal montre, pas par ce qu'on imagine.

## 12. L'outillage du plugin lui-même

Le vérificateur (`scripts/verifier-le-plugin.sh`) et son banc (`scripts/eprouver-le-verificateur.sh`) protègent de vraies pannes silencieuses : une commande qui disparaît, un manifeste cassé, une version oubliée, un README désynchronisé. On les garde. Mais on les **gèle** :

- Aucun nouveau contrôle sans une panne silencieuse mesurée sur une vraie utilisation.
- Les trois contournements de la garde du vocabulaire listés dans le registre ne sont pas bouchés.
- La table du contrôle 11 ne change qu'avec le roster (l'arrivée de `securite`).
- Si la garde du vocabulaire bloque deux fois une phrase légitime, les contrôles 11 et 12 sont retirés par une décision courte : un outil qui dicte comment rédiger ses instructions a inversé la priorité.
- `/flow:visibilite` est retirée dès que le choix 2 est appliqué : c'est la seule commande irréversible, et son motif disparaît avec elle. Retirer une commande est un sens que la porte ne couvre pas : le contrôle 8 exige aujourd'hui la présence de la bascule, le contrôle 2 ne voit pas une commande fantôme dans la description de la marketplace, et des renvois vivent dans `guide.md`, la décision `0002` et le registre. Le lot 11 adapte le contrôle 8, relit la marketplace à la main et retire les orphelins : c'est l'exception admise au gel, parce qu'un contrôle qui exige une commande retirée est un contrôle faux.
- Les termes gardés par le contrôle 11 (duplication, code mort, doublure, et demain sécurité) ne s'écrivent dans une commande qui convoque un relecteur qu'en nommant le propriétaire dans la phrase. Les lots 1 et 2, qui touchent `verify.md` et `audit.md`, s'y plieront.
- Le contrôle 4 déduit la liste des agents attendus de la **forme** de la liste de `verify.md` (des puces, le nom entre accents graves et en gras), et le banc ne couvre pas un changement de forme : réécrire cette liste en tableau la viderait sans rougir. Toute réécriture de `verify.md` ajoute d'abord ce cas au banc.
- Les conditions de convocation de `verify.md` restent dans la seule liste qu'il a déjà. Six lots en ajoutent ; éparpillées, elles deviendraient la partie la plus pénible à modifier du plugin.

Et la règle de cadence de la première page : un lot de plugin, puis une tâche réelle sur une app.

## 13. Les choix qui t'appartiennent maintenant

Sept choix. Les trois premiers dans la forme promise, complète ; les quatre autres en abrégé, parce qu'ils n'ont ni coût ni échéance à peser maintenant. Deux ont une échéance ; les autres attendent le lot qui les concerne. Une fois tranché, un choix s'écrit en décision dans `docs/decisions/` (0004 et suivantes) et sa ligne ici renvoie à ce numéro : cette section pose les questions, elle ne garde pas les réponses.

**Choix 1 : signer les exécutables**
Un exécutable non signé déclenche un avertissement rouge de Windows (« Windows a protégé votre ordinateur ») et un refus de macOS à la première ouverture. C'est la première impression que ton logiciel laisse.
Ce que ça change : de l'argent chaque année, une heure de mise en place par système, et une première ouverture propre pour chaque personne qui installe.
Option A, recommandée : signer Windows et macOS pour tout ce qui est distribué à d'autres. Apporte la première ouverture propre partout · coûte un compte développeur Apple (99 dollars par an) et un certificat ou un service de signature Windows (à chiffrer au moment de décider) · on le regretterait si personne d'autre que toi n'installe.
Option B : signer Windows seulement, et documenter le contournement macOS dans le manuel. Moins cher · les utilisateurs Mac ont un geste à faire à chaque première ouverture.
Option C : ne rien signer, et documenter l'avertissement. Gratuit · chaque installation commence par un avertissement de sécurité.
Si on se trompe : on peut signer plus tard ; rien à défaire. Ce que je te demande : A, B ou C. Échéance : le lot 7.

**Choix 2 : où tournent les tests de GitHub**
Aujourd'hui `/flow:visibilite` rend un dépôt public le temps d'une campagne pour ne pas payer les minutes. C'est la seule commande irréversible du plugin.
Ce que ça change : le risque d'exposer l'historique disparaît ou reste ; les tests tournent sur ta vraie machine ou sur celles de GitHub. Un coût caché à voir venir : un exécutant sur la tour ne construit pas macOS. Les constructions macOS du lot 7 restent sur les machines de GitHub, payantes en privé et dix fois plus chères que Linux ; pour un dépôt qui livre du macOS, l'option A se combine avec B ou C pour ces minutes-là.
Option A, recommandée : un exécutant auto-hébergé sur la tour Ubuntu (un petit programme qui exécute les tests demandés par GitHub), et un second sur le poste Windows. Apporte des minutes gratuites, les tests sur les vraies machines cibles, et la fin de `/flow:visibilite` pour tout ce qui n'est pas macOS · coûte une heure d'installation, une machine allumée pendant les tests, un peu d'entretien · réservé aux dépôts privés : sur un dépôt public, n'importe qui pourrait faire tourner du code sur ta machine par une pull request · on le regretterait si la tour est souvent éteinte.
Option B : assumer publics les dépôts qui peuvent l'être, définitivement, et garder privés les autres en payant leurs minutes. Simple · demande une fouille de l'historique une fois pour toutes, et une facture pour les privés.
Option C : payer les minutes partout. Zéro effort · une facture mensuelle, et macOS compte dix fois.
Si on se trompe : tout est réversible en une heure. Ce que je te demande : A, B ou C. Échéance : le lot 11.

**Choix 3 : le cinquième expert, la sécurité**
Ce que ça change : une convocation de plus à la porte quand la surface a changé, et toujours pour le web et les serveurs ; un modèle de menace à la conception des tâches exposées.
Option A, recommandée : oui. Un site ou un serveur sans expert sécurité n'est pas « pro », et un pont réseau de régie lit des octets venus de n'importe qui.
Option B : non, garder la revue générique seule. Moins cher · elle ne connaît ni le type du projet ni ce qui a de la valeur.
Si on se trompe : un agent se retire en un lot. Ce que je te demande : oui ou non.

**Choix 4 : le rythme par défaut**
Option A, recommandée, et c'est ta demande : enchaîné, avec les quatre raisons de s'arrêter. Option B : pas à pas, les trois arrêts d'aujourd'hui. Réglable par projet dans le profil, donc réversible en une ligne. À écrire en décision `0004` au lot 1, avec les quatre raisons de s'arrêter : c'est là qu'elle fera foi, pas ici.

**Choix 5 : l'hébergement du web et des serveurs**
À décider au premier projet concerné, pas maintenant. Le studio te présentera alors plateforme gérée contre serveur nu, avec les euros par mois, le temps d'exploitation et la dépendance au fournisseur. Sa recommandation d'avance : plateforme gérée.

**Choix 6 : la licence et l'accessibilité, par projet**
Chaque projet dit s'il est ouvert (code public, licence libre) ou fermé, et quel niveau d'accessibilité il vise : le socle pour tous (clavier, contraste, libellés), et le niveau AA de la norme pour un site public. `/flow:init-project` te posera la question une fois par projet.

**Choix 7 : l'ordre des lots**
Le tableau d'avancement en tête est ma recommandation. Tu le confirmes ou tu le changes ; ensuite `/flow:guide` le suit.

## 14. L'ordre des lots, en détail

Chaque lot suit le cycle complet sur ce dépôt : cadrage, conception, implémentation, porte, livraison. Chaque lot se termine par une tâche réelle sur une app qui le constate.

**Lot 1 : le rythme et la pédagogie.** Le réglage `rythme` et les quatre raisons dans les six commandes du cycle · la décision expliquée et l'annonce dans `/flow:design` · « pour toi » dans les quatre agents · les points de passage · le compte-rendu de lot, le bilan de porte et le compte-rendu de livraison · `/flow:guide <mot>` · la décision `0004` qui fixe le rythme et les quatre raisons. Constaté quand une tâche réelle traverse la chaîne sans arrêt inutile, et que chaque arrêt restant est l'une des quatre raisons. `/flow:studio` n'entre qu'après ce constat, si l'entrée unique manque encore ; le modèle par agent attend dix portes journalisées. Premier parce que c'est l'expérience même de « passer la porte ». (Corrigé le 5 septembre 2026 par la décision `0004` : il économise des relances, pas des jetons — une chaîne fait relire la conversation à chaque appel ; le constat mesurera.)

**Lot 2 : le journal et l'audit redéfini.** Le journal écrit par verify, ship et new-feature · le mode incident · l'audit en bilan de santé, à la version. Constaté par un audit lancé sur une vraie app, avec ses indicateurs.

**Lot 3 : le profil étendu, la fiche produit, la liste à faire.** Et `/flow:guide` qui propose un item, et qui ignore les cadrages marqués « Réalisé ». Constaté par la fiche produit de deux apps existantes.

**Lot 4 : l'expert sécurité et ses automates.** L'agent `securite` en trois contextes · sa convocation dans verify et design · les automates dans la CI posés par init-project · la table du contrôle 11. Constaté par un modèle de menace écrit pour une app réseau, et une CI qui passe au rouge sur un secret injecté volontairement.

**Lot 5 : la conception d'interface.** `docs/ecrans/`, le contexte A d'`ux-reviewer`, la charte légère, le contexte B qui juge contre la référence. Constaté par une fonctionnalité avec écran conçue puis jugée contre sa référence.

**Lot 6 : le socle, première moitié.** Bureau, ligne de commande, script, surcouche temps réel · init-project qui compare et propose · verify et release qui lisent. Constaté par le bilan de socle des quatre apps de régie, et un manque posé sur chacune.

**Lot 7 : livrer un exécutable comme un pro.** Constaté par une version réelle publiée par ce chemin, choix 1 appliqué.

**Lot 8 : endurance et simulateurs.** Constaté par une heure d'endurance sur une app de régie alimentée par un simulateur, et un simulateur Art-Net ou sACN posé dans un projet.

**Lot 9 : le socle web et serveur, et la mise en ligne.** Quand un projet web ou serveur l'appelle, pas avant. Constaté par une mise en ligne réelle avec retour arrière essayé.

**Lot 10 : le rédacteur et l'entretien.** Squelette de manuel, porte des docs à la version, licences, tendances dans l'audit. Constaté par le manuel d'une app aligné sur son changelog.

**Lot 11 : les tests sur la tour, le retrait de `/flow:visibilite`.** Choix 2 appliqué. Constaté par la CI d'une app tournant sur la tour, et la commande retirée du plugin et du README.

**Lot 12 : le bilan.** Après dix tâches réelles et deux versions passées par le studio : l'audit du journal, le roster ajusté avec des chiffres, le README réécrit comme la présentation d'un studio. Pas avant : une 1.0 se mérite par l'usage.

## 15. Ce que ce plan ne promet pas

- **Zéro bug.** Il change quand on les trouve : à la porte plutôt qu'en salle.
- **macOS sans Mac.** La construction et la machine vierge passent par GitHub ; l'écran macOS n'est jamais regardé, et `ux-reviewer` le dira en « non vérifié ». La signature macOS demande un compte Apple.
- **La machine de l'opérateur.** La machine vierge de GitHub n'a ni ses pilotes ni son antivirus. Le manuel et la section « avant le spectacle » prennent le relais.
- **Le rendement des experts.** Personne ne le connaît aujourd'hui. Le journal le mesurera ; d'ici là, le roster est un pari raisonné.
- **Un coût constant.** La porte coûte un expert de plus quand la surface change ; la version coûte plus qu'aujourd'hui parce qu'elle fait enfin tout ce qu'une version exige. En échange, les tâches enchaînées coûtent moins, et les automates prennent ce que les experts relisaient.
- **Ton temps.** Douze lots, chacun un cycle complet sur ce dépôt, entrecoupés de tâches réelles. Le plan ne date rien ; c'est l'usage qui donnera le rythme.

## Glossaire

Les mots qu'on rencontrera, en une ligne chacun. Depuis la 0.15.0, c'est la liste courte de `plugins/flow/commands/guide.md` qui fait foi pour `/flow:guide <mot>` ; celle-ci reste la liste longue.

- **Branche** : une copie de travail du projet, à côté de la version de référence ; on y construit, puis on fusionne.
- **Commit** : un enregistrement daté et décrit d'un ensemble de modifications.
- **Pull request** : la demande de fusion d'une branche dans la référence, relue et vérifiée avant d'être acceptée.
- **CI, intégration continue** : les vérifications que GitHub rejoue sur ses machines à chaque envoi.
- **Exécutant, runner** : la machine qui exécute la CI ; celle de GitHub, ou la tienne si elle est auto-hébergée.
- **Tag, étiquette de version** : la marque posée sur un état précis du code pour dire « ceci est la version 1.2.0 » ; c'est elle qui déclenche la publication.
- **Dépendance** : un morceau de logiciel écrit par d'autres dont ton projet se sert.
- **Faille connue, CVE** : un défaut de sécurité publié sur une dépendance, avec un numéro.
- **Secret** : un mot de passe, une clé, un jeton d'accès. Ne vit jamais dans le code.
- **Injection** : une entrée qui se fait passer pour une commande.
- **Signature de code** : la preuve, vérifiée par Windows ou macOS, que l'exécutable vient bien de toi et n'a pas été modifié.
- **Notarisation** : la vérification qu'Apple fait d'un exécutable signé avant de le laisser s'ouvrir.
- **Déploiement, mise en ligne** : installer une version sur le serveur qui la fait tourner pour les utilisateurs.
- **Environnement** : local (ta machine), préproduction (une copie pour essayer), production (ce que voient les utilisateurs).
- **Migration** : un changement de structure de la base de données, rejouable dans l'ordre.
- **Retour arrière** : remettre la version précédente quand la nouvelle casse.
- **Sauvegarde et restauration** : copier les données, et prouver qu'on sait les remettre.
- **Surveillance** : une machine qui vérifie en continu que le service répond, et qui alerte sinon.
- **Journal, logs** : ce que le logiciel écrit sur ce qu'il fait, pour comprendre après coup.
- **Diagnostic** : le paquet de journaux, configuration et version qu'on envoie au studio quand ça casse.
- **Simulateur** : un faux appareil ou un faux service qui se comporte comme le vrai, pour tester sans lui.
- **Doublure, mock** : un remplaçant simplifié d'une dépendance dans un test ; il accepte ce qu'on lui a dit d'accepter, donc il ne prouve pas le vrai.
- **Mutation** : casser le code exprès pour vérifier que les tests le voient.
- **Endurance** : faire tourner longtemps ou sous charge pour voir ce qui dérive.
- **Budget de performance** : une limite écrite (temps, mémoire, poids) mesurée à chaque porte.
- **Accessibilité** : le logiciel reste utilisable au clavier, en faible contraste, avec un lecteur d'écran, en gros caractères.
- **Modèle de menace** : la liste de ce qui a de la valeur, de qui pourrait vouloir y toucher, et par où.
- **Jeton** : deux sens. Un jeton d'accès est un secret qui ouvre un service. Un token d'IA est l'unité de texte facturée ; c'est le coût dont parle la section 4.
