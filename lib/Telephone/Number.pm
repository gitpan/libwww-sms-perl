#Copyright (c) 2001 Giulio Motta. All rights reserved.
#http://www-sms.sourceforge.net/
#This program is free software; you can redistribute it and/or
#modify it under the same terms as Perl itself.

package Telephone::Number;

$VERSION = '0.05';

use Carp;

sub new {
	my $class = shift;
	croak "Wrong number of parameters" unless (grep {$_ == @_} (1, 3));
	my $self;
	$_ = shift;
	s/^\+// unless (ref);
	($_, @_) = &parse_number($_) if (@_ == 0);
	$self = bless {
			intpref => $_,
			prefix => shift,,
			telnum => shift,
		} , $class;
	$self;
}

sub fits {
	my ($tn, $setn) = @_;
	for (keys %{$tn}) {
		next unless (defined $setn->{$_});
		return 0 unless (
			is_in($tn->{$_}, (
					  ref $setn->{$_} 
					  ? @{$setn->{$_}} 
					  : $setn->{$_}
					 ) 
			     )
		);
	}
	1;
}

sub whole_number {
	my $tn = shift;
	return $tn->{intpref} . $tn->{prefix} . $tn->{telnum};
}

sub parse_number {
	my $tn = shift;
	my ($key, @arr, @prefixes, $intpref, $prefix, $telnum);

	while (<DATA>) {
		next if (/^#/);
		if (/^(\d+)/ && $tn =~ /^($1)/) {
			chomp;
			@arr = split;
			shift @arr;
			push @prefixes, @arr;
			$intpref ||= $1;
		}
	}
	
	seek (DATA, 0, 0);
	
	unless ($intpref) {
		carp "No matching international prefix found";
		return (undef, undef, $tn);
	}
	
	$tn = substr($tn, length($intpref));

	for (sort { length($b) <=> length($a) } @prefixes) {
		if ($tn =~ /^$_/) {
			$prefix = $_;
			$telnum = substr($tn, length);
			last;
		}
	}
	
	unless ($prefix) {
		carp "No matching mobile phone provider found";
		$telnum = $tn;
	}

	return ($intpref, $prefix, $telnum);
}

sub is_in {
	$_ = shift;
	for $regexp (@_) {
		return 1 if (/^$regexp$/); 
	}
	return 0;
}


1;

__DATA__
#Bulgaria
359 88 87
#Finland
358 40 50 41
#France
33 6
#Germany
49 151 160 170 171 175 162 152 1520
49 172 173 174 163 177 178 176 179
#Italy
39 333 334 335 338 339 330 336 337 360 368 340 347 348 349 328 329 380 388 389
#Russia
7 901 903 902 910
#Spain
34 600 605 606 607 608 609 610 615 616 617 619 620 626 627 629 630 636 637 639
34 646 647 649 650 651 652 653 654 655 656 657 658 659 660 661 662 666 667 669
34 670 676 677 678 679 680 686 687 689 690 696 697 699
#United Kingdom
44 370 374 378 385 401 402 403 410 411 421 441 467 468 498 585 589 772 780 798 
44 802 831 836 850 860 966 973 976 4481 4624 7000 7002 7074 7624 7730 7765 7771
44 7781 7787 7866 7939 7941 7956 7957 7958 7961 7967 7970 7977 7979 8700 9797