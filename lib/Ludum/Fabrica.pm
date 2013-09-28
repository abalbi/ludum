package Fabrica;
use Data::Dumper;
use fields qw(_IDs);

sub new {
  return bless {
    _IDs => {}
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
  $self->{_IDs}->{$ID} = $obj;
  return $obj;
}
1;
