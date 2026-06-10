package sml{
use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum uniq all any shuffle);
use AI::MXNet qw(mx);
use Tie::IxHash;
# https://stackoverflow.com/questions/28373405/add-new-method-to-existing-object-in-
    sub add_to_class{ #@save
    # Register functions as methods in created class.
    my($class, $method_name, $code_ref) = @_;
    {
        # We need to use symbolic references.
        no strict 'refs';
        no warnings;
        # Shove the code reference into the class' symbol table.
        *{$class.'::'.$method_name} = $code_ref;
        }
    }
    

    sub str_column_to_float{
        my ($self, $dataset, $column, %args) = (splice (@_, 0, 3), precision=>1, @_);
        return if ($dataset->[0][$column] !~ /^\d+/);
        $args{precision} = '%.' . $args{precision} . 'f';
        for my $row (@$dataset){
        $row->[$column] = sprintf ($args{precision}, $row->[$column]);
        }
    }

    sub str_column_to_int{
        my ($self, $dataset, $column) = @_;
        my $class_values = [map {$_->[$column]} @$dataset];
        my @unique = uniq @$class_values;
        my %lookup = ();
        while (my ($i, $value) = each @unique) {
        $lookup{$value} = $i;
        }
        for my $row (@$dataset){
        $row->[$column] = $lookup{$row->[$column]};
        }
        return \%lookup;

    }

    sub load_csv{
        my ($self, $file_path, %args) = (splice(@_, 0, 2), delimiter => '[,;\t]', @_);
        
        open (FILE, "<", $file_path) or die "Cannot open file $file_path: $!";
        my $header = <FILE>;
        chomp($header);
        my @dataset = ();
        while (<FILE>){
        my $row = $_;
        $row =~ s/[\r\n]+$//g; # Regular expression that deletes characters such as \r \n 
        next if (!defined $row || $row =~ /^\s*$/);
        push @dataset, [split /$args{delimiter}/, $row];
        }
        close FILE;
        
        return wantarray ? (\@dataset, $header) : \@dataset;
    }

    sub get_min_max_values{
    my($self,$dataset) = @_;
    
    my $minmax = mx->nd->stack($dataset->min(axis=>0),$dataset->max(axis=>0)) -> transpose;

    return $minmax;

    # ESTA FUNCION DEVUELVE UNA MATRIZ DONDE CADA FILA REPRESENTA UNA COLUMNA DEL DATASET, LA POS 0 ES EL MINIMO DE ESA COLUMNA Y LA POS 1 ES EL MAXIMO DE ESA COLUMNA.

    # MINMAX = [0 2]   CON ESTE EJEMPLO DE LA IZQUIERDA, HAY 2 COLUMNAS EN 
    #          [1 5]   EL DATASET. DE LA PRIMERA MIN 0 Y MAX 2.


    }

    sub normalize_dataset{

    my($self,$dataset,$minmax) = @_;

    # SE HACE TRANSPUESTA PORQUE ASI, LA PRIMERA FILA SERAN LOS MINIMOS Y SE GUARDARAN EN MIN VALUES, Y LAS SEGUNDA LOS MAXIMOS Y SE GUARDAN EN MAX VALUES.

    my ($min_values, $max_values) = @{$minmax ->transpose};

    my $normalized_dataset = ($dataset - $min_values) / ($max_values - $min_values);
    return $normalized_dataset;

    }

    sub get_average_and_std{
    my($self,$dataset) = @_;

    my $mean = $dataset->sum(axis => 0) / $dataset->shape->[0];

    my $differences = mx->nd->square($dataset - $mean);

    my $std = mx->nd->sqrt($differences->sum(axis=>0)/  $dataset->shape->[0]);

    my $meanStd = mx->nd->stack($mean,$std)->transpose;

    # ESTA FUNCION DEVUELVE UNA MATRIZ DONDE CADA FILA REPRESENTA UNA COLUMNA DEL DATASET, LA POS 0 ES EL PROMEDIO DE ESA COLUMNA Y LA POS 1 ES LA DESVIACION ESTANDAR DE ESA COLUMNA.

    # meanStd = [2 3]   CON ESTE EJEMPLO DE LA IZQUIERDA, HAY 2 COLUMNAS EN 
    #          [1 5]   EL DATASET. DE LA PRIMERA average 0 Y std 3.

    return $meanStd
    }


    sub standardize_dataset{

    my($self,$dataset,$meanStd) = @_;
    
    my($mean, $std) = @{$meanStd ->transpose};

    my $datasetStandar = ($dataset - $mean) / $std;

    return $datasetStandar;
    }


    sub train_test_split{
    my($self,$dataset,%args) = (splice (@_,0,2), split =>0.6, @_);
    mx->random->seed(42); #SE DEBE FIJAR LA SEMILLA SIEMPRE

    #OBTENER EL NUMERO DE FILAS PARA SABER CUANTAS PARA TRAINING Y CUANTAS PARA TESTING

    my $rows = $dataset->len; #LEN YA ES UN ESCALAR

    #SE DEBE TRANSFORMAR A ENTEROS
    my $rows_training = int($rows * $args{split});

    #SE CREA UN VECTOR CON LOS INDICES DEL DATASET PERO DE FORMA ALEATORIA

    my $idxRows = mx->nd->arange(stop => $rows) ->shuffle;

    #SE SEPARAN LOS INDICES DE ENTRENAMIENTO Y DE TESTEO

    my $idxTraining = $idxRows->slice(begin => 0, end => $rows_training);
    my $idxTesting = $idxRows->slice(begin => $rows_training, end=> $dataset -> len);

    #SE TOMAN LOS DATOS
    my $train = mx->nd->take($dataset,$idxTraining);
    my $test = mx->nd->take($dataset,$idxTesting);
    return $train, $test;


    }

    sub cross_validation_split{

    my ($self, $dataset, %args) = (splice(@_, 0, 2), n_folds => 10, @_);
    
    #SEMILLA RANDOM PAR LOS DATOS

    mx->random->seed(12);

    #CALCULAMOS EL NUMERO DE FILAS DEL DATASET

    my $rows = $dataset ->len;

    #CALCULAMOS EL NUMERO DE FILA PARA CADA FOLD

    my $rowsForFold = int($rows / $args{n_folds});

    #ELIMINAMOS LAS SOBRANTES

    my $usableRows = $rowsForFold * $args{n_folds};

    #INDICES DEL DATASET DE FORMA RANDOMICA

    my $idx = mx->nd->arange(stop=>$rows)->shuffle ->slice(begin => 0, end => $usableRows);

    #TRANSFORMACION AL TENSOR 2D PARA GUARDAR LOS FOLDS

    my $folds_idx = $idx->reshape([$args{n_folds},$rowsForFold]);

    # DE ESTE MODO, SE CREA UNA MATRIZ DONDE CADA FILA GUARDA LOS INDICES
    # DE LAS FILAS QUE DEBE TENER CADA FOLD

    # [ -----> EL FOLD 3 CONTIENE LAS FILAS 2 Y 9 DEL DATA SET 

    #TOMA DE LOS DATOS DEL DATA SET

    my $folds_data = mx->nd->take($dataset, $folds_idx);

    # ESTO CREA UN TENSOR TRIDIMENSIONAL DONDE CADA PAGINA ES UN FOLD
    # Y DENTRO DE CADA PAGINA HAY UNA MATRIZ CON LAS FILAS SELECCIONADAS

    return $folds_data;

    }

    sub accuracy_metric{
    my ($self, $actual, $predicted) = @_;
    
    
    my $correct_tensor = $actual == $predicted;
    
    
    my $correct_sum = $correct_tensor->sum();
    
    
    my $accuracy = ($correct_sum / $actual->size) * 100.0;
    
    return $accuracy->asscalar;
    } 

   
    sub perf_metrics_clasification{
    my($self,$actual,$probabilities,$thresholds) = @_;

    my $num_classes = $actual->max->asscalar + 1;

    my $actual_oh = mx->nd->one_hot($actual, $num_classes);


    my @tprs;
    my @fprs;
   

    my @tresholds_array = @{$thresholds->aspdl->unpdl};

    foreach my $t (@tresholds_array){
        my $predicted = $probabilities >= $t;

        my $predicted_oh = mx->nd->one_hot($predicted, $num_classes);

        my $matrix = mx->nd->dot($actual_oh->T, $predicted_oh);

      
        my $tp = $matrix->at(0,0)->asscalar;
        my $fn = $matrix->at(0,1)->asscalar;
        my $fp = $matrix->at(1,0)->asscalar;
        my $tn = $matrix->at(1,1)->asscalar;

        my $tpr = $tp / ($tp + $fn); # True Positive Rate --- SENSIBILIDAD
        my $fpr = $fp / ($fp + $tn); # False Positive Rate ---


        #HACER CON ESTE FORMATO ES CLAVE PARA QUE FUNCIONE!!!.
        push @fprs, sprintf('%0.2f', $fpr);
        push @tprs, sprintf('%0.2f', $tpr);

    }

    return (\@fprs, \@tprs);


    }

    sub confusion_matrix{
        my($self,$actual,$predicted) = @_;

        my $num_classes = $actual->max->asscalar + 1;

        my $actual_oh = mx->nd->one_hot($actual, $num_classes);
        my $predicted_oh = mx->nd->one_hot($predicted, $num_classes);
        my $matrix = mx->nd->dot($actual_oh->T, $predicted_oh);

        return $matrix;
    }

    sub get_MAE{
    my($self,$actual,$predicted) = @_;

    my $differences = mx->nd->abs($actual - $predicted);
    my $MAE = $differences->sum() / $differences ->len;

    return $MAE;

    }

    sub get_RMSE{
    my($self,$actual,$predicted) = @_;

    my $differences = mx->nd->square($actual - $predicted);
   
    my $RMSE = mx->nd->sqrt($differences->sum() / $differences ->len);

    return $RMSE->asscalar;
    }


    sub random_algorithm{
        my($self, $train, $test) = @_;

        #SE RECUPERAN LAS ETIQUETAS, SIEMPRE DESDE EL TRAIN:

        my $labels = $train->slice_axis(axis=>1,
        begin=>$train->shape->[1] -1, 
        end => $train->shape->[1]);

        #SE OBTIENE EL VALOR DE LA CLASE MAS ALTA PORQUE CON ESTA SE HARA EL RANDOM

        my $max_label = $labels->max->asscalar;

        #SE CREA EL TENSOR CON VALORES ALEATORIOS DE 0 A EL VALOR DE LA CLASE MAS ALTA

        my $predicted = mx->nd->random->randint(
            low   => 0, 
            high  => $max_label + 1, 
            shape => [$test->len]
        );

        return $predicted;

    }

    sub zero_rule_classification{

    # SE UTILIZA UNICAMENTE CUANDO EL NUMERO DE CLASES ES ESTRICTAMENTE 2 Y ESTAN DESEQUILIBRADAS
    my($self, $train, $test) = @_;

    #SE RECUPERAN LAS ETIQUETAS:

    my $labels = $train->slice_axis(axis=>1,
    begin=>-1, 
    end => $train->shape->[1]);

    # SE SACA LA ETIQUETA MAXIMA Y EL NUMERO DE ETIQUETAS

    my $max_label = $labels ->max->asscalar;

    my $num_classes = $max_label + 1;

    # SE HACE ONE HOT PARA PODER TENER UNA MATRIZ PARA CONTAR CUANTAS VECES APARECIO CADA ETIQUETA

    my $one_hot = mx->nd->one_hot($labels,$num_classes);

    # SE OBTIENE EL VECTOR QUE SUMA LAS COLUMNAS (PARA SABER CUANTAS VECES SE REPITE UNA ETIQUETA)

    my $frecuencias = $one_hot->sum(axis => 0);

    #SE OBTIENE EL INDICE DE EN QUE POSICION DEL VECTOR ESTA EL VALOR MAS ALTO, ESTO DEVUELVE DIRECTO EL VALOR DE LA CLASE PORQUE ESTAN MAPEADAS GRACIAS AL ONE HOT

    my $clase_mayoritaria = mx->nd->argmax($frecuencias);

    # SE ARMA EL VECTOR RESULTANTE PARA LA PREDICCION

    my $predicted = mx->nd->full([$test->len],$clase_mayoritaria->asscalar);

    return $predicted;

    }

    sub evaluate_algorithm_train_test_split{
    my ($self, $dataset, $algorithm) = splice @_, 0, 3;
    
    my %args = (split => 0.6, metric => undef, @_);

    my ($train, $test) = sml->train_test_split($dataset, split=>$args{split});
    my ($actual, $predicted, $score);

    $predicted = $algorithm->('sml', $train, $test, @_);
    $actual = $test->slice_axis(axis => 1, begin => $test->shape->[1] -1, end => $test->shape->[-1])->squeeze();

    if (defined $args{metric}) {
        if ($args{metric} =~ /accuracy/i) {
            $score = sml->accuracy_metric($actual, $predicted);
        } elsif ($args{metric} =~ /rmse/i) {
            $score = sml->get_RMSE($actual, $predicted);
        }
    } else {
        # VERIFICACIÓN TENSORIAL:
        # 1. $actual->round() redondea todos los valores.
        # 2. ($actual == $actual->round()) genera un tensor de 1s (iguales) y 0s (distintos).
        # 3. Si la suma de esos 1s es exactamente igual al tamaño total del tensor, todos son enteros.
        my $is_integer = ($actual == $actual->round())->sum()->asscalar == $actual->size;

        if ($is_integer) {
            $score = sml->accuracy_metric($actual, $predicted);
        } else {
            $score = sml->get_RMSE($actual, $predicted);
        }
    }

    return wantarray ? ($score, $train, $test, $actual, $predicted) : $score;

    }

    sub evaluate_algorithm_cross_validation_split{
    # 1. Extraemos argumentos y seteamos defaults antes de @_
    my ($self, $dataset, $algorithm) = splice @_, 0, 3;
    my %args = (n_folds => 10, metric => undef, @_);

    # 2. Obtenemos el TENSOR 3D con nuestros folds
    
    my @folds = @{sml->cross_validation_split($dataset, n_folds=>$args{n_folds})}; #SE REDUCEN 1 DIMENSION,LA MAS EXTERNA
    my (@scores, @train_losses, @test_losses, @actuals, @predictions);
    
    # Obtenemos el número de columnas (features) para usarlo al remodelar
    my $num_features = $dataset->shape->[1];

    
    for my $i (0 .. $args{n_folds} - 1) {
        
        my @train_set = @folds;
        
        my $test_set = splice @train_set, $i, 1;

        my $train_set = mx->nd->concat(@train_set, dim=>0);
        

        # --- EJECUCIÓN DEL ALGORITMO ---
        my ($predicted, $train_loss, $test_loss) = $algorithm->('sml', $train_set, $test_set, %args);

        # Extraemos la última columna del test_set para comparar (los valores reales)
        my $last_col_idx = $num_features - 1;
        my $actual = $test_set->slice_axis(axis => 1, begin => $last_col_idx, end => $last_col_idx + 1)->squeeze();

        # --- VERIFICACIÓN DE MÉTRICAS ---
        my $score;
        if (defined $args{metric}) {
            if ($args{metric} =~ /accuracy/i) {
                $score = sml->accuracy_metric($actual, $predicted);
            } elsif ($args{metric} =~ /rmse/i) {
                $score = sml->get_RMSE($actual, $predicted);
            }
        } else {
            my $is_integer = ($actual == $actual->round())->sum()->asscalar == $actual->size;
            $score = $is_integer ? sml->accuracy_metric($actual, $predicted) : sml->get_RMSE($actual, $predicted);
        }

        # Guardamos los resultados de este ciclo
        push @scores, $score;
        push @train_losses, $train_loss if defined $train_loss;
        push @test_losses, $test_loss if defined $test_loss;
        push @actuals, $actual;
        push @predictions, $predicted;
    }

    return wantarray ? (\@scores, \@train_losses, \@test_losses, \@actuals, \@predictions) : \@scores;
}

# ==========================================
# 1. VERSIÓN NATIVA EN PERL
# ==========================================
sub viterbi_native {
    my ($self, $states, $pi, $y, $A, $B) = @_;
    
    my $K = scalar @$states;
    my $T_seq = scalar @$y;
    
    my @T1; # Matriz de probabilidades máximas
    my @T2; # Matriz de punteros traseros (backpointers)
    
    # Inicialización (t = 0)
    my $y_0 = $y->[0];
    for my $i (0 .. $K - 1) {
        $T1[$i][0] = $pi->[$i] * $B->[$i][$y_0];
        $T2[$i][0] = 0;
    }
    
    # Recursión (t = 1 hasta T-1)
    for my $j (1 .. $T_seq - 1) {
        my $y_j = $y->[$j];
        
        for my $i (0 .. $K - 1) {
            my $max_val = -1.0;
            my $argmax_k = -1;
            
            for my $k (0 .. $K - 1) {
                # Se toma el máximo, ¡no la suma!
                my $prob = $T1[$k][$j - 1] * $A->[$k][$i] * $B->[$i][$y_j];
                
                if ($prob > $max_val) {
                    $max_val = $prob;
                    $argmax_k = $k;
                }
            }
            $T1[$i][$j] = $max_val;
            $T2[$i][$j] = $argmax_k;
        }
    }
    
    # Terminación
    my @z; # Índices de los estados más probables
    my @x; # Nombres de los estados más probables
    
    my $max_prob = -1.0;
    my $last_state = 0;
    
    for my $k (0 .. $K - 1) {
        if ($T1[$k][$T_seq - 1] > $max_prob) {
            $max_prob = $T1[$k][$T_seq - 1];
            $last_state = $k;
        }
    }
    
    $z[$T_seq - 1] = $last_state;
    $x[$T_seq - 1] = $states->[$last_state];
    
    # Backtracking para reconstruir la ruta
    for (my $j = $T_seq - 1; $j > 0; $j--) {
        $z[$j - 1] = $T2[ $z[$j] ][$j];
        $x[$j - 1] = $states->[ $z[$j - 1] ];
    }
    
    return \@x;
}

# ==========================================
# 2. VERSIÓN TENSORIAL CON AI::MXNET
# ==========================================
# Requiere que $pi, $A y $B sean instancias de ndarray (nd)
sub viterbi_mxnet {
    my ($self, $states, $pi_nd, $y, $A_nd, $B_nd) = @_;
    
    my $K = scalar @$states;
    my $T_seq = scalar @$y;
    
    my @T2; # Los punteros los mantenemos en Perl estándar para el backtracking
    
    # Extraemos la columna de emisiones para la primera observación
    my $y_0 = $y->[0];
    my $B_col = $B_nd->slice([0, $K-1], [$y_0, $y_0])->reshape([$K]);
    
    # Inicialización vectorizada: (K,)
    my $T1_prev = $pi_nd * $B_col;
    
    for my $i (0 .. $K - 1) {
        $T2[$i][0] = 0;
    }
    
    # Recursión temporal
    for my $j (1 .. $T_seq - 1) {
        my $y_j = $y->[$j];
        
        # 1. Broadcasting mágico:
        # Expandimos T1_prev de (K,) a (K, 1) y multiplicamos con A (K, K)
        # Esto resulta en una matriz donde el elemento (k, i) es T1[k] * A[k, i]
        my $T1_expanded = $T1_prev->expand_dims(1);
        my $weighted_transitions = $T1_expanded * $A_nd;
        
        # 2. Max y Argmax a lo largo del eje 0 (el eje 'k')
        my $max_transitions = nd->max($weighted_transitions, axis => 0);
        my $argmax_transitions = nd->argmax($weighted_transitions, axis => 0);
        
        # 3. Multiplicamos por la probabilidad de emisión actual
        my $B_col_j = $B_nd->slice([0, $K-1], [$y_j, $y_j])->reshape([$K]);
        $T1_prev = $max_transitions * $B_col_j;
        
        # Guardamos los punteros convirtiendo el tensor a un array nativo de Perl
        my @argmax_vals = @{ $argmax_transitions->aspdl->unpdl };
        for my $i (0 .. $K - 1) {
            $T2[$i][$j] = $argmax_vals[$i];
        }
    }
    
    # Terminación
    my $last_state_nd = nd->argmax($T1_prev, axis => 0);
    my $last_state = $last_state_nd->asscalar();
    
    my @z;
    my @x;
    
    $z[$T_seq - 1] = $last_state;
    $x[$T_seq - 1] = $states->[$last_state];
    
    # Backtracking (idéntico a la versión nativa)
    for (my $j = $T_seq - 1; $j > 0; $j--) {
        $z[$j - 1] = $T2[ $z[$j] ][$j];
        $x[$j - 1] = $states->[ $z[$j - 1] ];
    }
    
    return \@x;
}

    1;
}


