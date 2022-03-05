#!/bin/bash

# Para los avisos de volumen instalar dunst
# Se necesita tener instalado rofi o se puede modificar para que lo use dmenu
# Se necesita tener instalado mpv-mpris para que funcione con mpv tambien

# USO
# en i3wm:
# bindsym XF86AudioNext exec --no-startup-id /path/test.sh 3
# bindsym XF86AudioPlay exec --no-startup-id /path/test.sh 2
# bindsym XF86AudioPrev exec --no-startup-id /path/test.sh 1
# 1 para -5 seg
# 2 para play/pause
# 3 para +5 seg
# 11 para -60 seg
# 13 para +60 seg
# 21 para retroceder 1 en el playlist
# 23 para avanzar 1 en el playlist
#
# 51 para aumentar volumen del video (NO AUMENTA EL GENERAL)
# 52 para disminuir volumen del video (NO DISMINUYE EL GENERAL)

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
    title="$(playerctl -p $act metadata title 2> /dev/null)"
    case $1 in
      1)
        playerctl -p $act position 5-
        dunstify -r 173 "MPRIS ($title):" "⏪ Fast-Rewind -5 seg."
        ;;
      2)
        playerctl -p $act play-pause
        if [[ "$(playerctl -p $act status)" == "Playing" ]]; then
          dunstify -r 173 "MPRIS ($title):" "▶ Playing"
        else
          dunstify -r 173 "MPRIS ($title):" "⏸ Paused"
        fi
        ;;
      3)
        playerctl -p $act position 5+
        dunstify -r 173 "MPRIS ($title):" "⏩ Fast-Forward +5 seg."
        ;;
      11)
        playerctl -p $act position 60-
        dunstify -r 173 "MPRIS ($title):" "⏪ Fast-Rewind -60 seg."
        ;;
      13)
        playerctl -p $act position 60+
        dunstify -r 173 "MPRIS ($title):" "⏩ Fast-Forward +60 seg."
        ;;
      21)
        playerctl -p $act previous
        dunstify -r 173 "MPRIS ($title):" "⏮ Previous Track"
        ;;
      23)
        playerctl -p $act next
        dunstify -r 173 "MPRIS ($title):" "⏭ Previous Track"
        ;;
      51|52)
        
        vol=$(playerctl --player=$act volume | awk '{printf("%.2f\n", $1*100)}')
        vol=$(echo $vol | sed 's/\..*//g')
        
        case "$1" in
            51)
                if [ $vol -le 145 ]; then
                    playerctl --player=$act volume '0.05+'
                fi
                ;;
            52)
                playerctl --player=$act volume '0.05-'
                ;;
            *)
                echo ERROR
                ;;
        esac
        
        if [ $vol -ge 50 ]; then
          dunstify -r 173 "MPRIS ($title):" "🔊 $vol%"  
        elif [ $vol -gt 25 ]; then
          dunstify -r 173 "MPRIS ($title):" "🔉 $vol%"
        elif [ $vol -ge 5 ]; then
          dunstify -r 173 "MPRIS ($title):" "🔈 $vol%"
        else
          dunstify -r 173 "MPRIS ($title):" "🔇 $vol%"
        fi
        ;;
      *)
        echo ERROR
        exit 1
        ;;
    esac
  fi
fi

        status=$(playerctl --player=mpv status)
        if [[ $status == "Playing" ]]; then
            play="▶"
        elif [[ $status == "Paused" ]]; then
            play="⏸"
        else
            play="⏹"
            video_title="[No video available]"
            percentage=0
        fi
