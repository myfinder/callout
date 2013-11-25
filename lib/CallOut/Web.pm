package CallOut::Web;
use strict;
use warnings;
use utf8;

use CallOut::Config qw/config/;
use CallOut::Api::HipChat;
use Kossy;
use LWP::UserAgent;
use JSON;


my $hipchat_client = CallOut::Api::HipChat->new( auth_token => config->{auth_token} );


get '/members' => sub {
    my ($self, $c) = @_;

    my $users; 
    eval {
        $users = $hipchat_client->get_all_users();
    };

    if($@) {
        $c->render_json({ result => 0 });
    }

    $c->render_json($users);
};

post '/message' => sub {
    my ($self,$c) = @_;

    eval {
        $hipchat_client->send_room_notification({ room => config->{room}, message => $c->req->param('message') //'' });
    };

    if($@) {
        $c->render_json({ result => 0 });
    }

    $c->render_json({ result => 1 });
};

1;
