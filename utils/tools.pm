package tools;

use strict;
use warnings;
use 5.010;
use autodie;
use Archive::Zip;
use File::Basename;
use XML::Simple;

use base 'Exporter';
our @EXPORT = qw/ unzip resolveArtifactInfo /;



sub unzip{
    my $ip = $_[0];
    my $zipname = "uploads/$ip.zip";
    my $destinationDirectory = "uploads/$ip";
    mkdir $destinationDirectory if not -e $destinationDirectory;
    my $zip = Archive::Zip->new($zipname);
    foreach my $member ($zip->members)
    {
        next if $member->isDirectory;
        my $extractName = $member->fileName;
        $member->extractToFileNamed(
            "$destinationDirectory/$extractName");
    }
}

sub listAllFile{
    my $ip = $_[0];
    my @files = glob("uploads/$ip/*.*");
    my %jsonFiles=();
    foreach my $file (@files){ 
        push @{$jsonFiles{files}}, $file;  
    }
    return %jsonFiles;
}

sub resolveArtifactInfo{
    my $pom = $_[0];
    my $file = $_[1];

    my @spl = split('/', $file);
    my $len = scalar @spl;
    my $version = @spl[$len-1];
    my $artifactId = @spl[$len-2];

    my $classifier = basename($file);
    $classifier =~ s/$artifactId//ig;
    $classifier =~ s/-//ig;
    $classifier =~ s/$version//ig;
    $classifier =~ s/.pom//ig;
    $classifier =~ s/.jar//ig;

    if(defined $classifier){
        $pom = $pom =~ s/-$classifier//r;
    }
    
    my $data = XMLin($pom);
    my $groupId = $data->{groupId};
    if (!(defined $groupId)) {
        $groupId = $data->{parent}{groupId};
    }
    $artifactId = $data->{artifactId};
    if (!(defined $artifactId)) {
        $artifactId = $data->{parent}{artifactId};
    }
    $version = $data->{version};
    if (!(defined $version)) {
        $version = $data->{parent}{version};
    }

    return $groupId,$artifactId,$version,$classifier;
}

1;