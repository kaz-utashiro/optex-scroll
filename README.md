[![Actions Status](https://github.com/kaz-utashiro/optex-scroll/workflows/test/badge.svg)](https://github.com/kaz-utashiro/optex-scroll/actions) [![MetaCPAN Release](https://badge.fury.io/pl/App-optex-scroll.svg)](https://metacpan.org/release/App-optex-scroll)
# NAME

scroll - optex scroll region module

# SYNOPSIS

optex -Mscroll \[ options -- \] command

# VERSION

Version 0.01

# DESCRIPTION

**optex**'s **scroll** module prevents a command that produces output
longer than terminal hight from causing the executed command line to
scroll out from the screen.

It sets the scroll region for the output of the command it executes.
The output of the command scrolls by default 10 lines from the cursor
position where it was executed.

<div>
    <p><img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/optex-scroll/main/images/ping.png">
</div>

# OPTIONS

- **--line**=_n_

    Set scroll region lines to _n_.
    Default is 10.

# LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Kazumasa Utashiro
