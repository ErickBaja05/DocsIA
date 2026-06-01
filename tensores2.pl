# Todo programa que usted desarrolle debe cargar las siguientes librerías:
use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

# Find the min and max values for each column

sub dataset_min_max{
    my ($self, $dataset) = @_;
    my $minmax  = mx->nd->stack($dataset->min->(axis => 0), $dataset->max->(axis => 0)) -> transpose;
    return $minmax;
}

sml->add_to_class('dataset_min_max', \&{'dataset_min_max'});

my $filename = "./data/pima-indians-diabetes.csv";

my $dataset = sml->load_csv($filename);

#TRANSFORMACION A TENSOR

$dataset = mx->nd->array($dataset);

#SE RECORTA LOS DATOS ELIMINANDO LA COLUMNA CON LA ETIQUETA

#AXIS1 => SE MUEVE DE IZQUIERDA A DERECHA, TOMA TODO MENOS LA ULTIMA DE LA ETIQUETA
my $dataset_columns = $dataset->slice_axis(axis=>1, begin =>0, end => -1);

my $min_max = sml -> min_max($dataset_columns);

# Function To Normalize a Dataset.

sub normalize_dataset_tensor {
    my ($self, $dataset,$min_max) = @_;
    
    my ($min, $max) = @{$min_max -> transpose};
    
    # 2. Aplicamos la fórmula tensorial gracias al Broadcasting
    my $dataset_normalized = ($dataset - $min) / ($max - $min);
    return $dataset_normalized;
}

sml->add_to_class('dataset_min_max', \&{'dataset_min_max'});





sub standardize_dataset{
    my($self, $dataset, $mean, $stdevs) = @_;
    my $datasetStandar = ($dataset - $mean) / $stdevs;
    return $datasetStandar;
}
