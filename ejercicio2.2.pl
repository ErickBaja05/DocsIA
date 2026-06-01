
use List::Util qw(zip min max sum any all first none);
# FUNCION PROMEDIO

sub promedio{
    my($numeros) = @_;

    foreach my $numero(@{$numeros}){
        if($numero !~ m/^\d+(?:\.\d+)?$/){
            print "Hay datos que no son numericos, no se puede calcular";
            return;
        }
    }

    my $promedio = sum(@{$numeros}) / @{$numeros};
    return $promedio;
}

my @arreglo1 = (1,3,4,5,2,3,4,5);
my @arreglo2 = (1,2,"hola",4,"Erick");

promedio(\@arreglo1);
promedio(\@arreglo2);

# # CREAR ESTUDIANTE CON DATOS OBLIGATORIOS Y OPCIONALES

# sub crear_estudiante{

#     my($apellidos, $email, %opcionales) = (splice(@_,0,2),ciudad =>"DEFAULT",@_) ;

#     if(!defined $apellidos){
#         print "NO SE DEFINIO APELLIDO\n";
#         return;
#     }

#     if(!defined $email){
#         print "NO SE DEFINIO EMAIL\n";
#         return;
#     }

#     print "Apellidos: $apellidos\n";
#     print "Email: $email\n";
#     print "Ciudad: $opcionales{ciudad}\n";
# }

# #crear_estudiante("Bajania",'erick@erick.com');
# #crear_estudiante("Almeida","cami.com",'ciudad' => "Quito");


# # OOP DEFINICION DE CLASEA

# package Estudiante{
#     sub new{
#         my ($class,$nombre,$nota) = @_;
#         my $self ={
#             nombre => $nombre,
#             nota => $nota,
#         };
#         return bless ($self,$class)
#     }

#     sub nombre{
#         my($self,$nombre) = @_;
#         $self ->{nombre} = $nombre if defined $nombre;
#         return $self -> {nombre};

#     }

#     sub nota{
#         my($self,$nota) = @_;
#         $self ->{nota} = $nota if defined $nota;
#         return $self -> {nota};

#     }

#     sub aprueba{
#         my($self,$nota) = @_;
#         return $self -> {nota} >= 7;
#     }

#     1;
# }

# my $estudiante1 = new Estudiante("Erick",10);
# my $estudiante2 = new Estudiante("Fer",5);


# if($estudiante1 -> aprueba()){
#     printf "%s APROBO\n", $estudiante1 ->nombre();
# }else{
#     printf "%s NO APROBO\n", $estudiante1 ->nombre();
# }

# if($estudiante2 -> aprueba()){
#     printf "%s APROBO\n", $estudiante2 ->nombre();
# }else{
#     printf "%s NO APROBO\n", $estudiante2 ->nombre();
# }

# #OOP HERENCIA

# package EstudianteBecado{
#     use base qw(Estudiante);

#      sub new{
#         my ($class,$monto_beca,) = @_;
#         my $self ={
#             monto_beca => $monto_beca,
#         };
#         return bless ($self,$class)
#     }

#     sub monto_beca{
#         my($self,$monto_beca) = @_;
#         $self ->{monto_beca} = $monto_beca if defined $monto_beca;
#         return $self -> {monto_beca};

#     }

#     1;

# }
