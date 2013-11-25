package CallOut::Web;
use strict;
use warnings;
use utf8;

use Kossy;
use LWP::UserAgent;
use JSON::XS;
use CallOut::Config qw/config/;
use CallOut::Api::HipChat;

get '/members' => sub {
    my ($self, $c) = @_;
   
    my $hipchat_client = CallOut::Api::HipChat->new( auth_token => config->{auth_token} );

    my $users; 
    eval {
        $users = $hipchat_client->get_allow_users();
    };
    if($@) {
        $c->render_json({ result => 0 });
    }

    $c->render_json($users);
};

post '/message' => sub {
    my ($self,$c) = @_;

    my $hipchat_client = CallOut::Api::HipChat->new( auth_token => config->{auth_token} );

    eval {
        $hipchat_client->send_room_notification({ room => config->{room}, message => $c->req->param('message') //'' });
    };

    if($@) {
        $c->render_json({ result => 0 });
    }

    $c->render_json({ result => 1 });
};

1;
