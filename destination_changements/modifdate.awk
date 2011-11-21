#!/bin/bash
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
