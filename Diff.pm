# Tomas Kreuzwieser <kreuzwieser@ro.vutbr.cz>, 2014, 2015
package Diff;

use strict;
use Data::Dumper;
#use Data::Compare;
#use Data::MessagePack;
use Storable;

$Data::Dumper::Terse = 1; # don't output names where feasible.
$Data::Dumper::Sortkeys = 1;

sub deduplicate_array
{
    my ($array) = @_;
    my @d_array = do {my %seen; grep { !$seen{$_}++ } @$array};

    return \@d_array;
}

sub sort_array
{
    my ($pk, $array) = @_;

    return sort { $a->{$pk} cmp $b->{$pk} } @$array;
}

sub compare_structures
{
    my ($d1, $d2) = @_;

    my $dumper = sub {
	my ($data) = @_;
	return JSON::XS->new->canonical->allow_nonref->encode($data);
	#return Dumper($data);
    };

    my $comparing = (&$dumper($d1) eq &$dumper($d2));

    return $comparing;
}

sub update_arguments
{
    my ($a, $b, $arguments_part) = @_;

    my $new_arguments_part = Storable::dclone($arguments_part);

    $new_arguments_part->{DEPTH} = $new_arguments_part->{DEPTH} + 1;
    push @{$new_arguments_part->{REFER_ARRAY}}, $_;
    push @{$new_arguments_part->{REFER_TYPES}}, ref($a->{$_});

    return $new_arguments_part;
}

sub compare_and_process
{
    my $a = shift;
    my $b = shift;
    my $callbacks  = shift || {};
    my $transforms = shift || {};
    my $arguments  = shift || {};

    my $callback_match     = $callbacks->{MATCH}     || sub { my ($pk, $a, $b, $callbacks, $transforms, $arguments, $operation) = @_; printf("(depth %d) %s\n%s => %s\n", $arguments->{CL}->{DEPTH}, $operation, $pk, Dumper($a->{$pk})) };
    my $callback_discard_a = $callbacks->{DISCARD_A} || sub { my ($pk, $a, $b, $callbacks, $transforms, $arguments, $operation) = @_; printf("(depth %d) %s\n%s => %s\n", $arguments->{CL}->{DEPTH}, $operation, $pk, Dumper($a->{$pk})) };
    my $callback_discard_b = $callbacks->{DISCARD_B} || sub { my ($pk, $a, $b, $callbacks, $transforms, $arguments, $operation) = @_; printf("(depth %d) %s\n%s => %s\n", $arguments->{CL}->{DEPTH}, $operation, $pk, Dumper($b->{$pk})) };
    my $callback_change    = $callbacks->{CHANGE}    || sub { my ($pk, $a, $b, $callbacks, $transforms, $arguments, $operation) = @_; printf("(depth %d) %s\n%s => %sTO\n%s => %s\n", $arguments->{CL}->{DEPTH}, $operation, $pk, Dumper($a->{$pk}), $pk, Dumper($b->{$pk})) };

    my $transform_a        = $transforms->{TRANSFORM_A} || sub { return shift() };
    my $transform_b        = $transforms->{TRANSFORM_B} || sub { return shift() };

    # initialize arguments for recursion changes
    $arguments->{MAX_DEPTH} = 10  if (!defined $arguments->{MAX_DEPTH});
    $arguments->{A}         = $a  if (!defined $arguments->{A});
    $arguments->{B}         = $b  if (!defined $arguments->{B});

    if (!defined $arguments->{CL}->{DEPTH})
    {
	my @current_refer_array = ();
	my @current_refer_types = ();
	$arguments->{CL}->{REFER_ARRAY} = \@current_refer_array;
	$arguments->{CL}->{REFER_TYPES} = \@current_refer_types;
	$arguments->{CL}->{DEPTH} = 0;
    }

    foreach (keys %$a)
    {
	if (!defined ($b->{$_}))
	{
	    &$callback_discard_a($_, $a, $b, $callbacks, $transforms, $arguments, 'DISCARD_A');
	}
	else
	{
	    if (compare_structures(&$transform_a($a->{$_}), &$transform_b($b->{$_})))
	    {
		&$callback_match($_, $a, $b, $callbacks, $transforms, $arguments, 'MATCH');
	    }
	    else
	    {
		if (((ref($a->{$_}) eq "HASH") && (ref($b->{$_}) eq "HASH")) && (($arguments->{CL}->{DEPTH} + 1 ) <= $arguments->{MAX_DEPTH}))
		{
		    my $thislevel = $arguments->{CL};
		    $arguments->{CL} = update_arguments($a, $b, $arguments->{CL});
		    compare_and_process($a->{$_}, $b->{$_}, $callbacks, $transforms, $arguments);
		    $arguments->{CL} = $thislevel;
		}
		else
		{
		    &$callback_change($_, $a, $b, $callbacks, $transforms, $arguments, 'CHANGE');
		}
	    }
	}
    }

    foreach (keys %$b)
    {
	if (!defined ($a->{$_}))
	{
	    &$callback_discard_b($_, $a, $b, $callbacks, $transforms, $arguments, 'DISCARD_B');
	}
    }
}

1;
