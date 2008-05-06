#!/usr/bin/perl -w
#
#
use strict;
use MIME::Lite::HTML;

my $PREFIX="/home/dmoreau/Documents/tan_update/";
my $EQUIPEMENT=$PREFIX."conf/equipement.txt";
my $TANIERE="/tmp/taniere.txt";
my $TANIERE_LOG="/tmp/taniere.log";
my $DATA_GP=$PREFIX."data";

# recupération des catégories
open (EQUIP,$EQUIPEMENT);
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




#system('wget http://www.kamikase.info/CCR/script/taniere_update.php -O /tmp/');
system("wget http://www.kamikase.info/CCR/script/taniere_update.log -O $TANIERE_LOG");
system("wget http://www.kamikase.info/CCR/script/taniere.txt -O $TANIERE");


foreach(@equip) {
	$_->{nombre} =`grep "$_->{nom}" $TANIERE | wc --lines`;
	chop($_->{nombre});
}


# ecriture du fichier de donnée pour gnuplot
open(FILE,">>$DATA_GP");
foreach(@equip) {
	print FILE "$_->{nombre}\t";
}
print FILE "\n";
close(FILE);


# génere une courbe par catégorie
my $i = 0;
foreach(@equip) {
	$i++;
	my $name = $_->{nom};
	$name =~ s/\s/_/g;
	open(SIMU,'>/tmp/.simu');
	print SIMU "set style data lp\n";
	print SIMU "set xlabel 'Update'\n";
	print SIMU "set ylabel 'Nombre'\n";
	print SIMU "set ter png\n";
	print SIMU "set out '/tmp/$name.png'\n";
	print SIMU "plot '$DATA_GP' using $i title '$_->{nom}'\n"; 
	close(SIMU);
	system('gnuplot /tmp/.simu');
}
# latex
#
my $date=`date`;
open(LATEX,'>/tmp/report.tex');

print LATEX "\\documentclass[12pt,a4paper]{article}\n";
print LATEX "\\usepackage[french]{babel}\n";
print LATEX "\\usepackage[utf8]{inputenc}\n";
print LATEX "\\usepackage{times}\n";
print LATEX "\\usepackage{amsfonts}\n";
print LATEX "\\usepackage{amssymb}\n";
print LATEX "\\usepackage{graphicx}\n";
print LATEX "\\usepackage{float}\n";
print LATEX "\\usepackage{listings}\n";

print LATEX "\\date{\\today}\n";
print LATEX "\\author{script taniere.pl}\n";
print LATEX "\\title{Mise à jour de la tanière}\n";
print LATEX "\\begin{document}\n";

print LATEX "\\maketitle\n";
print LATEX "\\cleardoublepage\n";

print LATEX "\\tableofcontents\n";
print LATEX "\\cleardoublepage\n";

print LATEX "\\section{Résumé}\n";
print LATEX "\\begin{itemize}\n";
foreach(@equip) {
	print LATEX "\\item $_->{nom} : $_->{nombre}\n";
}
print LATEX "\\end{itemize}\n";

print LATEX "\\section{Log}\n";
print LATEX "\\begin{lstlisting}[frame=single, breaklines=true, numbers=left]\n";
open(LOG,"$TANIERE_LOG");
while(<LOG>) {
	print LATEX "$_\n";
}
close(LOG);
print LATEX "\\end{lstlisting}\n";

print LATEX "\\section{Statistiques}\n";
foreach(@equip) {
	my $name = $_->{nom};
	$name =~ s/\s/_/g;
	print LATEX "\\subsection{$_->{nom}}";
	print LATEX "\\begin{figure}[H]\n";
	print LATEX "\\centering\n";
	print LATEX "\\includegraphics[scale=0.5]{/tmp/$name.png} \n";
	print LATEX "\\end{figure}\n";
}

print LATEX "\\end{document}\n";


close(LATEX);

system('pdflatex /tmp/report.tex');
system('pdflatex /tmp/report.tex');



my $msg = new MIME::Lite 
From    =>'cmoidavid@gmail.com', 
To      =>'cmoidavid@gmail.com',          
Subject =>"Mise à jour de la tanière - $date",
Type    =>'TEXT',   
Data    =>"";


attach $msg
	Type =>'application/pdf',
	Path =>'/home/dmoreau/report.pdf',
	Filename =>'report.pdf'; 

$msg -> send;

# clean
system('rm /tmp/taniere_update.php*');
system("rm $TANIERE_LOG*");
system("rm $TANIERE");
system("rm /tmp/.simu");
system("rm /tmp/*.png");
