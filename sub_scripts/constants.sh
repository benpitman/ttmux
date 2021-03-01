################################## GENERAL #####################################

declare -rg -- CONFIG_DIR="${HOME}/.config/ttmux"
declare -rg -- CONFIG_PATH="${CONFIG_DIR}/layout.sh"
declare -rg -- KEY_UP="A"
declare -rg -- KEY_DOWN="B"
declare -rg -- SCROLL_UP="5~"
declare -rg -- SCROLL_DOWN="6~"

declare -rg -- SCROLLBAR_UP="▴"
declare -rg -- SCROLLBAR_DOWN="▾"
declare -rg -- SCROLLBAR_BLANK="░"
declare -rg -- SCROLLBAR_BLOCK="█"

declare -Arg -- ERRORS=(

)

################################## SCREENS #####################################

declare -Arg -- SCREENS=(
    ["MAIN_MENU"]=0
    ["ADD_SESSION"]=1
    ["REMOVE_SESSION"]=2
)

declare -arg -- HEADER=(
    "  ┌─────────────────────────────────────────────────────────────┐"
    "  │                                ┌──────────────────────────┐ │"
    "  │     ┌─────────┐                │  Arrow Keys - Navigate   │ │"
    "  │        TTMUX         CONTROLS ─┤  Enter      - Select     │ │"
    "  │     └─────────┘                │  ESC        - Exit       │ │"
    "  │                                └──────────────────────────┘ │"
    "  ├─────────────────────────────────────────────────────────────┤"
    ""
)

declare -arg -- SESSION_SCREEN=(
    "  │                                                             │"
    "  │                                                          Pg │"
    "  │                                                          Up │"
    "  │                                                             │"
    "  │                                                             │"
    "  │                                                             │"
    "  │                                                             │"
    "  │                                                          Pg │"
    "  │                                                          Dn │"
    "  │                                                             │"
    "  │                                                             │"
    "  │                             EDIT                            │"
    "  │                             NEW                             │"
    "  │                                                             │"
    "  │                                                             │"
    "  └─────────────────────────────────────────────────────────────┘"
)

declare -arg -- LAYOUT_SELECT_SCREEN=(
    "  │                                                             │"
    "  │                                                             │"
    "  │                                                             │"
    "  │     1         2         3         4         5         6     │"
    "  │                                                             │"
    "  │  Please select a layout:                                    │"
    "  │                                                             │"
    "  │                                                             │"
    "  │                                                             │"
    "  └─────────────────────────────────────────────────────────────┘"
)

declare -Arg -- SESSION_CONTAINER=(
    ["Y"]=8
    ["X"]=5
    ["HEIGHT"]=10
    ["WIDTH"]=56
    ["NAME"]=""
    ["HEADER"]="getSessionName" # Callable
)

declare -Arg -- SESSION_SCROLLABLE=(
    ["Y"]=9
    ["X"]=7
    ["WIDTH"]=55
    ["HEIGHT"]=8
    ["BODY"]="buildScrollableWindows" # Callable
    ["SCROLLABLE"]=1
    ["INTERACTIVE"]=1
    ["LINE_HEIGHT"]=3
    ["ALIGN"]=0 # 0 = Left, 1 = Center, 2 = Right
)

declare -Arg -- LAYOUT_OPTIONS=(
    ["MAX"]=5

    ["INPUT,Y"]=14
    ["INPUT,X"]=30
    ["INPUT,MAX"]=1
    ["INPUT,REGEX"]="[^1-6]"
    ["INPUT,REPLACE"]=" "

    ["0,Y"]=9
    ["0,X"]=5

    ["1,Y"]=9
    ["1,X"]=15

    ["2,Y"]=9
    ["2,X"]=25

    ["3,Y"]=9
    ["3,X"]=35

    ["4,Y"]=9
    ["4,X"]=45

    ["5,Y"]=9
    ["5,X"]=55
)

declare -Arg -- LAYOUTS=(
    ["MAX"]=5

    ["0,MAX"]=2
    ["0,0"]="┌───────┐"
    ["0,1"]="│       │"
    ["0,2"]="└───────┘"

    ["1,MAX"]=2
    ["1,0"]="┌───┬───┐"
    ["1,1"]="│   │   │"
    ["1,2"]="└───┴───┘"

    ["2,MAX"]=2
    ["2,0"]="┌───────┐"
    ["2,1"]="├───────┤"
    ["2,2"]="└───────┘"

    ["3,MAX"]=2
    ["3,0"]="┌───┬───┐"
    ["3,1"]="├───┤   │"
    ["3,2"]="└───┴───┘"

    ["4,MAX"]=2
    ["4,0"]="┌───┬───┐"
    ["4,1"]="│   ├───┤"
    ["4,2"]="└───┴───┘"

    ["5,MAX"]=2
    ["5,0"]="┌───┬───┐"
    ["5,1"]="├───┼───┤"
    ["5,2"]="└───┴───┘"
)

############################### MENU NAVIGATION ################################

declare -Arg MAIN_MENU=(
    ["MAX"]=4

    ["0,Y"]=9
    ["0,X"]=30
    ["0,W"]=66
    ["0,FUNCTION"]="getCipher"

    ["1,Y"]=10
    ["1,X"]=30
    ["1,W"]=66
    ["1,FUNCTION"]="getInitialisationVector"

    ["2,Y"]=11
    ["2,X"]=30
    ["2,W"]=66
    ["2,FUNCTION"]="getDatabaseKey"

    ["3,Y"]=16
    ["3,X"]=18
    ["3,W"]=66
    ["3,FUNCTION"]="getDecrypted"

    ["4,Y"]=22
    ["4,X"]=6
    ["4,W"]=90
    ["4,FUNCTION"]="getEncrypted"
)
