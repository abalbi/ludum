package Cambio;
use Data::Dumper;
use Mojolicious;
use strict;
use base 'Ludum::Base';
use fields qw(_ID _app _evento);

sub new {
  my $class = shift;
  my $self = fields::new($class);
  $self->SUPER::new();
  return $self;
}

sub no_ID { return 1; }

sub evento {
  my $self = shift;
  my $evento = shift;
  $self->{_evento} = $evento if defined $evento;
  return $self->{_evento};
}

sub serializar {
  my $self = shift;
  my $ref = {%{$self}};
  delete $ref->{_app};
  delete $ref->{_evento};
  return $ref;
}

1;
