---
description: Le bilan de santé de tout le programme, à la version — ce qui se répète au journal, la dérive, ce qui est devenu faux. Rare et cher.
argument-hint: (rien), ou un périmètre à examiner
---

Audit de fond : $ARGUMENTS

Ce n'est pas `/flow:verify`. La porte examine **ce qui vient de changer** ; toi tu examines **tout le programme**, et tu cherches ce qu'aucun diff ne peut révéler : la dérive lente, les angles morts, et les affirmations devenues fausses.

Commande **chère et rare** : le bilan de santé du produit, à chaque version — `/flow:release` te lance avant l'étiquette —, jamais à chaque tâche. Annonce-moi sa durée avant de commencer.

## S'il existe déjà un rapport d'audit, confronte-le

Cherche-le avant toute chose : `docs/`, un dossier d'audits gardé hors du dépôt, tout fichier nommé `*AUDIT*` ou `*reste*`. S'il en existe un, **ne recommence pas de zéro : confronte-le.**

Pour chaque constat encore listé comme non traité, va voir dans le code s'il est toujours vrai, et classe-le en trois piles : **toujours ouvert**, **déjà corrigé**, ou **devenu faux** (le code a changé de forme, le constat ne décrit plus rien).

C'est beaucoup moins cher qu'un audit neuf, et bien plus utile : **un constat périmé est pire qu'aucun constat**, parce qu'il fait croire qu'on connaît ses risques. Un rapport de plusieurs semaines sur un projet qui a publié une version depuis est périmé par défaut.

Commence par les constats les plus graves, et ne confronte pas les cosmétiques tant que les majeurs ne sont pas tranchés. Rends d'abord le décompte : combien encore ouverts, combien déjà réglés.

## Mesure avant de juger

Un audit qui commence par une opinion ne vaut rien. Mais ne refais pas la mesure structurelle toi-même : la duplication, le code mort et les dépendances circulaires sont mesurés par `architect`. Tu lis son rapport, tu ne le doubles pas.

**Lance donc les agents maintenant** — section « Qui il convoque » plus bas — et attends leurs rapports avant de répondre aux questions : trois des cinq en dépendent. Préviens-moi de la durée.

## Les cinq questions

1. **Qu'est-ce qui n'a jamais rencontré la réalité ?** L'inventaire des doublures est établi par `test-engineer` — ne le refais pas. Ta question à toi est celle qu'il ne peut pas poser : ce que son inventaire révèle du **projet entier**. Un projet peut avoir trois cents tests verts et n'avoir jamais rien fait fonctionner pour de vrai ; si c'est le cas, c'est le premier constat du rapport, avant tous les autres.

2. **Quels tests ne protègent rien ?** Ne l'éprouve pas ici : `/flow:mutation` est écrit pour ça, avec les garde-fous qu'exige une commande qui casse du code exprès — cet audit, lui, ne modifie rien. Regarde simplement si cette épreuve a déjà été passée sur ce projet (un outil de mutation, une trace dans `docs/reste-a-faire.md`). Si non, dis-le et propose-la : un audit qui fait confiance à une suite de tests jamais éprouvée repose sur du sable.

3. **Qu'est-ce que le programme dit de lui-même qui est devenu faux ?** Textes d'interface, messages d'erreur, README, aide en ligne, notice. Une explication vieillit sans qu'aucun test ne s'en aperçoive — et c'est précisément ce que l'utilisateur lit.

4. **Quelle partie sera la plus pénible à modifier ?** Ne réponds pas toi-même : c'est la question centrale d'`architect`, avec son horizon à lui. Reprends sa réponse et dis si tu la partages. Deux horizons différents pour la même question ne donnent pas deux avis, ils donnent un doute.

5. **Qu'est-ce qui a été corrigé sans que la cause soit écrite ?** Un défaut réglé dont la leçon n'est consignée nulle part reviendra sous une autre forme.

## Ce que l'audit lit

- **Le journal**, `docs/journal.md` : une ligne par porte, livraison, incident et version. Dis **ce qui se répète** — un relecteur toujours à zéro ou toujours bloquant, la même chose en « non vérifié » deux fois, la même cause d'incident. Sans journal : dis-le en une ligne, indicateurs « sans objet ».
- **Le registre**, `docs/reste-a-faire.md` : ce qui est ouvert — c'est lui que tu confrontes.
- **Les dépendances**, avec les outils du projet s'ils existent — `npm outdated` et `npm audit`, `pip list --outdated` et `pip-audit`, `cargo outdated` et `cargo audit` : en retard, et failles connues. Sans outil, dis que ça manque ; n'installe rien.
- Demain, la liste à faire et la fiche produit (lot 3) : seulement si elles existent.

## Ce qu'il calcule

Deux indicateurs, par une seule commande sur les cases étiquetées du journal — les noms des relecteurs viennent des lignes, jamais d'ici :

```
DEPUIS=$(git log -1 --format=%as "$(git describe --tags --abbrev=0 2>/dev/null)" 2>/dev/null || echo 0000-00-00)
awk -F' · ' '
  { sub(/\r$/, "") }
  !/^- / { next }
  { d = $1; sub(/^- /, "", d) }
  $2 == "porte" { for (i = 4; i <= NF; i++) if ($i ~ /^bloquants : /) { s = $i; sub(/^bloquants : /, "", s); n = split(s, b, ", ")
      for (j = 1; j <= n; j++) { split(b[j], c, " "); conv[c[1]]++; if (c[2] == "?") pas[c[1]]++; else bloq[c[1]] += c[2] } } }
  $2 == "incident" && d >= depuis { inc++ }
  END { for (r in conv) printf "%s : %d bloquant(s) sur %d convocation(s), %d fois sans pouvoir regarder\n", r, bloq[r], conv[r], pas[r]
        printf "incidents depuis %s : %d\n", depuis, inc }
' depuis="$DEPUIS" docs/journal.md
```

**Comment lire.** Le rendement d'un relecteur, c'est ses bloquants réels par convocation ; un « ? » est une fois où il n'a pas pu regarder, jamais un zéro. Un zéro ne se lit qu'avec les incidents de la même période : sur des diffs propres, zéro n'est pas « inutile ». Un relecteur à zéro sur dix convocations devient rare — convoqué à la version seulement —, on ne le supprime pas. Les incidents se comptent **par date** depuis la dernière étiquette, pas par position dans le fichier — au jour près : un incident noté le jour de l'étiquette compte pour la période suivante, dis-le si ça pèse. Seules les lignes qui commencent par « - » comptent : l'en-tête, jamais. Et ces chiffres sont déclarés par la porte qui accepte, corrige et compte : ils mesurent l'accord entre elle et ses relecteurs, pas la vérité.

## Qui il convoque

Les relecteurs dont le projet a l'objet, sur le projet entier : `architect` en mode dérive structurelle, `test-engineer` sur les chemins critiques, et `ux-reviewer` sur l'interface complète — pas seulement les écrans récemment touchés —, mais pas d'`ux-reviewer` sans interface ni exécutable. Préviens-moi : plusieurs minutes.

**Sauf confrontation.** Si le registre porte déjà un bilan daté d'après la dernière étiquette et que tous ses « à corriger » sont rayés, ne convoque personne : confronte seulement, section du haut. Sur un projet repris, tu es aussi le bilan d'entrée.

## Rendu

Trois sections, hiérarchisées :

- **À corriger avant la prochaine version** — avec la conséquence concrète si on ne le fait pas
- **Dette assumable** — à noter, à supporter sciemment
- **Ce que cet audit n'a pas pu voir** — obligatoire, en citant nommément les conditions réelles qui manquent

Puis **écris ce qui est ouvert dans `docs/reste-a-faire.md`**, sous un titre daté « Bilan de santé du <date> » — à corriger, dette assumable. Ce bilan reste sous son titre jusqu'à l'étiquette suivante ; un « à corriger » réglé s'y **raye** (`~~…~~`), il ne s'efface pas avant la version suivante : c'est ce qui permet à `/flow:release` de ne pas te relancer pour rien. Ce qui s'est passé, c'est `/flow:release` qui l'écrit au journal, ligne `version`. Un audit qui ne survit pas à la conversation n'a servi à rien.

Et si l'audit dégage une leçon générale — pas un défaut, une règle —, propose-moi de l'ajouter au `CLAUDE.md` du projet. C'est ce qui évite de la réapprendre au prix fort.

---

## Arrêts et attentes

**Le rythme.** Lis la ligne `- rythme :` du bloc « Profil projet » du `CLAUDE.md` : `enchaîné` ou `pas à pas`. Ligne absente ou valeur inconnue : enchaîné, dit une fois par conversation. Un mot de ma part dans la discussion — « attends », « pas à pas », « enchaîne » — l'emporte sur le profil pour la tâche en cours. Ce réglage ne vaut que pour les commandes qui portent un paragraphe « Arrêts et suite » ; hors de ce cycle, les arrêts de la commande restent ce qu'ils sont.

**Les quatre raisons de s'arrêter.** En enchaîné, tu ne t'arrêtes que pour l'une d'elles, et tu la nommes : **(1)** une réponse qui n'appartient qu'à moi — le besoin, la priorité, l'apparence, « est-ce fini ? » · **(2)** de l'argent ou un engagement · **(3)** un acte irréversible ou public · **(4)** une porte rouge que tu ne sais pas rendre verte sans changer le besoin.

**Le point de passage, et lancer la suivante.** Avant l'étape suivante, trois lignes visibles : **Fait** : … · **Décidé ou constaté** : … · **Commence** : …. Lancer la suivante, c'est la charger toi-même, comme si je l'avais tapée, avec son argument — vers l'aval seulement : jamais celle qui t'a chargé, jamais une étape amont, que tu proposes sans la lancer (une seule remontée est admise, écrite dans `/flow:ship`). Si tu ne peux pas la charger, ou si la conversation a été résumée en route, dis-le et termine par « Ensuite » : `/flow:guide` retrouve l'état par git et les fichiers.

**Chaque fois que tu t'arrêtes pour attendre ma réponse**, commence par « **J'attends ta réponse.** » Puis la question en clair, la conséquence de chaque réponse possible, et les options quand il y en a. N'enchaîne jamais sur la suite sans avoir la réponse. Et ne me dis pas que rien n'a été écrit si des fichiers l'ont déjà été — dis exactement où on en est.

**Avant tout passage long et muet** — agents de revue, suite de tests, surveillance de la CI —, annonce-le en une ligne, avec sa durée approximative. Un silence long ressemble à un plantage, et ma réaction sera de taper une autre commande.

## Fin de réponse — obligatoire

Termine toujours ta dernière réponse par ces trois lignes — en chaîne, elles closent la chaîne, pas chaque étape. Les titres ne changent jamais ; le contenu décrit ce qui s'est réellement passé. **Si tu t'es arrêté en route, dis-le ici** — n'annonce jamais un travail qui n'a pas eu lieu.

**Où on en est** — un fait constaté, puis sa conséquence. Deux lignes maximum.
**Ensuite** — UNE seule chose : une commande à lancer, ou une phrase à me répondre. Jamais deux options que tu pourrais trancher toi-même en regardant le projet — tu l'as lu, moi non. En revanche, quand la réponse ne dépend que de moi (« est-ce que je considère ce travail comme fini ? », « laquelle de ces deux formes je préfère ? »), demande — mais constate d'abord, et présente ce que tu as vu en même temps que ta question.
**Si tu hésites** — `/flow:guide` : il regarde où j'en suis et me donne la seule chose à faire ensuite. Il ne modifie rien, ne lance aucun test, et coûte trois secondes.

Aucun terme technique sans sa traduction dans la même phrase. Je ne suis pas développeur : « branche », « commit », « CI », « pull request », « diff » demandent trois mots d'explication au passage, pas un renvoi à la documentation.
