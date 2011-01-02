package Lllo::Database;

use strict;
use warnings;
use DBIx::Simple;
use Lllo::Crypt;
use Lllo::Utils;

use Data::Dumper;

sub new {
    my $class = shift;
    my $code  = shift;

    # -- Read config
    my $cfg = Lllo::Utils::readConfig($code, 'database')->{$code};

    my $self = {
        'driver'   => defined $cfg->{'driver'}   ? $cfg->{'driver'} : 'mysql',
        'host'     => defined $cfg->{'host'}     ? $cfg->{'host'} : 'localhost',
        'user'     => defined $cfg->{'user'}     ? $cfg->{'user'} : 'hoge',
        'cipher'   => defined $cfg->{'cipher'}   ? $cfg->{'cipher'} : '',
        'database' => defined $cfg->{'database'} ? $cfg->{'database'} : 'test',
        'port'     => defined $cfg->{'port'}     ? $cfg->{'port'} : 3306,
        'code'     => defined $code              ? $code : '',
    };

    return bless $self, $class;
}

sub connect {
    my $self    = shift;
    my $dbi_opt = shift;

    my $pass = Lllo::Crypt->new()->decrypt($self->{'cipher'}, $self->{'code'});
    my $dsn  = sprintf('dbi:%s:host=%s;database=%s;', 
                    $self->{'driver'}, $self->{'host'}, $self->{'database'});

    return DBIx::Simple->connect($dsn, $self->{'user'}, $pass, $dbi_opt);
}

sub error {
    my $self = shift;
    return DBIx::Simple->error;
}
1;
