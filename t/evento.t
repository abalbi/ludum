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
  $db->drop;
  MockManager->limpiar;
};

sub after : Test(teardown) {
  MockManager->terminar;
}

# Issue c7b2f72a
sub agregar_cambio_a_evento : Test(2) {
  my $self = shift;
  my $ca1 = $self->{t}->app->fabrica->traer('Cambio');
  my $ev = $self->{t}->app->fabrica->traer('Evento');
  $ev->agregar($ca1);
  is(scalar(@{$ev->cambios}),1,'Un cambio mas para el Evento');
  is($ev->cambios->[0]->{cambio}, $ca1,'El cambio agregado es accesible')
}

#--- Issue 855213ea ---
sub peso_para_cambio : Test(1) {
  my $self = shift;
  my $ca1 = $self->{t}->app->fabrica->traer('Cambio');
  my $ev = $self->{t}->app->fabrica->traer('Evento');
  $ev->agregar($ca1);
  $ev->peso($ca1,10);
  is($ev->peso($ca1),10);
}

# Issue 41bb3ea2
sub IDs_para_eventos : Test(1) {
  my $self = shift;
  my $ev = $self->{t}->app->fabrica->traer('Evento');
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
  my $ca1 = $app->fabrica->traer('Cambio');
  my $ca2 = $app->fabrica->traer('Cambio');
  my $ev = $app->fabrica->traer('Evento');
  $ev->agregar($ca1);
  $ev->agregar($ca2);
  ok($ev->guardar,'Guardo Evento');
  is($db->get_collection('evento')->find({_ID => $ev->ID})->count, 1,"Chequeo contra la base"); 
}

sub cargar_evento_desde_db : Test(1) {
  my $self = shift;
  my $app = $self->{t}->app;
  my $db = $app->db;
  my $ca1 = $app->fabrica->traer('Cambio');
  my $ca2 = $app->fabrica->traer('Cambio');
  my $ev = $app->fabrica->traer('Evento');
  $ev->agregar($ca1);
  $ev->agregar($ca2);
  $ev->guardar;
  my $id = $ev->ID;
  my $ev2 = $app->fabrica->traer('Evento', $id);
  is_deeply($ev,$ev2);
}

#--- Issue 92b9cb50 ---
sub ordenar_cambios_por_peso : Test(1) {
  my $self = shift;
  my $ca1 = $self->{t}->app->fabrica->traer('Cambio');
  my $ca2 = $self->{t}->app->fabrica->traer('Cambio');
  my $ev = $self->{t}->app->fabrica->traer('Evento');
  $ev->agregar($ca1);
  $ev->agregar($ca2);
  $ev->peso($ca1,20);
  $ev->peso($ca2,10);
  is_deeply($ev->cambios,[
    { cambio => $ca2, peso => 10 },
    { cambio => $ca1, peso => 20 },
  ]);
}

1;

