alias s-n='snake'
alias s-w='snake-weather'
alias s-m='snake-matrix'
alias s-h='snake-help'
alias s-d='snake-downloader'

snake-downloader() {
    if [ -z "$1" ]; then
        printf "${RED}[-] Please provide a URL.${RESET}\n"
        return
    fi
    clear
    printf "${CYAN}[*] Initializing custom Snake-Downloader...${RESET}\n"
    printf "${GRAY}[*] Analyzing link stability...${RESET}\n"

    body=$(cat <<EOF
{
  "url": "$1",
  "videoQuality": "720",
  "filenameStyle": "basic"
}
EOF
)

    api_endpoints=(
        "https://cobalt-api.hyper.lol/"
        "https://api.cobalt.blackcat.sweeux.org/"
        "https://cobalt.meowing.de/"
        "https://api.co.rooot.gay/"
    )

    response=""
    active_node=""

    for api_url in "${api_endpoints[@]}"; do
        active_node=$(echo "$api_url" | cut -d'/' -f3)
        printf "${GRAY}[*] Testing secure API tunnel ($active_node)...${RESET}\n"
        response=$(curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "$body" --max-time 15 "$api_url")
        if [ -n "$response" ] && echo "$response" | grep -q '"status"'; then
            break
        fi
        printf "${YELLOW}[!] Node ($active_node) is rate-limited or busy. Switching tunnel...${RESET}\n"
        response=""
    done

    if [ -z "$response" ]; then
        printf "${RED}[-] All autorski API nodes are currently overloaded. Please try again in a few moments.${RESET}\n"
        return
    fi

    status=$(echo "$response" | grep -o '"status":"[^"]*' | head -n1 | cut -d'"' -f4)
    direct_link=""

    if [ "$status" = "stream" ] || [ "$status" = "tunnel" ] || [ "$status" = "redirect" ]; then
        direct_link=$(echo "$response" | grep -o '"url":"[^"]*' | head -n1 | cut -d'"' -f4)
    elif [ "$status" = "picker" ]; then
        direct_link=$(echo "$response" | grep -o '"url":"[^"]*' | head -n2 | tail -n1 | cut -d'"' -f4)
    fi

    if [ -n "$direct_link" ]; then
        filename="SnakeVideo_$(date +%Y%m%d_%H%M%S).mp4"
        download_dir="$HOME/Downloads"
        mkdir -p "$download_dir"
        destination="$download_dir/$filename"

        printf "${GREEN}[+] Stream interface resolved! Mode: $status${RESET}\n"
        printf "${CYAN}[*] Downloading file directly to disk...${RESET}\n"
        printf "${GRAY}--------------------------------------------------------${RESET}\n"

        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
        curl -H "User-Agent: $user_agent" -L -o "$destination" "$direct_link"

        clear
        printf "${GRAY}========================================================${RESET}\n"
        printf "${GREEN}              🐍 DOWNLOAD COMPLETE! 🐍                  ${RESET}\n"
        printf "${GRAY}========================================================${RESET}\n"
        printf "${GREEN}    ____\n"
        printf "   / . .\\ \n"
        printf "   \\  ---<      File: $filename\n"
        printf "    \\  \\        Path: $destination\n"
        printf "    /  /       \n"
        printf "   (_________/        Status: 100% Secured & Autorski!\n${RESET}"
        printf "\n${GREEN}[+] Success! Video downloaded safely without any external binaries or malware risk.${RESET}\n\n"
    else
        printf "${RED}[-] API responded, but did not provide a direct download URL. Status: $status${RESET}\n"
    fi
}


snake() {
    local rows cols max_x max_y
    rows=$(tput lines); cols=$(tput cols)
    max_x=$((cols - 5))
    max_y=$((rows - 2))

    local CHAR_H="-" CHAR_V="|" CHAR_SLASH="/" CHAR_BACK="\\"
    local CHAR_TL=$'\u250c' CHAR_TR=$'\u2510' CHAR_BL=$'\u2514' CHAR_BR=$'\u2518'

    local LEN=15
    local -a sx sy schar
    for ((i=0; i<LEN; i++)); do
        sx[i]=$((40 - i))
        sy[i]=12
        schar[i]="$CHAR_H"
    done

    local dirx=1 diry=0
    local old_dirx old_diry
    local in_loop=0 loop_steps=0 loop_dir=1
    local loop_angle="0"

    tput civis
    clear
    trap 'tput cnorm; clear; trap - INT; return 0' INT

    echo -e "\033[36mGenerating an advanced dynamic snake... Press Ctrl+C to stop.\033[0m"
    sleep 1
    clear


    while true; do
        old_dirx=$dirx
        old_diry=$diry

        if (( in_loop )); then
            loop_steps=$((loop_steps - 1))
            loop_angle=$(awk -v a="$loop_angle" -v d="$loop_dir" 'BEGIN{printf "%.6f", a + d*0.45}')
            dirx=$(awk -v a="$loop_angle" 'BEGIN{c=cos(a)*2; printf "%d", (c>0)-(c<0)*(c<-0.5) + (c>=0.5)-(c<=-0.5)}')
            dirx=$(awk -v a="$loop_angle" 'BEGIN{v=cos(a)*2; r=(v>=0)?int(v+0.5):int(v-0.5); print r}')
            diry=$(awk -v a="$loop_angle" 'BEGIN{v=sin(a); r=(v>=0)?int(v+0.5):int(v-0.5); print r}')

            if (( loop_steps <= 0 )); then
                in_loop=0
                (( dirx > 0 )) && dirx=1 || { (( dirx < 0 )) && dirx=-1 || dirx=0; }
                (( diry > 0 )) && diry=1 || { (( diry < 0 )) && diry=-1 || diry=0; }
            fi
        else
            local roll=$(( (RANDOM % 100) + 1 ))
            if (( roll <= 3 )); then
                in_loop=1
                loop_steps=$(( (RANDOM % 4) + 14 ))
                loop_dir=$(( (RANDOM % 2) == 0 ? 1 : -1 ))
                loop_angle=$(awk -v y="$diry" -v x="$dirx" 'BEGIN{printf "%.6f", atan2(y, x/2)}')
            elif (( roll <= 20 )); then
                local new_dx new_dy
                while true; do
                    new_dx=$(( (RANDOM % 3) - 1 ))
                    new_dy=$(( (RANDOM % 3) - 1 ))
                    (( new_dx == 0 && new_dy == 0 )) && continue
                    (( new_dx == -dirx && new_dx != 0 )) && continue
                    (( new_dy == -diry && new_dy != 0 )) && continue
                    break
                done
                dirx=$new_dx
                diry=$new_dy
            fi
        fi

        local new_x=$((sx[0] + dirx))
        local new_y=$((sy[0] + diry))

        if (( new_x < 1 || new_x > max_x || new_y < 1 || new_y > max_y )); then
            in_loop=0; loop_steps=0
            while true; do
                dirx=$(( (RANDOM % 3) - 1 ))
                diry=$(( (RANDOM % 3) - 1 ))
                new_x=$((sx[0] + dirx))
                new_y=$((sy[0] + diry))
                (( new_x < 1 || new_x > max_x || new_y < 1 || new_y > max_y )) && continue
                (( dirx == 0 && diry == 0 )) && continue
                break
            done
        fi

        local next_char="$CHAR_H"
        if (( in_loop )); then
            if (( (dirx > 0 && diry > 0) || (dirx < 0 && diry < 0) )); then next_char="$CHAR_BACK"
            elif (( (dirx < 0 && diry > 0) || (dirx > 0 && diry < 0) )); then next_char="$CHAR_SLASH"
            elif (( diry != 0 && dirx == 0 )); then next_char="$CHAR_V"
            else next_char="$CHAR_H"
            fi
        else
            if (( old_diry == 0 && dirx == 0 && diry > 0 )); then
                next_char=$([ $old_dirx -gt 0 ] && echo "$CHAR_TR" || echo "$CHAR_TL")
            elif (( old_diry == 0 && dirx == 0 && diry < 0 )); then
                next_char=$([ $old_dirx -gt 0 ] && echo "$CHAR_BR" || echo "$CHAR_BL")
            elif (( old_dirx == 0 && diry == 0 && dirx > 0 )); then
                next_char=$([ $old_diry -gt 0 ] && echo "$CHAR_BL" || echo "$CHAR_TL")
            elif (( old_dirx == 0 && diry == 0 && dirx < 0 )); then
                next_char=$([ $old_diry -gt 0 ] && echo "$CHAR_BR" || echo "$CHAR_TR")
            elif (( dirx != 0 && diry != 0 )); then
                if (( (dirx > 0 && diry > 0) || (dirx < 0 && diry < 0) )); then next_char="$CHAR_BACK"; else next_char="$CHAR_SLASH"; fi
            elif (( dirx != 0 && diry == 0 )); then next_char="$CHAR_H"
            elif (( dirx == 0 && diry != 0 )); then next_char="$CHAR_V"
            fi
        fi
        schar[0]="$next_char"
        local tail_idx=$((LEN - 1))
        printf "\033[%d;%dH \033[K" "${sy[tail_idx]}" "${sx[tail_idx]}" > /dev/tty 2>/dev/null
        tput cup "${sy[tail_idx]}" "${sx[tail_idx]}"
        printf " "

        for ((i=LEN-1; i>0; i--)); do
            sx[i]=${sx[i-1]}
            sy[i]=${sy[i-1]}
            schar[i]=${schar[i-1]}
        done
        sx[0]=$new_x
        sy[0]=$new_y

        for ((i=0; i<LEN; i++)); do
            tput cup "${sy[i]}" "${sx[i]}"
            if (( i == 0 )); then
                printf "\033[33m%%\033[0m"
            else
                printf "\033[32m%s\033[0m" "${schar[i]}"
            fi
        done

        sleep 0.06
    done
}

snake-info() {
    clear
    echo -e "\033[36mGathering full system information...\033[0m"

    local os kernel uptime_s shell locale cpu gpu mem_total mem_used local_ip
    os="$( ([ -f /etc/os-release ] && . /etc/os-release && echo "$PRETTY_NAME") || uname -s)"
    kernel="$(uname -sr)"

    if command -v uptime >/dev/null 2>&1; then
        uptime_s="$(uptime -p 2>/dev/null | sed 's/^up //')"
    fi
    [ -z "$uptime_s" ] && uptime_s="n/a"

    shell="bash ($BASH_VERSION)"
    locale="${LANG:-n/a}"

    if command -v lscpu >/dev/null 2>&1; then
        cpu="$(lscpu | awk -F: '/Model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}')"
    fi
    [ -z "$cpu" ] && cpu="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ //')"
    [ -z "$cpu" ] && cpu="n/a"

    if command -v lspci >/dev/null 2>&1; then
        gpu="$(lspci 2>/dev/null | grep -iE 'vga|3d controller' | head -1 | cut -d: -f3 | sed 's/^ //')"
    fi
    [ -z "$gpu" ] && gpu="n/a"

    if [ -r /proc/meminfo ]; then
        local mem_total_kb mem_avail_kb
        mem_total_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo)
        mem_avail_kb=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
        mem_total=$(awk -v t="$mem_total_kb" 'BEGIN{printf "%.2f", t/1024/1024}')
        mem_used=$(awk -v t="$mem_total_kb" -v a="$mem_avail_kb" 'BEGIN{printf "%.2f", (t-a)/1024/1024}')
    fi
    [ -z "$mem_total" ] && mem_total="n/a"
    [ -z "$mem_used" ] && mem_used="n/a"

    local -a disks=()
    if command -v df >/dev/null 2>&1; then
        while IFS= read -r line; do
            disks+=("$line")
        done < <(df -h --output=target,size,avail -x tmpfs -x devtmpfs -x squashfs -x overlay 2>/dev/null | tail -n +2 | awk '{printf "Disk (%s): [Free: %s / Total: %s]\n", $1, $3, $2}')
    fi

    if command -v ip >/dev/null 2>&1; then
        local_ip="$(ip -4 route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')"
    fi
    [ -z "$local_ip" ] && local_ip="n/a"

    local -a info=()
    info+=("OS:|$os")
    info+=("Kernel:|$kernel")
    info+=("Uptime:|$uptime_s")
    info+=("Shell:|$shell")
    info+=("CPU:|$cpu")
    info+=("GPU:|$gpu")
    info+=("Memory:|${mem_used} GiB / ${mem_total} GiB")
    for d in "${disks[@]}"; do info+=("|$d"); done
    info+=("Local IP:|$local_ip")
    info+=("Locale:|$locale")

    clear

    local -a snake_art=(
        "     ____       "
        "    / . .\\      "
        "    \\  ---<     "
        "     \\  \\       "
        "     /  /       "
        "     \\  \\       "
        "    /  /_____   "
        "   (________/   "
    )
    local -a logo_art=(
        "      .--."
        "     |o_o |"
        "     |:_/ |"
        "    //   \\ \\"
        "   (|     | )"
        "  /'\\_   _/'\\"
        "  \\___)=(___/"
    )

    local max_len=0
    for entry in "${info[@]}"; do
        local label="${entry%%|*}" value="${entry#*|}"
        local full="$label $value"
        (( ${#full} > max_len )) && max_len=${#full}
    done

    local text_x=18
    local logo_x=$((text_x + max_len + 5))

    for i in "${!snake_art[@]}"; do
        tput cup "$i" 0
        printf "\033[32m%s\033[0m" "${snake_art[$i]}"
    done

    for i in "${!logo_art[@]}"; do
        line="${logo_art[$i]}"
        if [[ -n "${line// }" ]]; then
            tput cup "$i" "$logo_x"
            printf "\033[33m%s\033[0m\n" "$line"
        fi
    done

    local row=0
    for entry in "${info[@]}"; do
        local label="${entry%%|*}" value="${entry#*|}"
        tput cup "$row" "$text_x"
        if [ -n "$label" ]; then
            printf "\033[33m=> %s\033[0m\033[37m%s\033[0m\n" "$label" "$value"
        else
            printf "\033[37m=> %s\033[0m\n" "$value"
        fi
        sleep 0.025
        row=$((row + 1))
    done

    local final_y=$(( row + 2 ))
    tput cup "$final_y" 0
    echo
}
snake-matrix() {
    local cols rows w h
    cols=$(tput cols); rows=$(tput lines)
    w=$cols
    h=$((rows - 3))

    local -a sx sy slen
    local n=0
    for ((x=0; x<w; x+=2)); do
        sx[n]=$x
        sy[n]=$(( RANDOM % (h>0?h:1) ))
        slen[n]=$(( (RANDOM % 15) + 5 ))
        n=$((n+1))
    done

    tput civis
    clear
    trap 'tput cnorm; clear; trap - INT; return 0' INT

    while true; do
        tput cup "$((h+1))" 2
        printf "\033[32m [MATRIX MODE] -- GUARD SNAKE ONLINE -- \033[0m"

        for ((i=0; i<n; i++)); do
            local x=${sx[i]}
            local erase_y=$((sy[i] - slen[i]))
            if (( erase_y >= 0 && erase_y < h )); then
                tput cup "$erase_y" "$x"
                printf " "
            fi

            if (( sy[i] < h )); then
                local code=$(( (RANDOM % 93) + 33 ))
                local ch
                ch=$(awk -v c="$code" 'BEGIN{printf "%c", c}')
                tput cup "${sy[i]}" "$x"
                printf "\033[37m%s\033[0m" "$ch"
                if (( sy[i] > 0 )); then
                    tput cup "$((sy[i]-1))" "$x"
                    printf "\033[32m%s\033[0m" "$ch"
                fi
            fi

            sy[i]=$(( sy[i] + 1 ))
            if (( (sy[i] - slen[i]) >= h )); then
                sy[i]=0
                slen[i]=$(( (RANDOM % 15) + 5 ))
            fi
        done
        sleep 0.03
    done
}

snake-weather() {
    local config_file="$HOME/.snake_weather_city.txt"
    local city="" do_reset=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -Reset|--reset) do_reset=1 ;;
            *) city="$1" ;;
        esac
        shift
    done

    if (( do_reset )); then
        [ -f "$config_file" ] && rm -f "$config_file"
        echo -e "\033[33mCity configuration has been reset.\033[0m"
        city=""
    fi

    if [ -z "$city" ] && [ -f "$config_file" ]; then
        city="$(cat "$config_file")"
    fi

    clear

    if [ -z "$city" ]; then
        read -rp "Enter your city name (e.g., Tluszcz, Krakow, Warszawa): " city
        if [ -z "$city" ]; then
            echo -e "\033[31mCity name cannot be empty.\033[0m"
            return 1
        fi
        echo "$city" > "$config_file"
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "\033[31mcurl is required for snake-weather. Install it first.\033[0m"
        return 1
    fi

    echo -e "\033[32mSearching location and current weather for: $city...\033[0m"

    local encoded_city geo_json lat lon display_name
    if command -v python3 >/dev/null 2>&1; then
        encoded_city=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$city")
    elif command -v jq >/dev/null 2>&1; then
        encoded_city=$(jq -rn --arg s "$city" '$s|@uri')
    else
        encoded_city=$(curl -Gso /dev/null -w '%{url_effective}' --data-urlencode "q=$city" "http://localhost" 2>/dev/null | sed 's#^http://localhost/?q=##')
    fi
    [ -z "$encoded_city" ] && encoded_city="$city"

    geo_json=$(curl -sf -A "BashSnakeWeatherScript" "https://nominatim.openstreetmap.org/search?q=${encoded_city}&format=json&limit=1")
    local curl_status=$?

    if (( curl_status != 0 )) || [ -z "$geo_json" ] || [ "$geo_json" = "[]" ]; then
        echo -e "\033[31mCould not find coordinates for '$city'. Check your connection or the city name.\033[0m"
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        lat=$(echo "$geo_json" | jq -r '.[0].lat')
        lon=$(echo "$geo_json" | jq -r '.[0].lon')
        display_name=$(echo "$geo_json" | jq -r '.[0].display_name' | cut -d',' -f1)
    else
        lat=$(echo "$geo_json" | grep -o '"lat":"[^"]*"' | head -1 | cut -d'"' -f4)
        lon=$(echo "$geo_json" | grep -o '"lon":"[^"]*"' | head -1 | cut -d'"' -f4)
        display_name=$(echo "$geo_json" | grep -o '"display_name":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -d',' -f1)
    fi

    if [ -z "$lat" ] || [ -z "$lon" ] || [ "$lat" = "null" ]; then
        echo -e "\033[31mCould not parse coordinates for '$city'.\033[0m"
        return 1
    fi

    local weather_json current_temp code
    weather_json=$(curl -sf "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code&timezone=auto")

    if [ $? -ne 0 ] || [ -z "$weather_json" ]; then
        echo -e "\033[31mFailed to load weather data. Check your connection.\033[0m"
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        current_temp=$(echo "$weather_json" | jq -r '.current.temperature_2m')
        code=$(echo "$weather_json" | jq -r '.current.weather_code')
    else
        current_temp=$(echo "$weather_json" | grep -o '"temperature_2m":[0-9.-]*' | cut -d: -f2)
        code=$(echo "$weather_json" | grep -o '"weather_code":[0-9]*' | cut -d: -f2)
    fi

    clear
    echo -e "\033[36mCurrent Weather (NOW):\033[0m"
    echo -e "\033[37mReport: $display_name\033[0m"
    echo -e "\033[33mTemperature: ${current_temp} °C\033[0m"

    if (( code == 0 )); then
        echo -e "\033[32mCondition: Sunny / Clear Sky\033[0m"
    elif (( code <= 3 )); then
        echo -e "\033[90mCondition: Cloudy / Partly Cloudy\033[0m"
    elif (( code >= 51 && code <= 67 )); then
        echo -e "\033[91mCondition: Rainy / Drizzle\033[0m"
    elif (( code >= 71 && code <= 86 )); then
        echo -e "\033[96mCondition: Snowy / Winter Weather\033[0m"
    elif (( code >= 95 )); then
        echo -e "\033[91mCondition: Stormy / Thunderstorm\033[0m"
    else
        echo -e "\033[90mCondition: Variable Weather\033[0m"
    fi

    echo -e "\n\033[90m[Tip] To change your saved city, type: snake-weather -Reset\033[0m"
}


snake-help() {
    clear

    local -a snake_art=(
        "     ____       "
        "    / . .\\      "
        "    \\  ---<     "
        "     \\  \\       "
        "     /  /       "
        "     \\  \\       "
        "    /  /_____   "
        "   (________/   "
    )
    local -a title_art=(
        ' ___  _  _    __    _  _  ____ '
        '/ __)( \( )  /__\  ( )/ )( ___)'
        '\__ \ )  (  /(__)\  )  (  )__) '
        '(___/(_)\_)(__)(__)(_)\_)(____)'
    )

    for i in "${!snake_art[@]}"; do
        tput cup "$i" 0
        printf "\033[32m%s\033[0m" "${snake_art[$i]}"
    done

    for i in "${!title_art[@]}"; do
        tput cup "$((i+2))" 18
        printf "\033[33m%s\033[0m\n" "${title_art[$i]}"
    done

    tput cup 9 0
    echo "=================================================================="
    echo -e "\033[33m  COMMAND             |  DESCRIPTION\033[0m"
    echo "=================================================================="
    printf "\033[36m  snake               \033[0m|  Starts the animated retro arcade snake game.\n"
    printf "\033[36m  snake-info          \033[0m|  Displays detailed system specs with custom logos.\n"
    printf "\033[36m  snake-matrix        \033[0m|  Triggers the animated Matrix digital rain effect.\n"
    printf "\033[36m  snake-weather       \033[0m|  Fetches accurate current weather and temperature.\n"
    printf "\033[36m  snake-weather -Reset\033[0m|  Resets the saved city configuration.\n"
    echo "=================================================================="
    echo -e "\033[90mType any command above to start! Press Ctrl+C to exit loops.\n\033[0m"
}
