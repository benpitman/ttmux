declare -g -- _state=0
declare -g -- _sessionName=

declare -ag -- _scrollableWindows=()

declare -ag -- _windows=()
declare -ag -- _locations=()
declare -ag -- _layouts=()

declare -Ag _selected=(
    ["main"]=0
)
