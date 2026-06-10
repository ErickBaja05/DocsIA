# Todo programa que usted desarrolle debe cargar las siguientes librerías:
use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

my $x = mx->nd->arange(start => 0,
    stop => 12,
    step => 1,
    ctx => mx->cpu(0));
    printf "%s\n", $x->aspdl;
my $y = $x->as_in_context(mx->cpu(1));
print $y;

# CONVERTIR UN ARREGLO A UN TENSOR 

my $a = [1,2];

$a = mx->nd->array($a);

my $b = mx->nd->arange(start => 1, step =>3, stop => 28, ctx => mx->cpu(5));

print $x->aspdl; #PARA IMPRIMR UN TENSOR
print $b; #PARA IMPRIMIR LA DEFINICION DEL CONTEXTO

my $c = mx->nd->array([1,3]);
print $c ->aspdl;

my $cubo -> mx->nd->full([2,3,4],5);

print $cubo ->aspdl;
