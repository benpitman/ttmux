disableEcho()
{
    # Disable the output buffer from stdin
    stty -echo
}

enableEcho()
{
    stty echo
}

disableCursor()
{
    # Disable cursor blinker
    printf "\e[?25l"
}

enableCursor()
{
    # Enabale cursor blinker
    printf "\e[?25h"
}

clearScreen()
{
    printf "\e[2J"
    resetCursorPosition
}

clearBuffer()
{
    # Clear input buffer
    read -n10000 -t0.0001
}

resetCursorPosition()
{
    navigateTo 1 1
}

navigateTo()
{
    printf "\e[%s;%sH" $1 $2
}

negativeRenderText()
{
    # Render text right aligned
    (( $# > 1 )) && printf "\e[7m%b\e[27m\n" "${@:1:$#-1}"
    printf "\e[7m%b\e[27m" "${@: -1}"
}

renderText()
{
    # Render text left aligned
    (( $# > 1 )) && printf "%b\e[0m\n" "${@:1:$#-1}"
    printf "%b\e[0m" "${@: -1}"
}

setHighlight()
{
    printf "\e[7m"
}

unsetHighlight()
{
    printf "\e[27m"
}

textEntry()
{
    local -- inputString
    local -- key
    local -- maxLength=$3
    local -- nameRef=$4
    local -- y=$1
    local -- x=$2
    local -- negativeRegex=${5:-'[[:punct:]]'}
    local -- replace="${6:-.}"

    navigateTo $y $x

    # Turn echo back on for text input
    stty echo
    tput cvvis
    clearBuffer

    # Clear IFS to avoid whitespace treated as null
    while IFS= read -sn1 key; do
        if [[ -z "$key" ]]; then
            if (( ${#inputString} )); then
                break
            else
                navigateTo $y $x
            fi
        elif [[ "$key" == $'\177' ]]; then
            # If backspace character is pressed, remove last entry
            if (( ${#inputString} )); then
                printf "\b${replace}\b"
                inputString=${inputString:0: -1}
            fi
        elif (( ${#inputString} >= $maxLength )); then
            continue
        elif [[ "$key" == ${negativeRegex} ]]; then
            # Disallow anything matching negative regex
            continue
        elif [[ "$key" == [\ _] ]]; then
            # Replace spaces with underscores
            printf "_"
            inputString+="_"
        elif [[ "$key" == [[:alnum:]] ]]; then
            printf "$key"
            inputString+="$key"
        fi
    done

    printf -v "$nameRef" "%s" "$inputString"
    tput civis
    stty -echo
}
