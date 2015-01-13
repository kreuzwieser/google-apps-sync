# Tomas Kreuzwieser <kreuzwieser@ro.vutbr.cz>, 2014, 2015
package Monitoring;

use strict;
use Time::HiRes qw(gettimeofday);
use parent qw/Exporter/;
use Term::ANSIColor;

our @EXPORT = qw/monitoring2 debug/;

# monitoring structure
my $monitoring = ();

# simple profilling
# first run for each message = start, second = print elapsed time
sub monitoring2
{
    my ($message) = @_;

    my ($seconds, $microseconds) = gettimeofday();
    if ((defined $monitoring) && (defined $monitoring->{$message}))
    {
	my $stime = ($seconds - $monitoring->{$message}->{seconds}) * 1000000 + $microseconds - $monitoring->{$message}->{microseconds};
	debug(sprintf("%s...done (%d.%06d s)", $message, int($stime/1000000), $stime - int($stime/1000000)), 'yellow')
    }
    else
    {
	$monitoring->{$message} = { seconds => $seconds, microseconds => $microseconds };
	debug($message, 'yellow')
    }
}

# print colored text for testing purposes
sub debug
{
    my ($par, $color, $visible) = @_;

    if ((!defined $visible) || $visible)
    {
	print color $color;
	print $par;
	print color 'reset';
	print "\n";
    }
}

1;
