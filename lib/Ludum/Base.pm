package Ludum::Base;
use fields qw(_ID);
sub new {
  my $self = shift;
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
1;
