package App::HTTPUserAgentUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

# copy-pasted from WWW::UserAgent::Random doc
our @ua_categories = qw(
                       amiga
                       beos
                       browsers
                       cloud_platforms
                       consoles
                       crawlers
                       feed_readers
                       freebsd
                       link_checkers
                       linux
                       macintosh
                       netbsd
                       openbsd
                       os2
                       others
                       phones
                       proxy
                       shell
                       sunos
                       tool
                       validators
                       wap
                       windows
                   );

our @parser_backends = qw(
                             HTML::ParseBrowser
                     );


$SPEC{':package'} = {
    v => 1.1,
    summary => 'CLI utilities related to HTTP User-Agent (string)',
};

my %args_common = (
);

$SPEC{gen_random_http_ua} = {
    v => 1.1,
    summary => "Generate random HTTP User-Agent string(s)",
    description => <<'_',

Currently using <pm:WWW::UserAgent::Random> as backend.

_
    args => {
        num => {
            schema => 'nonnegint*',
            default => 1,
            pos => 0,
            cmdline_aliases => {n=>{}},
        },
        category => {
            schema => ['str*', in=>\@ua_categories],
            cmdline_aliases => {c=>{}},
        },
    },
};
sub gen_random_http_ua {
    require WWW::UserAgent::Random;
    my %args = @_;

    my @res;
    for (1..($args{num} // 1)) {
        push @res, WWW::UserAgent::Random::rand_ua($args{category} // "");
    }
    [200, "OK", @res > 1 ? \@res : $res[0]];
}

$SPEC{parse_http_ua} = {
    v => 1.1,
    summary => "Parse HTTP User-Agent string using one of available backends",
    description => <<'_',

_
    args => {
        ua => {
            schema => 'str*',
            req => 1,
            pos => 0,
            cmdline_src => 'stdin_or_args',
        },
        backend => {
            schema => ['str*', in=>\@parser_backends],
            default => 'HTML::ParseBrowser',
            cmdline_aliases => {b=>{}},
        },
    },
};
sub parse_http_ua {
    my %args = @_;

    my $ua = $args{ua};
    my $backend = $args{backend} // 'HTML::ParseBrowser';

    my $res;
    if ($backend eq 'HTML::ParseBrowser') {
        require HTML::ParseBrowser;
        my $obj = HTML::ParseBrowser->new($ua);
        $res = {
            name     => $obj->name,
            v        => $obj->v,
            os       => $obj->os,
            language => $obj->language,
        };
    } else {
        return [400, "Uknown/unsupported backend '$backend'"];
    }

    [200, "OK", $res];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

=head1 DESCRIPTION

This distribution includes several utilities:

#INSERT_EXECS_LIST
