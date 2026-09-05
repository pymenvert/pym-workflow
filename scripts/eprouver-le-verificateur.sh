#!/bin/sh
# Le banc de mutation du vérificateur : qui garde le gardien.
#
# Une suite verte n'est pas une preuve, c'est une affirmation. Casser le code
# délibérément est le seul moyen de la vérifier — c'est ce que dit
# /flow:mutation, et ce script l'applique d'avance au seul code exécutable du
# dépôt.
#
# Quatre disciplines, chacune apprise d'un faux verdict constaté :
#
#   - Un cas qui n'a pas TOURNÉ n'est jamais compté comme réussi. Ni une copie
#     ratée, ni une interruption ne doivent pouvoir rendre « tous attrapés ».
#   - Une mutation qui n'a rien CHANGÉ est signalée, pas comptée : un `sed` dont
#     le motif a disparu laisse la porte verte à juste titre, et l'accuser
#     serait accuser le gardien d'un crime qu'on n'a pas commis.
#   - Un contrôle IGNORÉ n'est ni un rouge ni un trou : le cas est NON
#     CONCLUANT. Sans cette troisième valeur, le banc devient rouge sur un dépôt
#     sain dès que python3 manque — c'est-à-dire sur le poste Windows.
#   - Le banc pose aussi la RÉCIPROQUE : un changement légitime doit laisser la
#     porte verte. Sans contre-exemples, un contrôle qui rougit sur tout
#     passerait chaque cas avec les félicitations.
#
# Le dépôt n'est jamais touché : tout se passe dans des copies sous TMPDIR.
#
# Lancer : sh scripts/eprouver-le-verificateur.sh

set -u

RACINE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 1

case "${1:-}" in
    -h|--help|--aide)
        printf 'Éprouve scripts/verifier-le-plugin.sh en lui injectant des défauts.\n'
        printf "Aucun argument. Le dépôt n'est jamais modifié : tout se passe dans des copies.\n"
        printf 'Sortie 0 si chaque défaut injecté a bien été attrapé, 1 sinon.\n'
        printf "Un cas NON CONCLUANT (contrôle IGNORÉ faute d'outil) n'est pas un échec.\n"
        exit 0 ;;
    "") ;;
    *)  printf 'Argument inconnu : %s. Essaie --aide.\n' "$1" >&2; exit 2 ;;
esac

BAC=${TMPDIR:-/tmp}/eprouve-verif-$$
mkdir -p "$BAC" || exit 1
# EXIT nettoie ; les signaux nettoient PUIS SORTENT. Sans le « exit », une
# interruption effaçait le bac et laissait le script continuer sur des copies
# devenues impossibles — en concluant « tous attrapés ».
trap 'rm -rf "$BAC"' EXIT
trap 'rm -rf "$BAC"; printf "\ninterrompu — aucun verdict.\n" >&2; exit 130' HUP INT TERM PIPE

# La référence : une copie saine, dont l'historique est remplacé par un dépôt
# vierge. Sans branche par défaut ni distant, le contrôle de version s'y déclare
# IGNORÉ — il a ses propres cas, plus bas, montés sur un vrai dépôt. Mais git
# répond quand même aux questions de propriété de fichier, ce dont le contrôle
# des fins de ligne a besoin.
cp -R "$RACINE" "$BAC/ref" || exit 1
rm -rf "$BAC/ref/.git"
( cd "$BAC/ref" && git init -q ) >/dev/null 2>&1 || {
    printf "git indisponible — impossible de monter le bac d'essai.\n" >&2
    exit 1
}

ECHECS=0
NONCONCLUANTS=0
CAS=0

# Trois états, jamais deux :
#   0 → le contrôle $2 est ROUGE (le défaut est attrapé)
#   2 → le contrôle $2 s'est déclaré IGNORÉ (il n'a rien pu vérifier ici)
#   1 → le contrôle $2 est resté vert (c'est un trou)
# Deux pièges dans cette fonction, tous deux ayant déjà produit un faux vert.
#
# Le récapitulatif final (« PASSE avec réserves… 1 IGNORÉ(S) ») suit le dernier
# titre numéroté : sans le remettre à zéro, il était attribué au DERNIER contrôle,
# qui devenait le seul incapable d'être déclaré muet. Mesuré : tout cas visant le
# contrôle 11 ressortait « non concluant » et le banc sortait 0.
#
# Et l'initialisation de r dans BEGIN n'est pas une précaution de style : en awk,
# une variable jamais affectée vaut la chaîne vide, qui est ÉGALE À ZÉRO dans une
# comparaison numérique. Sans cette ligne, la fonction rendait « rouge » pour
# tout, et les vingt-quatre cas du banc passaient au vert sans rien prouver.
etat_du_controle() {
    printf '%s\n' "$1" | awk -v n="$2" '
        BEGIN            { r = 1 }
        /^[0-9]+\./      { c = $1; sub(/\./, "", c); next }
        /^(PASSE|BLOQU)/ { c = "" }   # le récapitulatif n appartient à aucun contrôle
        /ROUGE/          { if (c == n)           r = 0 }
        /IGNORÉ/         { if (c == n && r != 0) r = 2 }
        END              { exit r }'
}

# Lance la porte dans $1 et pose sa sortie dans $SORTIE, son code dans $CODE.
lancer_porte() {
    SORTIE=$(cd "$1" && sh scripts/verifier-le-plugin.sh 2>&1)
    CODE=$?
}

cas() { # $1 = contrôle attendu rouge · $2 = intitulé · $3… = commande de cassage
    attendu=$1; nom=$2; shift 2
    CAS=$((CAS + 1))
    rm -rf "$BAC/x"
    cp -R "$BAC/ref" "$BAC/x" || {
        printf "  ÉCHEC    %-52s → copie impossible, LE CAS N'A PAS TOURNÉ\n" "$nom"
        ECHECS=$((ECHECS + 1)); return 1
    }
    ( cd "$BAC/x" && sh -c "$*" ) >/dev/null 2>&1
    # Une mutation qui n'a rien changé ne prouve rien. Sept cas sont collés à la
    # mise en page exacte d'un fichier : le jour où elle bouge, le `sed` ne
    # trouve plus son motif, sort en 0, et le banc accuserait une porte saine.
    if diff -rq "$BAC/ref" "$BAC/x" >/dev/null 2>&1; then
        printf '  ÉCHEC    %-52s → la mutation n\047a RIEN changé, le cas ne teste plus rien\n' "$nom"
        ECHECS=$((ECHECS + 1)); return 1
    fi
    lancer_porte "$BAC/x"
    etat_du_controle "$SORTIE" "$attendu"; etat=$?
    case $etat in
        0)  if [ "$CODE" -eq 0 ]; then
                printf '  ÉCHEC    %-52s → contrôle %s rouge, mais code de sortie 0\n' "$nom" "$attendu"
                ECHECS=$((ECHECS + 1))
            else
                printf '  ok       %-52s → contrôle %s rouge\n' "$nom" "$attendu"
            fi ;;
        2)  printf '  non concluant  %-44s → contrôle %s IGNORÉ ici (outil absent)\n' "$nom" "$attendu"
            NONCONCLUANTS=$((NONCONCLUANTS + 1)) ;;
        *)  printf '  ÉCHEC    %-52s → contrôle %s MUET, le défaut passe\n' "$nom" "$attendu"
            ECHECS=$((ECHECS + 1)) ;;
    esac
}

reciproque() { # $1 = intitulé · $2… = changement LÉGITIME : rien ne doit rougir
    nom=$1; shift
    CAS=$((CAS + 1))
    rm -rf "$BAC/x"
    cp -R "$BAC/ref" "$BAC/x" || {
        printf "  ÉCHEC    %-52s → copie impossible, LE CAS N'A PAS TOURNÉ\n" "$nom"
        ECHECS=$((ECHECS + 1)); return 1
    }
    ( cd "$BAC/x" && sh -c "$*" ) >/dev/null 2>&1
    # Même garde que cas() : une réciproque dont le changement n'a pas eu lieu
    # est un test qui ne peut plus échouer — mesuré au bilan du 5 septembre 2026.
    if diff -rq "$BAC/ref" "$BAC/x" >/dev/null 2>&1; then
        printf '  ÉCHEC    %-52s → le changement n\047a RIEN changé, le cas ne teste plus rien\n' "$nom"
        ECHECS=$((ECHECS + 1)); return 1
    fi
    lancer_porte "$BAC/x"
    if printf '%s\n' "$SORTIE" | grep -q 'ROUGE'; then
        printf '  ÉCHEC    %-52s → la porte rougit sur un changement légitime\n' "$nom"
        printf '%s\n' "$SORTIE" | grep 'ROUGE' | sed 's/^/             /'
        ECHECS=$((ECHECS + 1))
    else
        printf '  ok       %-52s → reste vert, comme il se doit\n' "$nom"
    fi
}

# Monte dans $BAC/g un dépôt doté d'un VRAI « origin/main », sans réseau : le
# distant est un dépôt nu local. C'est la seule façon d'éprouver le contrôle de
# version, que la copie de référence laisse IGNORÉ faute d'historique.
monter_git() { # $1 = version portée par la branche par défaut
    rm -rf "$BAC/g" "$BAC/distant"
    git init -q --bare "$BAC/distant" >/dev/null 2>&1 || return 1
    cp -R "$BAC/ref" "$BAC/g" || return 1
    ( cd "$BAC/g"
      rm -rf .git && git init -q
      git config user.email banc@essai && git config user.name banc
      sed -i "s/\"version\"\([[:space:]]*\):[[:space:]]*\"[^\"]*\"/\"version\"\1: \"$1\"/" \
          plugins/flow/.claude-plugin/plugin.json
      git add -A && git commit -qm socle
      git remote add origin "$BAC/distant"
      git push -q origin HEAD:main
      git fetch -q origin
      git switch -q -c essai ) >/dev/null 2>&1
}

cas_version() { # $1 = version sur main · $2 = attendu rouge|vert · $3 = intitulé · $4… = changement
    vmain=$1; attendu=$2; nom=$3; shift 3
    CAS=$((CAS + 1))
    monter_git "$vmain" || {
        printf "  ÉCHEC    %-52s → montage git impossible, LE CAS N'A PAS TOURNÉ\n" "$nom"
        ECHECS=$((ECHECS + 1)); return 1
    }
    ( cd "$BAC/g" && sh -c "$*" ) >/dev/null 2>&1
    lancer_porte "$BAC/g"
    etat_du_controle "$SORTIE" 6; etat=$?
    if [ "$attendu" = rouge ]; then
        [ "$etat" -eq 0 ] &&
            printf '  ok       %-52s → contrôle 6 rouge\n' "$nom" ||
            { printf '  ÉCHEC    %-52s → contrôle 6 muet, le défaut passe\n' "$nom"
              ECHECS=$((ECHECS + 1)); }
    else
        [ "$etat" -ne 0 ] &&
            printf '  ok       %-52s → contrôle 6 ne rougit pas\n' "$nom" ||
            { printf '  ÉCHEC    %-52s → contrôle 6 rouge à tort\n' "$nom"
              ECHECS=$((ECHECS + 1)); }
    fi
}

C=plugins/flow/commands
A=plugins/flow/agents

printf 'Témoin — un dépôt sain : aucun rouge, et code de sortie 0\n'
lancer_porte "$BAC/ref"
if printf '%s\n' "$SORTIE" | grep -q 'ROUGE'; then
    printf '  ÉCHEC    le dépôt sain rend un rouge — tous les cas ci-dessous sont ininterprétables\n'
    printf '%s\n' "$SORTIE" | grep 'ROUGE' | sed 's/^/             /'
    ECHECS=$((ECHECS + 1))
elif [ "$CODE" -ne 0 ]; then
    printf '  ÉCHEC    aucun rouge, mais code de sortie %s — le rapport et la porte divergent\n' "$CODE"
    ECHECS=$((ECHECS + 1))
else
    printf '  ok       aucun rouge, code de sortie 0\n'
fi

# Un tuyau coupé — « | head » — envoie PIPE : la porte doit nettoyer ET sortir,
# code 130, sans verdict. Mesuré au bilan du 5 septembre 2026 : elle continuait
# à l'aveugle et concluait avec un rouge fantôme.
# Et sous le robot de GitHub, le signal PIPE est ignoré à la naissance des
# processus : la porte doit aussi sortir quand une ÉCRITURE échoue — mesuré le
# même jour, la CI rendait 0 ici.
CAS=$((CAS + 1))
( cd "$BAC/ref" && sh scripts/verifier-le-plugin.sh 2>/dev/null; printf '%s\n' "$?" > "$BAC/code-tube" ) | head -1 >/dev/null
if [ "$(cat "$BAC/code-tube" 2>/dev/null)" = 130 ]; then
    printf '  ok       %-52s → code 130, aucun verdict\n' "tuyau coupé : la porte nettoie et sort"
else
    printf '  ÉCHEC    %-52s → code %s au lieu de 130\n' "tuyau coupé : la porte nettoie et sort" "$(cat "$BAC/code-tube" 2>/dev/null)"
    ECHECS=$((ECHECS + 1))
fi

printf '\nDéfauts injectés — chacun doit faire rougir le bon contrôle\n'

cas 1 "bloc partagé retiré d'un fichier" \
    "sed -i '/^## Arrêts et attentes/,\$d' $C/spec.md"
cas 1 "bloc partagé altéré dans un seul fichier" \
    "sed -i 's/^\\*\\*Où on en est\\*\\*/**Ou on en est**/' $C/ship.md"
cas 1 "bloc vidé de la MÊME façon partout" \
    "for f in $C/*.md; do [ \"\$(basename \$f)\" = guide.md ] && continue; sed -i '/^## Arrêts et attentes/,\$d' \$f; printf '## Arrêts et attentes\n' >> \$f; done"

cas 2 "commande absente du README" \
    "cp $C/spec.md $C/orpheline.md"
cas 2 "README cite une commande qui n'existe pas" \
    "printf '\n/flow:fantome\n' >> README.md"
cas 2 "commande absente de la description de la marketplace" \
    "sed -i 's|/flow:mutation, ||' .claude-plugin/marketplace.json"
cas 2 "README ne cite qu'un préfixe de la commande" \
    "sed -i 's|/flow:mutation|/flow:mutationX|g' README.md"

cas 3 "commande privée de sa ligne description:" \
    "sed -i '2,4{/^description:/d}' $C/audit.md"
cas 3 "frontmatter jamais refermé" \
    "sed -i '2,6{/^---\$/d}' $C/spec.md"
cas 3 "commande privée de son frontmatter entier" \
    "sed -i '1,4d' $C/design.md"

cas 4 "agent privé de sa ligne tools:" \
    "sed -i '/^tools:/d' $A/architect.md"
cas 4 "agent qui réclame Edit, en ligne" \
    "sed -i 's/^tools: Read, Grep/tools: Read, Edit, Grep/' $A/code-reviewer.md"
cas 4 "agent qui réclame Edit, en liste YAML" \
    "sed -i 's/^tools: .*/tools:\n  - Read\n  - Edit\n  - Bash/' $A/code-reviewer.md"
cas 4 "agent dont la ligne tools: est vide" \
    "sed -i 's/^tools: .*/tools:/' $A/architect.md"
cas 4 "agent privé de sa ligne description:" \
    "sed -i '/^description:/d' $A/test-engineer.md"
cas 4 "liste des relecteurs de /flow:verify devenue illisible" \
    "sed -i 's/^- \*\*\`/- **/' $C/verify.md"
cas 4 "UNE ligne de relecteur reformatée, l'agent supprimé" \
    "sed -i 's/^- \*\*\`ux-reviewer\`\*\*/- **ux-reviewer**/' $C/verify.md && rm $A/ux-reviewer.md"
cas 4 "agent au frontmatter jamais refermé" \
    "sed -i '5{/^---\$/d}' $A/architect.md"
cas 4 "agent convoqué par /flow:verify mais supprimé" \
    "rm $A/test-engineer.md"

cas 5 "JSON du plugin invalide" \
    "sed -i 's/{/{,/' plugins/flow/.claude-plugin/plugin.json"
cas 5 "marketplace qui ne référence plus le nom du plugin" \
    "sed -i 's/\"name\": \"flow\"/\"name\": \"flowx\"/' plugins/flow/.claude-plugin/plugin.json"
cas 5 "marketplace dont la clé source pointe dans le vide" \
    "sed -i 's|\"./plugins/flow\"|\"./plugins/flow-v2\"|' .claude-plugin/marketplace.json"

cas 7 "README qui cite un fichier du dépôt inexistant" \
    "printf '\nVoir \`docs/jamais-ecrit.md\`\n' >> README.md"

cas 8 "retour de la sous-commande d'édition de dépôt" \
    "sed -i '10i gh repo edit --visibility private' $C/visibilite.md"
cas 8 "/flow:visibilite qui perd un de ses deux bouts" \
    "sed -i 's/visibility=private/visibility=prive/' $C/visibilite.md"

cas 9 "retour de PowerShell dans une commande" \
    "sed -i '10i powershell -File outil.ps1' $C/ship.md"

cas 10 ".gitattributes supprimé" \
    "rm .gitattributes"
cas 10 ".gitattributes qui n'impose plus LF au script" \
    "sed -i 's|^\\*\\.sh .*|*.sh   text|' .gitattributes"

cas 11 "duplication reprise par un agent sans nommer le propriétaire" \
    "sed -i 's/^- \*\*Simplicité\*\*.*/- **Simplicité** : duplication et code mort, partout dans le dépôt./' $A/code-reviewer.md"
cas 11 "duplication réintroduite dans une COMMANDE sans renvoi" \
    "sed -i '24i On mesure la duplication et les dépendances circulaires.' $C/audit.md"
cas 11 "doublure reprise par une commande sans renvoi" \
    "sed -i '28i On cherche ce qui est testé contre une doublure.' $C/audit.md"
cas 11 "renvoi écrit SANS accents graves (piège de l'homographe)" \
    "sed -i 's/(le dépôt entier, lui, est le sujet d.\`architect\`)./(le depot entier releve d une architecture inutile)./' $A/code-reviewer.md"
cas 11 "préoccupation disparue de son propriétaire" \
    "sed -i '/^- duplication : /d' $A/architect.md"

cas 11 "doublon greffé sur une ligne qui cite DÉJÀ le propriétaire" \
    "sed -i '24s/\$/ Puis établis toi-même la liste : duplication, code mort, dépendances circulaires./' $C/audit.md"
cas 11 "renvoi cité mais phrase qui ordonne le contraire" \
    "sed -i '24s/\$/ Le rapport est creux : refais la mesure de duplication toi-même./' $C/audit.md"
cas 11 "table terme → propriétaire vidée" \
    "sed -i '/^duplication|architect\$/,/^doublure|test-engineer\$/d' scripts/verifier-le-plugin.sh"
cas 12 "titre du bloc frontière dégradé en ###" \
    "sed -i 's/^## Ce que tu ne fais pas/### Ce que tu ne fais pas/' $A/architect.md"
cas 12 "agent privé de son bloc « Ce que tu ne fais pas »" \
    "sed -i '/^## Ce que tu ne fais pas/,/^## Méthode/{/^## Méthode/!d}' $A/test-engineer.md"

printf '\nLe contrôle de version, sur un dépôt doté d\047un vrai « origin/main »\n'

cas_version 0.13.0 rouge "version identique à celle de la branche par défaut" \
    "printf '\n' >> README.md"
cas_version 0.13.0 rouge "version qui RECULE" \
    "sed -i 's/\"version\": \"0.13.0\"/\"version\": \"0.9.0\"/' plugins/flow/.claude-plugin/plugin.json"
# monter_git pose la version sur la branche par défaut ; c'est donc au cas de
# bumper celle de la branche de travail, sinon les deux la partagent et le
# contrôle a raison de rougir.
cas_version 0.12.0 vert "version correctement bumpée" \
    "sed -i 's/\"version\": \"0.12.0\"/\"version\": \"0.14.0\"/' plugins/flow/.claude-plugin/plugin.json"
cas_version 0.13.0 rouge "fichier NEUF non suivi, sans bump" \
    "printf 'note\n' > docs/note-de-travail.md"

printf '\nRéciproques — un changement légitime ne doit rien faire rougir\n'

reciproque "douzième commande, documentée partout" \
    "cp $C/spec.md $C/exemple.md && sed -i 's|/flow:spec <idée>|/flow:spec <idée> et /flow:exemple|' README.md && sed -i 's|/flow:spec,|/flow:spec, /flow:exemple,|' .claude-plugin/marketplace.json"
reciproque ".gitattributes réécrit plus largement" \
    "printf '* text=auto eol=lf\n' > .gitattributes"
reciproque "agent déclarant ses outils en liste YAML, sans Edit" \
    "sed -i 's/^tools: .*/tools:\n  - Read\n  - Grep\n  - Bash/' $A/architect.md"
reciproque "terme employé en prose par une commande sans relecteur" \
    "sed -i '10i On y traque le code mort et la duplication.' $C/mutation.md"
reciproque "renvoi légitime depuis une commande" \
    "sed -i '24i La duplication est mesurée par \`architect\`, pas ici.' $C/audit.md"
reciproque "cinquième agent présent, sans être convoqué" \
    "printf -- '---\nname: relecteur-second\ndescription: Un cinquième relecteur.\ntools: Read, Grep, Glob, Bash\n---\n\n## Ce que tu ne fais pas\n\nLa structure du dépôt appartient à \`architect\`.\n\nTu relis ce que les autres ne relisent pas.\n' > $A/relecteur-second.md"

# La commande de calcul de /flow:audit, extraite d'audit.md et lancée sur un
# journal connu : ses chiffres décident de rendre un relecteur rare. Elle
# comptait zéro en silence sur une ligne mal formée — mesuré au bilan du
# 5 septembre 2026 — et rien ne l'éprouvait.
cas_journal() { # $1 = intitulé · $2 = lignes de journal · $3 = sortie attendue · $4 = date d'une étiquette à poser, facultative
    nom=$1; CAS=$((CAS + 1))
    rm -rf "$BAC/x"
    cp -R "$BAC/ref" "$BAC/x" || {
        printf "  ÉCHEC    %-52s → copie impossible, LE CAS N'A PAS TOURNÉ\n" "$nom"
        ECHECS=$((ECHECS + 1)); return 1
    }
    # %b interprète les antislashs de la fixture (\n, \r) : en doubler tout autre.
    printf '# Journal\n\n%b\n' "$2" > "$BAC/x/docs/journal.md"
    # Sans étiquette, « depuis » vaut 0000-00-00 et le filtre par date n'est
    # jamais exercé — c'est par là qu'un « dont » faux est passé. Une étiquette
    # datée dans la copie l'exerce.
    [ -n "${4:-}" ] && ( cd "$BAC/x" && { [ -d .git ] || git init -q; } &&
        git -c user.email=banc@essai -c user.name=banc commit -q --allow-empty -m etiquette --date="${4}T12:00:00" &&
        git tag v0 ) >/dev/null 2>&1
    OBTENU=$(cd "$BAC/x" && sed -n '/^DEPUIS=/,/^'"'"' depuis=/p' plugins/flow/commands/audit.md | sh 2>&1 | sort)
    if [ "$OBTENU" = "$(printf '%b' "$3" | sort)" ]; then
        printf '  ok       %-52s → compte juste\n' "$nom"
    else
        printf '  ÉCHEC    %-52s → compte faux :\n' "$nom"
        printf '%s\n' "$OBTENU" | sed 's/^/             /'
        ECHECS=$((ECHECS + 1))
    fi
}

printf '\nLa commande de calcul de /flow:audit, sur un journal connu\n'

cas_journal "deux portes, un « ? », un incident" \
    '- 2026-09-01 · porte · a · checks : 1 vert · bloquants : code-reviewer 2, architect ? · durée : 3 min\n- 2026-09-02 · incident · b · cause : ?\n- 2026-09-03 · porte · c · bloquants : code-reviewer 1, architect 0' \
    'code-reviewer : 3 bloquant(s) sur 2 convocation(s), 0 fois sans pouvoir regarder\narchitect : 0 bloquant(s) sur 2 convocation(s), 1 fois sans pouvoir regarder\nincidents depuis 0000-00-00 : 1, dont 1 sans cause connue ; 1 panne(s) ouverte(s) en tout'
cas_journal "journal arrivé en CRLF, panne corrigée par une seconde ligne" \
    '- 2026-09-01 · porte · a · bloquants : code-reviewer 2\r\n- 2026-09-02 · incident · b · cause : ?\r\n- 2026-09-03 · incident · b · cause : un câble · leçon : le tester\r' \
    'code-reviewer : 2 bloquant(s) sur 1 convocation(s), 0 fois sans pouvoir regarder\nincidents depuis 0000-00-00 : 1, dont 0 sans cause connue ; 0 panne(s) ouverte(s) en tout'
cas_journal "case « bloquants » illisible : signalée, jamais comptée zéro" \
    '- 2026-09-01 · porte · a · bloquants : code-reviewer : 5, architect : 2' \
    'illisible, ligne 3 : « code-reviewer : 5 »\nillisible, ligne 3 : « architect : 2 »\nincidents depuis 0000-00-00 : 0, dont 0 sans cause connue ; 0 panne(s) ouverte(s) en tout'
cas_journal "« ; » à la place de la virgule : illisible, pas un relecteur disparu" \
    '- 2026-09-01 · porte · a · bloquants : code-reviewer 2 ; architect 0' \
    'illisible, ligne 3 : « code-reviewer 2 ; architect 0 »\nincidents depuis 0000-00-00 : 0, dont 0 sans cause connue ; 0 panne(s) ouverte(s) en tout'
cas_journal "incident sans case « cause » : sans cause connue, jamais « connue »" \
    '- 2026-09-02 · incident · b' \
    'incidents depuis 0000-00-00 : 1, dont 1 sans cause connue ; 1 panne(s) ouverte(s) en tout'
cas_journal "ligne à puce « • » : ignorée, et dite" \
    '• 2026-09-01 · porte · a · bloquants : code-reviewer 2' \
    'ignorée, ligne 3 : ne commence pas par « - »\nincidents depuis 0000-00-00 : 0, dont 0 sans cause connue ; 0 panne(s) ouverte(s) en tout'
cas_journal "panne d'avant l'étiquette qui revient après : comptée, « dont » reste vrai" \
    '- 2026-08-01 · incident · b · cause : un câble\n- 2026-09-04 · incident · b · cause : ?\n- 2026-08-20 · incident · c · cause : ?' \
    'incidents depuis 2026-09-01 : 1, dont 1 sans cause connue ; 2 panne(s) ouverte(s) en tout' 2026-09-01

printf '\n'
[ "$NONCONCLUANTS" -gt 0 ] &&
    printf '%s cas non concluant(s) — un outil manquait, ils ne prouvent rien ici.\n' "$NONCONCLUANTS"
if [ "$ECHECS" -eq 0 ]; then
    printf "%s cas, aucun échec — la porte détecte ce qu'elle prétend détecter,\n" "$CAS"
    printf "et elle laisse passer ce qui doit passer.\n"
    exit 0
fi
printf '%s cas, %s ÉCHEC(S) — voir le détail ci-dessus : trou dans la porte,\n' "$CAS" "$ECHECS"
printf "faux rouge, ou cas qui n'a pas tourné.\n"
exit 1
