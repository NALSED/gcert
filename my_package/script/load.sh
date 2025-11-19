#!/usr/bin/env bash

# ====================================== !!! CE SCRIPT PROVIENT DES SOURCES CI-DESSOUS !!! ======================================  

# Source: https://github.com/Silejonu/bash_loading_animations

# shellcheck disable=SC2034 # https://github.com/koalaman/shellcheck/wiki/SC2034

### Loading animations list ###
# The first value of an array is the interval (in seconds) between each frame

## ASCII animations ##
# Will work in any terminal, including the TTY.


BLA_classic=( 0.25 '-' "\\" '|' '/' )
BLA_box=( 0.2 ┤ ┴ ├ ┬ )
BLA_bubble=( 0.2 · o O O o · )
BLA_breathe=( 0.9 '  ()  ' ' (  ) ' '(    )' ' (  ) ' )
BLA_growing_dots=( 0.5 '.  ' '.. ' '...' '.. ' '.  ' '   ' )
BLA_passing_dots=( 0.25 '.  ' '.. ' '...' ' ..' '  .' '   ' )
BLA_metro=( 0.2 '[    ]' '[=   ]' '[==  ]' '[=== ]' '[ ===]' '[  ==]' '[   =]' )

#!/usr/bin/env bash

# ------------ Animation loader ------------


declare -a BLA_active_loading_animation

BLA::play_loading_animation_loop() {
  local text="$1"
  while true; do
    for frame in "${BLA_active_loading_animation[@]}"; do
      printf "\r%s %s" "$msg" "$frame"
      sleep "$BLA_loading_animation_frame_interval"
    done
  done
}

BLA::start_loading_animation() {
  local text="$1"
  shift
  BLA_active_loading_animation=( "$@" )
  BLA_loading_animation_frame_interval="${BLA_active_loading_animation[0]}"
  unset "BLA_active_loading_animation[0]"
  tput civis
  BLA::play_loading_animation_loop "$text" &
  BLA_loading_animation_pid="${!}"
}

BLA::stop_loading_animation() {
  kill "$BLA_loading_animation_pid" &> /dev/null
  printf "\n"
  tput cnorm
}



###############################################################################
################################# USAGE GUIDE #################################
###############################################################################
################## Read below for the explanations on how to ##################
################### show loading animations in your script. ###################
###############################################################################

:<<'EXAMPLES'

## Put these lines at the top of your script:
## (replace /path/to/bash_loading_animations.sh with the appropriate filepath)
# Load in the functions and animations
source /path/to/bash_loading_animations.sh
# Run BLA::stop_loading_animation if the script is interrupted
trap BLA::stop_loading_animation SIGINT

# Show a loading animation for the command "foo"
BLA::start_loading_animation "${BLA_name_of_the_animation[@]}"
foo
BLA::stop_loading_animation

# If foo prints some output in the terminal, you may want to add:
foo 1> /dev/null # hide standard output
# or
foo 2> /dev/null # hide error messages
# or
foo &> /dev/null # hide all output

EXAMPLES