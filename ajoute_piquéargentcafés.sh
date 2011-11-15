#!/bin/bash - 
#===============================================================================
#
#          FILE:  ajoute_restau_rho.sh
# 
#         USAGE:  ./ajoute_restau_rho.sh 
# 
#   DESCRIPTION:  ajoute une opé de restau à RHODES
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 15/11/2011 03:44:27 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# retire un montant cafés de puce
# contre une créance vis à vis de corentin
UTIL="pu"
echo "montant?"
read MONTANT
LIB="corentin a pris argent pour cafés - ouverture"
echo "date?"
read DATE
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "411IOUCP" -N "IOU - co doit à pu"  -s D
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "530" -N "Caisse" -s C
./bal
# ajoute la dette dans la caisse corentin
# ajoute de l'argent dans la caisse corentin
UTIL="co"
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "530" -N "Caisse" -s D
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "401IOUCP" -N "IOU - co doit à pu" -s C
./bal
