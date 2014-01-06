package CallOut::Web;
use strict;
use warnings;
use utf8;

use Kossy;
use JSON::XS;
use CallOut::Config qw/config/;
use CallOut::Container 'container';
use CallOut::Cmd::Member;
use CallOut::MemberIndex;
use JSON;
use LWP::UserAgent;

get '/admin/member/' => sub {
    my ($self, $c) = @_;

    $c->render('/admin/member/index.tx', { members => container('db')->select_all("SELECT * FROM member") // [] });
};

get '/admin/syllabary/' => sub {
    my ($self, $c) = @_;
    my $syllabary = container('db')->select_all("
        SELECT
            syllabary.*, member.name AS member_name
        FROM syllabary
            JOIN syllabary_member ON syllabary_member.syllabary_id = syllabary.id
            JOIN member           ON syllabary_member.member_id    = member.id
            ORDER BY syllabary.name
    ");

    $c->render('/admin/syllabary/index.tx', {
        syllabary => $syllabary,
    });
};

get '/admin/member/show' => sub {
    my ($self, $c) = @_;
    my $member = container('db')->select_row("
        SELECT member.* ,syllabary.name AS syllabary_name, syllabary.id AS syllabary_id
        FROM member
            JOIN syllabary_member ON member.id = syllabary_member.member_id
            JOIN syllabary        ON syllabary_member.syllabary_id = syllabary.id
        WHERE member.id = ?", $c->req->param('member_id') //'' );

    $c->render('/admin/member/show.tx', {
        member => $member
    });
};

post '/admin/member/syllabary/update' => sub {
    my ($self, $c) = @_;

    my $member_id      = $c->req->param('member_id') or die 'require member_id';
    my $syllabary_id   = $c->req->param('syllabary_id') or die 'require syllabary_id';
    my $syllabary_name = $c->req->param('syllabary_name') or die 'require syllabary_name';

    my $syllabary = container('db')->select_row("SELECT * FROM syllabary WHERE name = ?", $syllabary_name);

    if( $syllabary ) {
        container('db')->do('UPDATE syllabary_member SET syllabary_id = ? WHERE member_id = ? ',{}, $syllabary->{id},$member_id);
    }
    else {
        container('db')->begin_work();

        eval{
            container('db')->do("INSERT INTO syllabary (name) VALUES(?)",{}, $syllabary_name,);
            my $new_syllabary = container('db')->select_row("SELECT * FROM syllabary WHERE name = ?", $syllabary_name);
            container('db')->do('UPDATE syllabary_member SET syllabary_id = ? WHERE member_id = ? ',{}, $new_syllabary->{id},$member_id);
            container('db')->commit();
        };
        if($@) {
            container('db')->rollback();
            die $@;
        }
    }

    container('db')->do("DELETE FROM syllabary WHERE id IN (SELECT id FROM syllabary WHERE id NOT IN (SELECT DISTINCT(syllabary_id) FROM syllabary_member))");

    $c->redirect('/admin/member/show?member_id=' . $member_id);
};

get '/' => sub {
    my ($self, $c) = @_;

    my $members = container('db')->select_all("
                SELECT member.*, syllabary.name as syllabary_name
                FROM member
                    JOIN syllabary_member ON member.id = syllabary_member.member_id
                    JOIN syllabary        ON syllabary_member.syllabary_id = syllabary.id");

    for my $member ( @{$members} ) {
        $member->{"index"} = CallOut::MemberIndex->get_index($member->{"syllabary_name"});
        $member->{'photo_url'} =
            $member->{'photo_url'} ? "https://s3-ap-northeast-1.amazonaws.com/" . $member->{'photo_url'} : "/img/company_logo_white.png"
    }

    $c->render('index.tx', { users => $members,
                             syllabaries => container('db')->select_all("SELECT * FROM syllabary")
                           });
};

get '/members' => sub {
    my ($self, $c) = @_;
    $c->render_json(
        container('db')->select_all("SELECT * FROM member")
    );
};

get '/view_user' => sub {
    my ($self, $c) = @_;

    my $view_user = container('db')->select_row("SELECT * FROM member WHERE id = ?",$c->req->param('user_id'));

    if($view_user) {
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
        container('hipchat')->send_room_notification(
            {
                room    => config->{room},
                message => $c->req->param('message') // '',
                mention_name => $c->req->param('mention_name') // undef,
            }
        );
        if (my $user_id = $c->req->param('user_id')) {
            container('hipchat')->send_user_notification(
                {
                    user_id => $user_id,
                    message => $c->req->param('message') // '',
                }
            );
        }
    };

    if($@) {
        warn $@;
        return $c->halt(500);
    }
    $c->halt(200);
};

post '/update_member' => sub {
    my ($self,$c) = @_;

    eval {
        CallOut::Cmd::Member->update;
    };

    if($@) {
        warn $@;
        return $c->render('message.tx', {result => 0});
    }

    $c->render('message.tx', {result => 1});
};

1;
