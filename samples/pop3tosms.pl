#!/usr/bin/perl -w
#Copyright (c) 2001 Giulio Motta. All rights reserved.
#http://www-sms.sourceforge.net/
#This program is free software; you can redistribute it and/or
#modify it under the same terms as Perl itself.

######################################################################
### Cron this job on a server to have a SMS alert when you receive ###
### an e-mail (you'll love getting SPAM!) ;)                       ###
######################################################################

use Net::POP3;
use WWW::SMS;

my $server = 'my_pop_server';
my $username = 'username';
my $password = 'password';
my $gateway = 'a_working_gateway';
my $intpref = 'intpref'; #without the initial '+', please
my $opprefix = 'opprefix';
my $phonenumber = 'phonenumber';

my ($subject, $from);

open(IN, "< messages.txt");
while (<IN>) {
	chomp;
	$oldmsg{$_} = 1;
}
close(IN);

my $pop = Net::POP3->new($server);

(my $mail = $pop->login($username, $password)) || die "Can't connect to $server\n";

%uid = %{$pop->uidl()};

@msgid = values %uid;
@msgnum = keys %uid;

for (my $i=0; $i < $mail; $i++) {
	unless (exists $oldmsg{$msgid[$i]}) {
		$mailH = join ('', @{$pop->top($msgnum[$i])} );
		($mailH =~ /^From: (.+)/m) && ($from = $1);
		($mailH =~ /^Subject: (.+)/m) && ($subject = $1);
		my $sms = WWW::SMS::new
			($intpref, $opprefix, $phonenumber, "New message from $from - $subject\n")
		$sms->send($gateway) || print $WWW::SMS::Error;
	}
}

$pop->quit();

open(OUT, "> messages.txt");
	print OUT join("\n", @msgid);
close(OUT);
