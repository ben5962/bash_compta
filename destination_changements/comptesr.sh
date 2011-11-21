#!/bin/bash - 
#===============================================================================
#
#          FILE:  comptesr.sh
# 
#         USAGE:  ./comptesr.sh 
# 
#   DESCRIPTION:  comptes valant une certaine regex
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 15/11/2011 03:29:18 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
./comptes.sh |grep "$1"

