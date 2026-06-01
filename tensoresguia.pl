# Todo programa que usted desarrolle debe cargar las siguientes librerías:
use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);


#ARANGE PERMITE CREAR UN TENSOR DE UNA SOLA DIMENSION O DE VARIAS (CON RESHAPE)


# my $x = mx->nd->arange(start => 0, #DESDE QUE NUMERO
#     stop => 12, #HASTA QUE NUMERO
#     step => 1, #CON QUE PASO
#     ctx => mx->cpu(0) #CON QUE PROCESADOR VA A TRABAJAR
#     );

#     #PARA IMPRIMIR EL TENSOR, SE USA EL ASPDL

# printf "%s\n", $x->aspdl;

# #AQUI SE HACE UN ARREGLO CON 12 VALORES, COMO 3X4 ES DOCE, SE USA RESHAPE PARA QUE SEA UNA MATRIZ DE 3 FILAS Y 4 COLUMNAS
# my $y = mx->nd->arange(stop => 12)->reshape([3, 4]);
# print $y, $y->aspdl;

# #PARA TRANSPONER MATRICES
# $x = $y->transpose();
# print $x, $x->aspdl;

# #ESTA OPERACION ES POSIBLE GRACIAS AL BROADCASTING


# $x = mx->nd->arange(stop=>12)->reshape([3,4]);
# print $x->aspdl;
# $y = mx->nd->arange(stop=>3)->reshape([3,1]); #automaticamente se completara para poder realizar la suma
# print $y->aspdl;
# my $z = $x + $y;
# print $z->aspdl;

# # AQUI OCURRE EXACTAMENTE LO MISMO DE ARRIBA, EL VALOR DE 2 CRECE AL 3 Y EL DE 0 SE HACE 4

# $y = mx->nd->array([2]);
# print $y->aspdl;
# $z = $x + $y;
# print $z->aspdl;


my $x = mx->nd->arange(stop => 12 * 2) / 2; #SE 
print $x->aspdl;



