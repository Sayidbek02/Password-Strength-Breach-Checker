#!/bin/bash

#############################################################################
#                                                                           #
#           PASSWORD STRENGTH & BREACH CHECKER                              #
#           Version: 1.0.1 (Bug fixes)                                      #
#           Author: Security Tool                                           #
#           Language: Bash                                                  #
#                                                                           #
#############################################################################

VERSION="1.0.1"
CONFIG_FILE="config.conf"
LOG_FILE="/var/log/password_checker.log"
WORDLIST_FILE="rockyou.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_HALF="◐"
ICON_WARNING="!"

signal_handler() {
    echo -e "\n\n${YELLOW}[!] Dastur to'xtatildi.${NC}"
    exit 0
}

trap signal_handler SIGINT SIGTERM

load_config() {
    MIN_LENGTH=8
    REQUIRE_UPPERCASE=true
    REQUIRE_LOWERCASE=true
    REQUIRE_NUMBERS=true
    REQUIRE_SPECIAL=true
    WORDLIST_PATH="$WORDLIST_FILE"
    LOG_ENABLED=true

    LENGTH_WEIGHT=2
    UPPERCASE_WEIGHT=1
    LOWERCASE_WEIGHT=1
    NUMBER_WEIGHT=1
    SPECIAL_WEIGHT=2
    ENTROPY_WEIGHT=3

    if [[ "$CONFIG_FILE" != /* ]]; then
        CONFIG_FILE="$SCRIPT_DIR/$CONFIG_FILE"
    fi

    if [[ "$LOG_FILE" != /* ]]; then
        LOG_FILE="$SCRIPT_DIR/$LOG_FILE"
    fi

    if [[ -f "$CONFIG_FILE" ]]; then
        if ! source "$CONFIG_FILE" 2>/dev/null; then
            echo -e "${YELLOW}[!] Config fayl yuklanmadi, default sozlamalar ishlatiladi.${NC}"
        fi
    else
        create_default_config
    fi

    if [[ "$WORDLIST_PATH" != /* ]]; then
        WORDLIST_PATH="$SCRIPT_DIR/$WORDLIST_PATH"
    fi
}

create_default_config() {
    cat > "$CONFIG_FILE" <<'EOF_CONFIG'
# Password Checker Configuration

MIN_LENGTH=8
REQUIRE_UPPERCASE=true
REQUIRE_LOWERCASE=true
REQUIRE_NUMBERS=true
REQUIRE_SPECIAL=true
WORDLIST_PATH="rockyou.txt"
LOG_ENABLED=true

LENGTH_WEIGHT=2
UPPERCASE_WEIGHT=1
LOWERCASE_WEIGHT=1
NUMBER_WEIGHT=1
SPECIAL_WEIGHT=2
ENTROPY_WEIGHT=3
EOF_CONFIG

    echo -e "${GREEN}[+] Config fayl yaratildi: $CONFIG_FILE${NC}"
}

setup_logging() {
    LOG_DIR=$(dirname "$LOG_FILE")

    if [[ ! -w "$LOG_DIR" ]] && [[ "$LOG_DIR" != "." ]]; then
        LOG_FILE="$SCRIPT_DIR/password_checker.log"
        echo -e "${YELLOW}[!] Log fayl o'rnatildi: $LOG_FILE${NC}"
    fi

    if ! touch "$LOG_FILE" 2>/dev/null; then
        LOG_FILE="$SCRIPT_DIR/password_checker.log"
        touch "$LOG_FILE" 2>/dev/null || true
    fi

    chmod 600 "$LOG_FILE" 2>/dev/null || true
}

log_message() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ "$LOG_ENABLED" == "true" ]]; then
        echo "$timestamp - INFO - $message" >> "$LOG_FILE" 2>/dev/null
    fi
}

check_length() {
    local password="$1"
    local length=${#password}
    local score=0
    local message=""

    if [[ $length -lt 6 ]]; then
        score=0
        message="Juda qisqa (minimal $MIN_LENGTH belgi kerak)"
    elif [[ $length -lt $MIN_LENGTH ]]; then
        score=1
        message="Qisqa ($MIN_LENGTH+ belgidan foydalaning)"
    elif [[ $length -lt 12 ]]; then
        score=2
        message="Yaxshi uzunlik"
    elif [[ $length -lt 16 ]]; then
        score=3
        message="Zo'r uzunlik"
    else
        score=4
        message="A'lo uzunlik"
    fi

    echo "$score|$message"
}

check_uppercase() {
    local password="$1"
    local count
    count=$(printf '%s' "$password" | grep -o '[A-Z]' | wc -l | tr -d ' ')
    local score=0
    local message=""

    if [[ $count -eq 0 ]]; then
        score=0
        message="Katta harf yo'q"
    elif [[ $count -eq 1 ]]; then
        score=1
        message="1 ta katta harf"
    else
        score=2
        message="$count ta katta harf"
    fi

    echo "$score|$message"
}

check_lowercase() {
    local password="$1"
    local count
    count=$(printf '%s' "$password" | grep -o '[a-z]' | wc -l | tr -d ' ')
    local score=0
    local message=""

    if [[ $count -eq 0 ]]; then
        score=0
        message="Kichik harf yo'q"
    elif [[ $count -eq 1 ]]; then
        score=1
        message="1 ta kichik harf"
    else
        score=2
        message="$count ta kichik harf"
    fi

    echo "$score|$message"
}

check_numbers() {
    local password="$1"
    local count
    count=$(printf '%s' "$password" | grep -o '[0-9]' | wc -l | tr -d ' ')
    local score=0
    local message=""

    if [[ $count -eq 0 ]]; then
        score=0
        message="Raqam yo'q"
    elif [[ $count -eq 1 ]]; then
        score=1
        message="1 ta raqam"
    else
        score=2
        message="$count ta raqam"
    fi

    echo "$score|$message"
}

check_special_chars() {
    local password="$1"
    local count
    count=$(printf '%s' "$password" | grep -o '[^[:alnum:]]' | wc -l | tr -d ' ')
    local score=0
    local message=""

    if [[ $count -eq 0 ]]; then
        score=0
        message="Maxsus belgi yo'q"
    elif [[ $count -eq 1 ]]; then
        score=1
        message="1 ta maxsus belgi"
    elif [[ $count -eq 2 ]]; then
        score=2
        message="2 ta maxsus belgi"
    else
        score=3
        message="$count ta maxsus belgi"
    fi

    echo "$score|$message"
}

check_dictionary() {
    local password="$1"
    local password_lower
    password_lower=$(printf '%s' "$password" | tr '[:upper:]' '[:lower:]')
    local score=2
    local message="Dictionary so'z topilmadi"

    local common_passwords=(
        "password" "123456" "12345678" "qwerty" "abc123"
        "monkey" "1234567" "letmein" "trustno1" "dragon"
        "baseball" "iloveyou" "master" "sunshine" "ashley"
        "admin" "welcome" "login" "password1" "qwerty123"
    )

    for common in "${common_passwords[@]}"; do
        if [[ "$password_lower" == "$common" ]]; then
            score=0
            message="Umumiy parol ro'yxatida topildi!"
            echo "$score|$message"
            return
        fi
    done

    local simple_words=("password" "qwerty" "admin" "user" "root" "login")
    for word in "${simple_words[@]}"; do
        if [[ "$password_lower" == *"$word"* ]]; then
            score=1
            message="'$word' so'zi topildi"
            echo "$score|$message"
            return
        fi
    done

    echo "$score|$message"
}

check_rockyou() {
    local password="$1"
    local score=2
    local message="RockYou wordlist topilmadi"

    if [[ ! -f "$WORDLIST_PATH" ]]; then
        echo "skip|$message"
        return
    fi

    local line_num=0
    while IFS= read -r line && [[ $line_num -lt 100000 ]]; do
        ((line_num++))
        if [[ "$line" == "$password" ]]; then
            score=0
            message="RockYou wordlist da topildi! (#$line_num)"
            echo "$score|$message"
            return
        fi
    done < "$WORDLIST_PATH"

    echo "$score|$message"
}

calculate_entropy() {
    local password="$1"
    local length=${#password}
    local pool_size=0

    if printf '%s' "$password" | grep -q '[a-z]'; then
        pool_size=$((pool_size + 26))
    fi

    if printf '%s' "$password" | grep -q '[A-Z]'; then
        pool_size=$((pool_size + 26))
    fi

    if printf '%s' "$password" | grep -q '[0-9]'; then
        pool_size=$((pool_size + 10))
    fi

    if printf '%s' "$password" | grep -q '[^[:alnum:]]'; then
        pool_size=$((pool_size + 32))
    fi

    if [[ $pool_size -eq 0 ]]; then
        echo "0"
        return
    fi

    local entropy=0
    if command -v bc &> /dev/null; then
        entropy=$(echo "scale=1; $length * l($pool_size)/l(2)" | bc -l 2>/dev/null)

        if [[ -z "$entropy" || "$entropy" == "0" ]]; then
            case $pool_size in
                26)
                    entropy=$(echo "$length * 4.7" | bc 2>/dev/null || echo "$((length * 5))")
                    ;;
                52)
                    entropy=$(echo "$length * 5.7" | bc 2>/dev/null || echo "$((length * 6))")
                    ;;
                62)
                    entropy=$(echo "$length * 5.95" | bc 2>/dev/null || echo "$((length * 6))")
                    ;;
                94)
                    entropy=$(echo "$length * 6.55" | bc 2>/dev/null || echo "$((length * 7))")
                    ;;
                *)
                    entropy=$(echo "$length * 6" | bc 2>/dev/null || echo "$((length * 6))")
                    ;;
            esac
        fi
    else
        case $pool_size in
            26) entropy=$((length * 5)) ;;
            52) entropy=$((length * 6)) ;;
            62) entropy=$((length * 6)) ;;
            94) entropy=$((length * 7)) ;;
            *) entropy=$((length * 6)) ;;
        esac
    fi

    echo "$entropy"
}

estimate_crack_time() {
    local entropy="$1"
    local entropy_int
    entropy_int=$(echo "$entropy" | cut -d'.' -f1)

    if [[ $entropy_int -lt 20 ]]; then
        echo "< 1 soniya|$RED"
    elif [[ $entropy_int -lt 30 ]]; then
        echo "bir necha soniya|$RED"
    elif [[ $entropy_int -lt 40 ]]; then
        echo "bir necha daqiqa|$YELLOW"
    elif [[ $entropy_int -lt 50 ]]; then
        echo "bir necha soat|$YELLOW"
    elif [[ $entropy_int -lt 60 ]]; then
        echo "bir necha kun|$CYAN"
    elif [[ $entropy_int -lt 70 ]]; then
        echo "bir necha oy|$CYAN"
    elif [[ $entropy_int -lt 80 ]]; then
        echo "bir necha yil|$GREEN"
    elif [[ $entropy_int -lt 90 ]]; then
        echo "ming yillar|$GREEN"
    else
        echo "million yillar|$GREEN"
    fi
}

calculate_score() {
    local length_score="$1"
    local uppercase_score="$2"
    local lowercase_score="$3"
    local number_score="$4"
    local special_score="$5"
    local entropy_value="$6"

    local length_weight=${LENGTH_WEIGHT:-2}
    local uppercase_weight=${UPPERCASE_WEIGHT:-1}
    local lowercase_weight=${LOWERCASE_WEIGHT:-1}
    local number_weight=${NUMBER_WEIGHT:-1}
    local special_weight=${SPECIAL_WEIGHT:-2}
    local entropy_weight=${ENTROPY_WEIGHT:-3}

    local entropy_score=0

    if command -v bc &> /dev/null; then
        entropy_score=$(echo "scale=2; if ($entropy_value / 25 > 4) 4 else $entropy_value / 25" | bc -l 2>/dev/null)

        if [[ -z "$entropy_score" ]]; then
            local entropy_int
            entropy_int=$(echo "$entropy_value" | cut -d'.' -f1)
            if [[ $entropy_int -ge 100 ]]; then
                entropy_score=4
            else
                entropy_score=$(echo "scale=2; $entropy_int / 25" | bc 2>/dev/null || echo "2")
            fi
        fi
    else
        local entropy_int
        entropy_int=$(echo "$entropy_value" | cut -d'.' -f1)
        if [[ $entropy_int -ge 100 ]]; then
            entropy_score=4
        elif [[ $entropy_int -ge 75 ]]; then
            entropy_score=3
        elif [[ $entropy_int -ge 50 ]]; then
            entropy_score=2
        elif [[ $entropy_int -ge 25 ]]; then
            entropy_score=1
        else
            entropy_score=0
        fi
    fi

    local total=0
    local max=0

    if command -v bc &> /dev/null; then
        total=$(echo "scale=2; ($length_score * $length_weight) + ($uppercase_score * $uppercase_weight) + ($lowercase_score * $lowercase_weight) + ($number_score * $number_weight) + ($special_score * $special_weight) + ($entropy_score * $entropy_weight)" | bc -l 2>/dev/null)
        max=$(echo "scale=2; (4 * $length_weight) + (4 * $uppercase_weight) + (4 * $lowercase_weight) + (4 * $number_weight) + (4 * $special_weight) + (4 * $entropy_weight)" | bc -l 2>/dev/null)
        local percentage
        percentage=$(echo "scale=1; ($total / $max) * 100" | bc -l 2>/dev/null)
    else
        total=$((length_score * length_weight + uppercase_score * uppercase_weight + lowercase_score * lowercase_weight + number_score * number_weight + special_score * special_weight + entropy_score * entropy_weight))
        max=$((4 * length_weight + 4 * uppercase_weight + 4 * lowercase_weight + 4 * number_weight + 4 * special_weight + 4 * entropy_weight))
        percentage=$((total * 100 / max))
    fi

    echo "$percentage"
}

get_strength_level() {
    local percentage="$1"
    local dictionary_score="$2"
    local rockyou_score="$3"

    if [[ "$dictionary_score" == "0" || "$rockyou_score" == "0" ]]; then
        echo "WEAK|$RED"
        return
    fi

    local percentage_int
    percentage_int=$(echo "$percentage" | cut -d'.' -f1)

    if [[ $percentage_int -lt 40 ]]; then
        echo "WEAK|$RED"
    elif [[ $percentage_int -lt 70 ]]; then
        echo "MEDIUM|$YELLOW"
    else
        echo "STRONG|$GREEN"
    fi
}

show_banner() {
    echo -e "${CYAN}${BOLD}"
    cat <<'EOF_BANNER'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║      PASSWORD STRENGTH & BREACH CHECKER v1.0.1           ║
║                                                           ║
║      Parol xavfsizligini tekshiruvchi professional tool   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF_BANNER
    echo -e "${NC}"
}

show_help() {
    cat <<EOF_HELP

${GREEN}${BOLD}FOYDALANISH:${NC}
    $0 [OPTIONS]

${GREEN}${BOLD}OPTIONS:${NC}
    -h, --help              Ushbu yordam xabarini ko'rsatish
    -v, --version           Versiyani ko'rsatish
    -p, --password PASSWORD Parolni argument sifatida berish (tavsiya etilmaydi)
    -i, --interactive       Interaktiv rejim (default)

${GREEN}${BOLD}XUSUSIYATLAR:${NC}
    • Parol uzunligini tekshirish
    • Katta/kichik harf tekshirish
    • Raqam mavjudligini tekshirish
    • Maxsus belgilarni tekshirish
    • Dictionary so'zlarni tekshirish
    • RockYou wordlist bilan tekshirish
    • Entropy hisoblash
    • Brute-force vaqtini taxmin qilish
    • Rangli natijalar
    • Log yozish

${GREEN}${BOLD}MISOLLAR:${NC}
    # Interaktiv rejim
    $0

    # Parolni argument orqali
    $0 -p "MyP@ssw0rd123"

    # Versiyani ko'rish
    $0 --version

${YELLOW}${BOLD}ESLATMA:${NC}
    Parolni argument orqali berish xavfsiz emas (shell history).
    Interaktiv rejimdan foydalaning.

EOF_HELP
}

get_icon_and_color() {
    local score="$1"

    case $score in
        0)
            echo "$ICON_CROSS|$RED"
            ;;
        1)
            echo "$ICON_CIRCLE|$YELLOW"
            ;;
        2)
            echo "$ICON_HALF|$CYAN"
            ;;
        3|4)
            echo "$ICON_CHECK|$GREEN"
            ;;
        skip)
            echo "$ICON_WARNING|$YELLOW"
            ;;
        *)
            echo "$ICON_CROSS|$RED"
            ;;
    esac
}

show_recommendations() {
    local strength="$1"
    local length_score="$2"
    local uppercase_score="$3"
    local lowercase_score="$4"
    local number_score="$5"
    local special_score="$6"
    local dictionary_score="$7"
    local rockyou_score="$8"
    local entropy="$9"

    if [[ "$strength" == "STRONG" ]]; then
        return
    fi

    echo -e "\n${YELLOW}${BOLD}TAVSIYALAR:${NC}"
    echo -e "${YELLOW}------------------------------------------------------------${NC}"

    local has_recommendations=false

    if [[ $length_score -lt 2 ]]; then
        echo -e "${YELLOW}• Kamida 12 belgidan foydalaning${NC}"
        has_recommendations=true
    fi

    if [[ $uppercase_score -eq 0 ]]; then
        echo -e "${YELLOW}• Katta harflar qo'shing (A-Z)${NC}"
        has_recommendations=true
    fi

    if [[ $lowercase_score -eq 0 ]]; then
        echo -e "${YELLOW}• Kichik harflar qo'shing (a-z)${NC}"
        has_recommendations=true
    fi

    if [[ $number_score -eq 0 ]]; then
        echo -e "${YELLOW}• Raqamlar qo'shing (0-9)${NC}"
        has_recommendations=true
    fi

    if [[ $special_score -lt 1 ]]; then
        echo -e "${YELLOW}• Maxsus belgilar qo'shing (!@#\$%^&*)${NC}"
        has_recommendations=true
    fi

    if [[ $dictionary_score -lt 2 ]]; then
        echo -e "${YELLOW}• Oddiy so'zlardan foydalanmang${NC}"
        has_recommendations=true
    fi

    if [[ "$rockyou_score" == "0" ]]; then
        echo -e "${YELLOW}• Bu parol ma'lum ro'yxatlarda mavjud!${NC}"
        has_recommendations=true
    fi

    local entropy_int
    entropy_int=$(echo "$entropy" | cut -d'.' -f1)
    if [[ $entropy_int -lt 50 ]]; then
        echo -e "${YELLOW}• Parolni murakkabroq qiling${NC}"
        has_recommendations=true
    fi

    if [[ "$has_recommendations" == "false" ]]; then
        echo -e "${GREEN}Yaxshi parol! Kichik yaxshilanishlar mumkin.${NC}"
    fi
}

analyze_password() {
    local password="$1"

    echo -e "\n${CYAN}============================================================${NC}"
    echo -e "${CYAN}PAROL TAHLILI${NC}"
    echo -e "${CYAN}============================================================${NC}\n"

    local length_result
    length_result=$(check_length "$password")
    local length_score
    length_score=$(echo "$length_result" | cut -d'|' -f1)
    local length_msg
    length_msg=$(echo "$length_result" | cut -d'|' -f2)

    local uppercase_result
    uppercase_result=$(check_uppercase "$password")
    local uppercase_score
    uppercase_score=$(echo "$uppercase_result" | cut -d'|' -f1)
    local uppercase_msg
    uppercase_msg=$(echo "$uppercase_result" | cut -d'|' -f2)

    local lowercase_result
    lowercase_result=$(check_lowercase "$password")
    local lowercase_score
    lowercase_score=$(echo "$lowercase_result" | cut -d'|' -f1)
    local lowercase_msg
    lowercase_msg=$(echo "$lowercase_result" | cut -d'|' -f2)

    local number_result
    number_result=$(check_numbers "$password")
    local number_score
    number_score=$(echo "$number_result" | cut -d'|' -f1)
    local number_msg
    number_msg=$(echo "$number_result" | cut -d'|' -f2)

    local special_result
    special_result=$(check_special_chars "$password")
    local special_score
    special_score=$(echo "$special_result" | cut -d'|' -f1)
    local special_msg
    special_msg=$(echo "$special_result" | cut -d'|' -f2)

    local dictionary_result
    dictionary_result=$(check_dictionary "$password")
    local dictionary_score
    dictionary_score=$(echo "$dictionary_result" | cut -d'|' -f1)
    local dictionary_msg
    dictionary_msg=$(echo "$dictionary_result" | cut -d'|' -f2)

    local entropy
    entropy=$(calculate_entropy "$password")

    local rockyou_result
    rockyou_result=$(check_rockyou "$password")
    local rockyou_score
    rockyou_score=$(echo "$rockyou_result" | cut -d'|' -f1)
    local rockyou_msg
    rockyou_msg=$(echo "$rockyou_result" | cut -d'|' -f2)

    echo -e "${WHITE}${BOLD}TEKSHIRUVLAR:${NC}"
    echo -e "${WHITE}------------------------------------------------------------${NC}"

    local icon_color
    local icon
    local color

    icon_color=$(get_icon_and_color "$length_score")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s${NC}\n" "$icon" "Length" "$length_msg"

    icon_color=$(get_icon_and_color "$uppercase_score")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s${NC}\n" "$icon" "Uppercase" "$uppercase_msg"

    icon_color=$(get_icon_and_color "$lowercase_score")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s${NC}\n" "$icon" "Lowercase" "$lowercase_msg"

    icon_color=$(get_icon_and_color "$number_score")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s${NC}\n" "$icon" "Numbers" "$number_msg"

    icon_color=$(get_icon_and_color "$special_score")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s${NC}\n" "$icon" "Special" "$special_msg"

    icon_color=$(get_icon_and_color "$dictionary_score")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s${NC}\n" "$icon" "Dictionary" "$dictionary_msg"

    icon_color=$(get_icon_and_color "3")
    icon=$(echo "$icon_color" | cut -d'|' -f1)
    color=$(echo "$icon_color" | cut -d'|' -f2)
    printf "${color}%s %-20s: %s bit${NC}\n" "$icon" "Entropy" "$entropy"

    if [[ "$rockyou_score" != "skip" ]]; then
        icon_color=$(get_icon_and_color "$rockyou_score")
        icon=$(echo "$icon_color" | cut -d'|' -f1)
        color=$(echo "$icon_color" | cut -d'|' -f2)
        printf "${color}%s %-20s: %s${NC}\n" "$icon" "Rockyou" "$rockyou_msg"
    fi

    local percentage
    percentage=$(calculate_score "$length_score" "$uppercase_score" "$lowercase_score" "$number_score" "$special_score" "$entropy")

    local strength_result
    strength_result=$(get_strength_level "$percentage" "$dictionary_score" "$rockyou_score")
    local strength
    strength=$(echo "$strength_result" | cut -d'|' -f1)
    local strength_color
    strength_color=$(echo "$strength_result" | cut -d'|' -f2)

    echo -e "\n${WHITE}${BOLD}NATIJA:${NC}"
    echo -e "${WHITE}------------------------------------------------------------${NC}"
    echo -e "${CYAN}Ball: ${WHITE}$percentage%${NC}"
    echo -e "${CYAN}Daraja: ${strength_color}${BOLD}$strength${NC}"

    local crack_time_result
    crack_time_result=$(estimate_crack_time "$entropy")
    local crack_time
    crack_time=$(echo "$crack_time_result" | cut -d'|' -f1)
    local crack_color
    crack_color=$(echo "$crack_time_result" | cut -d'|' -f2)
    echo -e "${CYAN}Buzish vaqti: ${crack_color}$crack_time${NC}"

    show_recommendations "$strength" "$length_score" "$uppercase_score" "$lowercase_score" "$number_score" "$special_score" "$dictionary_score" "$rockyou_score" "$entropy"

    echo -e "\n${CYAN}============================================================${NC}\n"

    local password_hash
    password_hash=$(echo -n "$password" | sha256sum 2>/dev/null | cut -c1-16 || echo "NO_HASH")
    log_message "Password checked - Hash: $password_hash, Score: $percentage%, Strength: $strength"
}

main() {
    load_config
    setup_logging

    local password=""
    local show_version=false
    local show_help_flag=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help_flag=true
                shift
                ;;
            -v|--version)
                show_version=true
                shift
                ;;
            -p|--password)
                if [[ $# -lt 2 ]]; then
                    echo -e "${RED}[✗] Missing password value after -p/--password${NC}"
                    exit 1
                fi
                password="$2"
                shift 2
                ;;
            -i|--interactive)
                shift
                ;;
            *)
                echo -e "${RED}Noma'lum option: $1${NC}"
                echo "Yordam uchun: $0 --help"
                exit 1
                ;;
        esac
    done

    if [[ "$show_version" == "true" ]]; then
        echo "Password Checker v$VERSION"
        exit 0
    fi

    if [[ "$show_help_flag" == "true" ]]; then
        show_help
        exit 0
    fi

    show_banner

    if [[ -n "$password" ]]; then
        echo -e "${YELLOW}[!] Ogohlantirish: Parolni argument orqali berish xavfsiz emas!${NC}"
    else
        echo -ne "${GREEN}[+] Parolni kiriting (yashirin): ${NC}"
        read -s password
        echo
    fi

    if [[ -z "$password" ]]; then
        echo -e "${RED}[✗] Parol kiritilmadi!${NC}"
        exit 1
    fi

    analyze_password "$password"
}

main "$@"
