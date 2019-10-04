#!/usr/bin/perl

my $info = `ip addr`;

# Get the nth line in a string. 
sub nthLine {
	my ($text, $n) = (@_);
	$n--;
	if ($text =~ /(?:^[^\n]*\n){$n}([^\n]*)/m) {
		return $1;
	}
	return undef;
}

sub trim {
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s 
}

while ($info =~ /(^\S.*\Wstate UP\W(?:.*\n(?!\S))*)/gm) {

	my $line = trim(nthLine($1, 1));
	my @atoms = split(/\s+/, $line);
	my $dev = substr($atoms[0], 0, length($atoms[0]) - 1);

	$line = trim(nthLine($1, 3));
	@atoms = split(/\s+/, $line);
	my $inet = $atoms[1];
	my $mask = $atoms[3];
	my $broadcast = $atoms[3];

	$line = trim(nthLine($1, 7));
	@atoms = split(/\s+/, $line);
	my $inet6 = $atoms[1];

	$line = trim(nthLine($1, 2));
	my ($type) = ( $line =~ /(\(.*\)$)/ );

	print "Device: $dev $type", "\n";
	print "\tinet: $inet", "\n";
	print "\tinet6: $inet6", "\n";
	# print "\tnetmask: $mask", "\n";
	print "\tbroadcast: $broadcast", "\n";
	print "\n";

}

my $publicIp = `curl --max-time 3 https://ident.me/ 2>/dev/null`;
print "Public IP: $publicIp", "\n";
