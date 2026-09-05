# Le rythme et la pédagogie : enchaîner, expliquer, rendre compte

Cadré le 5 septembre 2026. Réalise le **lot 1** de `docs/plan-studio.md`
(sections 2, 3 et 14), dont il reprend les formes sans les recopier.

## Problème

Trois commandes s'arrêtent à chaque tâche pour des réponses qui, le plus
souvent, ne dépendent pas de l'auteur : trois attentes, trois relances. Et la
pédagogie vit dans les commandes, pas dans les rapports des agents.

## Usage

Un auteur non développeur, seul, qui tape une commande et veut ensuite **lire**
plutôt que débloquer : ce qui a été fait, décidé, et ce que ça change pour lui.

## Critères d'acceptation

1. Étant donné `- rythme : enchaîné` dans le profil, quand `/flow:spec` s'achève
   sans question de type 1, alors conception, plan, code, porte et livraison
   **s'enchaînent dans la même conversation** jusqu'au lien de la pull request
   (la demande de fusion) ; la fusion reste à l'auteur.
2. Étant donné les six commandes du cycle, quand on relit chaque arrêt qui
   subsiste, alors il **nomme l'une des quatre raisons** : le besoin, la
   priorité, l'apparence, « est-ce fini ? » · de l'argent ou un engagement · un
   acte irréversible ou public · une porte rouge sans changer le besoin.
3. Étant donné `- rythme : pas à pas`, quand on traverse le cycle, alors les
   trois arrêts d'aujourd'hui sont là, inchangés.
4. Étant donné une transition enchaînée, quand l'étape suivante commence, alors
   trois lignes visibles la précèdent : fait, décidé ou constaté, commence.
5. Étant donné `/flow:design`, quand un choix revient à l'auteur, alors il est
   posé dans la forme « Décision : … » de la section 2 du plan et la commande
   attend ; un choix du studio est **annoncé** dans la même forme, sans attendre.
6. Étant donné l'un des quatre agents, quand il rend un rapport, alors il
   s'ouvre par les trois lignes « **Pour toi** » (regardé · ce que ça change ·
   recommandé) sans terme non traduit, puis ses blocs actuels inchangés.
7. Étant donné la fin de `/flow:new-feature`, `/flow:verify` et `/flow:ship`,
   quand la commande conclut, alors un paragraphe pour l'auteur dit ce que le
   logiciel fait maintenant, ce qui a été vérifié ou n'a pas pu l'être, et ce
   qui reste ; celui de `/flow:ship` figure aussi dans la pull request.
8. Étant donné `/flow:guide commit` (ou un mot du glossaire du plan), quand on le
   lance, alors trois lignes et un exemple du projet ; ni test, ni agent, ni appel en plus.
9. Étant donné `docs/decisions/0004-*.md`, quand on le lit, alors il fixe le rythme
   par défaut et les quatre raisons ; le bloc partagé fait foi à l'usage, README et
   `/flow:guide` les décrivent au lieu de « trois arrêts » ; les scripts restent verts.
10. Étant donné le lot livré, quand une tâche réelle traverse la chaîne, alors
    chaque arrêt constaté est l'une des quatre raisons ; sinon, pas « livré ».

## Hors périmètre

- **`/flow:studio`** : seulement après le critère 10, si l'entrée unique manque.
- Journal, mode incident, fiche produit, liste à faire, profil étendu au-delà
  de `rythme` (lots 2 et 3) ; le modèle par agent (attend dix portes).
- Qui regarde quoi dans les agents : trois lignes s'ajoutent, rien ne bouge.
- `/flow:audit`, `release`, `mutation`, `visibilite` : hors du cycle d'une tâche.

## Cas limites

- **Profil sans ligne `rythme`** (tous les projets existants) : enchaîné, dit
  une fois. **Un agent qui ne trouve rien** : « Pour toi » tient en une ligne.
- **`ux-reviewer` qui n'a pas pu lancer le logiciel** : sa première ligne reste
  « je n'ai pas pu regarder » ; jamais compté comme un feu vert.
- **Porte rouge ou question de type 1 en pleine chaîne** : arrêt (bilan de
  porte, ou « J'attends ta réponse ») ; puis la chaîne reprend où elle était.
- **Conversation coupée en pleine chaîne** : `/flow:guide` retrouve l'état par
  git et les fichiers, comme aujourd'hui ; aucun état de chaîne ne vit ailleurs.
- **Mot inconnu de `/flow:guide <mot>`** : il le dit ; il n'invente pas.

## Risques et inconnues

- **L'enchaînement n'a jamais tourné.** Constaté le 5 septembre 2026 : l'outil
  qui charge une commande est disponible à l'assistant en conversation (ce
  cadrage a été lancé ainsi) ; reste à voir qu'une commande en lance une autre.
- **La porte s'enchaîne sans accord, donc son coût aussi** (530 000 jetons la
  dernière fois ici) ; garde-fou : un expert ne tire que si son objet a changé.
- **Le vérificateur borne la forme** : bloc partagé identique (contrôle 1),
  liste des agents de `verify.md` inchangée (4), termes gardés avec leur
  propriétaire (11), README qui suit (2).
- **Le glossaire doit vivre dans le plugin**, sinon `/flow:guide <mot>` ne marche
  qu'ici. **Le plus gros lot du plugin** : coupé en deux si la porte le demande.
