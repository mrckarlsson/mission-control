#!/bin/bash

# Hitta mappen där skriptet ligger
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ladda inställningar från config.sh
if [ -f "$DIR/config.sh" ]; then
    source "$DIR/config.sh"
else
    echo "Fel: Hittade ingen config.sh!"
    exit 1
fi

# --- DATA-INSLAMLING ---
RSS=$(curl -s "$RSS_URL" | tr -d '\n')
STATS=$(curl -s "$API_URL")
COMMENTS=$(curl -s "$API_URL/comments/?number=2")
GH_COMMITS=$(curl -s "https://api.github.com/repos/$GH_REPO/commits?per_page=1")
GH_REPO_INFO=$(curl -s "https://api.github.com/repos/$GH_REPO")

# MailPoet & CrowdSignal
MP_RAW_SEG=$(curl -s -u "$WP_USER:$WP_PASS" "https://$SITE_XYZ/wp-json/mailpoet/v1/segments")
MP_RAW_EML=$(curl -s -u "$WP_USER:$WP_PASS" "https://$SITE_XYZ/wp-json/mailpoet/v1/newsletters")
CS_DATA=$(curl -s -u "$WP_USER:$WP_PASS" "https://$SITE_XYZ/wp-json/crowdsignal/v1/results" 2>/dev/null)
METRIC_CHECK=$(curl -s "https://$SITE_XYZ" | grep -q "metricool" && echo "Aktiv" || echo "Ej hittad")

# Bearbeta data
CRON_COUNT=$(echo "$MP_RAW_SEG" | jq -r 'if type=="array" then .[] | select(.name? | test("Torsdag|Krönika"; "i")) | .subscribers_count else 0 end' | head -n 1)
BLOG_COUNT=$(echo "$MP_RAW_SEG" | jq -r 'if type=="array" then .[] | select(.name? | test("Morgon|Blogg"; "i")) | .subscribers_count else 0 end' | head -n 1)
LATEST_SENT=$(echo "$MP_RAW_EML" | jq -r 'if type=="array" then [.[] | select(.status=="sent")] | sort_by(.sent_at) | reverse | .[0] else empty end')

ITEM=$(echo "$RSS" | grep -oP '<item>.*?</item>' | head -1)
TITLE=$(echo "$ITEM" | grep -oP '(?<=<title>).*?(?=</title>)' | sed 's/<!\[CDATA\[//g; s/\]\]>//g')
PDATE=$(echo "$ITEM" | grep -oP '(?<=<pubDate>).*?(?=</pubDate>)')
PUB_SEC=$(date -d "$PDATE" +%s)
DIFF=$(( (NOW_SEC - PUB_SEC) / 86400 ))

# --- DASHBOARD HEADER & MISSION ---
echo -e "${ESC}[1;34m[DASHBOARD]${ESC}[0m"
echo -e "${ESC}[1;33mMIN MISSION:${ESC}[0m"
echo "Från skyddsombud till politisk röst. Jag ägnar min tid åt det fackliga"
echo "samtalet, arbetsmiljön och att belysa vardagen för dem som bygger"
echo "landet. Genom analys och opinionsbildning överbryggar jag klyftan"
echo "mellan stad och land. Värderingar leder vägen."

# --- MÅL & AKTIVITET ---
echo -e "\n${ESC}[1;32m[ MÅL & AKTIVITET ]${ESC}[0m"
if [ $DIFF -eq 0 ]; then echo -e "Status: ${ESC}[1;35m🔥 Publicerat idag!${ESC}[0m"
elif [ $DIFF -lt 3 ]; then echo -e "Status: Du har $((3 - $DIFF)) d kvar till mål."
else echo -e "Status: ${ESC}[1;31mDags att skriva! Du är $(( $DIFF - 3 )) d efter mål.${ESC}[0m"; fi

# --- SENASTE PUBLICERADE ---
echo -e "\n${ESC}[1;32m[ SENASTE PUBLICERADE ]${ESC}[0m"
echo -e "Titel: $TITLE\nDatum: $(date -d "$PDATE" +%F) ($DIFF d sen)"

# --- AKTIVA SKRIVPROJEKT ---
echo -e "\n${ESC}[1;32m[ AKTIVA SKRIVPROJEKT ]${ESC}[0m"
if [ -d "$A_PATH" ]; then
    for f in "$A_PATH"/*.md; do
        [ -e "$f" ] || continue
        s_line=$(grep -m 1 "^status:" "$f" | cut -d' ' -f2-)
        if [[ "$s_line" == "Skriver på" || "$s_line" == "Färdig" ]]; then
            c_line=$(grep -m 1 "^category:" "$f" | cut -d' ' -f2-); [ -z "$c_line" ] && c_line="---"
            dead_raw=$(grep -m 1 "^deadline_date:" "$f" | cut -d' ' -f2-)
            dead_info="---"
            if [ -n "$dead_raw" ]; then
                dead_sec=$(date -d "$dead_raw" +%s)
                rem_days=$(( (dead_sec - NOW_SEC) / 86400 ))
                if [ $rem_days -gt 0 ]; then dead_info="${rem_days} d kvar"
                elif [ $rem_days -eq 0 ]; then dead_info="IDAG!"
                else dead_info="$((rem_days * -1)) d sen"; fi
            fi
            atime=$(stat -c %X "$f"); adate=$(date -d "@$atime" +%F); adiff=$(( (NOW_SEC - atime) / 86400 ))
            n=$(basename "$f" .md); cn=${n//-/ }; cn="$(tr '[:lower:]' '[:upper:]' <<< ${cn:0:1})${cn:1}"
            enc=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$f")
            scol="${ESC}[0m"; [[ "$s_line" == "Färdig" ]] && scol="${ESC}[32m"; [[ "$s_line" == "Skriver på" ]] && scol="${ESC}[33m"
            printf "📝 Titel: ${ESC}]8;;obsidian://open?path=%s${ESC}\\%-25s${ESC}]8;;${ESC} | Kategori: %-12s | Status: %b%-10s${ESC}[0m | Manusstopp: %-12s | Öppnades: %s (%s d)\n" \
                   "$enc" "$cn" "$c_line" "$scol" "$s_line" "$dead_info" "$adate" "$adiff"
        fi
    done
fi

# --- IDÉER ATT SKRIVA OM ---
echo -e "\n${ESC}[1;32m[ IDÉER ATT SKRIVA OM ]${ESC}[0m"
if [ -d "$A_PATH" ]; then
    find "$A_PATH" -maxdepth 1 -name "*.md" -exec grep -l "^status: Idé" {} + | shuf -n 2 | while read -r f; do
        atime=$(stat -c %X "$f"); adate=$(date -d "@$atime" +%F); adiff=$(( (NOW_SEC - atime) / 86400 ))
        n=$(basename "$f" .md); cn=${n//-/ }; cn="$(tr '[:lower:]' '[:upper:]' <<< ${cn:0:1})${cn:1}"
        enc=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$f")
        printf "💡 Titel: ${ESC}]8;;obsidian://open?path=%s${ESC}\\%-25s${ESC}]8;;${ESC} | Öppnades: %s (%s d)\n" "$enc" "$cn" "$adate" "$adiff"
    done
fi

# --- STATISTIK & NYHETSBREV ---
echo -e "\n${ESC}[1;32m[ STATISTIK & NYHETSBREV ]${ESC}[0m"
echo -e "Jetpack:  $(echo "$STATS" | jq -r '.subscribers_count // 0') följare"
echo -e "Listor:   ${CRON_COUNT:-0} (Torsdag) | ${BLOG_COUNT:-0} (Morgon)"
LS_SUBJ=$(echo "$LATEST_SENT" | jq -r '.subject // "Inga utskick än"')
LS_DATE=$(echo "$LATEST_SENT" | jq -r '.sent_at // "---"')
echo -e "Senast:   \"$LS_SUBJ\" ($LS_DATE)"
echo -e "Resultat: 📈 $(echo "$LATEST_SENT" | jq -r '.statistics.opened // 0') öppnade | 🖱 $(echo "$LATEST_SENT" | jq -r '.statistics.clicked // 0') klick | 🚫 $(echo "$LATEST_SENT" | jq -r '.statistics.bounced // 0') studsar"

# --- INTERAKTION & PLUGINS ---
echo -e "\n${ESC}[1;32m[ INTERAKTION & PLUGINS ]${ESC}[0m"
CS_VOTES=$(echo "$CS_DATA" | jq -r 'if type=="array" then .[0].total_votes // 0 elif type=="object" then .total_votes // 0 else 0 end')
echo -e "CrowdSignal: 🗳 $CS_VOTES röster"
echo -e "Metricool:   📊 Tracker: $METRIC_CHECK"

# --- WEBBPLATS-STATUS ---
echo -e "\n${ESC}[1;32m[ WEBBPLATS-STATUS ]${ESC}[0m"
for url in "$SITE_BLOG" "$SITE_XYZ" "$SITE_LINK"; do
    perf=$(curl -o /dev/null -s -w "%{time_starttransfer}" --max-time 5 "https://$url")
    CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "https://$url")
    eval_msg=$(awk -v p="$perf" 'BEGIN { if (p < 0.2) print "⚡ Blixtsnabb"; else if (p < 0.6) print "✅ Bra"; else print "🐢 Långsam" }')
    p_col="${ESC}[32m"; [[ "$eval_msg" == *"Långsam"* ]] && p_col="${ESC}[31m"; [[ "$eval_msg" == *"Bra"* ]] && p_col="${ESC}[33m"
    if [[ "$CODE" =~ ^(200|301|302)$ ]]; then
        printf "🌐 %-25s: OK (%s) | Svarstid: %b%-12s${ESC}[0m\n" "$url" "$CODE" "$p_col" "$eval_msg"
    fi
done

# --- SÄKERHET & UTVECKLING ---
echo -e "\n${ESC}[1;32m[ SÄKERHET & UTVECKLING ]${ESC}[0m"
COMMIT_MSG=$(echo "$GH_COMMITS" | jq -r '.[0].commit.message' | head -n 1)
COMMIT_DATE=$(echo "$GH_COMMITS" | jq -r '.[0].commit.author.date')

get_ssl_days() {
    local domain=$1
    local expiry=$(echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d'=' -f2)
    local expiry_sec=$(date -d "$expiry" +%s)
    echo "$(( (expiry_sec - NOW_SEC) / 86400 ))"
}
echo -e "GitHub:   Senaste commit: \"$COMMIT_MSG\" ($(date -d "$COMMIT_DATE" +%F))"
echo -e "Repo:     ⭐ $(echo "$GH_REPO_INFO" | jq -r '.stargazers_count // 0') stars | 🛠 $(echo "$GH_REPO_INFO" | jq -r '.open_issues_count // 0') issues"
echo -e "SSL:      🛡 $SITE_XYZ ($(get_ssl_days "$SITE_XYZ") d) | 🛡 $SITE_LINK ($(get_ssl_days "$SITE_LINK") d)"
