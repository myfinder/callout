package CallOut::Cmd::Member;
use strict;
use warnings;
use CallOut::Container 'container';
use Data::Dumper;
use Lingua::JA::Moji 'romaji2hiragana';
use Time::Piece::MySQL;
use constant max_results => 100;

sub update {
    my $index = 0;
    while(1) {
        my $results = container('hipchat')->get_all_users({ 'start-index' => $index, 'max-results' => max_results });        
        my $members = $results->{items};
        
        last unless @{$members}; 

        for my $row ( @{$members} ) {
            my $api_id   = $row->{id};
            my $member      = container('db')->select_one("SELECT * FROM member WHERE api_id = ?", $api_id);

            unless( $member ) {
                my $member_info = container('hipchat')->view_user({ user_id => $row->{id} }); 
                
                container('db')->do("INSERT INTO member (api_id,name,mention_name,email,photo_url,group_id,modified) VALUES(?,?,?,?,?,?,?)",{},
                    $api_id,
                    $member_info->{name},
                    $member_info->{mention_name},
                    $member_info->{email},
                    $member_info->{photo_url},
                    $member_info->{group}->{id},
                    localtime->mysql_datetime,
                );
            }

        }
        $index += max_results;
    }
}

sub create_syllabary {
    my $rows = container('db')->select_all("SELECT * FROM member");

    for my $row ( @{$rows} ) {
        my @names = split /\s+/, $row->{name};

        my ($first_name,$last_name) = ($names[0],$names[-1]);

        my $name_hiragana = romaji2hiragana($last_name);
        my ($name_index,) = split //, $name_hiragana;
        if( my $syllabary = container('db')->select_row("SELECT * FROM syllabary WHERE name = ?", $name_index) ) {
            unless( container('db')->select_row("SELECT * FROM syllabary_member WHERE syllabary_id = ? AND member_id = ?",$syllabary->{id},$row->{id}) ) {
                container('db')->do("INSERT INTO syllabary_member (syllabary_id,member_id) VALUES(?,?)",{}, $syllabary->{id},$row->{id});
            }
        }
        else {
            container('db')->do("INSERT INTO syllabary (name) VALUES(?)",{}, $name_index,);
            my $syllabary = container('db')->select_row("SELECT * FROM syllabary WHERE name = ?", $name_index);
            container('db')->do("INSERT INTO syllabary_member (syllabary_id,member_id) VALUES(?,?)",{}, $syllabary->{id},$row->{id});
        }
    }
}

1;
