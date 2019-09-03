use XML::Simple;
use File::Basename;

my $data = XMLin("/home/test/Desktop/outside/repository/com/github/jnr/jffi/1.2.15/jffi-1.2.15.pom");
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

my $path = "/home/test/Desktop/outside/repository/com/github/jnr/jffi/1.2.15/jffi-1.2.15-native.jar";
my $filename = basename($path);
$filename =~ s/$artifactId//ig;
$filename =~ s/-//ig;
$filename =~ s/$version//ig;
$filename =~ s/.pom//ig;
$filename =~ s/.jar//ig;


print $filename;