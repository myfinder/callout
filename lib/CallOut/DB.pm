package CallOut::DB;
use strict;
use warnings;
use DBI;
use CallOut::Config 'config';
use CallOut::Container 'container';

sub connect {
    DBI->connect(@{config->{DBI}});
}

1;
