package upload;

use strict;
use warnings;
use 5.010;
use autodie;

use Mojolicious::Lite;

use base 'Exporter';
our @EXPORT = qw/ uploadToServer /;

sub uploadToServer{
    my $c = $_[0];
    my $data = $c->req->upload('file');
    my $uploadFileDirectory = 'uploads';
    mkdir $uploadFileDirectory if not -e $uploadFileDirectory;
    my $ip = $c->client_ip;
    $data->move_to("$uploadFileDirectory/$ip.zip");
}

1;