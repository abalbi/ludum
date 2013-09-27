use strict;
use Data::Dumper;
use Getopt::Std;
my %args;
getopt('e', \%args);
my $file = shift;
die "No se encontro $file" if $file && not -e $file;
die "No se puede ejecutar un archivo y un inline al mismo tiempo" if $args{e} && $file;

print Dumper parser("16");
print Dumper parser("7 + 9");


exit;

sub parser {
  my $code = shift;
  my $obj->{code} = $code;
  $obj->{mod} = 1;
  while ($obj->{mod}) {
    $obj->{mod} = 0;
    $obj->{valor} = $obj->{code} if not $obj->{valor};
    parser_dados($obj);
    parser_operacion($obj);
    parser_digito($obj);
  }
  return $obj;
}

sub parser_digito {
  my $obj = shift;
  my $valor = $obj->{valor};
  my $rex = qr/(\d*)d(\d*)/i;
  if($valor =~ /$rex/) {
    $obj->{mod} = 1;
  }
  return $obj;
}

sub parser_operacion {
  my $obj = shift;
  my $valor = $obj->{valor};
  if($valor =~ /^([\d\+\*\/\- ]+)$/) {
    $valor = eval "$1";
    $obj->{valor} = $valor;
    $obj->{mod} = 1;
  }
  return $obj;
}

sub parser_digito {
  my $obj = shift;
  my $valor = $obj->{valor};
  if($valor =~ /^(\d+)$/) {
    my $valor = $1;
    $obj->{valor} = $valor;
    $obj->{mod} = 0;
  }
  return $obj;
}

my $rex = [
  { rule => qr/^([^\[]*)/, code => \&comp_string },
  { rule => qr/^\[([^[]*)\]/, code => \&comp_code },
];

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
