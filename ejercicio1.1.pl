# Todo código debe tener al menos esas 3 funciones
use strict; # Forza la declaración de las variables
use warnings; # Genera mensajes de error de sintaxis
use Data::Dump qw(dump); # Para la impresión de estructuras de datos


# Librerías adicionales
use List::Util qw(zip min max sum any all first none); # Reorganizar los arreglos con zip

my $db = [
{ nombre => "Ana", notas => [10, 20] },
{ nombre => "Luis", notas => [15, 25] }
];


my @notasAna = @{$db ->[0]->{notas}} ;
my @notasLuis = @{$db ->[1] ->{notas}};

print "Notas de Ana: ";
print "@notasAna\n"; 

print "Notas de Luis: ";
print "@notasLuis\n"; 


# PARTE 2: PROMEDIAR LAS NOTAS POR ESTUDIANTE

foreach my $elemento(@$db){
    my $sumatoria = sum(@{$elemento -> {notas}});
    my $promedio = $sumatoria / @{$elemento -> {notas}};

    printf "Promedio de notas de %s -> %.2f\n", $elemento ->{nombre},$promedio;
}


# PARTE 3: ITERAR SOBRE TODA LA ESTRUCTURA Y SUBESCTRUCTURAS (3 FOR)

foreach my $elemento2(@$db){
    # AQUI TAMBIEN DEBES DESREFERENCIAR
    for my $key (keys %$elemento2){
        if (ref($elemento2-> {$key}) eq 'ARRAY'){

            for my $elementoInterno (@{$elemento2-> {$key}}){
                printf "%d\n",$elementoInterno;
            }

        }else{
            printf "%s ---> %s\n", $key, $elemento2 -> {$key}
        }

    }
}
