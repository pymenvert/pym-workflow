---
description: Implémente une tâche — branche dédiée, plan court, petits lots vérifiés au fil de l'eau
argument-hint: description de la feature ou du bug, ou nom d'une spec
---

Tâche : $ARGUMENTS

1. **État des lieux.** `git status`. Si des fichiers sont modifiés, **ne te contente pas de me demander quoi en faire : regarde d'abord ce que c'est.** Lis le diff, et dis-moi ce que tu constates. « Ce sont les treize styles en ligne retirés et la politique de sécurité unifiée, donc le chantier annoncé semble terminé » vaut infiniment mieux que « treize fichiers modifiés, qu'en fais-tu ? ». Puis pose ta question — elle reste légitime : savoir si je considère ce travail comme fini n'appartient qu'à moi. Mais constate avant de demander.

   **En chaîne, les fichiers que la chaîne vient d'écrire — le cadrage, la décision, la ligne de journal — ne demandent rien** : constate-les en une ligne, ils suivront la branche. Tout autre fichier modifié reste une question, raison 1.

   **Puis tranche le sujet.** Si ce que je demande maintenant est une retouche du travail en cours, reste sur la branche actuelle et ne crée rien — c'est le même sujet. Si c'est autre chose, il faut d'abord livrer l'existant : **une pull request est un sujet, pas un panier.** Mélanger deux sujets rend le diff illisible, et dans six mois « pourquoi ce changement ? » n'a plus de réponse.

2. **Contexte.** Lis le `CLAUDE.md` du projet, en particulier son bloc « Profil projet ». Si une spec (`docs/specs/`) ou une décision d'architecture (`docs/decisions/`) correspond à cette tâche, lis-la : elle fait autorité sur ce qu'il faut construire.

   Si la tâche est structurante et qu'aucune spec n'existe, dis-le et propose `/flow:spec`. Ne cadre pas toi-même en douce ce qui mérite d'être décidé explicitement.

3. **Branche.** Mets la branche par défaut à jour, puis crée `feature/<slug>` ou `fix/<slug>` selon la nature de la tâche. Je n'ai rien à préparer avant : c'est toi qui crées la branche, dis-le-moi au passage.

   **Jamais de worktree** — pas de second dossier de travail. `/flow:guide` ne sait pas les voir : il me dirait « rien en cours » alors que mon travail vit ailleurs sur le disque.

4. **Exploration.** Lis le code concerné avant de proposer quoi que ce soit. Ne suppose pas l'architecture : vérifie-la. Si ce que tu découvres contredit la spec, arrête-toi et signale-le — c'est exactement le moment où ça coûte le moins cher.

5. **Plan court.** Fichiers touchés, approche, risques, ce que tu comptes tester. En pas à pas, **attends ma validation** avant d'implémenter ; en enchaîné, annonce-le dans un point de passage et implémente.

6. **Implémentation, par petits lots cohérents.**
   - Sur un **chemin critique** (données utilisateur, fichiers, argent, permissions, concurrence) : écris le test d'abord, vérifie qu'il échoue, puis fais-le passer. C'est la seule façon de savoir que le test teste vraiment quelque chose.
   - Ailleurs : code puis test, tant que le test existe à la fin du lot.
   - Lance les checks du profil au fil de l'eau, pas seulement à la fin.
   - Respecte les conventions existantes, même si tu les trouves discutables. On en discute dans `/flow:design`, pas au détour d'un diff.

7. **Traite les cas limites de la spec** — entrées vides, échecs, interruptions. S'ils ne sont pas gérés, la tâche n'est pas finie.

8. **Compte-rendu**, pour moi, sans terme non traduit, toujours dans cet ordre : ce que le logiciel fait maintenant qu'il ne faisait pas · ce qui a été vérifié, ou n'a pas pu l'être · ce qui reste.

Ne conclus pas par un commit : la suite est `/flow:verify`, puis `/flow:ship`.

## Mode incident

Quand ce que je décris est **un comportement qui existait et a cessé, ou un plantage** — « ça plante quand… », « ça a cassé chez… », un diagnostic ou des journaux de l'application collés —, tu passes en mode incident. C'est toi qui tranches après lecture, pas la forme de ma phrase : « ça plante quand je clique trop vite, je veux un bouton grisé » est une fonctionnalité. Les étapes 1 à 3 puis 8 s'appliquent ; ceci remplace les étapes 4 à 7.

1. **Lis ce qui t'est donné** — le diagnostic, les journaux, la description — avant de toucher au code. La branche est `fix/<slug>`.
2. **Écris la ligne d'incident tout de suite** dans `docs/journal.md`, par `cat >>` : `- <AAAA-MM-JJ> · incident · <quoi> · cause : ? · leçon : ?`. L'en-tête fait foi sur la forme : ni « · » ni retour à la ligne dans une case — un « ; » les remplace —, « ? » pour ce qu'on ne sait pas, jamais « aucun ». S'il manque, crée `docs/` et le fichier avec exactement cet en-tête, sans exemple de ligne :

   ```
   # Journal
   
   Une ligne par événement, ajoutée en fin de fichier par les commandes `/flow:*`, jamais réécrite. Forme : `- date · type · objet · étiquette : valeur · …` — quatre types, `porte`, `livraison`, `incident`, `version` ; jamais de « · » ni de retour à la ligne dans une case, un « ; » les remplace ; « ? » pour ce qu'on ne sait pas, à remplir plus tard. Lu par `/flow:audit`.
   ```

   Puis **enregistre et pousse cette ligne aussitôt** — un commit « journal : incident », seule exception à « ne conclus pas par un commit ». Une panne ne compte au bilan qu'une fois sa branche fusionnée : si tu dois t'arrêter sans correction, dis-le, et propose de livrer la branche telle quelle par `/flow:ship` — une panne connue et non réglée compte, c'est même celle qui compte le plus.
3. **Reproduis d'abord par un test qui échoue**, sur le vrai chemin. Si tu n'y arrives pas avec ce que tu as, arrête-toi — raison 1 : il me faut le diagnostic, les journaux ou les gestes exacts — plutôt que de corriger au jugé. Sur un projet sans tests, pose l'infrastructure minimale toi-même, comme le fait `/flow:init-project` : la veille d'un spectacle, un détour ferait contourner le plugin.
4. **Corrige, garde le test** — pour que la panne ne revienne pas sans être vue — et écris la ligne du changelog si le projet en a un.
5. **Remplis les « ? »** de la ligne d'incident : la cause, et la leçon — la règle qui empêche que ça revienne sous une autre forme. Remplir une case vide n'est pas réécrire le journal.

Puis la porte, comme pour toute tâche.

## Arrêts et suite

- **Arrêts** : du travail en cours sur un autre sujet, ou tout fichier modifié que la chaîne n'a pas écrit — moi seul sais ce qu'il vaut → raison 1 · une découverte qui contredit le cadrage → raison 1, c'est le besoin · un sujet structurant sans cadrage → raison 1 : tu proposes `/flow:spec` et tu t'arrêtes · une panne que tu ne sais pas reproduire avec ce qu'on a → raison 1, il me faut le diagnostic. Aucun autre.
- **En pas à pas** : « J'attends ta réponse » après le plan ; une fois validé, tu implémentes, et la suite, c'est moi qui la tape.
- **Suite en enchaîné** : point de passage, puis `/flow:verify`.

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
