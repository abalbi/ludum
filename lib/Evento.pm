package Evento;
use Data::Dumper;
use Mojolicious;
use strict;
use base 'Ludum::Base';
use fields qw(_cambios _ID);

sub new {
  my $class = shift;
  my $self = fields::new($class);
  $self->SUPER::new();
  $self->{_cambios} = [];
  return $self;
}

sub agregar {
  my $self = shift;
  my $cambio = shift;
  push @{$self->cambios}, {cambio => $cambio, peso => 0};
  $cambio->evento($self);
}

sub cambios {
  my $self = shift;
  return $self->{_cambios};
}

sub peso {
  my $self = shift;
  my $cambio = shift;
  my $peso = shift;
  foreach my $reg (@{$self->cambios}) {
    if($reg->{cambio} eq $cambio) {
      if(defined $peso) {
        $reg->{peso} = $peso;
      }
      return $reg->{peso};
    }
  }
}


sub guardar {
  my $self = shift;
  my $db = $self->app->db;
  my $eventos = $db->get_collection('evento');
  return $eventos->insert($self->serializar);
}

sub serializar {
  my $self = shift;
  my $ref = {%{$self}};
  delete $ref->{_app};
  foreach my $reg (@{$ref->{_cambios}}) { 
    $reg = {%{$reg}};
    $reg->{cambio} = $reg->{cambio}->serializar;
  }
  return $ref;
}


1;
