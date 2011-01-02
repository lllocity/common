package Lllo::Utils;

use strict;
use warnings;
use String::Random;

use Devel::Peek;
use Data::Dumper;

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
