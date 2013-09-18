use strict;
use Data::Dumper;
use Getopt::Std;
my %args;
getopt('e', \%args);
my $rex = [
  { rule => qr/^([^\[]*)/, code => \&comp_string },
  { rule => qr/^\[([^[]*)\]/, code => \&comp_code },
];
my $file = shift;
die "No se encontro $file" if $file && not -e $file;
die "No se puede ejecutar un archivo y un inline al mismo tiempo" if $args{e} && $file;
while(1) {
  my $script = `cat $file`;
  $script = $args{'e'} if not $script;
  my $perl = $script;
  my $tree = [];
  $tree = check_rules($rex, $script);
  my $string;
  foreach (@{$tree}) {
    $string .= $_->{res};
  }
  open my $fh, ">$file";
  print $fh $string;
  close $fh;
  system("vim $file");
  print "Continue?";
  my $NOK = <STDIN>;
  chomp($NOK);
  last if $NOK;
}

sub check_rules {
  my $rules = shift;
  my $code = shift;
  my $callback = shift;
  my $results = [];
  while(1) {
    my $boo = 1;
    foreach my $rx (@{$rules}) {
      if($code =~ /$rx->{rule}/) {
        $code =~ s/$rx->{rule}//;
        push @{$results},{rule => $rx->{rule}, res => &{$rx->{code}}($1,$2)};
        $boo = 0;
    
      }
    }
    $boo = 1 if not $code;
    last if $boo;
  }
  return $results; 
}

sub comp_die {
  my $min = shift;
  my $max = shift;
  $max = 6 if not $max;
  my $c = $min;
  my @arr;
  while($c){
    push @arr, int(rand($max))+1;
    $c--;
  }
  my $sum = '('.join('+', @arr).')';
  return $sum;
}

sub comp_code {
  my $code = shift;
  my $string = $code;
  my $rx = qr/(\d*)d(\d*)/i;
  my $rex = [
    { rule => $rx, code => \&comp_die },
  ];
  my $arr = check_rules($rex, $string);
  foreach my $item (@{$arr}) {
    $string =~ s/$item->{rule}/$item->{res}/;
  }
  my $res = eval "$string";
  return "{ $code: $string => $res }";
}

sub comp_string {
  my $string = shift;
  return $string;
}
