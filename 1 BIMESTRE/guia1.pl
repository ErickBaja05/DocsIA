# Todo código debe tener al menos esas 3 funciones
use strict; # Forza la declaración de las variables
use warnings; # Genera mensajes de error de sintaxis
use Data::Dump qw(dump); # Para la impresión de estructuras de datos


# Librerías adicionales
use List::Util qw(zip min max sum any all first none); # Reorganizar los arreglos con zi
use Tie::IxHash; # Preserva el orden de registro en arreglos asociativos
# use aliased 'jjap::numperl' => 'np';

print "Hola Mundo!!!\n";

my $z = 0.127; # real
my $x = 3.22e-14; # real
my $c = 1567; # entero
my $d = -122; # entero
print $x;
print "\n";

$x = 0377; # Representación octal, equivale a 255 decimal
my $y = 0xff; # Representación hexadecimal, equivale a 255

print $x;
print sprintf("%o", $x);
print $y;
print sprintf("%X", $y);
print sprintf("%.3f", 3.14151692);

print "\n";

my $cadena = "Brothers\t$x\n";
print $cadena;

$cadena = 'Brothers\t$x\n';
print $cadena;

my $p;
if ($p){
print "Verdadero";
}else{
print "Falso";
}

print dump $p;

my @array = (); # Declaro arreglo e lo inicializo vacío


@array = (10, 3, 7, "word");


push @array, "new"; # Agrega al final del array


unshift @array, "beginning"; # Agrega al inicio del array

splice @array, 2, 0, "between"; # Agrega en una posición arbitraria

print "\n@array \n";

my @array2 = @array[1 .. $#array]; # Imprimir 3, 7, "word", necesito un slice
print "@array2";

my $var1 = pop @array;# Retiro el elemento final del arreglo
print "var1:$var1\n";
print "array:", dump @array;

@array = (1 .. 5);
$var1 = splice @array, 2, 0, ( 6 .. 9 );# Retiro un elemento de una posición arbitraria
print "var1:$var1\n" if defined $var1;
print "array:", dump @array;

my @list1 = (0, 1, 2);
my @list2 = (3, 4, 5);
# Producir una lista3 que contenga los valores alternados
# de las 2 listas dadas: (0, 3, 1, 4, 2, 5) en un solo comando

my @lista3 = (@list1, @list2); # Concatenación de 2 listas simples

print dump zip (\@list1, \@list2);


my $ref1 = [1,3,5];
my $ref2 = [2,4,6];

my @sumatorias = map {$_->[0] + $_->[1]} zip ($ref1, $ref2);


