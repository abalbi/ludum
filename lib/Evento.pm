package Evento;
use strict;
use Data::Dumper;

use fields qw(_cambios);

sub new {
  return bless({
    _cambios => [],
  },'Evento');
}

sub agregar {
  my $self = shift;
  my $cambio = shift;
  push @{$self->cambios}, $cambio;
  $cambio->evento($self);
}

sub cambios {
  my $self = shift;
  return $self->{_cambios};
}
1;
