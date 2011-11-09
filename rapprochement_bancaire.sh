#!/bin/bash
set -o nounset
# rapprochement bancaire
ERR_NB_PARAM=65
ERR_FICHIER_EXISTEPAS=100
ERR_PAS_512=200
ERR_PAS_OFX=201
SUCCES="0"
# les valeurs qu'on peut passer à 1
# avant d invoquer rapprochement_bancaire:
DEBUG="1"
# TESTERR pour tester que les fonctions sortent bien si param incorrects
# TEST pour tester les fonctions en env normal


###########################
#   0 utilitaires
##############################
function debecho(){
if [ ! -z "$DEBUG" ]; then
	echo "$1" 1>&2
fi
}


function aumoinsun(){


# fait échouer les fonctions attendant un certain nb de lignes
# donc commenté
#debecho "DEBUG : $FONCTION lancé avec $# arguments"; 
if [ "$#" -lt 1 ];
then 
    echo "ERR: il faut au moins un arg pour $FONCTION"
    echo "ERR: je vais afficher le message dutilsation de la fonction"
    usage
    echo "ERR: je vais sortir avec un msg d erreur de $ERR_NB_PARAM"
    exit $ERR_NB_PARAM
fi
}


function unetunseul(){
debecho "DEBUG : $FONCTION lancé avec $# arguments"; 
if [ ! "$#" -eq 1 ];
then 
    echo "ERR: il faut un arg et un seul pour $FONCTION"
    echo "ERR: je vais afficher le message dutilsation de la fonction"
    usage
    echo "ERR: je vais sortir avec un msg d erreur de $ERR_NB_PARAM"
    exit $ERR_NB_PARAM
fi
}

#################################
# 1 VERIF DES ENTREES UTILISATEUR
##################################


# prend deux fichiers au format compta.txt en entree
#prendre deux parametres
#si nb param <2 sortir 
function rapprochement(){
function usage(){ echo "$0 <fich cpta|512 trié[montant]> <bq trié[montant]>"; }
[ $# -lt 2 ] && echo "ERR: $0: nombre de param insuffisant: 2 attendus $# obtenus" \
&& exit  $ERR_NB_PARAM
F_CPTA="$1"
F_BQ="$2"
##TODO ecrire la fonction de rapprochement bancaire (main)
}


#verifier que les deux param correspondent à des ficheirs 
# restreints aux comptes bancaires
#pour chaque fichier faire...
# pour chaque ligne faire..
#  si champ_num_cpte(ligne) different de 512 produire erreur et sortir
# tries par ordre de montant croissants


########################################
# FEATURE SORTIE SI NUMCOMPTE /= 512
########################################

# une fonc pour choper les num de comptes
function getallnumcomptes(){
# lignes non vides | 3eme champ
FONCTION="$FUNCNAME"
function usage(){
cat << findefichier 
$FONCTION <fichier_compta> -> n lignes contenant les numéros de comptes
findefichier
}
USAGE="$FUNCNAME <fichier_compta>"
[ $# -ge 2 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
if [ $# -eq 1 ]; then
FICHIER="$1"
# supprimer premiere ligne
cat "$FICHIER" |\
       	sed '1 s/^.*$//'|\
       	gawk 'NF' |\
       # afficher que le parm3 \
       gawk -F: '{print $3}'
else
# 0 param. on suppose que ca vient d un pipe.
       	sed '1 s/^.*$//'|\
       	gawk 'NF' |\
       # afficher que le parm3 \
       gawk -F: '{print $3}'
fi
}
# si les num de comptes diff de 512 on sort 


function getallusers(){
# lignes non vides | 2eme champ
USAGE="$FUNCNAME <fichier_compta>"
[ $# -ge 2 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
if [ $# -eq 1 ]; then
FICHIER="$1"
# supprimer premiere ligne
cat "$FICHIER" |\
       	sed '1 s/^.*$//'|\
       	gawk 'NF' |\
       # afficher que le parm3 \
       gawk -F: '{print $2}'
else
# 0 param. on suppose que ca vient d un pipe.
       	sed '1 s/^.*$//'|\
       	gawk 'NF' |\
       # afficher que le parm3 \
       gawk -F: '{print $2}'
fi
}



function err_sinumcompte_pasbq(){
USAGE="$FUNCNAME <fich_cpta|512>"
[ $# -ne 1 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
FICHIER="$1"
[ ! -e "$FICHIER" ] && echo "ERR: $FUNCNAME: fichier $FICHIER existe pas " && return $ERR_FICHIER_EXISTEPAS
while read F 
do
    [ "$F" != "512" ] && echo "ERR: $FUNCNAME: sur fichier $FICHIER ligne $F differe de 512" && return $ERR_PAS_512
done  <   <(getallnumcomptes "$FICHIER")
# was : done <     <(getallnumcomptes <$FICHIER) avec aucune verif du nb param de getallnumcomptes. là si. 
return $SUCCES
}


###############################################################
# 2. depuis compta.txt multi util multi comptes 
# produire un fichier compta.txt|util | 512 
############################################################




#############################################################
# 3. depuis un fichier mono-utilisateur ofx
# produire un fichier bq.txt | (forcément monoutil) 
###############################################################
# ./modifdate.awk |sed -n -f en_ligne.sed | ./danslordre.awk
# ofx_to_encol <fichier.ofx> | modifdate | encol_daterfc3339_to_enligne_precompta

function ofx_to_encol(){
FONCTION="$FUNCNAME"
function usage(){
echo "$FONCTION <fichier.ofx> -> fichier encol"

}
# on desactive:
# msg d'interpretation des fichiers --msg_parser off par défaut rien à faire
# msg de déboggage --msg_debut off par défaut rien à faire
# msg de statut ?? --msg_status on par défaut on s'en fout on le passe en param => --msg_status
# msg d'info progression --msg_info pareil on s'en fout on le passe en para => --msg_status --msg_info
# msg d'avertissement consturcitons inconnues --msg_warning on s'en fout donc param => --msg_status --msg_info --msg_warning
# on garde :
# msg d'erreur qu on envoie dans ofx.err --msg_err on par défaut rien à faire => --msg_status --msg_info --msg_warning 2> err

# homeostasie
#un seul param
#TODO: passer à aumoinsun lors paramétrisation -f et -p
unetunseul "$@"
# le param doit correspondre à un fichier existant
if [ ! -e "$1" ]; then echo "ERR: $FONCTION: le fichier $1 n'existe pas"; usage; exit $ERR_FICHIER_EXISTEPAS; fi
function detect_ofx_type(){
PREMIERE_LIGNE="$(head -n 1 "$@")"
debecho "premiere ligne : $PREMIERE_LIGNE"
CRITERE="OFXHEADER:100"
if [ "${PREMIERE_LIGNE}" == "${CRITERE}" ];
then
	debecho "$1 est un fichier de type ofx"
	return $SUCCES
else

	debecho "$1 n est pas un fichier de type ofx"
	usage;
	exit $ERR_PAS_OFX
fi
}
detect_ofx_type "$1"

# toujours là? c'est que tout est bon. appel de fonction.
ofxdump "$1" --msg_warning  --msg_status --msg_info 2> ofx.err
return ${SUCCES}
}

function modifdateawk(){
ofxdump todo.ofx 2>OFXDUMP_ERR.TXT |\
	sed -e 's/: /|/' -e 's/^ *//' |\
	gawk -F"|" \
	'$1 != "Date posted"; 
	$1 == "Date posted" 	{ 
		SAUVERLALIGNEGAWK=$0;
	       	SAUVERDATEPOSTED=$1	
		#cmd="date"; print "contenu de $2 de awk: "$2; 
		SAUVERDATE=$2; 
		#cmd|getline; 
		#RESULTATCMD=$0; 
		#close(cmd); 
		#print "0) DEBUG : preuve sauvegarde ligne gawk complete : " SAUVERLALIGNEGAWK ; 
		#print "1) DEBUG :  resultat de date|getline :" RESULTATCMD; 
		#print  "=============="; 
		#tmp=(cmd" " SAUVERDATE);
		#print "2) DEBUG: preuve concatenation date et var gawk SAUVERDATE :" tmp;
		#tmp | getline;
		#RES=$0; 
		#close(tmp);
		#print "***********";
		#print "3) DEBUG: marchera pas nécessite retouche, execution ligne concaténée date et var gawk SAUVERDATE : " RES; 
		#print "-----------";
		#CMD=("date --date=\"" "$(echo \"" SAUVERDATE "\"|sed 's/CEST//')\"");
		#print "4) DEBUG: tentative de creation d une chaine complete de pipes a executer sans getlines intermediaires :" CMD; 
		#CMD|getline;
		#resres=$0;
		#close("CMD" );
		#print "5) DEBUG: resultat de l execution de la commande date --date $(date sans CEST) : " resres;
		#print "/*/*/*//*//*/*/*/*//*";
		cmd=("date --rfc-3339='date' --date=\"" SAUVERDATE "\"");
		cmd|getline;
		RES=$0;
		close(cmd);
		#print "6) DEBUG: resultat de date --date $(date avec CEST):" SAUVERLALIGNEGAWK" "RES;
		print SAUVERDATEPOSTED"| "RES;
	};'
}

function encol_daterfc3339_to_enligne_precompta(){
sed  -n '
/ofx_proc_transaction.*/ {
# sauter la ligne ofx_proc.la supprimer du tampon. charger la ligne suivante qui expose le numero de compte 
n 
# supprimer cette ligne de numero de compte : on n en na pas besoin
s/^Account.*$// 
# supprimer cette ligne vide du tampon. charger la ligne suivante dans le tampon : le type de transaction
n 
# retoucher ce type de transaction: on ne veut que la valeur du type de
# transaction, on va se passer du titre de la colonne:
s/Transaction type|//
# on va maintenant retoucher la valeur de la ligne type de transaction:
# /POS:.*/CB sabot magasin/
s/POS:.*/CB sabot magasin/
# /CHECK:.*/chèque/
s/CHECK:.*/chèque /
# /PAYMENT: Electronic payment/prélèvement automatique/
s/PAYMENT: Electronic payment/prélèvement automatique /
# /ATM:.*/retrait de liquide/
s/ATM:.*/retrait de liquide /
# DEBIT: Generic debit/prélèvement (sans précision)/
s/DEBIT:.*/prélèvement (sans précision)/
# /DIRECTDEP: Direct deposit/virement /
s/DIRECTDEP:.*/virement / 
# /DEP:.*/dépot chq ou espèces/
s/DEP:.*/dépot chq ou espèces/g
# ajouter la ligne suivante dans le tampon sans le vider on récupère la ligne date, utile. les deux lignes forment une
# uniligne séparee par le car \n 
N
# remplacer \n par @ pour préparer formatage ligne 
s/\n/@/g
# il faut retoucher le champ date pour dégager la partie commentaire qui était
# utile uniquement lors du déboggage:
s/Date posted|//
# on obtient transaction@ date. on veut dégager cet espace surnuméraire
s/@ /@/g
# on obtient transaction@date. on veut encore @montant, la ligne suivante. 
# mais il nous faut le retoucher:
# on récupère notre ligne montant dans nv tampon sans éffacer la ligne construite 
N
# et on refait un remplacement de \n par @ (un seul suffira après la phase de déboggage puisque s///g
s/\n/@/g
# on fait maintenant notre retouche: on dégage la chaine "Total money amount |" on obtient transaction@date@(-)chiffre
s/Total money amount|//

# maintenant on veut zapper les trois prochaines lignes. mais on veut garder la commande en cours de construction.
# on la sauve donc
x
# on charge par trois fois les lignes suivantes dans le tampon en vidant le tampon:
# une premiere fois et on charge la ligne # of units
n
# une deuxieme fois et c est la ligne unit price qui est alors dans le pattern space:
n
# une troisieme fois et cest le jetoon tamporaire dinstituttion qui est chargé.
n
# la ligne suivante par contre nous intéresse: lidentification du tiers ou le libellé de la transac
# afin d obtenir transaction@date@(-)montant@libellé
# on veut la concaténer à la ligne en construction.
# on remet donc chaine wip dans lespace en cours de construction:
x
# on charge cette id du tiers à la suite de cette chaine, séparee par un \n:
N
# on refait un coup de nettoyage
s/\n/@/g
# on ne veut pas de la chaine "Name of payee or Transaction description |"
s/Name of payee or transaction description|//
# on ne veut pas non plus de check number. on le remplace par N°:
s/Check number|/n°/
# on veut : comme séparateur
s/@/:/g

# et finalement.... on imprime!
p
}
' 

}
#############################################################
# 4. méler les deux fichiers en préfixant chaque entree de compta ou bq
#    et produire un contenu trié par montant puis par date puis par bq ou compta
###############################################################





###################################################################
# 4. afficher les lignes presentant les memes soldes en cpta et bq
###################################################################
# bah. 1 lister les soldes uniques 2 greper .. simple.
# recuperer les montants

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
#debecho "\$\@ vaut : $@"
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


# obtenir un fichier contenant uniquement les champs d un utilisateur
function filtre_getlinesfromuser(){
UTIL="$1"
gawk -v util="$UTIL" -F: "\$2 == util"
}


# test du concept
# cat compta.txt |getlinesfromuser "co" |getonlybanq 
# getmontantope    := getmontants  #TODO: trier !!!
# => getmontants compta.txt
# getmontantopé bq.txt # TODO: trier !!!
# cat $(montants bq) $(montants cpta) | sort -n.... | uniq
# filtrer par montant <montant> bq
# filtrer par montant <montant> cpta



# trie les champs par ordre croissant de valeur
# pour permettre ensuite une élimination ligne par ligne
#TODO debut du chantier
# DONE fonction tri numerique par val csste
# fonction tri numerique par date

#DONE tr en here_doc



function triparmontant(){
FONCTION=$FUNCNAME
function usage(){
cat << EOD
"$FONCTION <fichier>"
"tri par ordre numerique croissant"
"selon la valeur de l operation"
"but: pour une meme periode"
"on espere que cela permet d eliminer un maximum"
"d operations communes a bq et a compta"
EOD
}


aumoinsun "$@"
# nimporte lequel des sort numeriques fonctionne
# a partir du moment ou on fournit un
# prefixe LANG=C
# ainsi le separateur de virgule pour les flottants est "." sinon
# fr_FR.utf8-> ","
LANG=C sort --numeric-sort \
    --key="6" \
    --field-separator=":"\
    "$@"
}
######################################################################
# 5. produire des opés sur les dates ds bq| mono util
# pour restreindre le rap bq à des opérations 
# postérieures au premier enregistrement du cpte de compta
##########################################################

#########################################################
# 6. produire des opés sur cpta pour effectuer les opérations 
# complémentaires EN CROYANT COMPLETEMENT LE CPTE BQ
# pour REMONTER LE TPS SUR LES COMPTES
###########################################################


