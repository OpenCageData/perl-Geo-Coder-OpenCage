use strict;
use warnings;

use Test::More;

use Geo::Coder::OpenCage;

my $api_key;
if ($ENV{GEO_CODER_OPENCAGE_API_KEY}) {
    $api_key = $ENV{GEO_CODER_OPENCAGE_API_KEY};
}
else {
    plan skip_all => "Set GEO_CODER_OPENCAGE_API_KEY environment variable to run this test";
}

my $Geocoder = Geo::Coder::OpenCage->new(
    api_key => $api_key,
);

my %tests = (
    "Mudgee, Australia" => [ -32.5980702, 149.5886383 ],
    "EC1M 5RF"          => [  51.5201666,  -0.0985142 ],
    "Donostia"          => [  43.300836,   -1.9809529 ],
);

for my $test (sort keys %tests) {
    ok $test, "Trying to geocode '$test'";

    my $result = $Geocoder->geocode(location => $test);

    ok $result, '... got a sane response';

    my @results = @{ $result->{results} || [] };
    my $num_results = @results;

    ok @results > 0, "... got at least one ($num_results) results";

    my $good_results = 0;
    for my $individual_result (@results) {
        $good_results++ if (
            (abs($individual_result->{geometry}{lat} - $tests{$test}[0]) < 0.05) &&
            (abs($individual_result->{geometry}{lng} - $tests{$test}[1]) < 0.05)
        );
    }
    ok $good_results, "... got at least one ($good_results) results where we expect them to be";
}

done_testing();
