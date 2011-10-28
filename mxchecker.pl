#!/usr/bin/perl
# mxchecker.pl                                    Copyright(c) 2011 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net

BEGIN {
    unshift @INC, '/usr/local/cpanel';
}

use Cpanel::Email::MX ();
use Whostmgr::DNS::MX ();
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

################################
my $VERSION = 1.00;

################################
# handle cli args
my ( $domain, $user, $debug, $verbose, $help );

GetOptions(
    'verbose'  => \$verbose,
    'user=s'   => \$user,
    'domain=s' => \$domain,
    'debug'    => \$debug,
    'help|?'   => \$help,
    'man'      => \$man
) or pod2usage( { -output => \*STDERR, -exitval => 2, -verbose => 1 } );

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

#################################
# validation
if ( !$domain ) {
    pod2usage( { -output => \*STDERR, -msg => "No domain specified.", -exitval => 2, -verbose => 1 } );
}
elsif ($debug) {
    print "\n=============================================\n";
    print "Checking MX records for $domain";
    print "\n=============================================\n";
}

if ( !$user ) {

    # We require a $user because under certain circumstances, namely an "auto" defined routing,
    # unnecessary write to the cpuser file will occur (though, it shouldn't be detrimental).
    pod2usage( { -output => \*STDERR, -msg => "No user specified. This is a require of this utility.", -exitval => 2, -verbose => 1 } );
}
elsif ($debug) {
    print "\n=============================================\n";
    print "Optimizing call with user '$user'";
    print "\n=============================================\n";
}

################################
# get a hash of mx data from zone records
my $zone = $domain . '.db';

my %mxdata = Whostmgr::DNS::MX::fetchmx($zone);

if ( !%mxdata ) {
    print STDERR "Could not retrieve stored MX data related to $domain\n" if $debug;
    exit(1);
}
elsif ($debug) {
    print "\n=============================================\n";
    print "Zone Data:\n";
    print Dumper \%mxdata;
    print "\n=============================================\n";
    print "\n=============================================\n";
    print "The raw value of 'alwaysaccept' is '$mxdata{'alwaysaccept'}'\n";
    print "The raw value of 'mxcheck' is '$mxdata{'mxcheck'}'";
    print "\n=============================================\n";
}

################################
# optimize the call by retrieving the expected, normalized value for 'alwaysaccept'
my $alwaysaccept = Cpanel::Email::MX::get_mxcheck_configuration( $domain, $user );

################################
# finally, get the the calculated value
# override the logger's info method to stop superfluous output
my $mx_values;
{
    local *Cpanel::Logger::info = sub { return; };
    $mx_values = Whostmgr::DNS::MX::checkmx( $domain, $mxdata{'entries'}, $alwaysaccept );
}
if ($debug) {
    print "\n=============================================\n";
    print "Calculated MX routing:\n";
    print Dumper $mx_values;
    print "\n=============================================\n";
}

################################
# OUTPUT: simple string or sentence result  output

if ($verbose) {
    my ( $set, $status, $method, $warnings ) = Cpanel::Email::MX::get_mxcheck_messages( $domain, $mx_values );
    print "$status\n$method\n";
}
else {
    print $mx_values->{'detected'} . "\n";
}
exit();

__END__

=head1 NAME

mxchecker - Utility script for detecting what MX routing logic will be used by cPanel for a given domain.

=head1 VERSION

Version 1.00

=head1 SYNOPSIS

mxchecker.pl [options] -domain=[fqdn.tld] -user=[cpuser]

  Options:
    -domain          domain to reference
    -user            account for domain
    -verbose         output similar to WHM
    -debug           debug output of data structures
    -help            brief help message
    -man             full documentation

=head1 OPTIONS

=over

=item B<-domain>

Specify which domain's MX records to reference.

=item B<-user>

Specify the cPanel account name that owns the domain.

=item B<-verbose>

I<optional> Produce output similar to that rendered by WHM's "Edit MX Entry" interface.

=item B<-debug>

I<optional> Output dumps of the various data structures that are used to produce the final output.
This option requires C<Data::Dumper> to be in your Perl path.

=item B<-help>

I<optional> Print a brief help masasge and exits.

=item B<-man>

I<optional> Full documentation for this utility.

=back

=head1 DESCRIPTION

F<mxchecker.pl> is designed as a simple CLI utility for custom MX applications on the cPanel web hosting platform.
It is a very close approximation of the I<read> operations performed within WHM's "Edit MX Entry" interface.

Because cPanel allows an administrator to select C<auto> when defining MX routing, it becomes problematic when a 
non-cpanel process needs to determine if a given domain's MX will receive C<local> or C<remote> handling.

=head1 OUTPUT

Normal output will be one of three values:

=over

=item I<local>

Mail will be accepted and delivered locally.

=item I<secondary>

Mail will be accepted locally, but not delivered.

=item I<remote>

Mail will be remotely delivered.

=back

If I<-verbose> is passed then a human, English string will be output.  This message string is equvalent to that produced in WHM's 
"Edit MX Entry" interface after saving the configuration.

If I<-debug> is passed, C<Data::Dumper> will be used to dump the data structures that are used to evaluate the MX routing logic.

If I<-domain> or I<-user> is omitted, the I<-help> option, along with a note,
will be sent to C<STDERR> and the script will C<exit(2)>.
No output will be send to C<STDOUT>. 

=head1 AUTHOR

David Neimeyer C<< <davidneimeyer@cpanel.net> >>

=head1 LICENSE & COPYRIGHT

Copyright (c) 2011, cPanel, Inc. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
=cut

