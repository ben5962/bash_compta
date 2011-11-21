#!/bin/bash - 
#===============================================================================
#
#          FILE:  test_interface.sh
# 
#         USAGE:  ./test_interface.sh 
# 
#   DESCRIPTION:  verif du proof of concept de la séparation de linterface et de l exe. pb de visibilité
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 26/11/2011 08:46:08 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# sanspipe
# avec pipe
# interface arbitrant entre les deux
function getmontantope(){
# lignes non vides | 6eme champ
FONCTION=${FUNCNAME}
	# la fonction doit indiquer son mode d emploi
	function usage(){
	echo "USAGE: $FONCTION <fich_cpta> TODO: version -p(ipe)| --f(fichier) <fichiercompta>"
	}

	# la fonction ne doit accepter qu un nombre correct de parametres
	aumoinsun "$@"

	# la fonction doit pouvoir etre appelee avec param à la getmontantope <fichiercompta>
	function sanspipe(){
	FICHIER="$1"
	[ ! -e "$FICHIER" ] && echo "ERR: $FUNCNAME: fichier $FICHIER existe pas " && exit $ERR_FICHIER_EXISTEPAS
	sed -n '2,$ p' "$FICHIER" | gawk -F: '{print $6}' 
	}


	# la fonction doit pouvoir etre appelée avec appel à un pipe: cat <fichiercompta> |getmontantope
	# ou getmontantope <fichiercompta
	
	function avecpipe(){
	# pour que ca marche avec un pipe il suffit d omettre le param du premier gawk
	# de gawk <transformation> <fichier>
	# on écrit gawk <transformation> rien
	sed -n '2,$ p' |gawk -F: '{print $6}'
	}

# gestion des params pour arbitrer les appels
function getmontantope_interface(){
debecho "\$\@ vaut : $@"
# p avec 0 argument donc p(rien)
# f avec 1 argument donc f":"
# traitement des erreurs donc ":" initial
# resultat :   ":pf:"
while getopts ":pf:" argu 
do
	case $argu in
		f) FICHIER="${OPTARG}"; sanspipe "$FICHIER" ;;
		p) avecpipe ;;
		*) echo "ERR parse des parms de ${FUNCNAME} : param ${OPTARG} pas implémenté";
			usage ;; #balancer msg erreur usage par appel a usage
		esac
done
shift $(( ${OPTIND} - 1 ))


		} # fin de interface

	# appels de fonctions 
	# sanspipe "$@"
	getmontantope_interface "$@"

} # fin de getmontantope
getmontantope -f "${FICHIERDEST}" 2> getmontantope.err
