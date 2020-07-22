(* A separate file with the underlying PQ spec-ed out *)
Require Import RamifyCoq.priq.priq_arr_specs.

(* Dijkstra-specific stuff *)
Require Import RamifyCoq.dijkstra.env_dijkstra_arr.
Require Import RamifyCoq.dijkstra.MathDijkGraph.
Require Import RamifyCoq.dijkstra.SpaceDijkGraph.
Require Import RamifyCoq.dijkstra.path_cost.

Local Open Scope Z_scope.

(*
Definition get_popped pq : list VType :=
  map snd (filter (fun x => (fst x) =? (inf + 1))
                  (combine pq (nat_inc_list (Z.to_nat (Zlength pq))))).
 *)

Definition path_correct (g : DijkGG) (prev dist: list V) src dst p : Prop  :=
  valid_path g p /\
  path_ends g p src dst /\
  path_cost g p < inf /\ 
  Znth dst dist = path_cost g p /\
  Forall (fun x => Znth (snd x) prev = fst x) (snd p).

Definition path_globally_optimal (g : DijkGG) src dst p : Prop :=
  forall p', valid_path g p' ->
             path_ends g p' src dst ->
             path_cost g p <= path_cost g p'.

Definition path_in_popped (g : DijkGG) popped dist path :=
  forall step, In_path g step path ->
               In step popped /\ Znth step dist < inf.

Definition inv_popped (g : DijkGG) src (popped prev dist : list V) dst :=
  In dst popped ->
  (Znth dst dist = inf /\
   (forall m,
     vvalid g m -> 
     (careful_add
        (Znth m dist)
        (elabel g (m, dst)) = inf) /\
     (~ In m popped -> Znth m dist = inf)))
  \/
  (exists path,
      path_correct g prev dist src dst path /\
      path_in_popped g popped dist path /\
      path_globally_optimal g src dst path).

Definition inv_unpopped (g : DijkGG) src (popped prev dist: list V) (dst: V) :=
  ~ In dst popped ->
  Znth dst dist < inf ->
  dst = src \/
  (dst <> src /\
   let mom := Znth dst prev in
   vvalid g mom /\
   In mom popped /\
   elabel g (mom, dst) < inf /\
   (Znth mom dist) + (elabel g (mom, dst)) < inf /\
   Znth dst dist = (Znth mom dist) + (elabel g (mom, dst)) /\
   forall mom',
     vvalid g mom' ->
     In mom' popped ->
     Znth dst dist <= careful_add (Znth mom' dist)
                                  (elabel g (mom', dst))).

Definition inv_unpopped_weak (g : DijkGG) (src: V) (popped prev dist : list V) (dst u : V) :=
  ~ In dst popped ->
  Znth dst dist < inf ->
  dst = src \/
  dst <> src /\
  (let mom := Znth dst prev in
   mom <> u /\
   vvalid g mom /\
   In mom popped /\
   (elabel g (mom, dst)) < inf /\
   Znth mom dist + (elabel g (mom, dst)) < inf /\
   Znth dst dist = Znth mom dist + (elabel g (mom, dst))) /\
  forall mom',
    mom' <> u ->
    vvalid g mom' ->
    In mom' popped ->
    Znth dst dist <=
    careful_add (Znth mom' dist)
                (elabel g (mom', dst)).
  
Definition inv_unseen (g : DijkGG) (popped dist: list V) (dst : V) :=
  ~ In dst popped ->
  Znth dst dist = inf ->
  forall m, vvalid g m ->
            In m popped ->
            careful_add 
              (Znth m dist)
              (elabel g (m, dst)) = inf.

Definition inv_unseen_weak (g : DijkGG) (popped dist: list V) (dst u : V) :=
  ~ In dst popped ->
  Znth dst dist = inf ->
  forall m, vvalid g m ->
            In m popped ->
            m <> u ->
            careful_add
              (Znth m dist)
              (elabel g (m, dst)) = inf.
                                                           
Definition dijkstra_correct (g : DijkGG) src popped prev dist : Prop :=
  forall dst,
    vvalid g dst ->
    inv_popped g src popped prev dist dst /\
    inv_unpopped g src popped prev dist dst /\
    inv_unseen g popped dist dst.

Definition dijkstra_spec :=
  DECLARE _dijkstra
  WITH sh: wshare, g: DijkGG, arr : pointer_val,
                                    dist : pointer_val, prev : pointer_val, src : V
  PRE [tptr (tarray tint SIZE), tint, tptr tint, tptr tint]
  PROP (0 <= src < SIZE;
       Forall (fun list => Zlength list = SIZE) (@graph_to_mat SIZE g id))
  PARAMS (pointer_val_val arr;
         Vint (Int.repr src);
         pointer_val_val dist;
         pointer_val_val prev)
  GLOBALS ()
  SEP (DijkGraph sh g (pointer_val_val arr);
      data_at_ Tsh (tarray tint SIZE) (pointer_val_val dist);
      data_at_ Tsh (tarray tint SIZE) (pointer_val_val prev))
  POST [tvoid]
   EX prev_contents : list V,
   EX dist_contents : list V,
   EX popped_verts: list V,                             
   PROP (dijkstra_correct g src popped_verts prev_contents dist_contents)
   LOCAL ()
   SEP (DijkGraph sh g (pointer_val_val arr);
       data_at Tsh (tarray tint SIZE) (map Vint (map Int.repr prev_contents)) (pointer_val_val prev);
       data_at Tsh (tarray tint SIZE) (map Vint (map Int.repr dist_contents)) (pointer_val_val dist)).

Definition Gprog : funspecs :=
  ltac:(with_library prog
                     [push_spec;
                     pq_emp_spec;
                     adjustWeight_spec;
                     popMin_spec;
                     dijkstra_spec]).
