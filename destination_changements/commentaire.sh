#!/bin/bash - 
#===============================================================================
#
#          FILE:  commentaire.sh
# 
#         USAGE:  ./commentaire.sh 
# 
#   DESCRIPTION:  ajouteuneligne de commentaire dans fichier dest. but: décrire les opés qui suivent
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 18/11/2011 01:37:06 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
. ./compta.conf
function commentaire(){
echo "# $1" >> "${FICHIERDEST}"
}
commentaire "$@"
