use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(shuffle);
use AI::MXNet qw(mx);
use sml;



# Defined in Section 3.2.1 Train and Test Split
# Function To Split a Dataset.
# Split a dataset into a train and test set

sub train_test_split{
    my ($self, $dataset, %args) = (splice (@_, 0, 2), split=>0.6, @_);
    # CON LEN SE OBTIENE EL NUMERO DE FILAS
    my $train_size = int($args{split} * $dataset->len);
    #my $idx = mx->nd->array([shuffle (0 .. $dataset->shape->[0])]);
    my $idx = mx->nd->arange(stop => $dataset->len)->shuffle;
    # EJE 0 PARA EL CORTE, PERO IDX ES VECTOR, EL EJE SE USA PARA MAS DE 1 DIMENSION
    my $train_idx = $idx->slice(begin => 0, end=> $train_size);
    my $test_idx = $idx->slice(begin => $train_size, end=> $dataset->len);
    my $train = mx->nd->take($dataset,$train_idx);
    my $test = mx->nd->take($dataset,$test_idx);
    return $train, $test;
}
sml->add_to_class('train_test_split', \&{'train_test_split'});

my $filename = "./data/pima-indians-diabetes.csv";
my $dataset = sml->load_csv($filename);
$dataset = mx->nd->array($dataset);

my ($train, $test) = sml->train_test_split($dataset);

print dump $train->shape;

print dump $test->shape;
