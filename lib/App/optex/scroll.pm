package App::optex::scroll;
use 5.024;
use warnings;

use Carp;
use Data::Dumper;
use IO::Handle;
use Term::ReadKey;
use Term::ANSIColor::Concise qw(:all);

our $VERSION = "0.01";
our $debug = $ENV{DEBUG_OPTEX_SCROLL};
our $TIMEOUT = $ENV{OPTEX_SCROLL_TIMEOUT} || 0.1;

my($mod, $argv);

sub flush {
    STDERR->printflush(@_);
}

END {
    flush "\e7\e[r\e8";
}

sub initialize {
    ($mod, $argv) = @_;
    my $region = 10;
    my($l, $c) = cursor_position() or return;
    flush "\n" x ($region + 1);
    flush csi_code('CPL', ($region + 1));
    printf STDERR "\e7\e[%d;%dr\e8", $l, $l + $region;
}

sub cursor_position {
    my $answer = ask(csi_code('DSR', 6), qr/R\z/);
    $answer =~ /\e\[(\d+);(\d+)R/ ? ($1, $2) : ();
}

sub uncntrl {
    $_[0] =~ s/([^\040-\176])/sprintf "\\%03o", ord $1/gear;
}

sub ask {
    my($request, $end_re) = @_;
    if ($debug) {
	printf STDERR "[%s] Request: %s\n",
	    __PACKAGE__,
	    uncntrl $request;
    }
    open my $tty, "+<", "/dev/tty" or return;
    ReadMode "cbreak", $tty;
    printflush $tty $request;
    my $timeout = $TIMEOUT;
    my $answer = '';
    while (defined (my $key = ReadKey $timeout, $tty)) {
	if ($debug) {
	    printf STDERR "[%s] ReadKey: \"%s\"\n",
		__PACKAGE__,
		$key =~ /\P{Cc}/ ? $key : uncntrl $key;
	}
	$answer .= $key;
	last if $answer =~ /$end_re/;
    }
    ReadMode "restore", $tty;
    if ($debug) {
	printf STDERR "[%s] Answer:  %s\n",
	    __PACKAGE__,
	    uncntrl $answer;
    }
    return $answer;
}

1;

__END__

=encoding utf-8

=head1 NAME

App::optex::scroll - It's new $module

=head1 SYNOPSIS

    use App::optex::scroll;

=head1 DESCRIPTION

App::optex::scroll is ...

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kazumasa Utashiro

=cut

