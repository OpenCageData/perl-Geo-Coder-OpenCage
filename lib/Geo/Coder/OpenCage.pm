package Geo::Coder::OpenCage;

use strict;
use warnings;

use JSON;
use LWP::UserAgent;
use Carp;

sub new {
    my $class = shift;
    my %params = @_;

    if (!$params{api_key}) {
        croak "api_key is a required parameter for new()";
    }

    my $self = {
        api_key => $params{api_key},
        ua      => LWP::UserAgent->new(agent => "Geo::Coder::OpenCage"),
        json    => JSON->new()->utf8(),
        url     => URI->new('http://prototype.opencagedata.com/geocode/v1/json/'),
    };

    return bless $self, $class;
}

sub geocode {
    my $self = shift;
    my %params = @_;

    if (!$params{location}) {
        croak "location is a required parameter for geocode()";
    }

    my $URL = $self->{url}->clone();
    $URL->query_form(
        key => $self->{api_key},
        q       => $params{location},
    );

    my $Response = $self->{ua}->get($URL);

    if (!$Response || !$Response->is_success) {
        croak "failed to fetch '$URL': ", $Response->status_line();
    }

    my $raw_content = $Response->decoded_content;

    my $result = $self->{json}->decode($raw_content);

    return $result;
}

1;

__END__

=pod

=head1 NAME

Geo::Coder::OpenCage - Geocode addresses with the OpenCage Geocoder API

=head1 DESCRIPTION

This module provides an interface to the OpenCage geocoding service.

=head1 SYNOPSIS

    my $Geocoder = Geo::Coder::OpenCage->new(
        api_key => $my_api_key,
    );

    my $result = $Geocoder->geocode(location => "Donostia");

=head1 METHODS

=head2 new

    my $Geocoder = Geo::Coder::OpenCage->new(
        api_key => $my_api_key,
    );

You can get your API key from http://opencagedata.com/ or something.

=head2 geocode

Takes a single named parameter 'location' and returns a result hashref.

    my result = $Geocoder->geocode(location => "Mudgee, Australia");

=head1 AUTHOR

Alex Balhatchet, C<alex@lokku.com>

=cut
