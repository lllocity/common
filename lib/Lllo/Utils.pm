package Lllo::Utils;

use strict;
use warnings;
use String::Random;
use File::HomeDir;
use File::Spec::Functions qw(catfile);
use JSON::XS;

use Devel::Peek;
use Data::Dumper;

sub readConfig {
    my $code = shift || 'foo';
    my $name = shift || 'bar';

    my $file = catfile(File::HomeDir->my_home, 'config', $code, $name . '.json');

    unless (-e $file) {
        die "Please specify the existing file.";
    }

    my $json = '';
    open(my $fh, '<', $file) or die "Failed to open file. $file";
    while (<$fh>) {
        chomp;
        $json .= $_;
    }
    close($fh);

    return JSON::XS->new->utf8->decode($json);
}

sub langConvStr2Code {
    my $str = shift;

    my @langs = split("･|\/", $str);
    my @codes = ();
    foreach my $lang (@langs) {
        if ($lang eq '英語') {
            push(@codes, 'en');     
        } elsif ($lang eq '日本語') {
            push(@codes, 'ja');     
        }
    }

    return @codes;
}

sub createRandomString {
    my $length = shift;

    $length = 1 unless ($length =~ /^\d+$/);

    return String::Random->new->randregex("[A-Za-z0-9]{$length}");
}
1;
