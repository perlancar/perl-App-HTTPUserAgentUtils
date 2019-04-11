package App::HTTPUserAgentUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use HTTP::UserAgentStr::Util::ByNickname;

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
                             HTTP::BrowserDetect
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
            default => 'HTTP::BrowserDetect',
            cmdline_aliases => {b=>{}},
        },
    },
};
sub parse_http_ua {
    my %args = @_;

    chomp(my $ua = $args{ua});
    my $backend = $args{backend} // 'HTML::ParseBrowser';

    my $res;
    if ($backend eq 'HTML::ParseBrowser') {
        require HTML::ParseBrowser;
        my $obj = HTML::ParseBrowser->new($ua);
        $res = {
            _orig    => $ua,
            name     => $obj->name,
            v        => $obj->v,
            os       => $obj->os,
            language => $obj->language,
        };
    } elsif ($backend eq 'HTTP::BrowserDetect') {
        require HTTP::BrowserDetect;
        my $obj = HTTP::BrowserDetect->new($ua);
        my @attrs = qw(
                          browser
                          browser_string
                          browser_version
                          browser_major
                          browser_minor
                          browser_beta

                          os
                          os_string
                          os_version
                          os_major
                          os_minor
                          os_beta

                          mobile
                          tablet
                          device
                          device_string

                          robot
                          lib
                          robot_string
                          robot_id
                          all_robot_ids
                          robot_version
                          robot_major
                          robot_minor
                          robot_beta

                          browser_properties

                          windows
                          dotnet
                          x11
                          webview
                          chromeos
                          firefoxos
                          mac
                          os2
                          bb10
                          rimtabletos
                          unix
                          vms
                          amiga
                          ps3gameos
                          pspgameos

                          adm
                          aol aol3 aol4 aol5 aol6
                          applecoremedia
                          avantgo
                          browsex
                          chrome
                          dalvik
                          emacs
                          epiphany
                          firefox
                          galeon
                          ie ie3 ie4 ie5 ie6 ie5up ie55 ie6 ie7 ie8 ie9 ie10 ie11
                          ie_compat_mode
                          konqueror
                          lotusnotes
                          lynx links elinks
                          mobile_safari
                          mosaic
                          mozilla
                          neoplanet neoplanet2
                          netfront
                          netscape nav2 nav3 nav4 nav4up nav45 nav45up navgold nav6 nav6up
                          obigo
                          opera opera3 opera4 opera5 opera6 opera7
                          polaris
                          pubsub
                          realplayer
                          realplayer_browser
                          safari
                          seamonkey
                          silk
                          staroffice
                          ucbrowser
                          webtv

                          android
                          audrey
                          avantgo
                          blackberry
                          dsi
                          iopener
                          iphone
                          ipod
                          ipad
                          kindle
                          kindlefire
                          n3ds
                          palm
                          webos
                          wap
                          psp
                          ps3

                          ahrefs
                          altavista
                          apache
                          askjeeves
                          baidu
                          bingbot
                          curl
                          facebook
                          getright
                          golib
                          google
                          googleadsbot
                          googlemobile
                          indy
                          infoseek
                          ipsagent
                          java
                          linkexchange
                          lwp
                          lycos
                          malware
                          mj12bot
                          msn
                          msoffice
                          puf
                          rubylib
                          slurp
                          wget
                          yahoo
                          yandex
                          yandeximages

                          webkit
                          gecko
                          trident
                          presto
                          khtml

                          u2f
                          country
                          language
                          engine
                          engine_string
                          engine_string
                          engine_version
                          engine_major
                          engine_minor
                          engine_beta

                  );
        $res = {
            _orig => $ua,
            map { $_ => $obj->$_ } @attrs,
        };
    } else {
        return [400, "Uknown/unsupported backend '$backend'"];
    }

    [200, "OK", $res];
}

$SPEC{http_ua_by_nickname} = {
    v => 1.1,
    summary => 'Get HTTP User-Agent string by nickname',
    args => {
        nickname => {
            schema => ['str*', in=>\@HTTP::UserAgentStr::Util::ByNickname::nicknames];
            req => 1,
            pos => 0,
        },
        action => {
            schema => ['str*', in=>['list', 'get']],
            default => 'get',
            cmdline_aliases => {
                l => {
                    summary => 'List available nicknames (shortcut for --action=list)',
                    is_flag => 1,
                    code => sub { $_[0]{action} = 'list' },
                },
            },
        },
    },
};
sub http_ua_by_nickname {
    my %args = @_;

    my $action = $args{action} // 'get';

    if ($action eq 'list') {
        return [200, "OK", \@HTTP::UserAgentStr::Util::ByNickname::nicknames];
    } else {
        # get
        [200, "OK", HTTP::UserAgentStr::Util::ByNickname::_get($args{nickname})];
    }
}

1;
# ABSTRACT:

=head1 SYNOPSIS

=head1 DESCRIPTION

This distribution includes several utilities:

#INSERT_EXECS_LIST
