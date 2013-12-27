package CallOut::Container;
use strict;
use warnings;
use Object::Container '-base';
use CallOut::Config qw/config/;
use CallOut::DB;
use CallOut::Api::HipChat;

register 'hipchat' => sub {
    CallOut::Api::HipChat->new( auth_token => config->{auth_token} );
};

register 'db' => sub { 
    CallOut::DB->connect() 
};


1;
