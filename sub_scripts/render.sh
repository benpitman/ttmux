navigateMenu()
{
    local -- key1
    local -- key2
    local -- key3
    local -- loadText
    local -- menuIndex
    local -- optionText
    local -- selected=${2:-0}
    local -- vertical=${3:-1}
    local -- previousKey
    local -- nextKey

    local -n -- menu="$1"

    if (( $vertical )); then
        previousKey=$KEY_UP
        nextKey=$KEY_DOWN
    else
        previousKey=$KEY_LEFT
        nextKey=$KEY_RIGHT
    fi

    if [[ -n "${menu[HEADER,TEXT]}" ]]; then
        navigateTo ${menu[HEADER,Y]} ${menu[HEADER,X]}
        renderText "${menu[HEADER,TEXT]}"
    fi

    while true; do

        for (( menuIndex = 0; $menuIndex < (${menu[MAX]} + 1); menuIndex++ )); do
            (( $menuIndex == $selected )) && optionText="\e[7m" || optionText="\e[27m"

            if [[ "${menu[$menuIndex,LOAD]}" != "" ]]; then
                # Function to load text
                ${menu[$menuIndex,LOAD]} "loadText"
            elif [[ "${menu[$menuIndex,TEXT]}" != "" ]]; then
                # No text to render
                continue
            else
                loadText=${menu[$menuIndex,TEXT]}
            fi

            optionText+="${menu[PADDING]}$loadText${menu[PADDING]}\e[27m"
            navigateTo ${menu[$menuIndex,Y]} ${menu[$menuIndex,X]}
            renderText "$optionText"
        done

        if [[ "${menu[$selected,NOTE]}" != "" ]]; then
            navigateTo ${NOTE[Y]} $(( ${NOTE[X]} - (${#menu[$selected,NOTE]} / 2) ))
            renderText "${menu[$selected,NOTE]}"
        fi

        IFS= read -srn 1 key1
        IFS= read -srn 1 -t 0.0001 key2
        IFS= read -srn 1 -t 0.0001 key3

        if [[ "$key1" =~ $KEY_SELECT ]]; then
            if [[ "${menu[$selected,RUN]}" != "" ]]; then
                ${menu[$selected,RUN]}
            fi
            break
        fi

        if [[ "${menu[$selected,NOTE]}" != "" ]]; then
            navigateTo ${NOTE[Y]} $(( ${NOTE[X]} - (${#NOTE[CLEAR]} / 2) ))
            renderText "${NOTE[CLEAR]}"
        fi

        case $key3 in
            ($previousKey) {
                (( $selected == 0 ? selected = ${menu[MAX]} : selected-- ))
            };;
            ($nextKey) {
                (( $selected == ${menu[MAX]} ? selected = 0 : selected++ ))
            };;
        esac

    done

    return $selected
}

renderPartial()
{
    local -- clear
    local -- half
    local -- optionText
    local -- partial

    local -n -- partialOptions="$1"

    for (( clear = 0; $clear < ${partialOptions[CLEAR,MAX]}; clear++ )); do
        navigateTo $(( ${partialOptions[CLEAR,Y]} + $clear )) ${partialOptions[CLEAR,X]}
        renderText "${partialOptions[CLEAR]}"
    done

    for (( partial = 0; $partial < (${partialOptions[MAX]} + 1); partial++ )); do
        if [[ "${partialOptions[$partial,LOAD]}" != "" ]]; then
            ${partialOptions[$partial,LOAD]} "optionText"
        else
            optionText=${partialOptions[$partial,TEXT]}
        fi

        half=$(( (${partialOptions[WIDTH]} - ${#optionText}) / 2 ))
        navigateTo ${partialOptions[$partial,Y]} $(( ${partialOptions[$partial,X]} + $half + 1 ))
        renderText "$optionText"
    done
}

renderOptions()
{
    local -- optionIndex=
    local -- optionTextIndex=
    local -- inputRef="$3"

    local -n -- options="$1"
    local -n -- settings="$2"

    for (( optionIndex=0; ${optionIndex} <= ${options[MAX]}; optionIndex++ )); do
        for (( optionTextIndex = 0; ${optionTextIndex} <= ${options[${optionIndex},MAX]}; optionTextIndex++ )); do
            navigateTo $(( ${settings[$optionIndex,Y]} + ${optionTextIndex} )) ${settings[${optionIndex},X]}
            renderText "${options[${optionIndex},${optionTextIndex}]}"
        done
    done

    textEntry ${settings[INPUT,Y]} ${settings[INPUT,X]} ${settings[INPUT,MAX]} ${inputRef} ${settings[INPUT,REGEX]} "${settings[INPUT,REPLACE]}"
}

renderSimple()
{
    local -- index=${2:-0}

    local -n -- render="$1"

    for (( ; ${index} <= ${render[MAX]}; index++ )); do
        navigateTo ${render[${index},Y]} ${render[${index},X]}
        renderText "${render[${index}]}"
    done
}

renderScrollable()
{
    local -n -- scrollable="$1"

    local -- width=$(( ${scrollable[WIDTH]} - 2 )) # for the scrollbar plus a 1 space gap
    local -- height=${scrollable[HEIGHT]}
    local -- bodyIndex=${2:-0} # Start point of the viewable body
    local -- scrollbarHeight=$(( ${height} - 2 )) # Dropped by two for the top and bottom arrows
    local -- viewIndex=
    local -- bodyList=
    local -- blockHeight=${height} # How many lines of the body does it take before the scrollbar moves
    local -- dropSegments=
    local -- segments=${scrollbarHeight} # The amount of segments in the scrollbar that are blocks
    local -- blockCarry=
    local -- scrollbarIndex=
    local -- blockIndex=
    local -- bodyCount=
    local -- blockCount=
    local -- overLimit=0 # If it has exceeded the limit that the scrollbar of this height can accommodate

    local -- key1
    local -- key2
    local -- key3
    local -- key4

    local -a -- blocks=(
        [0]=1 # Always set the first block to start at zero and end at body line 1
    )
    local -a -- scrollbar=(
        [0]="${SCROLLBAR_UP}"
        [$(( ${height} - 1 ))]="${SCROLLBAR_DOWN}"
    )

    ${scrollable[BODY]} "bodyList" ${width}
    local -n -- bodyList=${bodyList}
    bodyCount=${#bodyList[@]}

    if (( ${bodyCount} > (${height} * (${scrollbarHeight} - 1)) )); then
        (( overLimit = 1 ))
        (( blockHeight = (${bodyCount} - ${height} + ${scrollbarHeight} - 3) / (${scrollbarHeight} - 2) ))
        (( blockCount = ${scrollbarHeight} - 1 ))
        (( blockCarry = (${bodyCount} - ${height}) % ${blockHeight} ))
    else
        (( blockCarry = ${bodyCount} % ${blockHeight} ))
        (( blockCount = (${bodyCount} + (${blockHeight} - 1)) / ${blockHeight} )) # Divide body count by block height rounded up
    fi

    (( blockCarry = ${blockCarry} == 0 ? ${blockHeight} : ${blockCarry} ))

    # If the body cannot be fully contained in the view without scrolling
    if (( ${bodyCount} > ${height} )); then
        (( blockCount += (${blockCarry} > 1) ? 1 : 0 ))
        # Add carry block
        if (( ${blockCarry} != 1 )); then
            blocks+=($(( ${blockCarry} > 1 ? ${blockCarry} : ${blockHeight} )))
        fi

        # Fill in between carry/zeroth block and last block
        for (( blockIndex = ${#blocks[@]}; ${blockIndex} < (${blockCount} - (${overLimit} ? 2 : 1)); blockIndex++ )); do
            blocks+=($(( ${blocks[${blockIndex} - 1]} + ${blockHeight} )))
        done

        # This gives a botom-up approach to the scrollbar
        # So the last body entry will always be on the last block of the scrollbar
        if (( ${overLimit} )); then
            blocks+=($(( ${bodyCount} - ${height} )))
        fi
        blocks+=(${bodyCount})
    fi

    (( dropSegments = ${blockCount} - 1 )) # How many blocks off the scrollbar should be taken

    if (( ${dropSegments} > (${scrollbarHeight} - 1) )); then
        (( dropSegments = ${scrollbarHeight} - 1 )) # Maxiumum number of blocks that can be removed off the scrollbar can only be one less than the total
    fi
    (( segments -= ${dropSegments} ))

    while :; do

        # Determine which block we are in
        (( blockIndex = 0 ))
        while (( ${blockIndex} < ${blockCount} )); do
            if (( ${bodyIndex} < ${blocks[${blockIndex}]} )); then
                break
            fi
            (( blockIndex++ ))
        done

        # Determine the position of the blocks in the scrollbar
        (( scrollbarIndex = 0 ))
        while (( ${scrollbarIndex} < ${scrollbarHeight} )); do
            if (( ${scrollbarIndex} < ${blockIndex} )) || (( ${scrollbarIndex} >= (${blockIndex} + ${segments}) )); then
                scrollbar[$(( ${scrollbarIndex} + 1 ))]="${SCROLLBAR_BLANK}"
            else
                scrollbar[$(( ${scrollbarIndex} + 1 ))]="${SCROLLBAR_BLOCK}"
            fi
            (( scrollbarIndex++ ))
        done

        # Render the view
        (( viewIndex = 0 ))
        while (( ${viewIndex} < ${height} )); do
            bodyText="${bodyList[$(( ${bodyIndex} + ${viewIndex} ))]}"
            [[ -z "${bodyText}" ]] && printf -v bodyText "%${width}s"

            navigateTo $(( ${scrollable[Y]} + $viewIndex )) ${scrollable[X]}
            renderText "${bodyText:0:${width}} ${scrollbar[${viewIndex}]}"

            (( viewIndex++ ))
        done

        (( ${scrollable[SCROLLABLE]} )) || break

        IFS= read -srn 1 key1
        IFS= read -srn 1 -t 0.0001 key2
        IFS= read -srn 1 -t 0.0001 key3
        IFS= read -srn 1 -t 0.0001 key4

        case "${key3}${key4}" in
            (${SCROLL_DOWN}) {
                (( ${bodyIndex} < (${bodyCount} - ${height}) )) && (( bodyIndex++ ))
            };;
            (${SCROLL_UP}) {
                (( ${bodyIndex} > 0 )) && (( bodyIndex-- ))
            };;
        esac

    done
}

renderContainer()
{
    local -n -- container="$1"

    local -- indexY=0
    local -- indexX=
    local -- height=${container[HEIGHT]}
    local -- width=${container[WIDTH]}

    (( ${height} < 2 || ${width} < 2 )) && exit 1

    for (( ; ${indexY} < ${height}; indexY++ )); do

        isLast=$(( ${indexY} == (${height} - 1) ))

        if (( ${indexY} == 0 )); then
            start="┌"
            pad="─"
            end="┐"
        elif (( ${isLast} )); then
            start="└"
            pad="─"
            end="┘"
        else
            start="│"
            end="${start}"
        fi

        if (( ${indexY} == 0 || ${isLast} )); then
            eval printf -v padding "%.0s${pad}" {3..${width}} # 3 is inclusive here (therefore width - 2)
        else
            printf -v padding "%$(( ${width} - 2 ))s"
        fi

        navigateTo $(( ${container[Y]} + ${indexY} )) ${container[X]}
        renderText "${start}${padding}${end}"
    done
}

renderHeader()
{
    renderText "${HEADER[@]}"
}

renderSessionSelect()
{
    disableCursor
    disableEcho

    renderText "${SESSION_SCREEN[@]}"
    renderContainer "SESSION_CONTAINER"
    renderScrollable "SESSION_SCROLLABLE"
}

renderLayoutSelect()
{
    local -- layoutIndex=0
    local -- layoutTextIndex=0
    local -- selectedLayout=

    renderText "${LAYOUT_SELECT_SCREEN[@]}"

    renderOptions "LAYOUTS" "LAYOUT_OPTIONS" "selectedLayout"
}

renderField()
{
    renderText "${FIELD_SCREEN[@]}"
}

renderConstants()
{
    renderText "${CONSTANTS_SCREEN[@]}"

    renderPartial "CONSTANTS_SUB_MENU"
    navigateMenu "CONSTANTS_MENU" ${_selected[constants]}
    _selected["constants"]=$?

    (( ${_selected[settings]} == 6 )) && _selected["settings"]=0

    saveSettings
}

renderControls()
{
    renderText "${CONTROLS_SCREEN[@]}"

    navigateMenu "BACK_MENU"
}

renderAbout()
{
    renderText "${ABOUT_SCREEN[@]}"

    navigateMenu "ABOUT_MENU"
}

renderScreen()
{
    case $_state in
        (*) {
            clearScreen
            renderHeader
        };;&
        (0) {
            renderSessionSelect
        };;
    esac
}
