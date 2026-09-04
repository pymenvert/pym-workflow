---
description: Fait le point — où tu en es dans le cycle, et la seule chose à faire ensuite
argument-hint: (rien), ou une question sur le cycle
---

Tu fais le point. Réponse courte, concrète, une seule action à la fin.

## Budget

Faire le point doit coûter quelques secondes. **Jamais d'agent de revue, jamais de test, de lint, de typecheck ni de build, jamais de lecture du code** ni du contenu des specs — leurs noms de fichiers suffisent. Tu nommes la commande à lancer, tu ne la lances pas.

## Les signaux : au plus deux appels d'outils

**D'abord la conversation en cours.** Si une commande `/flow:*` vient de montrer une spec, une conception ou un plan et attend une validation, tu as déjà la réponse : **n'appelle aucun outil**. C'est le cas le plus fréquent, et il est gratuit.

Sinon, **un seul appel groupé**. Ne le découpe jamais : chaque appel d'outil relit toute la conversation, c'est là que part l'argent — pas dans la longueur des sorties.

```
git branch --show-current; git status --short; git rev-list --count HEAD --not main 2>/dev/null; ls docs/specs docs/decisions docs/reste-a-faire.md 2>/dev/null; grep -c "Profil projet" CLAUDE.md 2>/dev/null; cat .git/flow-depot-ouvert 2>/dev/null; gh repo view --json visibility -q .visibility 2>/dev/null
```

La visibilité tient dans **cette ligne-là**, pas dans un appel de plus. Le budget de cette commande se compte en appels d'outils, pas en secondes : replié dans le groupe, l'appel à GitHub en coûte **zéro de plus** (mesuré : un tiers de seconde de réponse). S'il ne rend rien — pas de dépôt distant, `gh` absent, pas de réseau —, **tu continues normalement**. `/flow:guide` est le recours de dernière instance : il n'a jamais le droit de s'arrêter en erreur.

**Mais dans ce cas, le témoin redevient la seule source, et il parle.** Si `.git/flow-depot-ouvert` existe alors que GitHub n'a rien répondu, dis-le en tête : « le dépôt a été ouvert et je n'ai pas pu vérifier s'il l'est encore ». Sans réseau, « je ne sais pas » n'est pas « c'est fermé » — et c'est précisément quand on ne peut pas vérifier qu'un dépôt oublié le reste.

**Deuxième appel seulement si rien n'est modifié** : `gh pr list --state open`. Si des fichiers sont modifiés, l'état des pull requests ne change pas la réponse — inutile de payer l'appel réseau.

## Ce que les signaux veulent dire

| Constat | Où il en est | La seule chose à lancer |
|---|---|---|
| **GitHub rend `PUBLIC` et `.git/flow-depot-ouvert` existe** | **le dépôt est ouvert et on sait pourquoi** — passe avant tout le reste, quelle que soit la suite du tableau ; cite le motif et la date que contient le témoin | `/flow:visibilite fermer` |
| **GitHub rend `PUBLIC` sans témoin** | le dépôt est public — ouvert depuis une autre machine, ou public de nature. Une **mention neutre en tête de réponse**, pas une alarme : « ce dépôt est public » | poursuis le tableau, et propose `/flow:visibilite fermer` seulement s'il dit que c'est anormal |
| **GitHub rend `PRIVATE` et un témoin existe** | le témoin est **périmé** : il a été refermé depuis une autre machine | le dire, et retirer `.git/flow-depot-ouvert` |
| pas de bloc « Profil projet » dans le CLAUDE.md | le projet n'est pas encore équipé | `/flow:init-project` |
| tout propre, sur la branche par défaut | au repos, rien en cours | `/flow:spec <son idée>` |
| des fichiers modifiés, sur la branche par défaut | du travail en cours au mauvais endroit | le prévenir, puis `/flow:verify` — il posera la question de la branche |
| des fichiers modifiés, sur une branche dédiée | **ambigu** — voir ci-dessous | poser UNE question |
| rien de modifié, des commits en avance | prêt à livrer | `/flow:ship` |
| une pull request ouverte | il reste à la fusionner | lui donner le lien et la marche à suivre |
| une spec sans décision correspondante dans `docs/decisions/` | conception pas encore tranchée | `/flow:design <nom de la spec>` |
| `docs/reste-a-faire.md` existe et n'est pas vide | des points ont été reportés par une porte précédente | lui en citer deux ou trois et proposer d'en prendre un |

**Qui tranche, du témoin ou de GitHub.** GitHub dit **si** le dépôt est ouvert ; le témoin dit seulement **pourquoi** et **depuis quand**. Quand les deux se contredisent, c'est GitHub qui a raison — le témoin vit dans un dossier de travail, il ne traverse pas les machines, et il ne sait pas ce qui a été fait depuis l'autre poste. Une absence de témoin n'a donc jamais voulu dire « rien en cours ».

**Le cas ambigu, à ne surtout pas deviner.** « Des fichiers modifiés sur une branche dédiée » recouvre trois situations que git ne distingue pas : implémentation en cours, implémentation finie mais non vérifiée, porte déjà passée. Si tu devines, tu l'enverras relancer la commande la plus chère du cycle pour rien. Pose une seule question : **« As-tu déjà lancé `/flow:verify` sur ce travail ? »** Puis `/flow:verify` s'il dit non, `/flow:ship` s'il dit oui.

## S'il demande à comprendre le cycle plutôt que son état

Réponds sur ce qu'il a demandé, pas sur les six étapes. Deux règles seulement méritent d'être répétées, parce qu'elles ne figurent nulle part ailleurs :

- **Trois commandes s'arrêtent et attendent une réponse dans la discussion** : `/flow:spec` après ses questions, `/flow:design` après sa proposition, `/flow:new-feature` après son plan. On répond « ok » dans le fil — on ne relance pas une commande.
- **`/flow:new-feature` crée la branche tout seul.** Rien à faire à la main avant. `/flow:verify` et `/flow:ship` travaillent ensuite sur cette branche.

Et dis-lui le coût, une fois : `/flow:verify` lance la suite de tests complète et jusqu'à quatre relecteurs automatiques, soit plusieurs minutes. C'est la seule commande chère du cycle ; les autres répondent en quelques secondes.

## Forme de la réponse

Quinze lignes maximum. **Aucun terme technique sans sa traduction dans la même phrase** — il n'est pas développeur et ne connaît ni « diff », ni « rebase », ni « worktree ». Termine par une seule chose à faire, jamais deux options — sauf la question du cas ambigu, qui est le seul endroit où demander coûte moins cher que supposer.
