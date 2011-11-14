#!/bin/bash
set -o nounset
. ./rapprochement_bancaire.sh

#####################
# compteur de tests
#####################
COMPTEUR=0

######################
# constantes
####################
TEST_OK="0"
TEST_KO="0"
TOT_TEST="0"
SUCCES="0"
PROG_PAS_INSTALLE=150
DEBUG=""
####################
# utilitaire
#####################
function debecho(){
if [ ! -z "$DEBUG" ]; then
	echo "$1" 1>&2
fi
}

function debexec(){
if [ ! -z "$DEBUG" ];
then eval "$@"
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

function incremente_compteur(){
export COMPTEUR=$((  $COMPTEUR + 1 ))
}
##################################
# les tests de fonctions de rapprochement_bancaire
#####################################


function test_getallnumcomptes(){
debecho "entree dans $FUNCNAME"	


#################
# utilitaires
#################
	function preload(){
cat << limitedefichier > temp
date:util:numcompte:nomcompte:sensope:montantope:libope
2011-09-05:co:512:"Banque":D:15138.55:"ouverture compte"
2011-09-05:co:101:"Capital social":C:15138.55:"ouverture compte"
2011-09-05:pu:512:"Banque":D:860.14:"ouverture compte"
2011-09-05:pu:101:"Capital social":C:860.14:"ouverture compte"
limitedefichier
	}

	function cleanup(){
rm -f temp
}

	
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

# lancement des tests
preload
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
cleanup
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
FONCTION="$FUNCNAME"
# un fichier de type compta.txt qui jouera le role d'env de test
function preload(){
cat << limitedefichier > temp
date:util:numcompte:nomcompte:sensope:montantope:libope
2011-09-05:co:512:"Banque":D:15138.55:"ouverture compte"
2011-09-05:co:101:"Capital social":C:15138.55:"ouverture compte"
2011-09-05:pu:512:"Banque":D:860.14:"ouverture compte"
2011-09-05:pu:101:"Capital social":C:860.14:"ouverture compte"
limitedefichier

cat << autrelimite > resultat
15138.55
15138.55
860.14
860.14
autrelimite
}

function cleanup(){
rm -f temp
rm -f resultat
}

function renvoie4lignes(){
debecho "entree dans $FUNCNAME"
F_CPTA="temp"
cat $F_CPTA |\
	# ligne suivante plus nécessaire: getmontantope tronque maintenant premiere ligne lui-meme
	#	sed -n '2,$ p'|\
	getmontantope -p |wc -l
	
}
function comptenblignes(){
debecho "entree dans $FUNCNAME"
F_CPTA="temp"
cat $F_CPTA |\
	sed -n '2,$ p' |wc -l

}

renvoie4lignesparam(){
F_CPTA="temp"
	getmontantope -f "$F_CPTA" |wc -l
# ce test prouve que le tronquage du fichier devrait se trouver dans getmontantope même:
# sinon il fonctionne qu'avec des wrappers
}
function invertmatchok(){
#echo doit renvoyer invert match fonctionne
grep --invert-match -E "[[:digit:].]" <<limite
123
34.3
invert match fonctionne
limite

}
function quedeschiffres(){
	F_CPTA="temp"

	RESULTAT="$(cat $F_CPTA |sed '1 s/.*$//' |getmontantope -p | grep --invert-match -E [[:digit:].])"
		
	}
	# lancement des tests

preload
# double emploi avec le test d'en dessous
#echo -e "$FUNCNAME en appel param normal doit renvoiyer les montants d'un fichier de type compta.txt \n $(COMMANDE='getmontantope -f temp'; echo "COMMANDE: $COMMANDE"; eval $COMMANDE)"
incremente_compteur
echo -e "$COMPTEUR $FUNCNAME en appel param normal doit renvoyer les valeurs attendues\n $(COMMANDE='$(getmontantope -f temp > tmp); diff -y --report-identical-files resultat tmp; ERR="$?"; rm tmp; affiche_test $ERR $SUCCES'; echo "COMMANDE: $COMMANDE"; eval $COMMANDE) "
incremente_compteur
echo -e "$COMPTEUR $FUNCNAME doit partir en message d'erreur si on ne lui fournit aucun param \n $(COMMANDE='getmontantope'; echo "COMMANDE: $COMMANDE"; eval "$COMMANDE")"
incremente_compteur
echo -e "$COMPTEUR $FUNCNAME doit partir en msg d'erreur si on appelle avec param -f mais sans fichier \n $(COMMANDE='getmontantope -f'; echo "COMMANDE: $COMMANDE"; eval "$COMMANDE")"
#renvoie4lignes
#comptenblignes
#invertmatchok
#renvoie4lignesparam
incremente_compteur
echo "$COMPTEUR besoin de vérifier la capacité de grep à pouvoir renvoyer les lignes ne matchant pas $(affiche_test "invert match fonctionne" "$(invertmatchok)")"
incremente_compteur
echo "$COMPTEUR $FONCTION envoi via pipe. nombre de montants extraits : autant que de lignes de donnees $(affiche_test "$(comptenblignes)" "$(renvoie4lignes)")"
incremente_compteur
echo "$COMPTEUR $FONCTION le champ selectionne est le bon s il ne comporte que des montants (chiffres et .) $(affiche_test "x$(quedeschiffres)" "x")"
incremente_compteur
echo "$COMPTEUR $FONCTION envoi via param. nombre de montants extraits : autant que de lignes de donnees $(affiche_test "$(comptenblignes)" "$(renvoie4lignesparam)")"

cleanup
}

function test_modifdateawk(){
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
















function test_encol_daterfc3339_to_enligne_precompta(){
FONCTION="${FUNCNAME}"
# fichier ofx --- ofxdump() --> fichier en colonnes --- modifdate awk() --> fichier en colonnes+ dates rfc-3339
# verifier que pour une entree de type fichier en colonnes +dates rfc-3339
# (format à préciser)
#  
# 1. les entetes 
# de 4 type. un seul type nous intéresse: ofx_prox_transaction
#ofx_proc_account():
#ofx_proc_statement():
#ofx_proc_status():
#ofx_proc_transaction():
	function test_nombre_lignes_produites(){
	BUTTEST="$FUNCNAME produit une ligne par transaction du fichier colonne"
	# cela nécessite la production d un fichier en colonnes +dates
	#	 

		function  wc_encol_daterfc3339_to_enligne_precompta_deuxlignes(){
encol_daterfc3339_to_enligne_precompta << inputvasuivre |wc -l 
ofx_proc_status():
Ofx entity this status is relevent to|SONRS 
Severity|INFO
Code|0, name: Success
Description|The server successfully processed the request.

ofx_proc_status():
Ofx entity this status is relevent to|STMTTRNRS 
Severity|INFO
Code|0, name: Success
Description|The server successfully processed the request.

ofx_proc_account():
Account ID|20041 01005 1081437V026
Account name|Bank account 1081437V026
Account type|CHECKING
Currency|EUR
Bank ID|20041
Branch ID|01005
Account #|1081437V026

ofx_proc_statement():
Currency|EUR
Account ID|20041 01005 1081437V026
Start date of this statement|Tue Jun 14 12:59:00 2011 CEST
End date of this statement|Fri Oct 14 11:59:00 2011 CEST
Ledger balance|14641.64
Available balance|14641.64

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|PAYMENT: Electronic payment
Date posted| 2011-10-10
Total money amount|-32.00
# of units|32.00
Unit price|1.00
Financial institution's ID for this transaction|PIXUY6LLLO
Name of payee or transaction description|PRELEVEMENT DE BOUYGUES TELECO

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|PAYMENT: Electronic payment
Date posted| 2011-10-10
Total money amount|-29.90
# of units|29.90
Unit price|1.00
Financial institution's ID for this transaction|PIXUY6LGYF
Name of payee or transaction description|PRELEVEMENT DE SA NORDNET
inputvasuivre
		} # fin wc_encol_daterfc3339_to_enligne_precompta_deuxlignes, tjs ds nombre_de_lignes


		function wc_grep_deuxlignes(){
grep 'ofx_proc_transaction()' << inputvasuivre |wc -l 
ofx_proc_status():
Ofx entity this status is relevent to|SONRS 
Severity|INFO
Code|0, name: Success
Description|The server successfully processed the request.

ofx_proc_status():
Ofx entity this status is relevent to|STMTTRNRS 
Severity|INFO
Code|0, name: Success
Description|The server successfully processed the request.

ofx_proc_account():
Account ID|20041 01005 1081437V026
Account name|Bank account 1081437V026
Account type|CHECKING
Currency|EUR
Bank ID|20041
Branch ID|01005
Account #|1081437V026

ofx_proc_statement():
Currency|EUR
Account ID|20041 01005 1081437V026
Start date of this statement|Tue Jun 14 12:59:00 2011 CEST
End date of this statement|Fri Oct 14 11:59:00 2011 CEST
Ledger balance|14641.64
Available balance|14641.64

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|PAYMENT: Electronic payment
Date posted| 2011-10-10
Total money amount|-32.00
# of units|32.00
Unit price|1.00
Financial institution's ID for this transaction|PIXUY6LLLO
Name of payee or transaction description|PRELEVEMENT DE BOUYGUES TELECO

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|PAYMENT: Electronic payment
Date posted| 2011-10-10
Total money amount|-29.90
# of units|29.90
Unit price|1.00
Financial institution's ID for this transaction|PIXUY6LGYF
Name of payee or transaction description|PRELEVEMENT DE SA NORDNET
inputvasuivre

		} #  fin de wc_grep_deuxlignes, tjs dans nombre de lignes
		echo "$FONCTION ${BUTTEST} $(affiche_test $(wc_encol_daterfc3339_to_enligne_precompta_deuxlignes) $(wc_grep_deuxlignes))"
} # fin de nombre de lignes








# on sort un format du type precompta.txt 
# c a d en ligne tq: 
# transaction@date@montant@libellé

# methode:
# fonctiondetest << limitedeheredoc
#  ligne d input
# autreligne d input
# fin de heredoc
# telle que l ouput soit une ligne unique.
# tester chaque cas attendu

# appels des fonctions produisant les résultats: les phrases devraient se trouver ici
test_nombre_lignes_produites
}


function test_ofx_to_encol(){
# on va pas tester la validité de ofxdump... trop long.
# on va juste vérifier que :
# 1 sans param ofx_to_encol envoie gentiment péter.
# 2 avec param mais pas ofx envoie msg err valable
# 3 avec fichier ofx valide renvoie fichier encol (faire semblant que bon) et MSG ERR "tt s est bien passé"
function preload(){
set +o nounset
cat <<limitedeofx >temp
OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE
<OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0<SEVERITY>INFO</STATUS><DTSERVER>20111104053200<LANGUAGE>FRE</SONRS></SIGNONMSGSRSV1><BANKMSGSRSV1><STMTTRNRS><TRNUID>1320381120334<STATUS><CODE>0<SEVERITY>INFO</STATUS><CLTCOOKIE>1320381120334<STMTRS><CURDEF>EUR<BANKACCTFROM><BANKID>20041<BRANCHID>01005<ACCTID>1081437V026<ACCTTYPE>CHECKING<ACCTKEY>45</BANKACCTFROM><BANKTRANLIST><DTSTART>20111018<DTEND>20111104<STMTTRN><TRNTYPE>DIRECTDEP<DTPOSTED>20111103<TRNAMT>-350.00<FITID>PIXUWALLQ_<NAME>VIREMENT POUR</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111102<TRNAMT>-15.73<FITID>PIXUMALLR5<NAME>ACHAT CB SUPER U        01.11.11</STMTTRN><STMTTRN><TRNTYPE>ATM<DTPOSTED>20111102<TRNAMT>-20.00<FITID>PIXUMALLEF<NAME>CARTE MASTERCA 31/10/11 A 12H38</STMTTRN><STMTTRN><TRNTYPE>DIRECTDEP<DTPOSTED>20111102<TRNAMT>1501.00<FITID>PIXUMAC$RO<NAME>VIREMENT DE LECLERE</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111031<TRNAMT>-23.93<FITID>PIXUVALNWF<NAME>ACHAT CB AUCHAN ENGLOS  29.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111031<TRNAMT>-5.44<FITID>PIXUVALLZR<NAME>ACHAT CB SUPERMARCHE MA 29.10.11</STMTTRN><STMTTRN><TRNTYPE>DIRECTDEP<DTPOSTED>20111031<TRNAMT>1542.20<FITID>PIXUVACAVO<NAME>VIREMENT DE DOMOVEIL SARL</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111028<TRNAMT>-15.61<FITID>PIXUKALLF5<NAME>ACHAT CB Hyper Service  27.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111025<TRNAMT>-63.03<FITID>PIXUJAL849<NAME>ACHAT CB AUCHAN DRIVE I 23.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111025<TRNAMT>-25.47<FITID>PIXUJALH8F<NAME>ACHAT CB AUCHAN ENGLOS  24.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111021<TRNAMT>-9.98<FITID>PIXU2ALLUZ<NAME>ACHAT CB SUPERMARCHE MA 20.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111021<TRNAMT>-8.80<FITID>PIXU2ALLLP<NAME>ACHAT CB CASTORAMA      20.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111020<TRNAMT>-16.58<FITID>PIXUSAL%FF<NAME>ACHAT CB HYPERSERVIC BV 18.10.11</STMTTRN><STMTTRN><TRNTYPE>ATM<DTPOSTED>20111020<TRNAMT>-10.00<FITID>PIXUSALLL3<NAME>CARTE MASTERCA 19/10/11 A 18H59</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111018<TRNAMT>-63.54<FITID>PIXUOALYU9<NAME>ACHAT CB AUCHAN DRIVE I 16.10.11</STMTTRN><STMTTRN><TRNTYPE>POS<DTPOSTED>20111018<TRNAMT>-37.50<FITID>PIXUOALGRO<NAME>ACHAT CB DR BATAILLE MI 17.10.11</STMTTRN></BANKTRANLIST><LEDGERBAL><BALAMT>16603.58<DTASOF>20111103</LEDGERBAL><AVAILBAL><BALAMT>16603.58<DTASOF>20111103</AVAILBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>

limitedeofx
set -o nounset

cat <<autrelimite > pasunofx
unelighe
uneautre
autrelimite

touch fichiervide
}


function cleanup(){
rm -f temp
rm -f pasunofx
rm -f fichiervide
}

function ofxdump_tempfile_for_diff(){


ofx_to_encol temp 2>/dev/null
ERR="$?"
debecho "en fonctionnement normal ofx_to_encol produit le msg err ${ERR}"

return ${ERR}
} # fin de ofxdump_tempfile_for_diff	
############################
# APPELS DES FONCTIONS DE TEST
###############################
: <<BLOCCOMMENTE
debecho " l'appel suivant ne marche pas. ofxdump ne semble pas voir qu'on lui passe du contenu sous forme de pipe "
debexec ofxdump_REFUSES_REDIRECTION_NEEDS_ARG_encol_for_diff
debecho " pourtant la syntaxe est correcte . preuve :"
debexec essai_de_heredoc
debecho "conclusion : ofxdump semble vérifier la présence d un nom de fichier en argument."
debecho "sera résolu plus tard. pour l instant construction fichier temporaire et d un wrapper: ofx_to_encol"
BLOCCOMMENTE
preload
incremente_compteur
echo "$COMPTEUR $FUNCNAME appel param. normal. val d'err ${SUCCES}? $(COMMANDE="ofxdump_tempfile_for_diff"; echo "COMMANDE: $COMMANDE"; RESULTAT=$($COMMANDE); ERR=$?; affiche_test ${ERR} ${SUCCES})"
incremente_compteur
echo "$COMPTEUR $FUNCNAME 2. appel param. pas d'arg. alors qu'exigé. val d'err $ERR_NB_PARAM? $(COMMANDE="ofx_to_encol"; echo "COMMANDE: $COMMANDE"; RES=$($COMMANDE); ERR="$?"; affiche_test ${ERR} ${ERR_NB_PARAM})"
incremente_compteur
echo -e "$COMPTEUR $FUNCNAME 3. appel param. param=<nom de fichier inexistant>. msg=fichier <bidule> existe pas?  \n $(COMMAND='ofx_to_encol qsdfdsf |tee -a resultat ; echo -e "ERR: ofx_to_encol: le fichier qsdfdsf n\x27existe pas" > attendu; echo "ofx_to_encol <fichier.ofx> -> fichier encol" >> attendu; diff -y --report-identical-files resultat attendu; export ERREUR="$?"; rm -f resultat; rm -f attendu'; echo "COMMAND: $COMMAND"; eval "$COMMAND"; affiche_test ${ERREUR} ${SUCCES})"
incremente_compteur
echo -e "$COMPTEUR $FUNCNAME 3bis appel param. param=<nom de fichier inexistant>. va retour err= $ERR_FICHIER_EXISTEPAS?; $(RES="$(ofx_to_encol qsdfdsf)"; ERR="$?"; affiche_test $ERR $ERR_FICHIER_EXISTEPAS;)"
incremente_compteur
echo -e "$COMPTEUR $FUNCNAME 4.appel param.=<non  vide pas ofx>. val retour err= $ERR_PAS_OFX? \n $(COMMANDE='RES=$(ofx_to_encol pasunofx); export ERRI="$?"'; echo "COMMANDE: $COMMANDE"; eval "$COMMANDE"; affiche_test ${ERRI} ${ERR_PAS_OFX})"
incremente_compteur
echo "$COMPTEUR $FUNCNAME 5. (vide)->encol => noanofx $ERR_PAS_OFX $(COMMANDE='RES="$(ofx_to_encol fichiervide)"; export ERRO="$?"; '; echo "COMMANDE: $COMMANDE"; eval "$COMMANDE"; affiche_test ${ERRO} ${ERR_FICHIER_VIDE})"


cleanup
}

function test_unetunseul(){
FONCTION="fonctionbidon"
function usage(){
echo "fonction usage ecrite uniquement pour le test de unetunseul"
}
echo "$FUNCNAME () => ERR ${ERR_NB_PARAM}  $(PREMIERTEST=$(unetunseul); RES=$?; affiche_test ${ERR_NB_PARAM} ${RES})"  
#unetunseul
}

function test_incremente_compteur(){
for i in $(seq -s ' ' 1 10);
do
 echo "COMPTEUR: $COMPTEUR"
 incremente_compteur
done
}


function test_fichier_doit_etre_non_vide(){
touch essai
incremente_compteur
RES=$(fichier_doit_etre_non_vide essai); ERR="$?"
echo "$COMPTEUR $FUNCNAME lanchement de fichier_doit_etre_non_vide sur un fichier vide renvoie val $ERR_FICHIER_VIDE $(affiche_test ${ERR} ${ERR_FICHIER_VIDE})"
#echo "TODO: $FUNCNAME "
rm essai

}

function test_journalmultiu_to_extraitgl_monou_monoc(){


function preload(){
cat <<fin_entree > resultat_voulu
date:util:numcompte:nomcompte:sensope:montantope:libope
2011-09-05:co:512:"Banque":D:15138.55:"ouverture compte"
2011-09-05:co:512:"Banque":C:55.71:"courses alimentaires"
2011-09-05:co:512:"Banque":C:7.01:"courses alimentaires"
2011-09-10:co:512:"Banque":C:20:"retrait pour frites et cafés"
2011-09-15:co:512:"Banque":C:32:"Télécom FT - fa 0320376880 11G5 2B05 - cheque 1494015f carnet 26969"
2011-09-15:co:512:"Banque":C:35.09:"EDF pmt fa 011E111629025 cheque 1494016g carnet 26969"
2011-09-15:co:512:"Banque":C:36.53:"pmt fa GDF n° f508755733577 par chq n° 1494017a carnet 26969"
2011-09-17:co:512:"Banque":C:15.63:"achat essence sandero"
2011-09-19:co:512:"Banque":C:55.55:"rhodes - voiture - pmt assurance + réservation voiture"
fin_entree



cat <<limite_entree > entree_de_test
date:util:numcompte:nomcompte:sensope:montantope:libope
2011-09-05:co:512:"Banque":D:15138.55:"ouverture compte"
2011-09-05:co:101:"Capital social":C:15138.55:"ouverture compte"
2011-09-05:pu:512:"Banque":D:860.14:"ouverture compte"
2011-09-05:pu:101:"Capital social":C:860.14:"ouverture compte"
2011-09-05:co:6257:"frais restauration":D:55.71:"courses alimentaires"
2011-09-05:co:512:"Banque":C:55.71:"courses alimentaires"
2011-09-05:co:6257:"frais restauration":D:7.01:"courses alimentaires"
2011-09-05:co:512:"Banque":C:7.01:"courses alimentaires"
2011-09-10:co:530:"Caisse":D:20:"retrait pour frites et cafés"
2011-09-10:co:512:"Banque":C:20:"retrait pour frites et cafés"
2011-09-07:pu:530:"Caisse":D:20:"retrait pour alimenter caisse"
2011-09-07:pu:512:"Banque":C:20:"retrait pour alimenter caisse"
2011-09-10:co:6257:"Frais restauration":C:3.70:"pmt caisse frites"
2011-09-10:co:530:"Caisse":D:3.70:"pmt caisse frites"
2011-09-07:pu:6234:"Cadeaux":C:10:"pmt  cai 10E cadeau france"
2011-09-07:pu:530:"Caisse":D:10:"pmt  cai 10E cadeau france"
2011-09-10:pu:6257:"Frais restauration":D:2.60:"pmt caisse tomates"
2011-09-10:pu:530:"Caisse":C:2.60:"pmt caisse tomates"
2011-09-10:pu:6257:"Frais restauration":D:5.91:"pmt caisse carrefour market saucisses + oeufs"
2011-09-10:pu:530:"Caisse":C:5.91:"pmt caisse carrefour market saucisses + oeufs"
2011-09-12:pu:6257:"Frais restauration":D:36.23:"pmt CB auchan englos"
2011-09-12:pu:512:"Banque":C:36.23:"pmt CB auchan englos"
2011-09-12:pu:6257:"Frais restauration":D:16.71:"pmt CB match"
2011-09-12:pu:512:"Banque":C:16.71:"pmt CB match"
2011-09-15:co:6261:"Frais postaux et télécom - ligne fixe FT":D:32:"Télécom FT"
2011-09-15:co:512:"Banque":C:32:"Télécom FT - fa 0320376880 11G5 2B05 - cheque 1494015f carnet 26969"
2011-09-15:co:411IOUPC:"IOU - Puce doit à Co - Créance cpt co":D:16:"1/2 Télécom FT"
2011-09-15:co:79161:"Transfert de charges d\'exploit -partage FT en deux":C:16:"1/2 Télécom FT"
2011-09-15:pu:655561:"Quote part de charges sur opé communes - 1/2 FT":D:16:"charge reportée par co - 1/2 Télécom FT"
2011-09-15:pu:401IOUPC:"IOU - Puce doit à co - dette cpte pu":C:16:"dette envers co - 1/2 Télécom FT"
2011-09-15:co:60611:"achat fourniture non stockable (énergie -EDF)":D:35.09:"EDF"
2011-09-15:co:512:"Banque":C:35.09:"EDF pmt fa 011E111629025 cheque 1494016g carnet 26969"
2011-09-15:co:411IOUPC:"IOU - Puce doit à co - créance sur compte cl":D:17.5:"report charge vers pu - 1/2 EDF "
2011-09-15:co:791162:"Transfert de charges d\'exploit - partage EDF ":C:17.5:"1/2 EDF"
2011-09-15:pu:65555EDF:"Quote part de charges sur opé communes - 1/2 EDF":D:17.5:"charge reportée par co -1/2 EDF"
2011-09-15:pu:411IOUPC:"IOU - puce doit à co - Dette sur compte pu":C:17.5:"dette envers co - 1/2 EDF"
2011-09-15:co:60612:"achat fourniture non stockable (energie - GDF)":D:36.53:"1/2 EDF"
2011-09-15:co:512:"Banque":C:36.53:"pmt fa GDF n° f508755733577 par chq n° 1494017a carnet 26969"
2011-09-15:co:411IOUPC:"IOU - Puce doit à co - créance compte co":D:36.53:"créance sur pu 1/2 GDF"
2011-09-15:co:791163:"Transfert de charges d'exploit - partage GDF":C:36.53:"report charge vers pu 1/2 GDF"
2011-09-15:pu:401IOUPC:"IOU - Puce doit à co - GDF":C:36.53:"1/2 GDF"
2011-09-15:pu:65555GDF:"Quote part de charges sur opés communes - 1/2 GDF":D:36.53:"charge reportée par co - 1/2 GDF"
2011-09-15:co:6257:"frais restauration":D:7.5:"pmt caisse cafés"
2011-09-15:co:530:"Caisse":C:7.5:"pmt caisse cafés"
2011-09-17:co:6248:"transport - divers - carburant ":D:15.63:"achat essence sandero"
2011-09-17:co:512:"Banque":C:15.63:"achat essence sandero"
2011-09-17:pu:6257:"frais restauration":D:8.57:"achat jus pruneau leclerc bailleul"
2011-09-17:pu:530:"Caisse":C:8.57:"achat jus pruneau leclerc bailleul"
2011-09-19:co:6251:"Voyages et déplacements":D:17.05:"rhodes - réservation voiture"
2011-09-19:co:6251:"Voyages et déplacements":D:100.90:"rhodes - voiture - à payer sur site"
2011-09-19:co:616:"Primes d'assurance":D:38.50:"rhodes - voiture - rachat de franchise"
2011-09-19:co:512:"Banque":C:55.55:"rhodes - voiture - pmt assurance + réservation voiture"
limite_entree
}

function cleanup(){
rm -f resultat_voulu
rm -f entree_de_test

}


function normal(){
journalmultiu_to_extraitgl_monou_monoc -u co -c 512 -g entree_de_test > mouais
diff -y --report-identical-files mouais resultat_voulu; ERR=$?
rm -f mouais
return "$?"

}
#####################
# lancement des tests
#####################
preload
normal


cleanup

}






function test_modifdate(){
#modifdate
# entreeofx -- ofx_to_encol --> entree_encol --  modifdate --> entree_encol-date_rfc3339
# il me faut donc :
# une entree de type encol
# une sortie de type encol_date3339

function preload(){
set +o nounset
cat <<encol > encol
ofx_proc_status():
    Ofx entity this status is relevent to: SONRS 
    Severity: INFO
    Code: 0, name: Success
    Description: The server successfully processed the request.

ofx_proc_status():
    Ofx entity this status is relevent to: STMTTRNRS 
    Severity: INFO
    Code: 0, name: Success
    Description: The server successfully processed the request.

ofx_proc_account():
    Account ID: 20041 01005 1081437V026
    Account name: Bank account 1081437V026
    Account type: CHECKING
    Currency: EUR
    Bank ID: 20041
    Branch ID: 01005
    Account #: 1081437V026

ofx_proc_statement():
    Currency: EUR
    Account ID: 20041 01005 1081437V026
    Start date of this statement: Tue Oct 18 12:59:00 2011 CEST
    End date of this statement: Fri Nov  4 10:59:00 2011 CET
    Ledger balance: 16603.58
    Available balance: 16603.58

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: DIRECTDEP: Direct deposit
    Date posted: Thu Nov  3 10:59:00 2011 CET
    Total money amount: -350.00
    # of units: 350.00
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUWALLQ_
    Name of payee or transaction description: VIREMENT POUR

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Wed Nov  2 10:59:00 2011 CET
    Total money amount: -15.73
    # of units: 15.73
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUMALLR5
    Name of payee or transaction description: ACHAT CB SUPER U        01.11.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: ATM: ATM debit or credit (Note: Depends on signage of amount)
    Date posted: Wed Nov  2 10:59:00 2011 CET
    Total money amount: -20.00
    # of units: 20.00
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUMALLEF
    Name of payee or transaction description: CARTE MASTERCA 31/10/11 A 12H38

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: DIRECTDEP: Direct deposit
    Date posted: Wed Nov  2 10:59:00 2011 CET
    Total money amount: 1501.00
    # of units: -1501.00
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUMAC$RO
    Name of payee or transaction description: VIREMENT DE LECLERE

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Mon Oct 31 10:59:00 2011 CET
    Total money amount: -23.93
    # of units: 23.93
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUVALNWF
    Name of payee or transaction description: ACHAT CB AUCHAN ENGLOS  29.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Mon Oct 31 10:59:00 2011 CET
    Total money amount: -5.44
    # of units: 5.44
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUVALLZR
    Name of payee or transaction description: ACHAT CB SUPERMARCHE MA 29.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: DIRECTDEP: Direct deposit
    Date posted: Mon Oct 31 10:59:00 2011 CET
    Total money amount: 1542.20
    # of units: -1542.20
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUVACAVO
    Name of payee or transaction description: VIREMENT DE DOMOVEIL SARL

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Fri Oct 28 11:59:00 2011 CEST
    Total money amount: -15.61
    # of units: 15.61
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUKALLF5
    Name of payee or transaction description: ACHAT CB Hyper Service  27.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Tue Oct 25 11:59:00 2011 CEST
    Total money amount: -63.03
    # of units: 63.03
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUJAL849
    Name of payee or transaction description: ACHAT CB AUCHAN DRIVE I 23.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Tue Oct 25 11:59:00 2011 CEST
    Total money amount: -25.47
    # of units: 25.47
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUJALH8F
    Name of payee or transaction description: ACHAT CB AUCHAN ENGLOS  24.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Fri Oct 21 11:59:00 2011 CEST
    Total money amount: -9.98
    # of units: 9.98
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXU2ALLUZ
    Name of payee or transaction description: ACHAT CB SUPERMARCHE MA 20.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Fri Oct 21 11:59:00 2011 CEST
    Total money amount: -8.80
    # of units: 8.80
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXU2ALLLP
    Name of payee or transaction description: ACHAT CB CASTORAMA      20.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Thu Oct 20 11:59:00 2011 CEST
    Total money amount: -16.58
    # of units: 16.58
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUSAL%FF
    Name of payee or transaction description: ACHAT CB HYPERSERVIC BV 18.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: ATM: ATM debit or credit (Note: Depends on signage of amount)
    Date posted: Thu Oct 20 11:59:00 2011 CEST
    Total money amount: -10.00
    # of units: 10.00
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUSALLL3
    Name of payee or transaction description: CARTE MASTERCA 19/10/11 A 18H59

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Tue Oct 18 11:59:00 2011 CEST
    Total money amount: -63.54
    # of units: 63.54
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUOALYU9
    Name of payee or transaction description: ACHAT CB AUCHAN DRIVE I 16.10.11

ofx_proc_transaction():
    Account ID : 20041 01005 1081437V026
    Transaction type: POS: Point of sale debit or credit (Note: Depends on signage of amount)
    Date posted: Tue Oct 18 11:59:00 2011 CEST
    Total money amount: -37.50
    # of units: 37.50
    Unit price: 1.00
    Financial institution's ID for this transaction: PIXUOALGRO
    Name of payee or transaction description: ACHAT CB DR BATAILLE MI 17.10.11
encol


cat <<rfc > rfc
ofx_proc_status():
Ofx entity this status is relevent to|SONRS 
Severity|INFO
Code|0, name: Success
Description|The server successfully processed the request.

ofx_proc_status():
Ofx entity this status is relevent to|STMTTRNRS 
Severity|INFO
Code|0, name: Success
Description|The server successfully processed the request.

ofx_proc_account():
Account ID|20041 01005 1081437V026
Account name|Bank account 1081437V026
Account type|CHECKING
Currency|EUR
Bank ID|20041
Branch ID|01005
Account #|1081437V026

ofx_proc_statement():
Currency|EUR
Account ID|20041 01005 1081437V026
Start date of this statement|Tue Oct 18 12:59:00 2011 CEST
End date of this statement|Fri Nov  4 10:59:00 2011 CET
Ledger balance|16603.58
Available balance|16603.58

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|DIRECTDEP: Direct deposit
Date posted| 2011-11-03
Total money amount|-350.00
# of units|350.00
Unit price|1.00
Financial institution's ID for this transaction|PIXUWALLQ_
Name of payee or transaction description|VIREMENT POUR

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-11-02
Total money amount|-15.73
# of units|15.73
Unit price|1.00
Financial institution's ID for this transaction|PIXUMALLR5
Name of payee or transaction description|ACHAT CB SUPER U        01.11.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|ATM: ATM debit or credit (Note: Depends on signage of amount)
Date posted| 2011-11-02
Total money amount|-20.00
# of units|20.00
Unit price|1.00
Financial institution's ID for this transaction|PIXUMALLEF
Name of payee or transaction description|CARTE MASTERCA 31/10/11 A 12H38

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|DIRECTDEP: Direct deposit
Date posted| 2011-11-02
Total money amount|1501.00
# of units|-1501.00
Unit price|1.00
Financial institution's ID for this transaction|PIXUMAC$RO
Name of payee or transaction description|VIREMENT DE LECLERE

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-31
Total money amount|-23.93
# of units|23.93
Unit price|1.00
Financial institution's ID for this transaction|PIXUVALNWF
Name of payee or transaction description|ACHAT CB AUCHAN ENGLOS  29.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-31
Total money amount|-5.44
# of units|5.44
Unit price|1.00
Financial institution's ID for this transaction|PIXUVALLZR
Name of payee or transaction description|ACHAT CB SUPERMARCHE MA 29.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|DIRECTDEP: Direct deposit
Date posted| 2011-10-31
Total money amount|1542.20
# of units|-1542.20
Unit price|1.00
Financial institution's ID for this transaction|PIXUVACAVO
Name of payee or transaction description|VIREMENT DE DOMOVEIL SARL

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-28
Total money amount|-15.61
# of units|15.61
Unit price|1.00
Financial institution's ID for this transaction|PIXUKALLF5
Name of payee or transaction description|ACHAT CB Hyper Service  27.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-25
Total money amount|-63.03
# of units|63.03
Unit price|1.00
Financial institution's ID for this transaction|PIXUJAL849
Name of payee or transaction description|ACHAT CB AUCHAN DRIVE I 23.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-25
Total money amount|-25.47
# of units|25.47
Unit price|1.00
Financial institution's ID for this transaction|PIXUJALH8F
Name of payee or transaction description|ACHAT CB AUCHAN ENGLOS  24.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-21
Total money amount|-9.98
# of units|9.98
Unit price|1.00
Financial institution's ID for this transaction|PIXU2ALLUZ
Name of payee or transaction description|ACHAT CB SUPERMARCHE MA 20.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-21
Total money amount|-8.80
# of units|8.80
Unit price|1.00
Financial institution's ID for this transaction|PIXU2ALLLP
Name of payee or transaction description|ACHAT CB CASTORAMA      20.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-20
Total money amount|-16.58
# of units|16.58
Unit price|1.00
Financial institution's ID for this transaction|PIXUSAL%FF
Name of payee or transaction description|ACHAT CB HYPERSERVIC BV 18.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|ATM: ATM debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-20
Total money amount|-10.00
# of units|10.00
Unit price|1.00
Financial institution's ID for this transaction|PIXUSALLL3
Name of payee or transaction description|CARTE MASTERCA 19/10/11 A 18H59

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-18
Total money amount|-63.54
# of units|63.54
Unit price|1.00
Financial institution's ID for this transaction|PIXUOALYU9
Name of payee or transaction description|ACHAT CB AUCHAN DRIVE I 16.10.11

ofx_proc_transaction():
Account ID |20041 01005 1081437V026
Transaction type|POS: Point of sale debit or credit (Note: Depends on signage of amount)
Date posted| 2011-10-18
Total money amount|-37.50
# of units|37.50
Unit price|1.00
Financial institution's ID for this transaction|PIXUOALGRO
Name of payee or transaction description|ACHAT CB DR BATAILLE MI 17.10.11
rfc
set -o nounset
} # fin de preload

function cleanup(){
rm -f encol
rm -f rfc

} # fin de cleanup
function normal(){
modifdate encol > atester
diff -y --report-identical-files rfc atester

rm -f atester
} # fin de normal


preload
normal
cleanup
}



function TEST(){
#############################
# tests en cours de mise au point 
#############################

test_modifdate
# getallnumcomptes sera testé correctement lorsque son utilité sera prouvée
#test_getallnumcomptes
# test_errsipasbq sera testé correctement lorsque son utilité sera prouvée
#test_errsipasbq
# test montant opé paramétrisé ok
# test montant opé les tests sont sous forme de heredoc
#test_getmontantope
#test_modifdateawk
#test_getlinesfromuser
#test_getallusers
#test_triparmontant
#test_encol_daterfc3339_to_enligne_precompta
###############################
# tests non satisfaisants
##############################
#test_unetunseul
#test_incremente_compteur


########################
# tests satisfaisants
########################
# incremente_compteur; echo "$COMPTEUR grep doit exister $(verifie_existence_binaires grep)"
# incremente_compteur; echo "$COMPTEUR sed doit exister $(verifie_existence_binaires sed)"
# incremente_compteur; echo "$COMPTEUR gawk doit exister $(verifie_existence_binaires gawk)"
# incremente_compteur; echo "$COMPTEUR ofxdump doit exister $(verifie_existence_binaires ofxdump)"

#test_journalmultiu_to_extraitgl_monou_monoc
# test_ofx_to_encol
# test_fichier_doit_etre_non_vide
}
TEST
