sub misubrutina{
print "Soy una misubrutina.\n";
}

misubrutina();

sub function{
my %args = @_;
foreach my $key (keys %args){
print $key, " ", $args{$key}, "\n";
}
}

sub function2{
my %args = @_;
print "Nombre: ", $args{nombre}, "\n";
print "Edad: ", $args{edad}, "\n";
}


sub duplicar{
    my($arr) = @_;

   foreach my $num(@{$arr}){
    $num *=2;
   }
}

my @numeros = (2,5,6,7,8);

duplicar(\@numeros);

print "@numeros";