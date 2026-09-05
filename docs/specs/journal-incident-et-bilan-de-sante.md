# Le journal, le mode incident, l'audit en bilan de santé à la version

Cadré le 5 septembre 2026. Réalise le **lot 2** de `docs/plan-studio.md` (sections
7, 11, 14 et fiche des développeurs), ouvert avant le constat du lot 1 sur demande
de l'auteur.

## Problème

Aucune décision sur les relecteurs n'a été prise avec des données, et le registre
le dit ; ses relevés datés en font un journal en prose qui grossit à chaque lot. Un
défaut corrigé n'a nulle part où laisser sa cause, et rien ne compte ce qui se répète.

## Usage

L'auteur, à chaque porte et livraison, sans rien taper de plus : une ligne s'écrit.
Quand « ça a cassé chez l'utilisateur », la correction part d'une reproduction. À
chaque version, un bilan de santé lu depuis le journal dit ce qui se répète.

## Critères d'acceptation

1. Étant donné un projet, quand `/flow:verify` rend son verdict, alors une ligne
   `porte` s'ajoute à `docs/journal.md` : date, tâche, checks verts ou rouges,
   bloquants réels par relecteur, non vérifié, durée — le fichier est créé s'il
   manque, et jamais réécrit, seulement complété.
2. Étant donné une livraison, quand `/flow:ship` enregistre, alors une ligne
   `livraison` s'ajoute avant le commit : date, tâche, branche, ce que ça change.
3. Étant donné une demande qui décrit une panne (« ça plante quand… », un
   diagnostic, des journaux), quand `/flow:new-feature` la reçoit, alors il passe
   en mode incident : il lit ce qui lui est donné, **reproduit d'abord par un
   test qui échoue**, corrige, garde le test, écrit la ligne du changelog si le
   projet en a un, et ajoute une ligne `incident` : date, quoi, cause, leçon.
4. Étant donné `/flow:audit`, quand il tourne, alors il lit le journal et dit
   **ce qui se répète**, relève deux indicateurs — bloquants réels par
   convocation, pour chaque relecteur ; incidents par version —, liste les
   dépendances en retard et leurs failles connues avec les outils du projet, et
   garde ses cinq questions et ses trois sections de rendu.
5. Étant donné `/flow:release`, quand il prépare une version, alors il lance
   l'audit avant l'étiquette, propose `/flow:mutation` si la suite de tests a
   nettement grossi depuis la version précédente, écrit une ligne `version` au
   journal — date, numéro, résumé du bilan —, et son seul arrêt est l'étiquette,
   raison 3 : le numéro est annoncé, pas demandé.
6. Étant donné le registre `docs/reste-a-faire.md`, quand un lot se termine après
   celui-ci, alors il n'y ajoute plus de relevé daté : ce qui s'est passé va au
   journal, et le registre ne garde que ce qui est ouvert.
7. Étant donné le README et le CLAUDE.md de ce dépôt, quand on les lit, alors ils
   décrivent le journal, le mode incident et l'audit à la version ; et les deux
   scripts restent verts.
8. Étant donné ce dépôt, quand ce lot est livré, alors `docs/journal.md` existe
   avec ses premières lignes réelles, et le bilan de santé de la version a tourné
   dessus — le constat minimal, en attendant une vraie app.

## Hors périmètre

- L'expert sécurité et ses automates (lot 4) ; la fiche produit et la liste à
  faire (lot 3) — l'audit ne les lit que si elles existent.
- L'endurance, la construction, la machine vierge (lots 7 à 9) : le cycle d'une
  version n'est étendu ici qu'à l'audit et à la mutation.
- Déplacer les relevés datés existants, et le diagnostic « en un geste » des apps
  (socle, lot 6) : le mode incident lit ce qu'on lui donne.

## Cas limites

- **Pas de journal** : créé avec un en-tête qui dit sa forme. **Champ inconnu**
  (durée, jetons) : « ? », jamais inventé.
- **Audit sur un projet sans journal** : il le dit, indicateurs « sans objet ».
- **Incident non reproductible** avec ce qu'on a : arrêt, raison 1 — il faut le
  diagnostic ou les journaux de l'auteur, pas une correction au jugé.
- **Incident sur un projet sans tests** : il pose l'infrastructure minimale
  lui-même, comme `/flow:init-project`, puis reproduit — jamais en aveugle.
- **Chaîne coupée** avant la ligne du journal : elle manque, l'audit compte ce qu'il trouve.

## Risques et inconnues

- **Durée et jetons d'une porte** ne sont pas mesurés par le plugin ; une commande
  note ce qu'elle voit (l'heure, le compte rendu de l'outil des agents) — partiel d'abord.
- **La version devient chère** : l'audit à chaque version, avec ses relecteurs.
  C'est le choix du plan (section 4) ; à mesurer par le journal lui-même.
- **`audit.md` et `verify.md` sont des commandes arbitres** du contrôle 11 : tout
  texte neuf y nomme les propriétaires. Et trois formes de plus — la ligne du
  journal, le mode incident, l'indicateur — se tiennent à la relecture seule.
