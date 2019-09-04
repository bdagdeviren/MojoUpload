use File::FindLib 'utils/';

use Mojolicious::Lite;
use Mojo::Transaction::WebSocket;
use Mojo::AsyncAwait;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request::Common;
use Mojo::Server::Daemon;
use Mojo::File;
use XML::Simple;

plugin 'ClientIP';

use upload;
use tools qw/ unzip resolveArtifactInfo /;

my $ua = LWP::UserAgent->new();

my $urlNpm   = 'http://192.168.1.7:8081/service/rest/v1/components?repository=deneme';
my $urlMaven   = 'http://10.150.0.247:8081/service/rest/v1/components?repository=deneme2';

post '/upload' => sub {
    my $c = shift;
    my $tx = $c->tx;
    upload::uploadToServer($c);
    $c->render(json => { status => "204" });
};

post '/uploadtonexus' => sub {
    my $c = shift;
    my $tx = $c->tx;
    my $file = $c->req->body_params->param('file');
    my $type = $c->req->body_params->param('type');
    my $request;
    if ($type eq 'npm'){
        $request = HTTP::Request::Common::POST(
            $urlNpm,
            Authorization => 'Basic ' . encode_base64('admin:admin'),
            Content_Type  => 'multipart/form-data; boundary=----WebKitFormBoundaryQPRsOenHPfgxL9GL',
            Content       => [ "npm.asset" => [$file] ],
        );
    }if ($type eq 'maven'){
        my $extension = "pom";
        my $pom = $file;
        if($file =~ m/jar/){
            $pom = $file =~ s/jar/pom/r;
            $extension = "jar";
        }
        my ($groupId, $artifactId, $version, $classifier) = &resolveArtifactInfo($pom);
        $request = HTTP::Request::Common::POST(
            $urlMaven,
            Authorization => 'Basic ' . encode_base64('admin:admin'),
            Content_Type  => 'multipart/form-data; boundary=----WebKitFormBoundaryQPRsOenHPfgxL9GL',
            Content       => {  "maven2.groupId" => $groupId,
                                "maven2.artifactId" => $artifactId,
                                "maven2.version" => $version,
                                "maven2.asset1.classifier" => $classifier,
                                "maven2.asset1.extension" => $extension,
                                "maven2.asset1" => [$file] },
        );
    }
    my $res=  $ua->request($request);
    if($res -> is_success){
        $c->render(json => { status => "Success" });
    }else {
        $c->render(json => { status => "Error" });
    }
    
};

get '/' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

get '/getfilelist' => sub {
    my ( $c ) = @_;
    my $tx = $c->tx;
    my $ip = $c->client_ip;
    tools::unzip($ip);
    my @fileList = tools::listAllFile($ip);

    $c->render(json => { @fileList });
};

websocket '/ws' => sub {
    my $c = shift;
    my $tx = $c->tx;
    my $ip = $c->client_ip;
    $c->on('message' => sub {
        tools::unzip($ip);
        $tx->send("Unzipping.....");
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
            $tx->send($file);
            sleep(2);
        };
        $tx->send("Unzipping Successful.....");
    });
};

app->max_request_size(1073741824);

app->hook(after_build_tx => sub {
    my ($tx, $app) = @_;
    $tx->res->headers->header( 'Access-Control-Allow-Origin' => '*' );
    $tx->res->headers->header( 'Access-Control-Allow-Methods' => 'GET, POST, PUT, PATCH, DELETE, OPTIONS' );
    $tx->res->headers->header( 'Access-Control-Max-Age' => 3600 );
    $tx->res->headers->header( 'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With' );
});

Mojo::Server::Daemon->new( app => app, listen => ["http://*:8080"] ) -> run;