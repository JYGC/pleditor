#!/usr/bin/perl
#
# Copyright (c) 2014, Junying Chen
#
# This file is released under the Artistic License-2.0

use warnings;

exit &main();

sub main(){

	my $filename=$ARGV[0];
	my $uin;
	my @u;

	&banner();

	while(1){
		print "main: ";
		$uin=<STDIN>;
		chomp($uin);
		@u=split(/;/, $uin);

		if($u[0] eq "w"){
			&write_mode(
				$filename,
				$u[1],
				$u[2]
			);
		}elsif($u[0] eq "r"){
			&read_mode(
				$filename,
				$u[1],
				$u[2]
			);
		}elsif($u[0] eq "t"){
			&translate_mode(
				$filename,
				$u[1],
				$u[2]
				);
		}elsif($u[0] eq "q"){
			return 0;
		}
	}
	
	return 1;
}

sub banner(){
	print STDOUT "Copyright (c) 2014, Junying Chen\n";
	print STDOUT "This software is released under the Artistic License.\n\n";
	print STDOUT "Thank you for using 'pelditor-1.0', a crappy knockoff of the more famous and better text editor 'ed'. 'pelditor' is written in perl so it's much slower then 'ed'. :D:D:D\n";
}

sub write_mode(){

	my $line;
	my $linenum;
	my $startline;
	my $endline;
	my $filename	=shift;
	my @filebuffer	=&get_filecontent($filename);
	if(@filebuffer){
		$startline	=do{
			my $arg=shift;
			chomp($arg);
			$arg=~/^\d+\z/ ? $arg : $#filebuffer+2
		};
		$endline	=do{
			my $arg=shift;
			chomp($arg);
			$arg=~/^\d+\z/ ? $arg : 'inf'
		};
	}else{
		$startline	=1;
		$endline	='inf';
	}

	$linenum=$startline-1;

	do{
		print STDOUT "write: ";
		$line=<STDIN>;
		if($line ne "\e\n"){
			if($filebuffer[$linenum]){
				$filebuffer[$linenum]=$line;
			}else{
				push(@filebuffer,$line);
			}
		}
		$linenum++;
	}while($line ne "\e\n" && $linenum < $endline);

	&write_tofile(\@filebuffer,$filename);

}

sub read_mode(){

	my $i;
	my $line;
	my $linenum;

	my $filename	=shift;
	my @filebuffer	=&get_filecontent($filename);
	my $startline	=do{
		my $arg=shift;
		chomp($arg);
		$arg=~/^\d+\z/ ? $arg : 1
	};
	my $endline	=do{
		my $arg=shift;
		chomp($arg);
		$arg=~/^\d+\z/ ? $arg : $#filebuffer+1
	};

	for(
		$i=$startline-1;
		$i<=$endline-1;
		$i++
	){
		$linenum=$i+1;
		print STDOUT "$linenum.\t$filebuffer[$i]";
	}
}

sub translate_mode(){
	
	my $i;
	my $linenum;
	my $increment;
	my $stopline;
	my $translation;
	
	my $filename	=shift;
	my @filebuffer	=&get_filecontent($filename);
	my $oldrefline	=shift;
	my $newrefline	=do{
		my $arg=shift;
		chomp($arg);
		$arg=~/^\d+\z/ ? $arg : $oldrefline
	};
	
	$translation=$newrefline-$oldrefline;
	
	if($translation > 0){
		$linenum	=$#filebuffer;
		$increment	=-1;
		$stopline	=$oldrefline-2;
	}elsif($translation < 0){
		$linenum	=$oldrefline-1;
		$increment	=1;
		$stopline	=$#filebuffer+1;
	}else{
		return 0;
	}
	
	print STDOUT $linenum . $increment . $stopline . "\n";
	
	if($translation > 0){
		for(
			$i	=1;
			$i	<=$translation;
			$i++
		){
			push(@filebuffer,"");
		}
	}
	
	print STDOUT $#filebuffer . "\n";

	do{
		$filebuffer[
			$linenum+$translation
		]=$filebuffer[$linenum];
		$linenum+=$increment;
	}while($linenum != $stopline); ####stop here####
	
	if($translation < 0){
		for(
			$i	=1;
			$i	<=$translation;
			$i++
		){
			pop(\@filebuffer);
		}
	}
	
	print STDOUT $#filebuffer . "\n";
	
	&write_tofile(\@filebuffer,$filename);
	
}

sub write_tofile(){
	my ($filebuf,$filename)=@_;
	my @filebuffer=@$filebuf;

	open(FILE, ">", $filename);
	print FILE @filebuffer;
	close(FILE);
}

sub get_filecontent(){

	my @filebuffer;
	my $line;
	my $linenum=0;

	my $filename=shift;

	open(FILE, "<", $filename);
	while($line=<FILE>){
		push(@filebuffer,$line);
		$linenum++;
	}
	close(FILE);

	return @filebuffer;
}
