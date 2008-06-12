#!/usr/bin/perl -w
#
#
use strict;
use MIME::Lite::HTML;


# recupération des catégories
open (EQUIP,'conf/equipement.txt');
my @equip = ();
while(<EQUIP>) {
	chop($_);
	my %tmp = (
		nom => $_,
		nombre => 0
	);
	push(@equip, \%tmp);
}
close(EQUIP);




#system('wget http://www.kamikase.info/CCR/script/taniere_update.php');
system('wget http://www.kamikase.info/CCR/script/taniere.txt');


foreach(@equip) {
	$_->{nombre} =`grep "$_->{nom}" taniere.txt | wc --lines`;
	chop($_->{nombre});
}



# latex
#
my $date=`date`;
open(LATEX,'>report.tex');

print LATEX "\\documentclass[12pt,a4paper]{article}\n";
print LATEX "\\usepackage[french]{babel}\n";
print LATEX "\\usepackage[utf8]{inputenc}\n";
print LATEX "\\usepackage{palatino}\n";
print LATEX "\\usepackage{amsfonts}\n";
print LATEX "\\usepackage{amssymb}\n";
print LATEX "\\usepackage{graphicx}\n";
print LATEX "\\usepackage{float}\n";
print LATEX "\\usepackage{listings}\n";
print LATEX "\\begin{document}\n";

open(TAN,"taniere.txt");
while(<TAN>) {
	if(/Composant/) {
		my @explode = split(/;/, $_);
		my $name = $explode[4]." ".$explode[5]."\\\\\n";
		print LATEX "$name";
	}
}
close(TAN);

print LATEX "\\end{document}\n";
close(LATEX);
system('pdflatex report.tex');




my $data = "";
foreach(@equip) {
	$data .= "$_->{nom} : $_->{nombre}\n";
}


my $msg = new MIME::Lite 
From    =>'cmoidavid@gmail.com', 
To      =>'cmoidavid@gmail.com, jxing33@gmail.com, arnaud.marion.ldc@gmail.com',
Subject =>"Mise à jour de la tanière - $date",
Type    =>'TEXT',   
Data    =>"$data";

attach $msg
	Type =>'application/pdf',
	Path =>'report.pdf',
	Filename =>'report.pdf'; 

$msg -> send;

# clean
system('rm ./taniere_update.php*');
system('rm ./taniere.txt');
