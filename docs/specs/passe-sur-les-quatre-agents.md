# Une passe sur les quatre agents : rôle, frontières, pertinence

Cadré le 4 septembre 2026. **Absorbe `audit-et-architect-en-double.md`** — voir Hors périmètre.

## Problème

Les préoccupations les plus coûteuses n'ont pas de propriétaire : « duplication »
et « code mort » apparaissent dans **trois** fichiers (`code-reviewer`,
`architect`, `audit`), les cas limites dans **deux**, les doublures dans
**deux**, et la sécurité est à la fois dans `code-reviewer`:14 et dans
`/security-review` que `verify.md`:41 lance à côté. Symétriquement, rien ne
couvre ce qui fait la qualité des logiciels de l'auteur : leur tenue en
conditions réelles, et leur distribution.

## Usage

Un développeur solo, pas développeur de métier, qui écrit des outils de
**spectacle vivant** — séquenceur LED, pont Art-Net/sACN, mur tactile LiDAR,
lecteur vidéo. Distribués en exécutables Windows, macOS et Linux, souvent « zéro
dépendance », ils **tournent en régie pendant une représentation**, où un
plantage se voit dans la salle. Il lance `/flow:verify` à chaque tâche et veut,
en quelques minutes, la liste courte de ce qui casserait pour de vrai.

## Critères d'acceptation

1. Étant donné les agents et les commandes qui les convoquent, quand on cherche
   une préoccupation (duplication, code mort, cas limites, doublures, sécurité),
   alors elle a **exactement un propriétaire** ; les autres y renvoient.
2. Étant donné les cinq recouvrements mesurés ci-dessus, quand on les recherche
   après le lot, alors **aucun ne subsiste**.
3. Étant donné `code-reviewer` et `/security-review`, quand on lit l'un des deux,
   alors la frontière est **écrite** : qui regarde quoi, et quand.
4. Étant donné n'importe quel agent, quand on le lit, alors il dit **ce qu'il ne
   fait pas**, en nommant celui qui le fait à sa place.
5. Étant donné un projet temps réel livré en exécutable, quand `/flow:verify` s'y
   applique, alors **deux préoccupations absentes sont couvertes** : la tenue en
   conditions réelles (appareil perdu, latence, reprise, arrêt d'urgence) et la
   première exécution sur machine nue.
6. Étant donné une interface, quand `ux-reviewer` la juge, alors il le fait dans
   les **conditions réelles d'usage** — régie, pénombre, urgence, pas de seconde
   chance — pas selon une grille générique.
7. Étant donné le lot terminé, quand on compare avant/après, alors le **coût est
   chiffré et écrit** : tokens toujours actifs, et nombre d'agents convoqués par
   `/flow:verify` dans un cas courant.
8. Étant donné `/flow:design`, `/flow:verify` et `/flow:audit`, quand on les
   lance après le lot, alors chacun convoque toujours ses agents, et aucun
   n'échoue faute d'un agent disparu.
9. Étant donné les deux scripts du dépôt, quand on les lance, alors ils restent
   verts — et un contrôle empêche **mécaniquement** une préoccupation de
   réapparaître chez deux propriétaires.

## Hors périmètre

- **`audit-et-architect-en-double.md` est absorbé.** Ce doublon est l'un des cinq
  mesurés ici ; le traiter à part modifierait `architect.md` deux fois pour deux
  raisons. Ses six critères sont couverts par les neuf ci-dessus.
- **Les onze commandes**, sauf là où elles convoquent un agent.
- **La forme des rapports** : on redéfinit qui regarde quoi, pas les verdicts.
- **Rendre le plugin utilisable par quelqu'un d'autre** : il est taillé pour un auteur et ses projets, c'est une force.

## Cas limites

- **Projet sans interface, sans temps réel ni exécutable** — ce dépôt lui-même :
  les agents concernés ne sont pas convoqués, et la nouvelle couverture rend
  « sans objet », jamais une liste vide muette.
- **Un agent qui ne trouve rien** : une ligne, et il s'arrête — règle existante
  qui doit survivre au lot.
- **Deux agents qui se contredisent** sur le même fichier : il faut dire qui
  tranche, sinon la porte rend un verdict ambigu.

## Risques et inconnues

- **Couvrir plus coûte plus, à chaque tâche** — le contraire de « me faciliter le
  travail ». Cet arbitrage est le vrai débat de la conception ; le critère 7 est là pour le chiffrer.
- **Aucun de ces agents n'a jamais été mesuré à l'usage.** On ignore lequel
  trouve réellement des défauts : on répartit des rôles sans données. C'est
  l'inconnue la plus sérieuse.
- **« Super interface » n'est pas mesurable.** Le risque est d'écrire des vœux ;
  le garde-fou est le critère 6 — des conditions nommées, pas des adjectifs.
- **Les outils navigateur n'ont pas le même nom sur les deux machines** (mesuré au lot 0.12.0) : `ux-reviewer` ne peut pas les inscrire en dur.
