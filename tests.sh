#!/bin/bash
set -o nounset
. ./rapprochement_bancaire.sh
######################
# constantes
####################
TEST_OK="0"
TEST_KO="0"
TOT_TEST="0"
SUCCES="0"
PROG_PAS_INSTALLE=150
####################
# utilitaire
#####################
function debecho(){
if [ ! -z "$DEBUG" ]; then
	echo "$1" 1>&2
fi
}



function affiche_test(){
if [ "$1" == "$2" ];
then
	echo "[OK]";
else 
	echo "[KO]";
fi
}
DEBUG=""



function verifie_existence_binaires(){
resultat="$(which $1)"
err="$?"
cmdepasinstallee="1"
if [ "$err" == "$SUCCES" ];
then
	echo "[OK]"

else
	if [ "$err" == "$cmdepasinstallee" ];
	then
		echo "[KO] $resultat $1 pas installe . je vais maintenant sortir avec une val d erreur $PROG_PAS_INSTALLE"
		exit $PROG_PAS_INSTALLE	
	fi
fi
}

function test_getallnumcomptes(){
debecho "entree dans $FUNCNAME"	
	
	
	# TODO: pb premiere ligne pas compte
	function getallnumcompte_withfilename(){
		TEST_VIDE_SI_alnum="$(getallnumcomptes $1 |tr '\n' ' ' |(LANG=C grep -v -E [[:alnum:]]))"
		#	debecho "test_vide_si_alnum vaut : ${TEST_VIDE_SI_alnum}"
		affiche_test "x${TEST_VIDE_SI_alnum}" "x" 
			}


	function getallnumcompte_withoutfilename(){
		TEST_VIDE_SI_alnum=$(getallnumcomptes | tr '\n' ' ' |grep -v -E [[:alnum:]])
		affiche_test "x${TEST_VIDE_SI_alnum}" "x" 
			}


echo "$FUNCNAME doit renvoyer des numéros de comptes si parse compta.txt passé en param normal $(getallnumcompte_withfilename compta.txt)"
echo "$FUNCNAME doit renvoyer des numéros de compts si parase bq_trie.txt passé en param normal $(getallnumcompte_withfilename bq_trie.txt)"
echo "$FUNCNAME doit renvoyer des numéros de compte si parse compta.txt passé en param < $(getallnumcompte_withoutfilename  <compta.txt)"
echo "$FUNCNAME doit renvoyer des numéros de compte si fichier passé en heredoc"
getallnumcompte_withoutfilename <<findefichier
date:util:numcompte:nomcompte:sensope:montantope:libope
2011-09-05:co:512:"Banque":D:15138.55:"ouverture compte"
2011-09-05:co:101:"Capital social":C:15138.55:"ouverture compte"
2011-09-05:pu:512:"Banque":D:860.14:"ouverture compte"
2011-09-05:pu:101:"Capital social":C:860.14:"ouverture compte"
2011-09-05:co:6257:"frais restauration":D:55.71:"courses alimentaires"
findefichier

}









function test_errsipasbq(){
F_CPTA="compta.txt"
F_BQ="bq_trie_sans_prem_ligne.txt"
FONCTION="$FUNCNAME"
function fail_cptpasbq(){
	#FAIL VOLONTAIRE OK
		
	RESULTAT="$(err_sinumcompte_pasbq "compta.txt")"; ERR="$?"
	echo "$FONCTION: si num compte pas bq alors msg err 200 $(affiche_test \"${ERR}\" \"200\")"
	}

	function fail_aintfile(){
	#FAIL VOLONTAIRE OK

	RESULTAT="$(err_sinumcompte_pasbq "sqmfldqjkfjsld")"; ERR="$?";
		echo "$FONCTION:  doit renvoyer msg erreur ${ERR_FICHIER_EXISTEPAS} si fichier existe pas $(affiche_test \"${ERR}\" \"${ERR_FICHIER_EXISTEPAS}\")"

			}	


	function succes_onlybq(){

	
	#err_sinumcompte_pasbq <$F_CPTA
	RESULTAT="$(err_sinumcompte_pasbq "$F_BQ")"; ERR="$?"
	echo "$FONCTION doit sortir sur une valeu de succes $SUCCES si ts les nums de comptes valent 512 $(affiche_test \"${ERR}\"   \"${SUCCES}\")"

	}
fail_cptpasbq
fail_aintfile
succes_onlybq
}

function test_getmontantope(){
## verif que bon champ
RESULTAT="$(cat $F_CPTA |sed '1 s/.*$//' |getmontantope |tr '\n' ' '| grep --invert-match -E [[:digit:].])"

echo "$FUNCNAME doit ne renvoyer que des chiffres $(affiche_test "x${RESULTAT}" "x")"

}

function test_modifdate(){
debecho "entree dans $FUNCNAME"
verifie_existence_binaires "ofxdump"

	
	echo "$FUNCNAME les champs <Date posted> sont au format rfc-3339=date"
	

	
#	modifdateawk
#truc et astuce : rendre disponible la fonction affiche_test au subshell via declare -fx affiche_test
# parametrage de debecho:
# vide pour pouvoir le param à 1
# rendre disponible debecho
declare -x DEBUG=""
declare -f -x debecho
# parametrage de affiche_test:
# j'ai besoin d'une valeur pour succes
# j ai besoin de rendre disponible affiche_test
declare -x SUCCES="0"
declare -f -x affiche_test

# commentaires sur xargs:
# - pas de -t car cela fait afficher la commande avant de la lancer
# - pas de -d " " car les sorties de gawk sont séparées par des \n. tant que pas de jeu avec tr, 
modifdateawk |grep "Date posted" | sed 's/ //g' | gawk -F'|' '{print $2;}' | xargs -i sh -u -c 'RESULTAT="$(date -d {} --rfc-3339="date" | grep --only-matching -E "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}")"; ERR="$?"; debecho "ERR vaut ${ERR}"; debecho "SUCCES vaut ${SUCCES}"; affiche_test "${ERR}" "${SUCCES}" |tr "\n" " " '
echo " "
}

function test_getlinesfromuser(){

PREMIER="$(cat compta.txt |filtre_getlinesfromuser "co" |wc -l)"
DEUXIEME="$(cat compta.txt |getallusers |grep "co" |wc -l)"
echo "$FUNCNAME avec pour param co produit le m nb de lignes que chp util restreint à co $(affiche_test $PREMIER $DEUXIEME)"
# okay
}


# tests sur triparmontant
# 1. verif de la sortie avec usage
# en cas d'absence de param
function test_triparmontant(){



echo "$FUNCNAME doit exiger au moins un param $(RES="$(triparmontant)"; ERR="$?"; affiche_test ${ERR} ${ERR_NB_PARAM})"
# ok
# 2. lancement avec un fichier et verif de la sortie par ordre croissant en utilisant sort.
ERR_PAS_TRIE="1"
TRI_OK="0"
echo "$FUNCNAME : test du test: si ens trié, un ensemble trie doit donner un msg err de val ${TRI_OK} $(CMD=$(triparmontant compta.txt | getmontantope |(LANG=C sort --check --numeric-sort)); ERR=$? ; affiche_test ${ERR} ${TRI_OK} )"

echo "$FUNCNAME : test du test: si ens non trié, un ensemble non trie doit donner un msg err de val ${ERR_PAS_TRIE} $(CMD=$(getmontantope compta.txt |(LANG=C sort --check --numeric-sort 2>sort.err)); ERR=$? ; affiche_test ${ERR} ${ERR_PAS_TRIE})"
}
# ok

#TDD: fonction existant pas
function test_getallusers(){
#vérif cohérence facile: util ne peut valoir que co ou pu pour l instant
# le nb de lignes matchées vaut donc le nb de  lignes totales
PREMIER="$(cat compta.txt|getallusers |wc -l)"
DEUXIEME="$(cat compta.txt |getallusers |grep --only-matching -E 'co|pu' |wc -l)"
echo "$FUNCNAME : les val de champs sont soit co soit pu $(affiche_test $PREMIER $DEUXIEME)"
}

function test_sedenligne(){
# verifier que pour une entree de type ofxdump
# (format à préciser)

# on sort un format du type
# transaction@date@montant@libellé

# methode:
# fonctiondetest << limitedeheredoc
#  ligne d input
# autreligne d input
# fin de heredoc
# telle que l ouput soit une ligne unique.
# tester chaque cas attendu
echo "$FUNCNAME : TODO"

}
function TEST(){
echo "grep doit exister $(verifie_existence_binaires grep)"
echo "sed doit exister $(verifie_existence_binaires sed)"
echo "gawk doit exister $(verifie_existence_binaires gawk)"
echo "ofxdump doit exister $(verifie_existence_binaires ofxdump)"
test_getallnumcomptes
test_errsipasbq
test_getmontantope
test_modifdate
test_getlinesfromuser
test_getallusers
test_triparmontant
test_sedenligne
}
TEST
