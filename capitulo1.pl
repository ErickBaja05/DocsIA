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

$x = 0377; # Representación octal, equivale a 255 decimal
my $y = 0xff; # Representación hexadecimal, equivale a 255

my @array = (); # Declaro arreglo e lo inicializo vacío
print dump @array;

@array = (10, 3, 7, "word");
print dump @array;

push @array, "new"; # Agrega al final del array
print "@array";

unshift @array, "beginning"; # Agrega al inicio del array
print dump @array;

splice @array, 2, 0, "between"; # Agrega en una posición arbitraria
print dump @array;

print $#array; #LONGIDUT DEL ARREGLO .

#DESDE LA 1 HASTA EL FINAL.
my @array2 = @array[1 .. $#array]; # Imprimir 3, 7, "word", necesito un slice
print "@array2";


my $var1 = pop @array;# Retiro el elemento final del arreglo
print "var1:$var1\n";
print "array:", dump @array;


$var1 = shift @array;# Retiro el elemento inicio del arreglo
print "var1:$var1\n";
print "array:", dump @array;

my @list1 = (0, 1, 2);
my @list2 = (3, 4, 5);
# Producir una lista3 que contenga los valores alternados
# de las 2 listas dadas: (0, 3, 1, 4, 2, 5) en un solo comando.

print dump zip (\@list1, \@list2); # La función zip agrupa los elementos de cada lista d
# Las entradas son referencias a arreglos.
# Produce una lista simple como salida.


my @arreglo = (1, 3, 5); # Inicializamos el arreglo
my @foo = @arreglo;
# Copiamos el arreglo
@arreglo = ();
# Limpiamos el arreglo
print "arreglo:", dump (@arreglo), "\n";
print "foo:", dump (@foo), "\n";

# CON MAP HAGO REFERENCIA A ACADA ELEMENTO. $_ ESE EL ELEMENTO y le hago alguja operaciona
print dump (map { $_  *3} -1 .. 3);

# CON GREP, SACO UN ARREGLO DE LOS ELEMENTOS QUE CUMPLAN 1 CONDICION
print dump (grep { $_ > 0 } -1 .. 3);


my %months = (Jan => 1, Feb => 2, Mar => 3,
Apr => 4, May => 5, Jun => 6,
Jul => 7, Aug => 8, Sep => 9,
Oct => 10, Nov => 11, Dec => 12);
print dump keys %months;


print dump values %months;

my %stock = (limones => 6, peras => 3, uvas => 2); # Creamos arreglo asociativo con datos
# Use el caracter % para refirirse a todos los miembros del arreglo asociativo
print dump %stock;

# Use el caracter $ para refirirse a un miembro específico del arreglo asociativo
print $stock{peras};

my $A = 0;
my $B = 1;
print "A y B resulta verdadero\n" if $A and $B;
print "A o B resulta verdadero\n" if $A or $B;
print "A xor B resulta verdadero\n" if $A xor $B;
print "A nand B resulta verdadero\n" if not ($A and $B);