package CallOut::Api::HipChat;
use strict;
use warnings;
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/auth_token/],
);

use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST);
use JSON::XS;
use Carp ();
use URI;
use URI::QueryParam;

use constant SEND_ROOM_NOTIFICATION_URL => "https://api.hipchat.com/v2/room/%s/notification?auth_token=%s";
use constant GET_ALL_USERS_URL          => "https://api.hipchat.com/v2/user?format=json&auth_token=%s";

sub client {
    my $self = shift;        
    $self->{_client} //= LWP::UserAgent->new( agent => __PACKAGE__ );
}

sub send_room_notification {
    my ($self,$args) = @_;

    my $message = $args->{message} or die 'require message'; 
    my $room    = $args->{room}    or die 'require room'; 
    my $color   = $args->{color} // 'yellow';

    my $json = encode_json({
        color   => $color,
        message => $message,
    });           
    
    my $url = sprintf(SEND_ROOM_NOTIFICATION_URL,$room,$self->auth_token);

    my $res = $self->client->request(
        POST $url, 'content-type' => 'application/json',  Content => $json 
    );

    unless( $res->is_success ) {
        die $res->status_line;         
    }
}

sub get_all_users {
    my ($self,$args) = @_;

    my $uri = URI->new(
        sprintf(GET_ALL_USERS_URL,$self->auth_token)
    );
    for my $name (qw/start-index max-results include-deleted/ ) {
        if( $args->{$name} ) {
            $uri->query_param_append($name,$args->{$name});
        }
    }
   
    my $res = $self->client->get($uri->as_string);

    unless( $res->is_success ) {
        die $res->status_line;         
    }

    return decode_json($res->decoded_content);
}

1;
__END__

=encoding utf-8

=head1 NAME

    CallOut::Api::HipChat

=head1 SYNOPSIS

    use strict;
    use warnings;
    use utf8;
    use Data::Dumper;
    use CallOut::Config qw/config/;
    use CallOut::Api::HipChat;

    my $hc = CallOut::Api::HipChat->new(
        auth_token => config->{auth_token},
    );

    $hc->send_room_notification({ room => config->{room}, message => "test!"});
    my $users = $hc->get_all_users();
    warn Dumper $users;
