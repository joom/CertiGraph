Require Import VST.floyd.proofauto.
Require Import RamifyCoq.sample_mark.env_dispose_bi.
Require Import RamifyCoq.graph.graph_model.
Require RamifyCoq.graph.marked_graph. Import RamifyCoq.graph.marked_graph.MarkGraph.
Require Import RamifyCoq.graph.path_lemmas.
Require Import RamifyCoq.graph.subgraph2.
Require Import RamifyCoq.graph.spanning_tree.
Require Import RamifyCoq.graph.reachable_computable.
Require Import RamifyCoq.data_structure.general_spatial_graph.
Require Import RamifyCoq.data_structure.spatial_graph_mark.
Require Import RamifyCoq.data_structure.spatial_graph_dispose.

Local Open Scope logic.

Arguments SingleFrame' {l} {g} {s}.

Notation graph sh x g := (@graph _ _ _ _ _ _ (SGP_VST sh) _ x g).
Existing Instances MGS biGraph maGraph finGraph RGF.

Definition mark_spec :=
 DECLARE _mark
  WITH sh: share, g: Graph, x: pointer_val
  PRE [ _x OF (tptr (Tstruct _Node noattr))]
          PROP  (writable_share sh; weak_valid (pg_gg g) x)
          LOCAL (temp _x (pointer_val_val x))
          SEP   (`(graph sh x g))
  POST [ Tvoid ]
        PROP ()
        LOCAL()
        SEP (`(EX g': Graph, !! mark g x g' && graph sh x g')).

Definition spanning_spec :=
  DECLARE _spanning
  WITH sh: share, g: Graph, x: pointer_val
  PRE [ _x OF (tptr (Tstruct _Node noattr))]
          PROP  (writable_share sh; vvalid (pg_gg g) x; unmarked g x)
          LOCAL (temp _x (pointer_val_val x))
          SEP   (`(graph sh x g))
  POST [ Tvoid ]
        PROP ()
        LOCAL()
        SEP (`(EX g': Graph, !! spanning_tree g x g' && graph sh x g')).

Definition dispose_spec :=
  DECLARE _dispose
  WITH sh: share, g: Graph, x: pointer_val
  PRE [ _x OF (tptr (Tstruct _Node noattr))]
          PROP  (writable_share sh; weak_valid (pg_gg g) x)
          LOCAL (temp _x (pointer_val_val x))
          SEP   (`(!!tree g x && graph sh x g))
  POST [ Tvoid ]
        PROP ()
        LOCAL()
        SEP (`emp).

Definition main_spec :=
 DECLARE _main
  WITH u : unit
  PRE  [] main_pre prog u
  POST [ tint ] main_post prog u.

Definition Vprog : varspecs := nil.

Definition Gprog : funspecs := mark_spec :: spanning_spec :: dispose_spec :: main_spec::nil.

Lemma body_spanning: semax_body Vprog Gprog f_spanning spanning_spec.
Proof.
  start_function.
  remember (vgamma g x) as dlr eqn:?H.
  destruct dlr as [[d l] r].
  assert (d = false). {
    hnf in H1. simpl in H1. unfold Ensembles.In in H1.
    simpl in H2. unfold gamma in H2. destruct (vlabel g x) eqn:? .
    symmetry in Heqb. specialize (H1 Heqb). exfalso; auto.
    inversion H2. auto.
  } subst.

  localize
   (PROP  ()
    LOCAL (temp _x (pointer_val_val x))
    SEP   (`(data_at sh node_type (Vint (Int.repr 0), (pointer_val_val l, pointer_val_val r))
                     (pointer_val_val x)))).
  
  (* begin l = x -> l; *)
  apply -> ram_seq_assoc.
  eapply semax_ram_seq;
    [ repeat apply eexists_add_stats_cons; constructor
    | new_load_tac 
    | abbreviate_semax_ram].
  apply ram_extract_exists_pre.
  intro l_old; autorewrite with subst; clear l_old.
  (* end l = x -> l; *)

  (* begin r = x -> r; *)
  apply -> ram_seq_assoc.
  eapply semax_ram_seq;
    [ repeat apply eexists_add_stats_cons; constructor
    | new_load_tac 
    | abbreviate_semax_ram].
  apply ram_extract_exists_pre.
  intro r_old; autorewrite with subst; clear r_old.
  (* end r = x -> r; *)

  (* begin x -> m = 1; *)
  apply -> ram_seq_assoc.
  eapply semax_ram_seq;
    [ repeat apply eexists_add_stats_cons; constructor
    | new_store_tac
    | abbreviate_semax_ram].
  cbv beta zeta iota delta [replace_nth].
  change (@field_at CompSpecs CS_legal sh node_type []
           (Vint (Int.repr 1), (pointer_val_val l, pointer_val_val r))) with
         (@data_at CompSpecs CS_legal sh node_type
                   (Vint (Int.repr 1), (pointer_val_val l, pointer_val_val r))).
  (* end x -> m = 1; *)
  
  unlocalize (PROP ()
              LOCAL  (temp _r (pointer_val_val r); temp _l (pointer_val_val l); temp _x (pointer_val_val x))
              SEP  (`(graph sh x (Graph_gen g x true)))).
  Grab Existential Variables.
  Focus 6. { solve_split_by_closed. } Unfocus.
  Focus 2. { entailer!. } Unfocus.
  Focus 3. { entailer!. } Unfocus.
  Focus 3. { repeat constructor; auto with closed. } Unfocus.
  Focus 2. {
    entailer!.
    rewrite Graph_gen_spatial_spec by eauto.
    pose proof (@graph_ramify_aux0 _ _ _ _ _ _ _ (SGA_VST sh) g _ x (false, l, r) (true, l, r)).
    simpl in H4; auto.
  } Unfocus.

  (* if (l) { *)
  apply -> ram_seq_assoc.
  symmetry in H2.
  pose proof Graph_gen_true_mark1 g x _ _ H2 H0.
  assert (H_GAMMA_g1: vgamma (Graph_gen g x true) x = (true, l, r)) by
   (rewrite (proj1 (proj2 (Graph_gen_spatial_spec g x _ true _ _ H2))) by assumption;
    apply spacialgraph_gen_vgamma).
  forget (Graph_gen g x true) as g1.
  unfold semax_ram.
  
  forward_if_tac
    (PROP  ()
     LOCAL (temp _r (pointer_val_val r);
            temp _l (pointer_val_val l);
            temp _x (pointer_val_val x))
     SEP (`(EX g2: Graph, !! spanning_tree g1 l g2 && graph sh x g2))); [| gather_current_goal_with_evar ..].

  (* root_mark = l -> m; *)
  localize
    (PROP  ()
     LOCAL  (temp _l (pointer_val_val l))
     SEP  (`(data_at sh node_type (vgamma2cdata (vgamma g1 l)) (pointer_val_val l)))).
  remember (vgamma g1 l) as dlr in |-*.
  destruct dlr as [[dd ll] rr].
  eapply semax_ram_seq;
    [ repeat apply eexists_add_stats_cons; constructor
    | new_load_tac 
    | abbreviate_semax_ram].
  apply ram_extract_exists_pre.
  intro root_mark_old; autorewrite with subst; clear root_mark_old.
  replace (if dd then 1 else 0) with (if node_pred_dec (marked g1) l then 1 else 0).
  Focus 2. {
    destruct (node_pred_dec (marked g1)); destruct dd; auto; symmetry in Heqdlr.
    apply vgamma_is_false in Heqdlr. simpl in a. unfold unmarked in Heqdlr. hnf in Heqdlr.
    unfold Ensembles.In in Heqdlr. simpl in Heqdlr. apply Heqdlr in a. exfalso; auto.
    apply vgamma_is_true in Heqdlr. exfalso; auto.
  } Unfocus.
  rewrite Heqdlr.
  unlocalize
    (PROP  ()
     LOCAL (temp _root_mark (Vint (Int.repr (if node_pred_dec (marked g1) l then 1 else 0)));
            temp _r (pointer_val_val r);
            temp _l (pointer_val_val l);
            temp _x (pointer_val_val x))
     SEP  (`(graph sh x g1))).
  Grab Existential Variables.
  Focus 6. { solve_split_by_closed. } Unfocus.
  Focus 2. { entailer!. } Unfocus.
  Focus 3. { entailer!. } Unfocus.
  Focus 3. { repeat constructor; auto with closed. } Unfocus.
(*  Focus 2. {
    
    assert ((dd, ll, rr) = vgamma g1 l).
    rewrite Heqdlr.
    entailer!.
    rewrite H5.
    pose proof (@graph_ramify_aux0 _ _ _ _ _ _ _ (SGA_VST sh) g1 _ x). (false, l, r) (true, l, r)).
    simpl in H4; auto.
*)
  (* assert (isptr (pointer_val_val x)). admit. *)
Abort.