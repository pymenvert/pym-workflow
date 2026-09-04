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
trap 'rm -rf "$BAC"; printf "\ninterrompu — aucun verdict.\n" >&2; exit 130' HUP INT TERM

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
# L'initialisation de r dans BEGIN n'est pas une précaution de style : en awk,
# une variable jamais affectée vaut la chaîne vide, qui est ÉGALE À ZÉRO dans une
# comparaison numérique. Sans cette ligne, la fonction rendait « rouge » pour
# tout, et les vingt-quatre cas du banc passaient au vert sans rien prouver.
etat_du_controle() {
    printf '%s\n' "$1" | awk -v n="$2" '
        BEGIN       { r = 1 }
        /^[0-9]+\./ { c = $1; sub(/\./, "", c) }
        /ROUGE/     { if (c == n)             r = 0 }
        /IGNORÉ/    { if (c == n && r != 0)   r = 2 }
        END         { exit r }'
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
reciproque "cinquième agent, convoqué et présent" \
    "cp $A/architect.md $A/relecteur-second.md && sed -i 's/^name: architect/name: relecteur-second/' $A/relecteur-second.md"

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
