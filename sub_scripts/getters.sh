getSessionName()
{
    printf -v "$1" "${_sessionName}"
}

sessionExists()
{
    [[ -s "${CONFIG_PATH}" ]]
}
