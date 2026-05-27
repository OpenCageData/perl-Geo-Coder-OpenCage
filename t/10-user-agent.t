use strict;
use warnings;
use utf8;
use Net::Ping;
use Test::More;
use Test::Warn;
use LWP::UserAgent;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

binmode Test::More->builder->output,         ":encoding(utf8)";
binmode Test::More->builder->failure_output, ":encoding(utf8)";
binmode Test::More->builder->todo_output,    ":encoding(utf8)";

use lib './lib'; # actually use the module, not other versions installed
use Geo::Coder::OpenCage;

# Verify the UA string format documented in the pod: "Geo::Coder::OpenCage/$VERSION"
{
    my $geocoder = Geo::Coder::OpenCage->new(api_key => 'dummy');
    like(
        $geocoder->ua->agent,
        qr{^Geo::Coder::OpenCage/\S+$},
        'default HTTP::Tiny UA has agent "Geo::Coder::OpenCage/<version>"',
    );

    my $lwp = LWP::UserAgent->new;
    $geocoder->ua($lwp);
    like(
        $lwp->agent,
        qr{^Geo::Coder::OpenCage/\S+$},
        'caller-supplied UA gets agent "Geo::Coder::OpenCage/<version>" via ua() setter',
    );

    my $lwp_via_new = LWP::UserAgent->new;
    my $geocoder2 = Geo::Coder::OpenCage->new(api_key => 'dummy', ua => $lwp_via_new);
    like(
        $lwp_via_new->agent,
        qr{^Geo::Coder::OpenCage/\S+$},
        'caller-supplied UA gets agent "Geo::Coder::OpenCage/<version>" when passed via new()',
    );
}

# TODO should move this into module to share with other tests
# Use TCP/443 so the connectivity check works for non-root users (ICMP needs privileges)
my $api_host        = 'api.opencagedata.com';
my $p               = Net::Ping->new('tcp', 1);
$p->port_number(443);
my $have_connection = $p->ping($api_host) ? 1 : 0;

SKIP: {
    skip 'skipping test that requires connectivity', 2 unless ($have_connection);

    my $user_agent = LWP::UserAgent->new();

    # use special key OpenCage makes available for testing
    # https://opencagedata.com/api#testingkeys
    my $api_key = '6d0e711d72d74daeb2b0bfd2a5cdfdba';

    my $geocoder = Geo::Coder::OpenCage->new(api_key => $api_key, ua => $user_agent);
    my $result = $geocoder->reverse_geocode('lat' => 1, 'lng' => 2);
    is($result->{status}->{code}, 200, 'got http 200 status');
}

done_testing();

