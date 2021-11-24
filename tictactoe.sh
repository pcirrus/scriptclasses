#!/bin/bash

#tictactoe v1

#TODO: prettify
EMPTY='_'
board=("$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY")
path="$HOME/.tictactoe_saves"
savename_start="tictactoe_save_"
POSITIONBOARD=(1 2 3 4 5 6 7 8 9)
player1='x'
player2='o'

set -e

function save_game()
{
    filename="$savename_start$(date +'%Y-%m-%d-%H-%M-%S')"
    if [ -e "$path" ]; then
        [ -d "$path" ] || (echo "$path exists and is not a directory, aborting" \
                           return 1)
    else
        mkdir -p "$path"
    fi
    
    fullpath="$path/$filename"
    if [ -e "$fullpath" ]; then
        [ -f "$fullpath" ] || (echo "$fullpath exists and is not a file, aborting" \
                               return 1)
        read -r -p "$fullpath already exists. Overwrite? [y/N]"
        [[ ${REPLY} =~ ^[yY]$ ]] || return 1
    fi
    echo "${board[@]}" > "$fullpath"
}

function save_game_prompt()
{
    printf "\n"
    read -r -p "You've pressed Ctrl+C. Do you want to save your game before exiting? [Y/n] "
    [[ ${REPLY} =~ ^[nN]$ ]] && exit 0
    if ! save_game; then
        read -r -p "Save was not successful (error code $?). Do you want to quit? [y/N]"
        [[ ${REPLY} =~ ^[yY]$ ]] && exit 1
    fi
    exit 0
}

function try_loading_game()
{
    # Check if there are any saves
    [ ! -d "$path" ] && return 0;
    filelist=("$path"/*)
    [ -e "${filelist[0]}" ] || return 0;

    echo "There are following saves present: "
    i=0

    for file in "${filelist[@]}"; do
        echo "$i : ${file#$savename_start}"
        i=$((i+1))
    done
    while true; do
        read -r -p "Choose save to load (numeric value), or press any other key to start a new game: "
        if [[ "${REPLY}" =~ ^[0-9]+$ ]]; then
            if [ "${REPLY}" -ge ${#filelist[@]} ]; then
                echo "Invalid index: ${REPLY}"
                continue
            else
                read -r -a board <<< "$(cat "${filelist[$REPLY]}")"
                rm "${filelist[$REPLY]}"
            fi
        fi
        break
    done
}

function print_board()
{
    # TODO: cmon ffs you can do better than that
    echo "${1} | ${2} | ${3}"
    echo "${4} | ${5} | ${6}"
    echo "${7} | ${8} | ${9}"
}

function check_full_board()
{
    for n in "${board[@]}"; do
        [ "${n}" = ${EMPTY} ] && return 1;
    done
    return 0;
}

function check_single_line()
{
    [ "${1}" != ${EMPTY} ] && [ "${1}" = "${2}" ] && [ "${1}" = "${3}" ]
}

function check_and_announce()
{
    check_single_line "${1}" "${2}" "${3}" \
        && (echo "${1} wins!!!"; return 0) \
        || return 1
}

#TODO: wyrugować parametr tablicy z funkcji
function check_lines()
{
    for n in {0..2}; do
        check_and_announce "${board[$((n))]}" "${board[$((n+3))]}" "${board[$((n+6))]}" && return 0
    done
    for n in 0 3 6; do
        check_and_announce "${board[$((n))]}" "${board[$((n+1))]}" "${board[$((n+2))]}" && return 0
    done
    check_and_announce "${board[0]}" "${board[4]}" "${board[8]}" && return 0
    check_and_announce "${board[2]}" "${board[4]}" "${board[6]}" && return 0
}

function get_player_move()
{
    while true; do
        echo "Player ${1} moves"
        print_board "${POSITIONBOARD[@]}"
        read -r -p "Please select a position (1-9): "
        if ! [[ "${REPLY}" =~ ^[1-9]$ ]]; then
            echo "${REPLY} is not a valid position, try again"
        fi
        
        position=$((REPLY-1))
        if [ "${board[${position}]}" != "${EMPTY}" ]; then
            echo "Position ${REPLY} already filled, try again"
        else
            if [ "${1}" -eq 1 ]; then
                board[${position}]="${player1}"
            elif [ "${1}" -eq 2 ]; then
                board[${position}]="${player2}"
            else
                echo "[!!!] Invalid player passed to get_player_move: ${1}"
                exit
            fi
            break;
        fi
    done
}

function play()
{
    current_player=1
    while true; do
        print_board "${board[@]}"
        get_player_move ${current_player}

        if check_lines; then
            break
        fi

        if check_full_board; then
            echo "Full board, there's a tie!"
            break
        fi

        if [ ${current_player} -eq 1 ]; then
            current_player=2
        else
            current_player=1
        fi
    done
}

function main()
{
    board=("$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY")
    while true; do
        try_loading_game
        trap 'save_game_prompt' INT
        play
        read -r -p "Do you want to play again? [Y/n]"
        [[ ${REPLY} =~ ^[nN]$ ]] && break
        board=("$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY" "$EMPTY")
    done
}

main