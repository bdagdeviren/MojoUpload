use File::FindLib 'utils/';

use Mojolicious::Lite;
use Mojo::Transaction::WebSocket;
use Mojo::AsyncAwait;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request::Common;
use Mojo::Server::Daemon;
use Mojo::File;

plugin 'ClientIP';

use upload;
use tools qw/ unzip /;

my $ua = LWP::UserAgent->new();

post '/upload' => sub {
    my $c = shift;
    upload::uploadToServer($c);
    $c->reply->static('index.html');
};

get '/' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

websocket '/ws' => async sub {
    my $c = shift;
    my $ip = $c->client_ip;
    $c->on(message => sub {
        tools::unzip($ip);
        $c->send("Unzipping.....");
        my $url   = 'http://192.168.1.7:8081/service/rest/v1/components?repository=deneme';
        my @fileList = tools::listAllFile($ip);
        foreach my $file (@fileList){
            my $request = HTTP::Request::Common::POST(
                $url,
                Authorization => 'Basic ' . encode_base64('admin:admin'),
                Content_Type  => 'multipart/form-data; boundary=----WebKitFormBoundaryQPRsOenHPfgxL9GL',
                Content       => [ file => [$file] ],
            );
            $ua->request($request);
            await $c->send($file);
        };
        $c->send("Unzipping Successful.....");
    });
};

app->max_request_size(1073741824);

Mojo::Server::Daemon->new( app => app, listen => ["http://*:8080"] ) -> run;