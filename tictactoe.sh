#!/bin/bash

#tictactoe v1
#to consider: use curses and a wiser algorithm to play from computer side

#TODO: prettify
EMPTY='_'
board=($EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY)
POSITIONBOARD=(1 2 3 4 5 6 7 8 9)
player1='x'
player2='o'


function print_board()
{
    # TODO: cmon ffs you can do better than that
    echo "${1} | ${2} | ${3}"
    echo "${4} | ${5} | ${6}"
    echo "${7} | ${8} | ${9}"
}

function check_full_board()
{
    for n in ${board[@]}; do
        [ ${n} = ${EMPTY} ] && return 1;
    done
    return 0;
}

function check_single_line()
{
    [ ${1} != ${EMPTY} ] && [ ${1} = ${2} ] && [ ${1} = ${3} ]
}

function check_and_announce()
{
    check_single_line ${1} ${2} ${3} \
        && (echo "${1} wins!!!"; return 0) \
        || return 1
}

#TODO: wyrugować parametr tablicy z funkcji
function check_lines()
{
    for n in {0..2}; do
        check_and_announce ${board[$((n))]} ${board[$((n+3))]} ${board[$((n+6))]} && return 0
    done
    for n in 0 3 6; do
        check_and_announce ${board[$((n))]} ${board[$((n+1))]} ${board[$((n+2))]} && return 0
    done
    check_and_announce ${board[0]} ${board[4]} ${board[8]} && return 0
    check_and_announce ${board[2]} ${board[4]} ${board[6]} && return 0
}

function get_player_move()
{
    while true; do
        echo "Player ${1} moves"
        print_board "${POSITIONBOARD[@]}"
        printf "Please select a position (1-9): "
        read
        if ! [[ "${REPLY}" =~ ^[1-9]$ ]]; then
            echo "${REPLY} is not a valid position, try again"
        fi
        
        position=$((${REPLY}-1))
        if [ "${board[${position}]}" != "${EMPTY}" ]; then
            echo "Position ${REPLY} already filled, try again"
        else
            if [ ${1} -eq 1 ]; then
                board[${position}]="${player1}"
            elif [ ${1} -eq 2 ]; then
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
        print_board ${board[@]}
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
    while true; do
        board=($EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY)
        play
        echo "Do you want to play again? [Y/n]"
        read
        [[ ${REPLY} =~ '^[nN]$' ]] && break
    done
}

main