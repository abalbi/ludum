package Evento;
use Data::Dumper;
use Mojolicious;
use strict;
use Cambio;
use base 'Ludum::Base';
use fields qw(_cambios _ID _app);

sub new {
  my $class = shift;
  my $self = fields::new($class);
  $self->SUPER::new();
  $self->{_cambios} = [];
  return $self;
}


sub no_ID { return 0; }


sub agregar {
  my $self = shift;
  my $cambio = shift;
  push @{$self->cambios}, {cambio => $cambio, peso => 0};
  $cambio->evento($self);
}

sub cambios {
  my $self = shift;
  my $sorted = [sort {$a->{peso} <=> $b->{peso}} @{$self->{_cambios}}];
  $self->{_cambios} = $sorted;
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
  $ref->{_cambios} = [];
  foreach my $cambio (@{$self->cambios}) { 
    my $reg = {%{$cambio}};
    $reg->{cambio} = $cambio->{cambio}->serializar;
    push @{$ref->{_cambios}}, $reg;
  }
  return $ref;
}

sub llenar {
  my $self = shift;
  my $hash = shift;
  $self->SUPER::llenar($hash);
  foreach my $reg (@{$hash->{_cambios}}) {
    $self->agregar($self->app->fabrica->traer('Cambio',$reg->{cambio}));
  }
}

1;
