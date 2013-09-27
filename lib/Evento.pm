package Evento;
use strict;
use Data::Dumper;

use fields qw(_cambios _pesos);

sub new {
  return bless({
    _cambios => [],
    _pesos => [],
  },'Evento');
}

sub agregar {
  my $self = shift;
  my $cambio = shift;
  push @{$self->cambios}, $cambio;
  push @{$self->pesos}, {cambio => $cambio, peso => 0};
  $cambio->evento($self);
}

sub cambios {
  my $self = shift;
  return $self->{_cambios};
}

sub pesos {
  my $self = shift;
  return $self->{_pesos};
}

sub peso {
  my $self = shift;
  my $cambio = shift;
  my $peso = shift;
  foreach my $reg (@{$self->pesos}) {
    if($reg->{cambio} eq $cambio) {
      if(defined $peso) {
        $reg->{peso} = $peso;
      }
      return $reg->{peso};
    }
  }
}
1;
