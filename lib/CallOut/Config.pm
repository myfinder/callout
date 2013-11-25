package CallOut::Config;
use strict;
use warnings;
use File::Basename qw/dirname/;
use Exporter qw/import/;
our @EXPORT_OK = qw/config/;

{
    my $config;
    sub config() {
        $config //= do {
            my $script_dir = $ENV{CALLOUT_CONFIG_PATH} || dirname $0;
            do "$script_dir/config.pl";
        }
    }
}

1;
__END__
