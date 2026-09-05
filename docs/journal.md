# Journal

Une ligne par événement, ajoutée en fin de fichier par les commandes `/flow:*`, jamais réécrite. Forme : `- date · type · objet · étiquette : valeur · …` — quatre types, `porte`, `livraison`, `incident`, `version` ; jamais de « · » ni de retour à la ligne dans une case, un « ; » les remplace ; « ? » pour ce qu'on ne sait pas, à remplir plus tard. Lu par `/flow:audit`.

- 2026-09-05 · porte · rythme-et-pedagogie · checks : 2 verts, 0 rouge · bloquants : code-reviewer 5, architect 2 · non vérifié : la chaîne avec la 0.15.0 installée ; Windows · durée : ? · jetons : code-reviewer 175k, architect 139k · note : reconstitué depuis le registre
- 2026-09-05 · livraison · rythme-et-pedagogie · branche : feature/rythme-et-pedagogie · change : les commandes du cycle s'enchaînent sans attendre et ne s'arrêtent que pour quatre raisons nommées ; les relecteurs parlent à l'auteur · note : reconstitué depuis le registre
- 2026-09-05 · version · 0.15.0 · bilan : aucun, le bilan de santé n'existait pas encore
- 2026-09-05 · porte · journal-incident-et-bilan-de-sante · checks : 2 verts, 0 rouge · bloquants : code-reviewer 5, architect 3 · non vérifié : la chaîne et le journal avec la 0.16.0 installée ; Windows · durée : 12 min · jetons : code-reviewer 170k, architect 107k
- 2026-09-05 · livraison · journal-incident-et-bilan-de-sante · branche : feature/journal-incident-et-bilan-de-sante · change : le plugin tient un journal par projet, une panne passe par un mode incident qui la note avant de la corriger, et chaque version commence par un bilan de santé
