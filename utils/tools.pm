package tools;

use strict;
use warnings;
use 5.010;
use autodie;
use Archive::Zip;

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

1;