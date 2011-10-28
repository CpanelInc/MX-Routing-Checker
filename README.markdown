# NAME

mxchecker - Utility script for detecting what MX routing logic will be used by cPanel for a given domain.

# VERSION

Version 1.00

# SYNOPSIS

mxchecker.pl [options] -domain=[fqdn.tld] -user=[cpuser]

# OPTIONS

- __-domain__

Specify which domain's MX records to reference.

- __-user__

Specify the cPanel account name that owns the domain.

- __-verbose__

_optional_ Produce output similar to that rendered by WHM's "Edit MX Entry" interface.

- __-debug__

_optional_ Output dumps of the various data structures that are used to produce the final output.
This option requires `Data::Dumper` to be in your Perl path.

- __-help__

_optional_ Print a brief help masasge and exits.

- __-man__

_optional_ Full documentation for this utility.

# DESCRIPTION

`mxchecker.pl` is designed as a simple CLI utility for custom MX applications on the cPanel web hosting platform.
It is a very close approximation of the _read_ operations performed within WHM's "Edit MX Entry" interface.

Because cPanel allows an administrator to select `auto` when defining MX routing, it becomes problematic when a 
non-cpanel process needs to determine if a given domain's MX will receive `local` or `remote` handling.

# OUTPUT

Normal output will be one of three values:

- _local_

Mail will be accepted and delivered locally.

- _secondary_

Mail will be accepted locally, but not delivered.

- _remote_

Mail will be remotely delivered.

If _-verbose_ is passed then a human, English string will be output.  This message string is equvalent to that produced in WHM's 
"Edit MX Entry" interface after saving the configuration.

If _-debug_ is passed, `Data::Dumper` will be used to dump the data structures that are used to evaluate the MX routing logic.

If _-domain_ or _-user_ is omitted, the _-help_ option, along with a note,
will be sent to `STDERR` and the script will `exit(2)`.
No output will be send to `STDOUT`. 

# AUTHOR

David Neimeyer `<davidneimeyer@cpanel.net>`

# LICENSE & COPYRIGHT

Copyright (c) 2011, cPanel, Inc. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See [perlartistic](http://search.cpan.org/perldoc?perlartistic).

# DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
=cut