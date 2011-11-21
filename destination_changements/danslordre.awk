#!/bin/bash

function usage(){
echo "$(basename $0) -u <co|pu>"
}


function aumoinsunparam(){
ERR_NB_PARAM=65
if [ "$#" -lt 2 ];
then 
	echo "$FUNCNAME: $0 attend au moins deux param"
	echo "je vais maintenant sortir avec un code d'erreur de $ERR_NB_PARAM"
	usage
	exit $ERR_NB_PARAM
fi
}

aumoinsunparam "$@"
while getopts ":u:" OPTS
do
	case $OPTS in
	    u) UTIL="${OPTARG}";;
	    *) echo "$OPTARG: pas implémenté";;
	    esac
done
shift $(( ${OPTIND} - 1 ))

gawk -F"@" -v UTIL="$UTIL" \
     '{
	     ch="";
		# jajoute à la chaine le champ 2 correspondant à la date
			# attention pas d apostrophe dans les commentaires de gawk
			# ou ca merche plus.
		ch=(ch $2 ":");
		# je rajoute co ou puce en fonction du param passé
                ch=(ch UTIL ":")
                # je rajoute les chaines fixes ":512:" et ":Banque"
                ch=(ch "512:Banque:")
                # je rajoute D si le signe du montant est positif et C sinon:
                # TRAPEUR : d abord il faut convertir $3 en nombre
                #print $3
                # et on voit que ca marche pas parce que prefixé par TOTAL monney amount |
                # qu il faut dégager.
                $3=$3+0
                #print $3
                # puis on claque la comparaison 
                if ( $3 < 0 ) 
                ch=(ch "C:")
                if ( $3 > 0 )
                ch=(ch "D:")
                # pour le champ suivant seule la valeur absolue du montant de lopé m intéresse.
                # donc opération de prog impérative sub(/regex/, remplacement, cible)
                sub(/-/, "", $3)
                ch=(ch $3 ":")
                # il ne reste plus qu a ajouter les deux composantes du libellé:
                # le type de transaction
                ch=(ch $1)
                # la description de la transaction ou le tiers ou le num cheque
                ch=(ch $4)
                print ch;
};' 
