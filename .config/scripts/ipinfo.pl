#!/usr/bin/perl

use List::Util qw[min max];

my $info = `ip addr`;

sub cidrToSubmask {
	my ($nbits) = @_;
	my @mask = ();
	for (my $i = 0; $i < 4; $i++) {
		my $n = min($nbits, 8);
		push @mask, (256 - 2**(8 - $n));
		$nbits -= $n;
	}
	return join(".", @mask);
}

while ($info =~ /(^\S.*\Wstate UP\W(?:.*\n(?!\S))*)/gm) {
	
	my $section = $1;
	
	my ($dev) = ( $section =~ /^\d: ([a-zA-Z0-9]+):/ );
	my ($inet4, $cidr4) = ( $section =~ /inet (\d{1,3}(?:.\d{1,3}){3})\/(\d+)/m );
	my $mask4 = cidrToSubmask($cidr4);
	my ($inet6, $cidr6) = ( $section =~ /inet6 (\S+:(?::\S+){4})\/(\d+)/m );
	my ($broadcast) = ( $section =~ /^\s*inet .*brd (\d{1,3}(?:.\d{1,3}){3})/m );

	print "Device: $dev $type", "\n";
	print "  inet: $inet4", "\n";
	print "  ├── netmask: $mask4 (CIDR: $cidr4)", "\n";
	print "  └── broadcast: $broadcast", "\n";
	print "  inet6: $inet6", "\n";
	print "  └── prefixlen: $cidr6", "\n";
	print "\n";

}

my $publicIp = `curl --max-time 3 https://ifconfig.me 2>/dev/null`;
print "Public IP: $publicIp", "\n";
