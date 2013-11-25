package CallOut::Web;
use strict;
use warnings;
use utf8;

use CallOut::Config qw/config/;
use Kossy;
use LWP::UserAgent;
use JSON;

get '/members' => sub {
    my ($self, $c) = @_;
    
    $ua = LWP::UserAgent->new;
    $my $url = config->{member_list_url};
    my $req = HTTP::Request->new(GET => $url);
    $req->header('Host' => 'api.hipchat.com');
    my $res = $ua->request($req);

    my $list = decode_json($res->content);

    $c->render_json($list);
}

#post '/message' => sub {
#
#}

1;
__END__
