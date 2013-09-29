package Fabrica;
use Data::Dumper;
use fields qw(_IDs _app);

sub new {
  my $pkg = shift;
  my $app = shift;
  return bless {
    _IDs => {},
    _app => $app
  }, 'Fabrica';
}

sub hacer {
  my $self = shift;
  my $pkg = shift;
  my $obj;
  my $code = "\$obj \= $pkg\-\>new\(\)";
  eval $code;
  my $ID;
  while (1) {
    $ID = join '',(map { ("a".."z", 0..9)[rand 36] } 1..8);
    last if not exists $self->{_IDs}->{$ID};
  }
  $obj->ID($ID);
  $obj->app($self->app);
  $self->{_IDs}->{$ID} = $obj;
  return $obj;
}

sub app {shift->{_app}};
1;
