#!/bin/bash

# Se necesita tener instalado mpv-mpris para que funcione con mpv tambien

mprislist=($(playerctl --list-all))
function clearall(){
  num=$(( ${#mprislist[@]} - 1 ))
  count=0;
  for list1 in ${mprislist[@]}; do
    count2=$(($count + 1))
    if [[ $list1 == "mpv" ]]; then
      mprislist=( "${mprislist[@]:0:$count}" "${mprislist[@]:$count2}" )
    fi
    count=$(( $count + 1 ))
  done
}

function verify(){
  if [ -f /tmp/player_tmp.ale ]; then
    actual="$(cat /tmp/player_tmp.ale)"
    num=1
    for i in ${mprislist[@]}; do
      if [ $i = $actual ]; then
        num=0
      fi
    done
    return $num 
  fi
}


if [ ! -f /tmp/player_tmp.ale ] || ! verify || [ $# -eq 0 ]; then

  mpvlist=($(printf '%s\n' "${mprislist[@]}" | grep "mpv"))
  if [ ${#mpvlist[@]} -gt 1 ]; then
    clearall 
  fi
  player=$(for i in ${mprislist[@]}; do echo -n "$(echo $i | sed 's/\..*//'): "; playerctl -p $i metadata title 2> /dev/null || echo; done | dmenu -p "Controlar audio" -format 'i')
  echo ${mprislist[$player]} > /tmp/player_tmp.ale
else 
  if verify && [ $# -gt 0 ]; then
    act="$(cat /tmp/player_tmp.ale)"
    case $1 in
      1)
        playerctl -p $act position 5-
        ;;
      2)
        playerctl -p $act play-pause
        ;;
      3)
        playerctl -p $act position 5+
        ;;
      11)
        playerctl -p $act position 60-
        ;;
      12)
        playerctl -p $act position 60+
        ;;
      21)
        playerctl -p $act previous
        ;;
      23)
        playerctl -p $act next
        ;;
      *)
        echo ERROR
        exit 1
        ;;
    esac
  fi
fi

