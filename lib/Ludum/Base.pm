package Ludum::Base;
use fields qw(_ID _app);
sub new {
  my $self = shift;
  my $hash = shift;
  unless (ref $self) {
    $self = fields::new($self);
  }
  $self->{_ID} = '';
  return $self; 
}


sub ID {
  my $self = shift;
  my $ID = shift;
  $self->{_ID} = $ID if defined $ID;
  return $self->{_ID};
}

sub app {
  my $self = shift;
  my $app = shift;
  $self->{_app} = $app if defined $app;
  return $self->{_app};
};

sub llenar {
  my $self = shift;
  my $hash = shift;
  $self->{_ID} = $hash->{_ID} if $hash->{_ID};
}
1;
