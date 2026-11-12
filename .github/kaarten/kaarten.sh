#!/usr/bin/env bash
# Deelt de projectkaarten uit als GitHub Issues:
#   push               -> Kaart 1, als er nog geen kaart is
#   /klaar op kaart    -> label "aftekenen" + commitoverzicht van deze kaart
#   docent sluit kaart -> volgende kaart
set -euo pipefail

K=.github/kaarten
LAATSTE=6
GROOT=300
event=$(cat "$GITHUB_EVENT_PATH")
veld() { jq -r "$1" <<<"$event"; }

bestaat() {
    gh issue list --state all --limit 100 --json title --jq '.[].title' | grep -q "^Kaart $1 "
}

open_kaart() {
    local n=$1
    bestaat "$n" && return 0
    tail -n +2 "$K/$n.md" | gh issue create --title "$(head -1 "$K/$n.md" | sed 's/^# //')" --body-file -
}

# Commits sinds de vorige kaart is afgetekend (kaart 1: alle commits)
commit_overzicht() {
    local n=$1 sinds=""
    if [ "$n" -gt 1 ]; then
        sinds=$(gh issue list --state closed --limit 100 --json title,closedAt \
            --jq ".[] | select(.title | startswith(\"Kaart $((n - 1)) \")) | .closedAt" | head -1)
    fi
    echo "### Commits voor deze kaart"
    echo
    [ -n "$sinds" ] && echo "_Sinds kaart $((n - 1)) is afgetekend ($sinds)._" && echo
    git log HEAD --no-merges ${sinds:+--since="$sinds"} --shortstat --date=short \
        --pretty=format:'@@%h|%ad|%an|%s' |
    awk -v n="$n" -v groot="$GROOT" '
        function flush() {
            if (sha == "" || msg == "Set up a fresh Laravel app") { sha = ""; return }
            tot++
            if (index(msg, "K" n ": ") == 1) goed++
            else fout[++nf] = "`" sha "` " dag " — " msg
            if (ins > groot) grote[++ng] = "`" sha "` " dag " — +" ins " regels — " msg
            if (!(auteur in a)) { a[auteur] = 1; auteurs = auteurs (auteurs == "" ? "" : ", ") auteur }
            sha = ""
        }
        /^@@/ {
            flush()
            split(substr($0, 3), f, "|")
            sha = f[1]; dag = f[2]; auteur = f[3]
            msg = substr($0, length(f[1] f[2] f[3]) + 6); ins = 0; next
        }
        /insertion/ { if (match($0, /[0-9]+ insertion/)) ins = substr($0, RSTART, RLENGTH) + 0 }
        END {
            flush()
            printf "- **Commits:** %d, waarvan %d met `K%d:`\n", tot, goed, n
            printf "- **Auteurs:** %s\n", (auteurs == "" ? "-" : auteurs)
            if (nf) { printf "- ⚠️ **Ander of geen kaartnummer:** %d\n", nf; for (i = 1; i <= nf; i++) print "  - " fout[i] }
            if (ng) { printf "- ⚠️ **Grote commits (meer dan %d regels):** %d\n", groot, ng; for (i = 1; i <= ng; i++) print "  - " grote[i] }
        }'
}

# GitHub-gebruikersnamen zijn niet hoofdlettergevoelig
is_docent() {
    local docenten wie
    docenten=$(tr -d ' ' <<<",$DOCENTEN," | tr '[:upper:]' '[:lower:]')
    wie=$(tr '[:upper:]' '[:lower:]' <<<"$1")
    [[ $docenten == *",$wie,"* ]]
}

case $GITHUB_EVENT_NAME in
    push|workflow_dispatch)
        open_kaart 1
        ;;

    issue_comment)
        n=$(veld .issue.title | sed -n 's/^Kaart \([0-9]*\) .*/\1/p')
        [ -n "$n" ] && [ "$(veld .issue.state)" = open ] || exit 0
        [[ $(veld '.comment.body | split("\n")[0] | ascii_downcase') =~ ^\ */klaar ]] || exit 0
        nr=$(veld .issue.number)
        gh label create aftekenen --color FBCA04 --description "Wacht op aftekenen door docent" --force
        gh issue edit "$nr" --add-label aftekenen
        { echo "Je staat in de wachtrij. Je docent komt langs om af te tekenen."; echo; commit_overzicht "$n"; } |
            gh issue comment "$nr" --body-file -
        ;;

    issues)
        n=$(veld .issue.title | sed -n 's/^Kaart \([0-9]*\) .*/\1/p')
        [ -n "$n" ] || exit 0
        : "${DOCENTEN:?Org-variabele DOCENTEN ontbreekt, zie .github/DOCENT.md}"
        nr=$(veld .issue.number)
        if ! is_docent "$(veld .sender.login)"; then
            gh issue reopen "$nr"
            gh issue comment "$nr" --body "Alleen een docent kan een kaart aftekenen. Klaar? Typ \`/klaar\`."
            exit 0
        fi
        gh issue edit "$nr" --remove-label aftekenen || true
        # Gesloten als "not planned" = niet afgetekend
        [ "$(veld .issue.state_reason)" = completed ] || exit 0
        if [ "$n" -lt "$LAATSTE" ]; then
            open_kaart $((n + 1))
        else
            gh issue comment "$nr" --body "Alle kaarten zijn afgetekend. Goed gedaan! Op naar het eindproject."
        fi
        ;;
esac
