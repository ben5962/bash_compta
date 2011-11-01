#!/bin/bash
. ./rapprochement_bancaire.sh
######################
# constantes
####################
TEST_OK=0
TEST_KO=0
TOT_TEST=0
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
DEBUG="1"

function test_getallnumcomptes(){
debecho "entree dans $FUNCNAME"	
	
echo "essai de la fonction de récup des comptes sur compta.txt"
	# TODO: pb premiere ligne pas compte
	function getallnumcompte_withfilename(){
	TEST_VIDE_SI_alnum="$(getallnumcomptes $1 |tr '\n' ' ' |(LANG=C grep -v -E [[:alnum:]]))"
#	debecho "test_vide_si_alnum vaut : ${TEST_VIDE_SI_alnum}"
	affiche_test "x${TEST_VIDE_SI_alnum}" "x" 
		}

getallnumcompte_withfilename "compta.txt"
echo " "
echo "essai de la fonction de récup des comptes sur bq.txt"
#getallnumcomptes <$F_BQ
getallnumcompte_withfilename "bq_trie.txt"
echo " "
#echo "essai de cette fonction en pas a pas pour comprendre"
#getallnumcomptes "bq_trie.txt" |grep -v -E [[:alnum:]]

echo " "
echo "essai avec un pipe sans filename en param"

function getallnumcompte_withoutfilename(){
TEST_VIDE_SI_alnum=$(getallnumcomptes | tr '\n' ' ' |grep -v -E [[:alnum:]])
	affiche_test "x${TEST_VIDE_SI_alnum}" "x" 

}
getallnumcompte_withoutfilename  <compta.txt
echo " "
echo "essai avec un heredoc"
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
	function fail_cptpasbq(){
	#FAIL VOLONTAIRE OK
	echo " "
	echo " "
	echo " "
	echo "test des err pas512"
	echo "essai de err_sipas512 sur le fichier compta qui comporte d autres numcomptes"
	echo "le test réussit si la sortie de la commande vaut 200"
	RESULTAT="$(err_sinumcompte_pasbq "compta.txt")"; ERR="$?"
	affiche_test "${ERR}" "200"
	}

	function fail_aintfile(){
	#FAIL VOLONTAIRE OK
	echo "test de fichier pas existant"
	RESULTAT="$(err_sinumcompte_pasbq "sqmfldqjkfjsld")"; ERR="$?";
	affiche_test "${ERR}" "${ERR_FICHIER_EXISTEPAS}"
	}	


	function succes_onlybq(){
	echo "test de non-sortie sur des valeurs correctes de fichier compta |512"
	echo "le test réussit si la valeur de sortie est 0"
	#err_sinumcompte_pasbq <$F_CPTA
	RESULTAT="$(err_sinumcompte_pasbq "$F_BQ")"; ERR="$?"
	affiche_test "${ERR}" "${SUCCES}"
	echo "fin du test de non-sortie. toujours là? oui? on continue!"
	}
fail_cptpasbq
fail_aintfile
succes_onlybq
}

function test_getmontantope(){
## verif que bon champ
echo " "
echo " "
echo "verif du bon fonctionnement de getmontantope"
echo " le test reussit si cela affiche des chiffres"
RESULTAT="$(cat $F_CPTA |sed '1 s/.*$//' |getmontantope |tr '\n' ' '| grep -v -E [[:digit:].])"
affiche_test "x${RESULTAT}" "x"
echo " "
# ok
#ok


}

function test_modifdate(){
debecho "entree dans $FUNCNAME"
if [ "$TEST" == "1" ]; then 
	echo "essai de modifdate.awk transforme en fonction"
	echo "tous les champs <Date posted> sont censés avoir leur date transformée selon rfc-3339=date"
	echo "si date reconnait la date alors c est bon"
	modifdateawk |grep "Date posted" | sed 's/ //g' | gawk -F'|' '{print $2;}' | tr '\n' ' ' |xargs -d " " -i -t date -d {}
fi
}
if [ "$TEST" == "1" ]
then
	echo "TEST lancement de cat compta.txt| filtre_getlinesfromuser co"
	echo "pour verifier que les lignes affichees ne contiennent que l util co"
	echo "le test est RATE si des champs s affichent"

cat compta.txt |filtre_getlinesfromuser "co" |grep -v "co"
        echo "meme test mais en comptant les lignes contenant co"
	echo "le test est RATE si le resultat est nul"
cat compta.txt |filtre_getlinesfromuser "co" |wc -l
fi
# okay

# tests sur triparmontant
# 1. verif de la sortie avec usage
# en cas d'absence de param
if [ "${TESTERR}" == "1" ];
then
echo "TESTERR vaut ${TESTERR}"
echo "TESTERR: triparmontant lancé sans param pour tester msg err manque param"
triparmontant 
fi
# ok
# 2. lancement avec un fichier et verif de la sortie par ordre croissant en utilisant sort.
if [ "$TEST"=="1" ];
then
	echo "TEST: triparmontant lancé avec un fichier compta.txt pour vérif tri par montant croissant"
	echo "le test fonctionne si le resultat est une suite croissante"
	triparmontant compta.txt | getmontantope |(LANG=C sort --check --numeric-sort)
	echo "résultat : $?"
	#TODO echo "si n a rien sorti c est bon: pour sort c est trie"
	echo "pour verifier la veracite du test meme chose avec du nontrie"
	echo "sort renvoie la premiere valeur non triee et sa ligne"
	getmontantope compta.txt |(LANG=C sort --check --numeric-sort )
	echo "résultat : $?"
	echo " "
fi
# ok
function TEST(){
test_getallnumcomptes
test_errsipasbq
test_getmontantope
test_modifdate
}
TEST
