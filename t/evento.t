package Test::MockManager;
use Data::Dumper;
use base qw(Test::Class);
use lib 'lib';
use MockManager;
use MockObjectX;
use Test::More;
use Test::Mojo;
use Test::Exception;
use Evento;


__PACKAGE__->new->runtests;

sub before : Test(setup) {
  my $self = shift;
  $self->{t} = Test::Mojo->new('Ludum');
  my $app = $self->{t}->app;
  my $db = $app->db;
  #$db->get_collection('evento')->drop;
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
  my $ev = $self->{t}->app->fabrica->hacer('Evento');
  $mm->etiqueta($ca1,'cambio1');
  $mm->agregar(['cambio1','evento',$ev,$ev]);
  $ev->agregar($ca1);
  is(scalar(@{$ev->cambios}),1,'Un cambio mas para el Evento');
  is($ev->cambios->[0]->{cambio}, $ca1,'El cambio agregado es accesible')
}

#--- Issue 855213ea ---
sub peso_para_cambio : Test(1) {
  my $self = shift;
  my $mm = MockManager->instancia;
  my $ca1 = MockObjectX->new();
  my $ev = $self->{t}->app->fabrica->hacer('Evento');
  $mm->etiqueta($ca1,'cambio1');
  $mm->agregar(['cambio1','evento',$ev,$ev]);
  $ev->agregar($ca1);
  $ev->peso($ca1,10);
  is($ev->peso($ca1),10);
}

# Issue 41bb3ea2
sub IDs_para_eventos : Test(1) {
  my $self = shift;
  my $ev = $self->{t}->app->fabrica->hacer('Evento');
  ok($ev->ID =~ /[a-z|1-9]{8}/);
}

sub agregar_helper_db : Test(1) {
  my $self = shift;
  my $app = $self->{t}->app;
  my $db = $app->db;
  isa_ok($db,'MongoDB::Database');
}

sub guardar_evento_en_db : Test(2) {
  my $self = shift;
  my $app = $self->{t}->app;
  my $db = $app->db;
  my $mm = MockManager->instancia;
  my $ca1 = MockObjectX->new();
  my $ca2 = MockObjectX->new();
  my $ev = $app->fabrica->hacer('Evento');
  $mm->agregar([$ca1,'evento',$ev,$ev]);
  $mm->agregar([$ca2,'evento',$ev,$ev]);
  $mm->agregar([$ca1,'serializar',{}]);
  $mm->agregar([$ca2,'serializar',{}]);
  $ev->agregar($ca1);
  $ev->agregar($ca2);
  ok($ev->guardar);
  is($db->get_collection('evento')->find({_ID => $ev->ID})->count, 1); 
}
1;

