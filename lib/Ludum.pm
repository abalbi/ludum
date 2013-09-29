package Ludum;
use Mango;
use Mojo::Base 'Mojolicious';
use Ludum::Fabrica;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

 $self->helper(fabrica => sub { state $fabrica = Fabrica->new() });
 $self->helper(db => sub {
   state $db = Mango->new('mongodb://localhost:27017')->db('ludum_test');
 });

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

1;
