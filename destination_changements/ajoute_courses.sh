#!/bin/bash - 
#===============================================================================
#
#          FILE:  ajoute_courses.sh
# 
#         USAGE:  ./ajoute_courses.sh 
# 
#   DESCRIPTION:  ajoute une opé de course semaine et les relations de cd liées
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

./commentaire.sh "début opé"
./commentaire.sh "pmt courses"
# ajoute des courses par bq
echo "util?"
read UTIL
echo "montant?"
read MONTANT
echo "libellé?"
read LIB
echo "date?"
read DATE
./commentaire "pmt des courses du $DATE par $UTIL"
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "6257COU" -N "Réceptions - Frais restauration - courses semaine"  -s D
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "512" -N "Banque" -s C
# gérer comme d'habitude les deux cas de créances.

case $UTIL in 
	co)
# gestion des ious:
# cas 1 : c'est corentin qui a payé => il a une créance sur puce de montant/2 contre un transfert de ch 7xx
#  corentin
#  401IOUPCdx	|		créance sur puce "401 (cré cli) IOU Puce doit à CO"
#  		| 791 cx	.. car charge transférée
#
# montant : MONTANT/2
NVMONTANT=$(echo "scale=2; $MONTANT / 2" |bc)
./commentaire.sh "$COMMENTAIRE créance de co sur pu vue depuis compte co"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "401IOUPC" -N "IOU Puce doit à co" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "791" -N "Transferts de charge d'exploitation" -s C 

#         et dans le compte de puce , elle a une dette de 16E  contre un ajout de ch. "ch transférée (sans typologie)
#  puce
#  65555dx	|            charge dans ta face par transfert
# 		| 411IOUPCcx		... pas encore payée " 411(dette fou) IOU  Puce doit à Co"
./commentaire.sh "$COMMENTAIRE créance de co sur pu vue depuis compte pu"

UTIL="pu"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "65555COU" -N "Quote-part de charges sur opérations communes - COU" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "411IOUPC" -N "IOU Puce doit à co" -s C
UTIL="co"
;;

	pu)
# cas 2 : c'est puce qui a payé => elle a une créance
# puce
#  401IOUCPdx	|		créance sur puce "401 (cré cli) IOU Co doit à pu"
#  		| 791 cx	.. car charge transférée
#
# montant : MONTANT/2
NVMONTANT=$(echo "scale=2; $MONTANT / 2" |bc)
./commentaire.sh "$COMMENTAIRE créance de puce sur co vue depuis compte pu"

./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "401IOUCP" -N "IOU co doit à pu" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "791" -N "Transferts de charge d'exploitation" -s C 
#         et dans le compte de co , il a une dette de 16E  contre un ajout de ch. "ch transférée (sans typologie)
#  co
#  65555dx	|            charge dans ta face par transfert
# 		| 411IOUCPcx		... pas encore payée " 411(dette fou) IOU  co doit à pu"
UTIL="co"

./comentaire.sh "$COMMENTAIRE créance de puce sur co vue depuis compte co"

./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "65555COU" -N "Quote-part de charges sur opérations communes - COU" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "411IOUCP" -N "IOU co doit à pu" -s C
UTIL="pu"

;;
	*) echo "util $UTIL pas prévu"
		;;

esac
./commentaire.sh "fin opé"
./commentaire.sh " "
./bal
