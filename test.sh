#!/bin/bash

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

if [ ! -f /tmp/player_tmp.ale || $1 -eq 1 ]; then

  mprislist=($(playerctl --list-all))
  mpvlist=($(printf '%s\n' "${mprislist[@]}" | grep "mpv"))
  if [ ${#mpvlist[@]} -gt 1 ]; then
    clearall 
  fi
  player=$(for i in ${mprislist[@]}; do echo -n "$(echo $i | sed 's/\..*//'): "; playerctl -p $i metadata title 2> /dev/null || echo; done | dmenu -p "Controlar audio" -no-custom -only-match -format 'i')
  echo ${mprislist[$player]} > /tmp/player_tmp.ale
else 
  player
fi


