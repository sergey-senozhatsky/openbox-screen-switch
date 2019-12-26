#!/bin/perl

my $screen = 0, $x = 777, $y = 777, $window = 0;

sub __exec($)
{
	my $c = shift;
	my $r = `$c`;

	print "Error: $c\n" if ($? != 0);
	return $r;
}

sub parse_location($)
{
	my $d = shift;

	chomp $d;
	if ($d =~ m/x:(\d+) y:(\d+) screen:(\d+) window:(\d+)/) {
		$x = $1;
		$y = $2;
		$screen = $3;
		$window = $4;
	}
}

sub write_location()
{
	my $filename = "/tmp/$screen-location-data";

	if (open(my $fh, '>', $filename)) {
		print $fh "x:$x y:$y screen:$screen window:$window";
		close $fh;
	}
}

sub current_location()
{
	my $filename;
	my $data;

	$data = __exec("xdotool getmouselocation");
	parse_location($data);
	write_location();
}

sub prev_location()
{
	my $filename = "/tmp/$screen-location-data";
	my $data;

	if (open(my $fh, '<', $filename)) {
		while (my $row = <$fh>) {
			chomp $row;
			$data = $row;
		}
		close $fh;
	}

	parse_location($data);
	__exec("xdotool mousemove --screen $screen $x $y");
	__exec("xdotool windowfocus $window");
	__exec("xdotool windowactivate $window");
}

sub switch($)
{
	my $dir = shift;

	current_location();
	if ($dir == 0) {
		return 0 if ($screen == 0);
		$screen = 0;
	} else {
		return 0 if ($screen == 1);
		$screen = 1;
	}

	prev_location();
}

switch($ARGV[0]);
