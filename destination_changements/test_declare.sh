#!/bin/bash - 
#===============================================================================
#
#          FILE:  test_declare.sh
# 
#         USAGE:  ./test_declare.sh 
# 
#   DESCRIPTION:  essai de déclare apres une fonction. devrait lister la fonction. c'est à dire?
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 16/11/2011 05:41:05 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

function unefonc(){
echo "entree dans $FUNCTION"
}

function uneautrefonc(){
echo "entree dans $FUNCTION"
}

declare -F
# provoque affichage de
# declare -f unefonc
# declare -f uneautrefonc


# declare
# provoque affichage de
# function unefonc(){ echo "entree dans $FUNCTION" }
# et de l'autre
