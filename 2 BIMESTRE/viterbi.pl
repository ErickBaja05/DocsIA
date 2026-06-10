package Algorithm::Viterbi;

use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

sub new{
  my ($class, %args) = (shift, states => [], observables => [], @_); 
  my $self = {
              states      => $args{states},
              observables => $args{observables},
             };
  return bless $self, $class;
}

sub get_start_probs{
  my ($self, $training_data, $start_probs) = @_;
  
  return $self->{start} if defined $self->{start};
}

sub set_start{
  my ($self, $start) = @_;
  return $self->{start} = $start;
}

sub set_emissions{
  my ($self, $emissions) = @_;
  return $self->{emissions} = $emissions;
}

sub set_transitions{
  my ($self, $transitions) = @_;
  return $self->{transitions} = $transitions;
}

sub viterbi{
  my ($self, $O, %args) = (splice(@_, 0, 2), debug=>0, log=>0, @_);

  my $tiny = 1e-30;

    my $A  = $self->{transitions};
    my $B  = $self->{emissions};
    my $pi = $self->{start};


    if($args{log}){
        $A  = mx->nd->log($A + $tiny);
        $B  = mx->nd->log($B + $tiny);
        $pi = mx->nd->log($pi + $tiny);
    }


  
  my $I = $A->len;

  my $N = $O->len;

  my $D = mx->nd->zeros([$I, $N]);
  my $E = mx->nd->zeros([$I, $N-1]);

  my $obs = $O->slice(0)->asscalar;
  my $b0 =$B->slice(':', $obs);

  
  if($args{log}){
    $D->slice(':', 0)->set(($pi + $b0)->expand_dims(axis=>1));
  }else{
    $D->slice(':', 0)->set(($pi * $b0)->expand_dims(axis=>1));
  }

  
  #$D->slice(':',0)->set($pi + $b0);

  #RECURSION DEL ALGORITMO DE VITERBI

  for my $n(1..$N-1){
    $obs = $O->slice($n)->asscalar;
    my $prev = $D->slice(':' , $n-1);
    $prev = $prev->expand_dims(axis=>1);
    my $temp;

    
    if($args{log}){
        $temp = $prev + $A;
    }
    else{
        $temp = $prev * $A;
    }



    

    my $max_vals = $temp->max(axis=>0);

    my $argmaxes = $temp->argmax(axis=>0);

    my $emit = $B->slice(':', $obs);

    
    if($args{log}){
        $D->slice(':', $n)->set(($max_vals + $emit)->expand_dims(axis=>1));
    }else{
        $D->slice(':', $n)->set(($max_vals * $emit)->expand_dims(axis=>1));
    }


    $E->slice(':', $n-1)->set($argmaxes->expand_dims(axis=>1));

    #BACKTRACKING DE VITERBI
  }

    my $S_opt = mx->nd->zeros([$N]);

    $S_opt->slice($N-1)->set($D->slice(':', $N-1)->argmax->asscalar);

    for(my $n = $N-2; $n >= 0; $n--){
        my $next_state = $S_opt->slice($n+1)->asscalar;
        $S_opt->slice($n)->set($E->slice($next_state, $n));
    }
       
    $args{log} ? return ($S_opt, mx->nd->exp($D), $E) : return ($S_opt, $D, $E);



}

1;

use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

sub print_tensors{
  printf "type: %s shape:%s%s\n", ref($_), dump($_->shape), $_->aspdl for (@_);
}

my $vit = new Algorithm::Viterbi(states=>[0, 1], observables=>[10, 11, 12]);

my $A = mx->nd->array([
    [0.7, 0.3],
    [0.4, 0.6],
]);

my $B = mx->nd->array([
    [1.0, 0.0, 0.0],
    [0.2, 0.3, 0.5],
]);


my $pi = mx->nd->array([4/7, 3/7]);
my $O = mx->nd->array([0, 2, 0]);

$vit->set_transitions($A);
$vit->set_emissions($B);
$vit->set_start($pi);

my ($S_opt, $D, $E) = $vit->viterbi($O, log=>0, order=>1);
print_tensors($O, $S_opt, $D, $E);

