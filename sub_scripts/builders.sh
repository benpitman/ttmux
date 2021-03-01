buildScrollableWindows ()
{
    # local -n -- items="$1"
    printf -v "$1" _scrollableWindows

    if (( ${#_scrollableWindows[@]} )); then
        return
    fi

    local -- windowIndex=${3:-0} # Start point
    local -- layoutIndex=
    local -- width=$(( $2 - ${#LAYOUTS[0,0]} ))
    local -- item=
    local -- spacerLength=
    local -- spacer=
    local -- items=()
    local -- windowMax=${#_windows[@]}

    for (( ; ${windowIndex} < ${windowMax}; windowIndex++ )); do
        for (( layoutIndex = 0; ${layoutIndex} <= ${LAYOUTS[0,MAX]}; layoutIndex++ )); do

            if (( layoutIndex == 1 )); then
                printf -v item "%-${#windowMax}s" $(( ${windowIndex} + 1 ))
                item+=" ${_windows[${windowIndex}]} (${_locations[${windowIndex}]}) "
                spacerLength=$(( ${width} - ${#item} - ${#windowMax} - 1 )) # Minus two for a space either side
                spacer=

                if (( ${spacerLength} < 0 )); then
                    item=${item:0:${spacerLength%-}}
                    spacerLength=0
                fi

                (( ${spacerLength} )) && eval printf -v spacer "%.0s." {1..${spacerLength}}
                item+="${spacer} "
            else
                printf -v item "%$(( ${width} - ${#windowMax} ))s"
            fi

            item+="${LAYOUTS[${_layouts[${windowIndex}]},${layoutIndex}]}"
            items+=("$item")
        done
    done
    _scrollableWindows=("${items[@]}")
}
# buildScrollableWindows ()
# {
#     # local -n -- items="$1"
#     printf -v "$1" _scrollableWindows

#     if (( ${#_scrollableWindows[@]} )); then
#         return
#     fi

#     local -- windowIndex=${3:-0} # Start point
#     local -- layoutIndex=
#     local -- width=$2
#     local -- item=
#     local -- spacerLength=
#     local -- spacer=
#     local -- items=()

#     for file in /var/*; do
#         printf -v file "%$(( (${width} / 2) + (${#file} / 2) ))s" "${file}"
#         printf -v file "%-${width}s" "${file}"
#         items+=("${file}")
#     done
#     _scrollableWindows=("${items[@]}")
# }
