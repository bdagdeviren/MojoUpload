package tools;

use strict;
use warnings;
use 5.010;
use autodie;
use Archive::Zip;
use File::Basename;

use base 'Exporter';
our @EXPORT = qw/ unzip /;



sub unzip{
    my $ip = $_[0];
    my $zipname = "uploads/$ip.zip";
    my $destinationDirectory = "uploads/$ip";
    mkdir $destinationDirectory if not -e $destinationDirectory;
    my $zip = Archive::Zip->new($zipname);
    foreach my $member ($zip->members)
    {
        next if $member->isDirectory;
        (my $extractName = $member->fileName) =~ s{.*/}{};
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
    my $file = $_[0];
    my $groupId = $data->{groupId};
    if ($groupId eq '') {
        $groupId = $data->{parent}{groupId};
    }
    my $artifactId = $data->{artifactId};
    if ($artifactId eq '') {
        $artifactId = $data->{parent}{artifactId};
    }
    my $version = $data->{version};
    if ($version eq '') {
        $version = $data->{parent}{version};
    }

    my $classifier = basename($file);
    $classifier =~ s/$artifactId//ig;
    $classifier =~ s/-//ig;
    $classifier =~ s/$version//ig;
    $classifier =~ s/.pom//ig;
    $classifier =~ s/.jar//ig;

    return $groupId,$artifactId,$version,$classifier;
}

1;