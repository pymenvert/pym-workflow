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
git branch --show-current; git status --short; git rev-list --count HEAD --not main 2>/dev/null; ls docs/specs docs/decisions docs/reste-a-faire.md 2>/dev/null; grep -c "Profil projet" CLAUDE.md 2>/dev/null; cat .git/flow-depot-ouvert 2>/dev/null
```

**Deuxième appel seulement si rien n'est modifié** : `gh pr list --state open`. Si des fichiers sont modifiés, l'état des pull requests ne change pas la réponse — inutile de payer l'appel réseau.

## Ce que les signaux veulent dire

| Constat | Où il en est | La seule chose à lancer |
|---|---|---|
| **`.git/flow-depot-ouvert` existe** | **le dépôt est ouvert au public** — passe avant tout le reste, quelle que soit la suite du tableau | `/flow:visibilite fermer` |
| pas de bloc « Profil projet » dans le CLAUDE.md | le projet n'est pas encore équipé | `/flow:init-project` |
| tout propre, sur la branche par défaut | au repos, rien en cours | `/flow:spec <son idée>` |
| des fichiers modifiés, sur la branche par défaut | du travail en cours au mauvais endroit | le prévenir, puis `/flow:verify` — il posera la question de la branche |
| des fichiers modifiés, sur une branche dédiée | **ambigu** — voir ci-dessous | poser UNE question |
| rien de modifié, des commits en avance | prêt à livrer | `/flow:ship` |
| une pull request ouverte | il reste à la fusionner | lui donner le lien et la marche à suivre |
| une spec sans décision correspondante dans `docs/decisions/` | conception pas encore tranchée | `/flow:design <nom de la spec>` |
| `docs/reste-a-faire.md` existe et n'est pas vide | des points ont été reportés par une porte précédente | lui en citer deux ou trois et proposer d'en prendre un |

**Le cas ambigu, à ne surtout pas deviner.** « Des fichiers modifiés sur une branche dédiée » recouvre trois situations que git ne distingue pas : implémentation en cours, implémentation finie mais non vérifiée, porte déjà passée. Si tu devines, tu l'enverras relancer la commande la plus chère du cycle pour rien. Pose une seule question : **« As-tu déjà lancé `/flow:verify` sur ce travail ? »** Puis `/flow:verify` s'il dit non, `/flow:ship` s'il dit oui.

## S'il demande à comprendre le cycle plutôt que son état

Réponds sur ce qu'il a demandé, pas sur les six étapes. Deux règles seulement méritent d'être répétées, parce qu'elles ne figurent nulle part ailleurs :

- **Trois commandes s'arrêtent et attendent une réponse dans la discussion** : `/flow:spec` après ses questions, `/flow:design` après sa proposition, `/flow:new-feature` après son plan. On répond « ok » dans le fil — on ne relance pas une commande.
- **`/flow:new-feature` crée la branche tout seul.** Rien à faire à la main avant. `/flow:verify` et `/flow:ship` travaillent ensuite sur cette branche.

Et dis-lui le coût, une fois : `/flow:verify` lance la suite de tests complète et jusqu'à quatre relecteurs automatiques, soit plusieurs minutes. C'est la seule commande chère du cycle ; les autres répondent en quelques secondes.

## Forme de la réponse

Quinze lignes maximum. **Aucun terme technique sans sa traduction dans la même phrase** — il n'est pas développeur et ne connaît ni « diff », ni « rebase », ni « worktree ». Termine par une seule chose à faire, jamais deux options — sauf la question du cas ambigu, qui est le seul endroit où demander coûte moins cher que supposer.
