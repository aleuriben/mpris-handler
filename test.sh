#!/bin/bash

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
    actual=$(cat /tmp/player_tmp.ale)
    for i in ${mprislist[@]}; do
      if [[ ! "$i" == "$actual" ]]; then
        return 0
      fi
    done
    return 1 
  fi
}

if [ ! -f /tmp/player_tmp.alea ] || [ $(verify) -eq 0 ] || [ $1 -eq 1 ]; then

  mpvlist=($(printf '%s\n' "${mprislist[@]}" | grep "mpv"))
  if [ ${#mpvlist[@]} -gt 1 ]; then
    clearall 
  fi
  player=$(for i in ${mprislist[@]}; do echo -n "$(echo $i | sed 's/\..*//'): "; playerctl -p $i metadata title 2> /dev/null || echo; done | dmenu -p "Controlar audio" -no-custom -only-match -format 'i')
  echo ${mprislist[$player]} > /tmp/player_tmp.ale
  echo $player
else 
  playerctl --list-all
fi

echo $(verify)
