#!/bin/sh
# La porte du plugin sur lui-même.
#
# Des contrôles mécaniques — comptés, jamais écrits en dur —, en sh POSIX pour
# Ubuntu et sous Git Bash (Windows). Sortie 0 si tout est vert, 1 sinon.
#
# Deux règles de conception, apprises de la porte qu'il imite :
#
#   - Il lance TOUS les contrôles avant de conclure. S'arrêter au premier rouge
#     obligerait à le relancer autant de fois qu'il y a de défauts, et c'est le
#     meilleur moyen de faire abandonner à la troisième.
#   - Il ne rend rouge que sur un défaut réel. Un contrôle qui crie faux dès sa
#     naissance est désactivé dans la semaine — et le jour où il a raison,
#     personne ne l'écoute. « IGNORÉ » existe pour ça : ni vert, ni rouge.
#
# Lancer : sh scripts/verifier-le-plugin.sh

set -u

RACINE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
cd "$RACINE" || exit 1

case "${1:-}" in
    -h|--help|--aide)
        printf 'Vérifie le plugin sur lui-même. Aucun argument.\n'
        printf "Sortie 0 si aucun contrôle n'est rouge, 1 sinon.\n"
        printf "Un contrôle IGNORÉ n'est pas un contrôle vert : il est compté à part.\n"
        printf 'Le banc qui éprouve ces contrôles : sh scripts/eprouver-le-verificateur.sh\n'
        exit 0 ;;
    "") ;;
    *)  printf 'Argument inconnu : %s. Essaie --aide.\n' "$1" >&2; exit 2 ;;
esac

TOTAL=0   # contrôles rouges, toutes sections confondues
SECTION=0 # contrôles rouges de la section en cours
IGNORES=0 # contrôles qui n'ont rien pu vérifier — ni verts, ni rouges
COMPTE=0  # contrôles lancés — compté, jamais écrit en dur

TMP=${TMPDIR:-/tmp}/verif-plugin-$$
mkdir -p "$TMP" || exit 1
# Les signaux nettoient PUIS SORTENT : une porte qui continue après un tuyau
# coupé ou un Ctrl-C rend un verdict avec des rouges fantômes — mesuré au bilan
# du 5 septembre 2026. Même discipline que le banc.
trap 'rm -rf "$TMP"' EXIT
trap 'rm -rf "$TMP"; exit 130' HUP INT TERM PIPE

# Toute sortie passe par dire() : si l'écriture échoue — tuyau fermé alors que
# le signal PIPE est ignoré, ce qui est le cas des processus lancés par le robot
# de GitHub —, la porte sort sans verdict, exactement comme sur le signal.
# Mesuré : sur le runner, « | head -1 » rendait 0 avec le seul piège du signal.
dire()   { printf "$@" || exit 130; }
titre()  { SECTION=0; COMPTE=$((COMPTE + 1)); dire '\n%s\n' "$1"; }
ok()     { dire '  ok      %s\n' "$1"; }
ignore() { dire '  IGNORÉ  %s\n' "$1"; IGNORES=$((IGNORES + 1)); }
rate()   { dire '  ROUGE   %s\n' "$1"; SECTION=$((SECTION + 1)); TOTAL=$((TOTAL + 1)); }
# Conclut une section : le récapitulatif vert n'apparaît que si rien n'a raté.
fin()    { [ "$SECTION" -eq 0 ] && ok "$1"; return 0; }

# Retire les retours chariot Windows : aucune comparaison ne doit dépendre du
# système sur lequel le dépôt a été récupéré. (.gitattributes impose LF, ce
# filtre est la ceinture qui va avec les bretelles.)
sansCR() { tr -d '\r' < "$1"; }

version_de() { sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1; }

# Vrai si $1 est STRICTEMENT supérieure à $2. Une simple inégalité de chaînes ne
# suffit pas : elle laisserait passer un numéro qui RECULE — ce qui arrive pour
# de bon en résolvant un conflit de fusion sur plugin.json, et qui a exactement
# le même effet qu'une absence de bump.
# Vérifié : 1.0.0 > 0.99.0 · 0.10.0 > 0.9.0 · 1.2.10 > 1.2.9 · égalité = faux.
plus_grande() {
    [ "$1" != "$2" ] &&
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$2" ]
}

PLUGIN_JSON=plugins/flow/.claude-plugin/plugin.json
MARKET_JSON=.claude-plugin/marketplace.json
COMMANDES=plugins/flow/commands

# ---------------------------------------------------------------- 1
titre "1. Le bloc partagé : présent partout, et identique à l'octet"

# guide.md est la seule exception, et elle est écrite en dur ici volontairement :
# c'est la commande de dernier recours, elle ne peut pas se citer elle-même.
# Aucun décompte de fichiers n'est codé en dur — une douzième commande demain
# est contrôlée sans que ce script bouge.
REF=""
NB=0
for f in "$COMMANDES"/*.md; do
    case "$(basename "$f")" in guide.md) continue ;; esac
    if ! sansCR "$f" | grep -q '^## Arrêts et attentes'; then
        rate "$(basename "$f") ne porte pas le bloc partagé — la fin de réponse obligatoire a disparu"
        continue
    fi
    # Le reste du contrôle compare les fichiers ENTRE EUX : dix blocs vidés de
    # la même façon resteraient identiques, donc verts. Cette ligne est la seule
    # ancre à un contenu réel — sans elle, le contrôle est auto-réalisateur.
    sansCR "$f" | grep -q '^## Fin de réponse' ||
        rate "$(basename "$f") a perdu « ## Fin de réponse » — le bloc partagé a été vidé de sa substance"
    NB=$((NB + 1))
    sansCR "$f" | sed -n '/^## Arrêts et attentes/,$p' > "$TMP/bloc"
    if [ -z "$REF" ]; then
        REF=$(basename "$f")
        cp "$TMP/bloc" "$TMP/reference"
    elif ! diff -q "$TMP/reference" "$TMP/bloc" >/dev/null 2>&1; then
        rate "$(basename "$f") porte un bloc qui diverge de $REF"
    fi
done
[ "$NB" -eq 0 ] && rate "plus aucune commande ne porte le bloc partagé"
fin "$NB commandes, bloc présent et identique (guide.md exempté)"

# ---------------------------------------------------------------- 2
titre "2. README et commandes se citent mutuellement"

# Le nom doit être cité ENTIER : une recherche de sous-chaîne ferait passer
# « /flow:mutationX » pour une citation de « /flow:mutation », et un README qui
# a dérivé d'une lettre resterait vert.
cite_entier() { grep -qE -- "/flow:$2([^a-zA-Z0-9-]|\$)" "$1" 2>/dev/null; }

for f in "$COMMANDES"/*.md; do
    n=$(basename "$f" .md)
    cite_entier README.md "$n" ||
        rate "/flow:$n existe mais n'est nulle part dans le README"
done

grep -o -- '/flow:[a-z][a-z-]*' README.md 2>/dev/null | sed 's|/flow:||' | sort -u > "$TMP/cites"
while read -r n; do
    [ -z "$n" ] && continue
    [ -f "$COMMANDES/$n.md" ] || printf '%s\n' "$n" >> "$TMP/fantomes"
done < "$TMP/cites"
if [ -f "$TMP/fantomes" ]; then
    while read -r n; do rate "le README cite /flow:$n, qui n'existe pas"; done < "$TMP/fantomes"
fi
# La description de marketplace.json énumère les commandes à la main : c'est le
# champ le plus dérivant du dépôt, et le défaut s'y est DÉJÀ produit — le relevé
# du 4 septembre note que /flow:init-project y manquait. Rien ne le lisait.
# Sens aller seulement : les écarts observés ont toujours été des absences.
# Garde conditionnelle : le jour où la description cessera d'énumérer, le
# contrôle se taira au lieu de crier faux.
if grep -q '/flow:' "$MARKET_JSON" 2>/dev/null; then
    for f in "$COMMANDES"/*.md; do
        n=$(basename "$f" .md)
        cite_entier "$MARKET_JSON" "$n" ||
            rate "/flow:$n manque à la description de marketplace.json, qui énumère les commandes"
    done
fi

fin "$(wc -l < "$TMP/cites" | tr -d ' ') commandes, citées par le README et par la marketplace"

# ---------------------------------------------------------------- 3
titre "3. Chaque commande a un frontmatter exploitable"

# C'est lui qui décide si une commande existe pour Claude Code. Un `description:`
# perdu, et la commande disparaît de l'autocomplétion : panne totale, invisible,
# et qu'aucun autre contrôle n'attrape.
for f in "$COMMANDES"/*.md; do
    n=$(basename "$f")
    if [ "$(sansCR "$f" | head -1)" != "---" ]; then
        rate "$n ne commence pas par un frontmatter"
        continue
    fi
    # Un en-tête jamais refermé passait : la plage « 2,/^---$/ » courait jusqu'au
    # séparateur du bloc partagé, où « description: » se trouve encore — mesuré
    # au bilan du 5 septembre 2026. Le symptôme sûr : un titre de section dans
    # la plage. (Exiger la fermeture avant la première ligne vide rougirait un
    # en-tête YAML légitime qui en contient une.)
    if sansCR "$f" | sed -n '2,/^---$/p' | grep -q '^## '; then
        rate "$n a un frontmatter jamais refermé — sans second « --- », Claude Code ne sait plus où finit l'en-tête"
    fi
    sansCR "$f" | sed -n '2,/^---$/p' | grep -q '^description:[[:space:]]*[^[:space:]]' ||
        rate "$n n'a pas de ligne « description: » renseignée — la commande disparaîtrait de l'autocomplétion"
done
fin "$(ls "$COMMANDES"/*.md 2>/dev/null | wc -l | tr -d ' ') commandes, frontmatter renseigné"

# ---------------------------------------------------------------- 4
titre "4. Chaque agent déclare ses outils, sans Edit ni Write"

for f in plugins/flow/agents/*.md; do
    n=$(basename "$f")
    # YAML accepte deux écritures pour la même chose : « tools: A, B » sur une
    # ligne, ou « tools: » suivi d'une liste à tirets. Ne lire que la première
    # laissait passer un agent qui réclame Edit sous la seconde forme — mesuré.
    bloc=$(sansCR "$f" | awk '
        /^tools:/                        { pris = 1; print; next }
        pris && /^[[:space:]]*-[[:space:]]*[A-Za-z]/ { print; next }
        pris                             { exit }')
    valeur=$(printf '%s' "$bloc" | sed '1s/^tools:[[:space:]]*//' | tr -d '[:space:]-')
    if [ -z "$bloc" ]; then
        rate "$n n'a pas de ligne « tools: » — il hérite de tout, Edit et Write compris"
    elif [ -z "$valeur" ]; then
        rate "$n a une ligne « tools: » vide — elle ne déclare rien du tout"
    else
        case "$bloc" in
            *Edit*|*Write*) rate "$n déclare Edit ou Write : un relecteur rapporte, il ne répare pas" ;;
        esac
    fi
    # Même exigence que pour les commandes : sans « description: », Claude Code
    # ne sait plus quand convoquer l'agent. Le défaut est silencieux.
    if sansCR "$f" | sed -n '2,/^---$/p' | grep -q '^## '; then
        rate "$n a un frontmatter jamais refermé — sans second « --- », Claude Code ne sait plus où finit l'en-tête"
    fi
    sansCR "$f" | sed -n '2,/^---$/p' | grep -q '^description:[[:space:]]*[^[:space:]]' ||
        rate "$n n'a pas de ligne « description: » renseignée — plus rien ne dit quand le convoquer"
done

# Un agent SUPPRIMÉ ne se voyait pas : la boucle ci-dessus ne parcourt que ce
# qui existe, et le décompte affiché tombait de 4 à 3 sans être comparé à rien.
# C'est /flow:verify qui fait autorité sur la liste attendue — même forme que le
# contrôle 2, où le README fait autorité sur les commandes.
sansCR "$COMMANDES/verify.md" | sed -n 's/^- \*\*`\([a-z][a-z-]*\)`\*\*.*/\1/p' | sort -u > "$TMP/agents-attendus"
while read -r a; do
    [ -z "$a" ] && continue
    [ -f "plugins/flow/agents/$a.md" ] ||
        rate "/flow:verify convoque l'agent « $a », dont le fichier n'existe pas"
done < "$TMP/agents-attendus"
# Une liste vide éteignait la boucle en silence : verify.md reformaté, un agent
# supprimé, et « tous présents » — mesuré au bilan du 5 septembre 2026. Même
# garde que le contrôle 12 avec NB_AG.
[ -s "$TMP/agents-attendus" ] ||
    rate "/flow:verify ne convoque plus aucun agent lisible (forme « - **\`nom\`** ») — un agent supprimé passerait inaperçu"
# Et UNE seule ligne reformatée suffisait à faire disparaître son agent de la
# liste — mesuré. Toute puce de la section 2 doit avoir la forme lisible.
NB_ILLISIBLES=$(sansCR "$COMMANDES/verify.md" | sed -n '/^## 2\./,/^## 3\./p' | grep '^- ' | grep -vc '^- \*\*`[a-z][a-z-]*`\*\*')
[ "$NB_ILLISIBLES" -eq 0 ] ||
    rate "/flow:verify : $NB_ILLISIBLES ligne(s) de relecteur illisible(s) dans la section 2 (forme attendue « - **\`nom\`** ») — l'agent qu'elles nomment n'est plus contrôlé"

fin "$(ls plugins/flow/agents/*.md 2>/dev/null | wc -l | tr -d ' ') agents, tous déclarés et tous présents"

# ---------------------------------------------------------------- 5
titre "5. Les manifestes sont valides et se répondent"

if command -v python3 >/dev/null 2>&1; then
    for m in $PLUGIN_JSON $MARKET_JSON; do
        python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$m" 2>/dev/null ||
            rate "$m n'est pas un JSON valide — le plugin serait ininstallable"
    done
    fin "les deux manifestes parsent"
else
    for m in $PLUGIN_JSON $MARKET_JSON; do
        grep -q '"name"' "$m" 2>/dev/null || rate "$m : clé « name » absente"
    done
    ignore "python3 absent — validation JSON réduite à une recherche de clés"
fi

NOM_PLUGIN=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PLUGIN_JSON" 2>/dev/null | head -1)
if [ -z "$NOM_PLUGIN" ]; then
    rate "aucun nom lisible dans $PLUGIN_JSON"
elif ! grep -q "\"$NOM_PLUGIN\"" "$MARKET_JSON" 2>/dev/null; then
    rate "marketplace.json ne référence aucun plugin nommé « $NOM_PLUGIN »"
fi

# La clé « source » dit OÙ est le plugin. Une valeur qui pointe dans le vide rend
# le plugin ininstallable sans qu'aucun autre contrôle ne bronche — le nom, lui,
# continue de correspondre.
SOURCE=$(sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MARKET_JSON" 2>/dev/null | head -1)
if [ -z "$SOURCE" ]; then
    rate "marketplace.json n'a pas de clé « source » lisible"
elif [ ! -f "${SOURCE#./}/.claude-plugin/plugin.json" ]; then
    rate "marketplace.json pointe vers « $SOURCE », où il n'y a pas de plugin.json"
fi

# ---------------------------------------------------------------- 6
titre "6. La version est bumpée par rapport à la branche par défaut"

# Sans bump, aucune mise à jour n'est proposée, même si le dépôt distant a
# changé : c'est la panne silencieuse que le README décrit à sa section
# « Mettre à jour le workflow ».
VERSION=$(version_de < "$PLUGIN_JSON")
if [ -z "$VERSION" ]; then
    rate "aucune version lisible dans $PLUGIN_JSON"
else
    # JAMAIS de --depth ici. Sur un clone complet privé de la ref origin/main
    # (clone --single-branch, git init + remote add, CI sans fetch-depth), un
    # fetch superficiel pose .git/shallow et ampute l'historique du dossier de
    # travail — mesuré : 24 commits ramenés à 1. Une commande « test » n'a pas
    # le droit d'abîmer le dépôt qu'elle vérifie.
    git fetch --quiet origin main 2>/dev/null || true
    REF_MAIN=""
    for r in origin/main FETCH_HEAD main; do
        git rev-parse --verify --quiet "$r" >/dev/null 2>&1 && { REF_MAIN=$r; break; }
    done
    if [ -z "$REF_MAIN" ]; then
        ignore "branche par défaut introuvable — rien à quoi comparer $VERSION"
    # La bonne question est « le dépôt diffère-t-il de la branche par défaut ? »,
    # pas « HEAD a-t-il bougé ? ». /flow:verify tourne AVANT le commit de
    # /flow:ship : comparer les commits rendrait ce contrôle inerte à chaque
    # passage de la porte, c'est-à-dire exactement quand on le lance.
    # `git diff <ref>` ne voit PAS les fichiers non suivis. Or /flow:verify passe
    # avant le commit de /flow:ship : un fichier tout neuf y est encore non suivi,
    # et l'ajout d'un fichier est précisément ce qui réclame un bump. Sans cette
    # seconde condition, le contrôle se déclarait IGNORÉ au moment exact où il
    # avait quelque chose à dire.
    elif git diff --quiet "$REF_MAIN" -- 2>/dev/null &&
         [ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        ignore "rien ne diffère de $REF_MAIN ($VERSION) — aucun bump attendu"
    else
        AVANT=$(git show "$REF_MAIN:$PLUGIN_JSON" 2>/dev/null | version_de)
        if [ -z "$AVANT" ]; then
            ignore "version illisible sur $REF_MAIN — comparaison sautée"
        elif [ "$AVANT" = "$VERSION" ]; then
            rate "version toujours $VERSION alors que $REF_MAIN porte la même — sans bump, aucune mise à jour ne sera proposée"
        elif ! plus_grande "$VERSION" "$AVANT"; then
            rate "version $VERSION en RECUL par rapport à $REF_MAIN ($AVANT) — même effet qu'une absence de bump"
        else
            fin "version $VERSION ($REF_MAIN : $AVANT)"
        fi
    fi
fi

# ---------------------------------------------------------------- 7
titre "7. Les chemins du dépôt cités par le README existent"

# Uniquement les chaînes qui prétendent désigner un fichier DE CE DÉPÔT, c'est-à-dire
# celles qui commencent par un de ses dossiers de premier niveau. Tout le reste —
# motifs de permission (`**/.env`), chemins d'exemple (`config/.env`), chemins hors
# dépôt (`~/.claude/settings.json`) — est ignoré sans exception : une extraction
# générique produit une dizaine de fausses alertes sur un README juste.
grep -o '`[a-zA-Z0-9_.][a-zA-Z0-9_./-]*`' README.md 2>/dev/null | tr -d '`' |
    grep -E '^(docs|plugins|scripts|\.github|\.claude-plugin)/' | sort -u > "$TMP/chemins"
while read -r p; do
    [ -z "$p" ] && continue
    [ -e "$p" ] || rate "le README cite $p, qui n'existe pas"
done < "$TMP/chemins"
fin "$(wc -l < "$TMP/chemins" | tr -d ' ') chemins du dépôt cités, tous présents"

# ---------------------------------------------------------------- 8
titre "8. Aucun appel gh dépendant d'une version"

# Garde de la décision 0002. `gh repo edit --visibility` est cassé des DEUX
# côtés : avant gh 2.61.0 le drapeau --accept-visibility-change-consequences
# n'existe pas, à partir de 2.61.0 il est obligatoire. Interdire la commande
# entière plutôt qu'un de ses drapeaux couvre les deux formes, et toute variante
# future. Le périmètre est volontairement `commands/` : `docs/` a le droit de
# nommer le drapeau, et le nomme (spec et décision), sans quoi ce contrôle
# serait rouge le jour de sa naissance.
TROUVE=$(grep -rn -- 'gh repo edit' "$COMMANDES" 2>/dev/null)
if [ -n "$TROUVE" ]; then
    rate "cet appel échoue avant gh 2.61.0 (drapeau inexistant) ET à partir de 2.61.0 (drapeau obligatoire) : passer par gh api"
    printf '%s\n' "$TROUVE" | sed 's/^/          /'
else
    fin "aucune commande n'emploie la sous-commande d'édition de dépôt"
fi

for v in public private; do
    grep -rq -- "visibility=$v" "$COMMANDES" 2>/dev/null ||
        rate "plus aucun appel « visibility=$v » : /flow:visibilite a perdu un de ses deux bouts"
done

# ---------------------------------------------------------------- 9
titre "9. Aucun reste PowerShell dans le plugin"

TROUVE=$(grep -rniE 'powershell|\.ps1' plugins/ 2>/dev/null)
if [ -n "$TROUVE" ]; then
    rate "PowerShell n'existe pas sous Linux — la décision 0001 l'avait retiré"
    printf '%s\n' "$TROUVE" | sed 's/^/          /'
else
    fin "rien de spécifique à Windows dans le plugin"
fi

# ---------------------------------------------------------------- 10
titre "10. Les scripts arrivent en LF, y compris sous Windows"

# La décision 0002 fait de cette garantie la raison de NE PAS payer un runner
# Windows. Elle reposait sur un fichier que rien ne lisait.
#
# On interroge git sur la propriété EFFECTIVE, pas sur la rédaction de
# .gitattributes : une réécriture plus large (« * text=auto eol=lf ») est plus
# protectrice et rendrait rouge un contrôle qui chercherait la ligne « *.sh ».
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    ignore "hors d'un dépôt git — la propriété de fin de ligne n'est pas interrogeable"
else
    for s in scripts/*.sh; do
        [ -e "$s" ] || continue
        EOL=$(git check-attr eol -- "$s" 2>/dev/null | sed 's/.*: eol: //')
        [ "$EOL" = "lf" ] ||
            rate "$s n'est pas forcé en LF (git répond « $EOL ») : Git Bash refuserait de l'exécuter sous Windows"
    done
    fin "$(ls scripts/*.sh 2>/dev/null | wc -l | tr -d ' ') scripts, fin de ligne LF garantie par git"
fi

# ---------------------------------------------------------------- 11
titre "11. Une préoccupation, un propriétaire"

# Garde de la décision 0003. Une préoccupation partagée entre deux agents produit
# deux mesures pour un seul fait, et deux avis qu'on ne sait pas départager.
#
# Deux règles :
#   (a) le terme doit exister chez son propriétaire — sinon la préoccupation a
#       disparu du plugin ;
#   (b) ailleurs, il n'est toléré que sur une ligne qui CITE le propriétaire
#       ENTRE ACCENTS GRAVES. Sans les accents, « duplication d'une architecture
#       inutile » passerait pour un renvoi à `architect` — mesuré.
#
# Périmètre : agents ET commandes. Aveugle aux commandes, cette garde ratait
# trois doublons sur cinq, dont celui d'audit.md qui a motivé la décision.
# `docs/` est exclu pour la même raison que le contrôle 8 : la spec et les
# décisions ont le droit de nommer ces termes en prose.
#
# Limite assumée : une PARAPHRASE échappe au grep. audit.md disait « code exporté
# jamais utilisé » pour « code mort ». Cette garde couvre quatre recouvrements
# sur cinq — seule une relecture attrape le cinquième.

BT=$(printf '\140')   # un accent grave, littéral

# Une commande n'attribue du travail de revue que si elle convoque un relecteur.
# Les autres emploient ces mots en prose ordinaire — mutation.md parle de code
# « mort » tout à fait légitimement. Le périmètre se calcule donc, il n'est pas
# écrit en dur : les noms d'agents viennent des fichiers d'agents.
COMMANDES_ARBITRES=""
for c in plugins/flow/commands/*.md; do
    [ -e "$c" ] || continue
    for a in plugins/flow/agents/*.md; do
        [ -e "$a" ] || continue
        if grep -qF -- "$BT$(basename "$a" .md)$BT" "$c"; then
            COMMANDES_ARBITRES="$COMMANDES_ARBITRES $c"
            break
        fi
    done
done

cat > "$TMP/garde" <<'FIN_GARDE'
duplication|architect
code mort|architect
dépendances circulaires|architect
doublure|test-engineer
FIN_GARDE

NB_TERMES=0
while IFS='|' read -r terme prop; do
    [ -z "$terme" ] && continue
    NB_TERMES=$((NB_TERMES + 1))
    FPROP="plugins/flow/agents/$prop.md"
    if [ ! -f "$FPROP" ]; then
        rate "« $terme » est attribué à $prop, dont le fichier n'existe pas"
        continue
    fi
    # La présence se juge HORS du bloc « Ce que tu ne fais pas ». Sans ça, un
    # propriétaire qui a perdu la préoccupation reste vert grâce au seul mot
    # laissé dans son propre renvoi aux autres — mesuré.
    CORPS=$(sansCR "$FPROP" | awk '
        /^## Ce que tu ne fais pas/ { saute = 1; next }
        /^## /                      { saute = 0 }
        !saute')
    if ! printf '%s\n' "$CORPS" | grep -qiF -- "$terme"; then
        rate "« $terme » a disparu du corps de son propriétaire ($prop) — la préoccupation n'est plus couverte"
        continue
    fi
    for f in plugins/flow/agents/*.md $COMMANDES_ARBITRES; do
        [ "$f" = "$FPROP" ] && continue
        [ -e "$f" ] || continue
        # La maille est la PHRASE, pas la ligne. Exempter la ligne entière
        # laissait greffer un doublon sur une ligne qui cite déjà le
        # propriétaire — mesuré sur audit.md:24, la ligne même du renvoi.
        FAUTIVES=$(sansCR "$f" | awk -v t="$terme" -v pat="$BT$prop$BT" '
            { n = $0; gsub(/\. /, ".\n", n); k = split(n, ph, "\n")
              for (i = 1; i <= k; i++)
                  if (index(tolower(ph[i]), tolower(t)) && !index(ph[i], pat))
                      printf "%d:%s\n", FNR, ph[i] }')
        if [ -n "$FAUTIVES" ]; then
            rate "« $terme » appartient à $prop, et $(basename "$f") le reprend sans le nommer entre accents graves"
            printf '%s\n' "$FAUTIVES" | cut -c1-100 | sed 's/^/          /'
        fi
    done
done < "$TMP/garde"
[ "$NB_TERMES" -eq 0 ] && rate "la table terme → propriétaire est vide : ce contrôle ne garde plus rien"
fin "$NB_TERMES préoccupations, chacune chez un seul propriétaire"

# ---------------------------------------------------------------- 12
titre "12. Chaque agent dit ce qu'il ne fait pas"

# Critère 4 de la spec, et socle du contrôle 11 : celui-ci juge la présence HORS
# du bloc « Ce que tu ne fais pas », qu'il exclut par son TITRE LITTÉRAL. Un bloc
# supprimé — ou dont le titre passe en ### — rend cette règle inerte en silence,
# et le contrôle 11 redevient la passoire que le banc avait trouvée. Même
# discipline que le contrôle 1, qui protège l'ancre « ## Fin de réponse ».
NB_AG=0
for f in plugins/flow/agents/*.md; do
    [ -e "$f" ] || continue
    NB_AG=$((NB_AG + 1))
    sansCR "$f" | grep -q '^## Ce que tu ne fais pas' ||
        rate "$(basename "$f") n'a pas de bloc « Ce que tu ne fais pas » — et le contrôle 11 juge la présence hors d'un bloc qui n'existe plus"
done
[ "$NB_AG" -eq 0 ] && rate "plus aucun agent"
fin "$NB_AG agents, chacun nomme ce qu'il laisse aux autres"

# ----------------------------------------------------------------
dire '\n'
# Un contrôle IGNORÉ n'est pas un contrôle vert. Le dire est la seule règle que
# ce script impose à tous les projets et qu'il se doit à lui-même : « une
# commande absente se note non configuré — jamais OK ». Le code de sortie reste
# 0, en revanche : rendre rouge sur « python3 absent » ferait crier la porte dès
# sa naissance sur le poste Windows, et une porte qui crie faux est désactivée
# dans la semaine.
if [ "$TOTAL" -eq 0 ]; then
    if [ "$IGNORES" -eq 0 ]; then
        dire 'PASSE — les %s contrôles sont verts.\n' "$COMPTE"
    else
        dire "PASSE avec réserves — sur %s contrôles, aucun rouge mais %s IGNORÉ(S) ci-dessus : ils n'ont rien pu vérifier.\n" "$COMPTE" "$IGNORES"
    fi
    exit 0
fi
dire 'BLOQUÉ — %s contrôle(s) rouge(s)' "$TOTAL"
[ "$IGNORES" -gt 0 ] && dire ', et %s IGNORÉ(S)' "$IGNORES"
dire '.\n'
exit 1
