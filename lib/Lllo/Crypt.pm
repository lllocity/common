package Lllo::Crypt;

use strict;
use warnings;
use File::HomeDir;
use File::Spec::Functions qw(catfile);
use Crypt::CBC;
use JSON::XS;

sub new {
    my $class = shift;

    my $self = {
        'key'            => undef,
        'cipher'         => 'Blowfish',
        'header'         => 'none',
        'padding'        => 'null',
        'literal_key'    => 1,
    };

    return bless $self, $class;
}

sub encrypt {
    my $self    = shift;
    my $plain   = shift || ''; 
    my $code    = shift;
    my $private = shift;

    # -- set key
    $self->_set_key($code, $private);

    my $cbc = Crypt::CBC->new({
        'key'         => $self->{'key'},
        'cipher'      => $self->{'cipher'},
        'iv'          => substr($self->{'key'}, 0, 8),
        'header'      => $self->{'header'},
        'padding'     => $self->{'padding'},
        'literal_key' => $self->{'literal_key'},
        'keysize'     => length($self->{'key'}),
    });

    return $cbc->encrypt_hex($plain);
}

sub decrypt {
    my $self    = shift;
    my $cipher  = shift || '';     
    my $code    = shift;
    my $private = shift;

    # -- set key
    $self->_set_key($code, $private);

    my $key_len = length($self->{'key'});

    my $cbc = Crypt::CBC->new({
        'key'         => $self->{'key'},
        'cipher'      => $self->{'cipher'},
        'iv'          => $key_len >= 8 ? substr($self->{'key'}, 0, 8) : sprintf('%08s', $self->{'key'}),
        'header'      => $self->{'header'},
        'padding'     => $self->{'padding'},
        'literal_key' => $self->{'literal_key'},
        'keysize'     => $key_len,
    });

    return $cbc->decrypt_hex($cipher);
}

sub _set_key {
    my $self    = shift;
    my $code    = shift || 'global';
    my $private = shift || catfile(File::HomeDir->my_home, 'config', 'private', 'secret.json');

    unless (defined $private and -e $private) {
        die "Please specify the existing file.";
    }

    my $json = '';
    open(my $fh, '<', $private) or die "Failed to open file. $private";
    while (<$fh>) {
        chomp;
        $json .= $_;
    }
    close($fh);

    my $data = JSON::XS->new->utf8->decode($json);
    unless (defined $data->{$code} and length($data->{$code}) > 7) {
        die "Key length needs 8 byte at least.";
    }
    $self->{'key'} = $data->{$code};
}
1;
