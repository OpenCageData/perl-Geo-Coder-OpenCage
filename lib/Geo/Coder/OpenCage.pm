package Geo::Coder::OpenCage;

use strict;
use warnings;

use JSON;
use HTTP::Tiny;
use URI;
use Carp;

sub new {
    my $class = shift;
    my %params = @_;

    if (!$params{api_key}) {
        croak "api_key is a required parameter for new()";
    }

    my $self = {
        api_key => $params{api_key},
        ua      => HTTP::Tiny->new(agent => "Geo::Coder::OpenCage"),
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
        q   => $params{location},
    );

    my $response = $self->{ua}->get($URL);

    if (!$response || !$response->{success}) {
        croak "failed to fetch '$URL': ", $response->{reason};
    }

    my $raw_content = $response->{content};

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

You can get your API key from http://geocoder.opencagedata.com

=head2 geocode

Takes a single named parameter 'location' and returns a result hashref.

    my result = $Geocoder->geocode(location => "Mudgee, Australia");

=head1 ENCODING

All strings passed to and recieved from Geo::Coder::OpenCage methods are expected to be character strings, not byte strings.

For more information see L<perlunicode>.

=head1 AUTHOR

Alex Balhatchet, C<alex@lokku.com>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Lokku Ltd <cpan@lokku.com>

Please check out all our open source work over at https://github.com/lokku
and our developer blog: http://devblog.nestoria.com

Thanks!

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16 or,
at your option, any later version of Perl 5 you may have available.

=cut
