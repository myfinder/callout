package CallOut::Web;
use strict;
use warnings;
use utf8;

use CallOut::Config qw/config/;
use CallOut::Api::HipChat;
use Kossy;
use JSON;
use LWP::UserAgent;

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

get '/view_user' => sub {
    my ($self, $c) = @_;

    my $view_user; 
    eval {
        $view_user = $hipchat_client->view_user({ user_id => $c->req->param('user_id') });
    };

    if($@) {
        $c->render_json({ result => 0 });
    }


    if( config->{view_user} && ref(config->{view_user}->{permit_params}) eq 'ARRAY' ) {
        $view_user = +{ map { $_ => $view_user->{$_} } @{config->{view_user}->{permit_params}} }; 
    }

    $c->render_json($view_user);
    
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
