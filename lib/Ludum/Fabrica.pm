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
  $obj->app($self->app);
  if (not $obj->no_ID) {
    $obj->ID($ID);
    $self->{_IDs}->{$ID} = $obj;
  }
  return $obj;
}

sub cargar {
  my $self = shift;
  my $pkg = shift;
  my $ID = shift;
  my $obj = shift;
  my $db = $self->app->db;
  my $hash = $db->get_collection(lc $pkg)->find({_ID => $ID})->next;
  $obj = $self->hacer($pkg) if not defined $obj;
  $self->llenar($obj,$hash);
  return $obj;
}

sub traer {
  my $self = shift;
  my $pkg = shift;
  my $arg = shift;
  my $obj = $self->hacer($pkg);
  if (defined $arg) {
    if (not ref $arg) {
      $self->cargar($pkg,$arg,$obj);
    } else {
      $self->llenar($obj,$hash);
    }
  }
  return $obj;
}

sub llenar {
  my $self = shift;
  my $obj = shift;
  my $hash = shift;
  $obj->llenar($hash);
}

sub app {shift->{_app}};
1;
