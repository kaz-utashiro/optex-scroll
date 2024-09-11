package App::optex::scroll;
use 5.024;
use warnings;

use Carp;
use Data::Dumper;
use IO::Handle;
use Term::ReadKey;
use Term::ANSIColor::Concise qw(:all);
use List::Util qw(first pairmap);

our $VERSION = "0.99";
our $debug = $ENV{DEBUG_OPTEX_SCROLL};
our $TIMEOUT = $ENV{OPTEX_SCROLL_TIMEOUT} || 0.1;

my %opt = (
    line => 10,
);

sub hash_to_spec {
    pairmap {
	$a = "$a|${\(uc(substr($a, 0, 1)))}";
	if    (not defined $b) { "$a"   }
	elsif ($b =~ /^\d+$/)  { "$a=i" }
	else                   { "$a=s" }
    } %{+shift};
}

my($mod, $argv);

sub flush {
    STDERR->printflush(@_);
}

END {
    flush "\e7\e[r\e8";
}

sub finalize {
    ($mod, $argv) = @_;

    #
    # private option handling
    #
    if (my $i = (first { $argv->[$_] eq '--' } keys @$argv)) {
	splice @$argv, $i, 1; # remove '--'
	if (local @ARGV = splice @$argv, 0, $i) {
	    use Getopt::Long qw(GetOptionsFromArray);
	    Getopt::Long::Configure qw(bundling);
	    GetOptions \%opt, hash_to_spec \%opt or die "Option parse error.\n";
	}
    }

    my $region = $opt{line};
    flush "\n" x ($region + 0);
    flush csi_code('CPL', ($region + 0)); # CPL: Cursor Previous Line
    my($l, $c) = cursor_position() or return;
    flush sprintf "\e7\e[%d;%dr\e8", $l, $l + $region;
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
	flush sprintf "[%s] Request: %s\n",
	    __PACKAGE__,
	    uncntrl $request;
    }
    open my $tty, "+<", "/dev/tty" or return;
    ReadMode "cbreak", $tty;
    $tty->printflush($request);
    my $timeout = $TIMEOUT;
    my $answer = '';
    while (defined (my $key = ReadKey $timeout, $tty)) {
	if ($debug) {
	    flush sprintf "[%s] ReadKey: \"%s\"\n",
		__PACKAGE__,
		$key =~ /\P{Cc}/ ? $key : uncntrl $key;
	}
	$answer .= $key;
	last if $answer =~ /$end_re/;
    }
    ReadMode "restore", $tty;
    if ($debug) {
	flush sprintf "[%s] Answer:  %s\n",
	    __PACKAGE__,
	    uncntrl $answer;
    }
    return $answer;
}

sub set {
    %opt = (%opt, @_);
}

1;

__END__

=encoding utf-8

=head1 NAME

scroll - optex scroll region module

=head1 SYNOPSIS

optex -Mscroll [ options -- ] command

=head1 VERSION

Version 0.99

=head1 DESCRIPTION

B<optex>'s B<scroll> module prevents a command that produces output
longer than terminal hight from causing the executed command line to
scroll out from the screen.

It sets the scroll region for the output of the command it executes.
The output of the command scrolls by default 10 lines from the cursor
position where it was executed.

=head1 OPTIONS

=over 7

=item B<--line>=I<n>

Set scroll region lines to I<n>.
Default is 10.

=back

=head1 EXAMPLES

    optex -Mscroll ping localhost

    optex -Mscroll seq 100000

    optex -Mscroll tail -f /var/log/system.log

=begin html

<p><img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/optex-scroll/main/images/ping.png">

=end html

    optex -Mpingu -Mscroll --line 20 -- ping --pingu -i0.2 -c75 localhost

=begin html

<p>
<a href="https://www.youtube.com/watch?v=C3LoPAe7YB8">
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/optex-scroll/main/images/pingu.png">
</a>

=end html

=head1 SEE ALSO

L<App::optex>,
L<https://github.com/kaz-utashiro/optex/>

L<App::optex::pingu>,
L<https://github.com/kaz-utashiro/optex-pingu/>

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kazumasa Utashiro

=cut

