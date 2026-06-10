use AI::MXNet qw(mx);

my $matrix = mx->nd->array([[0.9 , 0.1], [0.5, 0.5]]);

my $vector = mx->nd->array([0.15, 0.85]);

my $x = 1;

while ($x){
    my $valid = mx->nd->dot($vector, $matrix);
    my $valid2 = mx->nd->dot($valid, $matrix);

    my $isequal = $valid == $valid2;
    print $isequal ->aspdl;

    if($isequal){
        $x = 0;
        $vector = $valid2;
    }else{
        $vector = $valid2;
    }
}

print $vector ->aspdl;$vector = $valid2;