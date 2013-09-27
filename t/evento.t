package Test::MockManager;
use Data::Dumper;
use base qw(Test::Class);
use lib 'lib';
use MockManager;
use MockObjectX;
use Test::More;
use Test::Exception;
use Evento;


__PACKAGE__->new->runtests;

sub before : Test(setup) {
  MockManager->limpiar;
};

sub after : Test(teardown) {
  MockManager->terminar;
}

# Issue c7b2f72a
sub agregar_cambio_a_evento : Test(2) {
  my $self = shift;
  my $mm = MockManager->instancia;
  my $ca1 = MockObjectX->new();
  my $ev = Evento->new();
  $mm->etiqueta($ca1,'cambio1');
  $mm->agregar(['cambio1','evento',$ev,$ev]);
  $ev->agregar($ca1);
  is(scalar(@{$ev->cambios}),1);
  is($ev->cambios->[0], $ca1)
}

1;

