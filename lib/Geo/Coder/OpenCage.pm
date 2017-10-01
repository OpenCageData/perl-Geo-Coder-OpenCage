package Geo::Coder::OpenCage;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use HTTP::Tiny;
use JSON;
use URI;

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
        url     => URI->new('https://api.opencagedata.com/geocode/v1/json/'),
    };
    return bless $self, $class;
}

# see list: https://geocoder.opencagedata.com/api#forward-opt
my %valid_params = (
    abbrv            => 1,
    add_request      => 1,
    bounds           => 1,
    countrycode      => 1,
    format           => 0,    
    jsonp            => 0,
    language         => 1,
    limit            => 1,
    min_confidence   => 1,
    no_annotations   => 1,
    no_dedupe        => 1,
    no_record        => 1,
    q                => 1,
    pretty           => 1,  # makes no actual difference
);

sub geocode {
    my $self = shift;
    my %params = @_;

    if (defined($params{location})) {
        $params{q} = delete $params{location};
    }
    else {
        warn "location is a required parameter for geocode()";
        return undef;
    }

    for my $k (keys %params){
        if (!defined($params{$k})){
            warn "Unknown geocode parameter: $k";
            delete $params{$k};
        }
        if (!$params{$k}){  # is a real parameter but we dont support it
            warn "Unsupported geocode parameter: $k";
            delete $params{$k};            
        }
    }

    my $URL = $self->{url}->clone();
    $URL->query_form(
        key => $self->{api_key},
        %params,
    );

    my $response = $self->{ua}->get($URL);

    if (!$response){ 
        warn "failed to fetch '$URL': ", $response->{reason};        
        return undef;
    }

    my $rh_content = $self->{json}->decode( $response->{content} );

    if (!$response->{success}) {
        warn "response when requesting '$URL': "
            . $rh_content->{status}{code}
            . ', '
            . $rh_content->{status}{message};
        return undef;
    }
   
    return $rh_content;
}

sub reverse_geocode {
    my $self = shift;
    my %params = @_;

    foreach my $k (qw(lat lng)){
        if (!defined($params{$k})){
            warn "$k is a required parameter";
            return undef;
        }
    }

    $params{location} = join(',', delete @params{'lat','lng'});
    return $self->geocode(%params);
}

1;

__END__

=encoding utf8

=head1 NAME

Geo::Coder::OpenCage - Geocode coordinates and addresses with the OpenCage Geocoder

=head1 DESCRIPTION

This module provides an interface to the OpenCage geocoding service.

For full details of the API visit L<https://geocoder.opencagedata.com/api>.

=head1 SYNOPSIS

    my $Geocoder = Geo::Coder::OpenCage->new(api_key => $my_api_key);

    my $result = $Geocoder->geocode(location => "Donostia");

=head1 METHODS

=head2 new

    my $Geocoder = Geo::Coder::OpenCage->new(api_key => $my_api_key);

Get your API key from L<https://geocoder.opencagedata.com>

=head2 geocode

Takes a single named parameter 'location' and returns a result hashref.

    my $result = $Geocoder->geocode(location => "Mudgee, Australia");

warns and returns undef if the query fails for some reason.

The OpenCage Geocoder has a few optional parameters

=over 1

=item Supported Parameters

please see L<the OpenCage geocoder documentation|https://geocoder.opencagedata.com/api>. Most of 
L<the various optional parameters|https://geocoder.opencagedata.com/api#forward-opt> are supported. For example:

=over 2

=item language

An IETF format language code (such as es for Spanish or pt-BR for Brazilian
Portuguese); if this is omitted a code of en (English) will be assumed.

=item limit

Limits the maximum number of results returned. Default is 10.  

=item countrycode

Provides the geocoder with a hint to the country that the query resides in.
This value will help the geocoder but will not restrict the possible results to
the supplied country.

The country code is a comma seperated list of 2 character code as defined by 
the ISO 3166-1 Alpha 2standard.

=back

=item Not Supported

=over 2

=item jsonp

This module always parses the response as a Perl data structure, so the jsonp
option is never used.

=back

=back

As a full example:

    my $result = $Geocoder->geocode(
        location => "Псковская улица, Санкт-Петербург, Россия",
        language => "ru",
        countrycode => "ru",
    );

=head2 reverse_geocode

Takes two named parameters 'lat' and 'lng' and returns a result hashref.

    my $result = $Geocoder->reverse_geocode(lat => -22.6792, lng => 14.5272);

This method supports the optional parameters in the same way that geocode() 
does.

=head1 ENCODING

All strings passed to and recieved from Geo::Coder::OpenCage methods are 
expected to be character strings, not byte strings.

For more information see L<perlunicode>.

=head1 SEE ALSO

This module was featured in the 2016 Perl Advent Calendar. L<Read the article|http://perladvent.org/2016/2016-12-08.html>.

=head1 AUTHOR

Ed Freyfogle 

=cut

=head1 COPYRIGHT AND LICENSE

Copyright 2017 OpenCage Data Ltd <cpan@opencagedata.com>

Please check out all our open source work over at L<https://github.com/opencagedata> and our developer blog: L<https://blog.opencagedata.com>

Thanks!

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16 or,
at your option, any later version of Perl 5 you may have available.

=cut
