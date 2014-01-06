package CallOut::MemberIndex;
use strict;
use warnings;
use utf8;
use Encode qw(encode_utf8);

sub get_index {
    my ($self, $syllabary_name) = @_;

    my @separation_regixs = qw(
        [あ-お] [か-こ|が-ご] [さ-そ|ざ-ぞ] [た-と|だ-ど] [な-の] [は-ほ|ば-ぼ|ぱ-ぽ] [ま-も] [や-よ] [ら-ろ] [わ-ん]
    );
    for my $index (0 .. $#separation_regixs) {
        if ($syllabary_name =~ /^$separation_regixs[$index]+$/) {
            return $index;
        }
    }
    return -1;
}

1;
__END__