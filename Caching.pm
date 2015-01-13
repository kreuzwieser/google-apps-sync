# Tomas Kreuzwieser <kreuzwieser@ro.vutbr.cz>, 2014, 2015
# only for Google apps sync
package Caching;

use strict;
use JSON;
use File::Path qw(make_path);
use parent qw/Exporter/;
use Monitoring;

our @EXPORT = qw/load_scopes_from_cache save_scopes_to_cache load_scopes_from_cache_dir save_scopes_to_cache_dir get_data_from_json_file/;

my $CACHE_DIRECTORY = "cache";

sub load_scopes_from_cache
{
    my ($file) = @_;

    return get_data_from_json_file((defined $file) ? $file : "cache.json");
}

sub save_scopes_to_cache
{
    my ($data, $file) = @_;

    return save_data_to_json_file($data, (defined $file) ? $file : "cache.json");
}

sub load_scopes_from_cache_dir
{
    my $var = ();
    foreach my $part (`ls -1 $CACHE_DIRECTORY`)
    {
	chomp $part;
	foreach my $scope (`ls -1 $CACHE_DIRECTORY/$part`)
	{
	    chomp $scope;
	    if (($part eq "apps") && (($scope eq "members") || ($scope eq "photos") || ($scope eq "aliases")))
	    {
		foreach my $member (`ls -1 $CACHE_DIRECTORY/$part/$scope`)
		{
		    chomp $member;
		    $var->{$part}->{$scope}->{$member} = load_scopes_from_cache("cache/$part/$scope/$member");
		}
	    }
	    else
	    {
		$var->{$part}->{$scope} = load_scopes_from_cache("cache/$part/$scope");
	    }

	}
    }

    return $var;
}

sub save_scopes_to_cache_dir
{
    my ($apps_data, $ts_start) = @_;

    foreach my $part (keys %{$apps_data})
    {
	foreach my $scope (keys %{$apps_data->{$part}})
	{
	    if (($part eq "apps") && (($scope eq "members") || ($scope eq "photos")  || ($scope eq "aliases")))
	    {
		make_path("$CACHE_DIRECTORY/$part/$scope");
		foreach my $o (keys %{$apps_data->{$part}->{$scope}})
		{
		    if (defined $apps_data->{$part}->{$scope}->{$o}->{last})
		    {
			if ($apps_data->{$part}->{$scope}->{$o}->{last} >= $ts_start)
			{
			    debug("Save $part -> $scope -> {$o} to cache", 'white');
			    save_scopes_to_cache($apps_data->{$part}->{$scope}->{$o}, "$CACHE_DIRECTORY/$part/$scope/$o") 
			}
		    }
		    else
		    {
			debug("Time $part -> $scope -> {$o} -> {last} is not defined, check it!", 'red');
		    }
		}
	    }
	    else
	    {
		make_path("$CACHE_DIRECTORY/$part");
		my $last = $apps_data->{$part}->{$scope}->{last} if (defined $apps_data->{$part}->{$scope}->{last});
		$last = $apps_data->{$part}->{$scope}->{1}->{last} if (defined $apps_data->{$part}->{$scope}->{1}->{last});
		
		if (defined $last)
		{
		    if ($last >= $ts_start)
		    {
			#debug("Save $part->$scope to cache", 'white');
			save_scopes_to_cache($apps_data->{$part}->{$scope}, "$CACHE_DIRECTORY/$part/$scope");
		    }
		}
		else
		{
		    debug("Time $part -> $scope -> {last} is not defined, check it!", 'red');
		}
	    }
	}
    }
}

# load JSON formated data from file and return as data sructure
sub get_data_from_json_file
{
    my ($filename) = @_;

    my $data = undef;
    if (open(JF, $filename))
    {
	local $/ = undef;
	$data = from_json(<JF>);
	close(JF);
    }

    return $data;
}

# sava json data structure to file as JSON
sub save_data_to_json_file
{
    my ($data, $filename) = @_;

    if (defined $data)
    {
	if (open(JF, ">$filename"))
	{
	    #local $/ = undef;
	    print JF to_json($data, { pretty => 1, utf8 => 1 });
	    close(JF);

	    return 0;
	}
    }

    return 1;
}

1;
