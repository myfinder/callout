package CallOut::Web;
use strict;
use warnings;
use utf8;

use Kossy;
use LWP::UserAgent;
use JSON;
use CallOut::Config qw/config/;

get '/members' => sub {
    my ($self, $c) = @_;

    my $ua = LWP::UserAgent->new;
    my $url = config->{'member_list_url'} . config->{'auth_token'};
    my $req = HTTP::Request->new(GET => $url);
    $req->header('Host' => 'api.hipchat.com');
    my $res = $ua->request($req);

    my $list = decode_json($res->content);

    $c->render_json($list);
};

post '/message' => sub {
    my ($self, $c) = @_;

    my $ua = LWP::UserAgent->new;
    my $url = config->{'notification_url'} . config->{'auth_token'};
    my $req = HTTP::Request->new(POST => $url);
    my $mention_name = $c->req->param('mention_name');
    #my $content = encode_json {  message => "ほげ さんに来客です" };
    my $content = "room_id=352440&from=Alerts&message=dareka+kita";
    #$req->header('Content-Type' => 'application/json');
    $req->header('Content-Type' => 'application/x-www-form-urlencoded');
    $req->content($content);
    my $res = $ua->request($req);

    warn $res;
};

1;
__END__
