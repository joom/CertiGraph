Require Import RamifyCoq.lib.Ensembles_ext.
Require Import Coq.Lists.List.
Require Import VST.msl.seplog.
Require Import VST.msl.log_normalize.
Require Import VST.msl.Coqlib2.
Require Import RamifyCoq.lib.Coqlib.
Require Import RamifyCoq.lib.EquivDec_ext.
Require Import RamifyCoq.lib.relation_list.
Require Import RamifyCoq.msl_ext.abs_addr.
Require Import RamifyCoq.msl_ext.seplog.
Require Import RamifyCoq.msl_ext.log_normalize.
Require Import RamifyCoq.msl_ext.iter_sepcon.
Require Import RamifyCoq.graph.graph_model.
Require Import RamifyCoq.graph.path_lemmas.
Require Import RamifyCoq.graph.reachable_computable.
Require Import RamifyCoq.graph.reachable_ind.
Require Import RamifyCoq.graph.subgraph2.
Require Import RamifyCoq.graph.graph_gen.
Require Import RamifyCoq.graph.dag.
Require Import RamifyCoq.graph.weak_mark_lemmas.
Require Import RamifyCoq.msl_application.Graph.
Require Import RamifyCoq.msl_application.GraphBi.
Require Import RamifyCoq.msl_application.Graph_Mark.
Require Import Coq.Logic.Classical.
Import RamifyCoq.msl_ext.seplog.OconNotation.

Open Scope logic.

Instance MGS: WeakMarkGraph.MarkGraphSetting bool.
  apply (WeakMarkGraph.Build_MarkGraphSetting bool
          (eq true)).
  intros.
  destruct x; [left | right]; congruence.
Defined.

Section SpatialGraph_Mark_Bi.

Context {pSGG_Bi: pSpatialGraph_Graph_Bi}.
Context {sSGG_Bi: sSpatialGraph_Graph_Bi}.

Lemma vlabel_eq: forall (g1 g2: Graph) x1 x2, (WeakMarkGraph.marked g1 x1 <-> WeakMarkGraph.marked g2 x2) -> vlabel g1 x1 = vlabel g2 x2.
Proof.
  intros.
  simpl in H.
  destruct H.
  destruct (vlabel g1 x1), (vlabel g2 x2); try congruence.
  + tauto.
  + symmetry; tauto.
Qed.

Lemma mark_null_refl: forall (g: Graph), mark null g g.
Proof. intros. apply mark_invalid_refl, invalid_null. Qed.

Lemma mark_vgamma_true_refl: forall (g: Graph) root d l r, vgamma g root = (d, l, r) -> d = true -> mark root g g.
Proof.
  intros.
  apply mark_marked_root_refl.
  inversion H.
  simpl; congruence.
Qed.

Lemma Graph_gen_true_mark1: forall (G: Graph) (x: addr) l r,
  vgamma G x = (false, l, r) ->
  vvalid G x ->
  mark1 x (G: LabeledGraph _ _ _ _) (Graph_gen G x true: LabeledGraph _ _ _ _).
Proof.
  intros.
  split; [| split; [| split]].
  + reflexivity.
  + simpl.
    unfold update_vlabel.
    destruct_eq_dec x x; congruence.
  + intros.
    simpl.
    unfold update_vlabel; simpl.
    destruct_eq_dec x n'; [congruence |].
    reflexivity.
  + intros.
    reflexivity.
Qed.

Lemma left_weak_valid: forall (G G1: Graph) (x l r: addr),
  vgamma G x = (false, l, r) ->
  vvalid G x ->
  mark1 x G G1 ->
  @weak_valid _ _ _ _ G1 (maGraph _) l.
Proof.
  intros.
  destruct H1 as [? _].
  eapply weak_valid_si; [symmetry; eauto |].
  eapply gamma_left_weak_valid; eauto.
Qed.

Lemma right_weak_valid: forall (G G1 G2: Graph) (x l r: addr),
  vgamma G x = (false, l, r) ->
  vvalid G x ->
  mark1 x G G1 ->
  mark l G1 G2 ->
  @weak_valid _ _ _ _ G2 (maGraph _) r.
Proof.
  intros.
  destruct H1 as [? _].
  destruct H2 as [_ ?].
  eapply weak_valid_si; [symmetry; transitivity G1; eauto |].
  eapply gamma_right_weak_valid; eauto.
Qed.

Lemma graph_ramify_left: forall {RamUnit: Type} (g g1: Graph) x l r,
  vvalid g x ->
  vgamma g x = (false, l, r) ->
  mark1 x g g1 ->
  (graph x g1: pred) |-- graph l g1 *
   (ALL a: RamUnit * Graph,
     !! (mark l g1 (snd a)) -->
     (graph l (snd a) -* graph x (snd a))).
Proof.
  intros.
  destruct H1 as [? _].
  eapply vertices_at_ramify_Q; auto.
  + rewrite <- H1.
    eapply Prop_join_reachable_left; eauto.
  + intros.
    destruct H2 as [_ ?].
    rewrite <- H2, <- H1.
    eapply Prop_join_reachable_left; eauto.
  + intros ? [? ?] ? ?.
    simpl; unfold gamma.
    rewrite Intersection_spec in H4; unfold Complement, Ensembles.In in H4; destruct H4.
    f_equal; [f_equal |].
    - apply vlabel_eq.
      apply (proj2 (proj2 H2)).
      rewrite <- H1.
      intro.
      apply reachable_by_subset_reachable in H6; unfold Ensembles.In in H6.
      tauto.
    - apply dst_L_eq; auto.
      rewrite H1 in H4.
      apply reachable_foot_valid in H4; auto.
    - apply dst_R_eq; auto.
      rewrite H1 in H4.
      apply reachable_foot_valid in H4; auto.
Qed.

Lemma graph_ramify_right: forall {RamUnit: Type} (g g1 g2: Graph) x l r,
  vvalid g x ->
  vgamma g x = (false, l, r) ->
  mark1 x g g1 ->
  mark l g1 g2 ->
  (graph x g2: pred) |-- graph r g2 *
   (ALL a: RamUnit * Graph,
     !! (mark r g2 (snd a)) -->
     (graph r (snd a) -* graph x (snd a))).
Proof.
  intros.
  destruct H1 as [? _].
  destruct H2 as [_ ?].
  eapply vertices_at_ramify_Q; auto.
  + rewrite <- H2, <- H1.
    eapply Prop_join_reachable_right; eauto.
  + intros.
    destruct H3 as [_ ?].
    rewrite <- H3, <- H2, <- H1.
    eapply Prop_join_reachable_right; eauto.
  + intros ? [? ?] ? ?.
    simpl; unfold gamma.
    rewrite Intersection_spec in H5; unfold Complement, Ensembles.In in H5; destruct H5.
    f_equal; [f_equal |].
    - apply vlabel_eq.
      apply (proj2 (proj2 H3)).
      rewrite <- H2, <- H1.
      intro.
      apply reachable_by_subset_reachable in H7; unfold Ensembles.In in H7.
      tauto.
    - apply dst_L_eq; auto.
      rewrite H1, H2 in H5.
      apply reachable_foot_valid in H5; auto.
    - apply dst_R_eq; auto.
      rewrite H1, H2 in H5.
      apply reachable_foot_valid in H5; auto.
Qed.

Lemma mark1_mark_left_mark_right: forall (g1 g2 g3 g4: Graph) root l r,
  vvalid g1 root ->
  vgamma g1 root = (false, l, r) ->
  mark1 root g1 g2 ->
  mark l g2 g3 ->
  mark r g3 g4 ->
  mark root g1 g4.
Proof.
  intros.
  apply (mark1_mark_list_mark root (l :: r :: nil)); auto.
  + intros.
    destruct_eq_dec x l; [| destruct_eq_dec x r; [| exfalso]].
    - subst; eapply weak_valid_vvalid_dec, gamma_left_weak_valid; eauto.
    - subst; eapply weak_valid_vvalid_dec, gamma_right_weak_valid; eauto.
    - destruct H4 as [| [|]]; try congruence; inversion H4.
  + intros; simpl.
    inversion H0.
    unfold Complement, Ensembles.In.
    rewrite H5; congruence.
  + hnf; intros.
    apply gamma_step with (y := n') in H0; auto.
    rewrite H0; simpl.
    pose proof eq_sym_iff n' l.
    pose proof eq_sym_iff n' r.
    tauto.
  + split_relation_list ((lg_gg g2) :: nil); eauto.
    unfold mark_list.
    simpl map.
    split_relation_list ((lg_gg g3) :: nil); eauto.
Qed.

(*
Lemma gamma_true_mark: forall (g g': Graph) x y l r,
    Decidable (vvalid g y) -> vgamma g x = (true, l, r) -> mark y g g' -> vvalid g' x-> vgamma g' x = (true, l, r).
Proof.
  intros.
  simpl in H0 |- *.
  unfold gamma in H0 |- *.
  inversion H0; subst.
  pose proof mark_marked g y g' H1.
  spec H3; [apply Graph_reachable_by_dec; auto |].
  specialize (H3 x).
  simpl in H3.
  destruct (vlabel g x); [| congruence].
  spec H3; [auto |].
  rewrite <- H3.
  destruct H1 as [[? [? [? ?]]] _].
  f_equal; [f_equal |].
  + apply (left_valid g') in H2. assert (evalid g (x, L)) by (rewrite <- H5 in H2; auto). symmetry; apply H7; auto.
  + apply (right_valid g') in H2. assert (evalid g (x, R)) by (rewrite <- H5 in H2; auto). symmetry; apply H7; auto.
Qed.

Lemma vgamma_is_true: forall (g : Graph) (x l r : addr), vgamma g x = (true, l, r) -> marked g x.
Proof. intros. simpl in H. unfold gamma in H. simpl. destruct (vlabel g x) eqn:? . auto. inversion H. Qed.

Lemma vgamma_is_false: forall (g : Graph) (x l r : addr), vgamma g x = (false, l, r) -> unmarked g x.
Proof.
  intros. simpl in H. unfold gamma in H. hnf. unfold Ensembles.In. simpl. intro.
  destruct (vlabel g x) eqn:? . inversion H. simpl in H0. inversion H0.
Qed.

Local Open Scope logic.

Lemma graph_ramify_aux1: forall (g: Graph) (x l: addr)
  {V_DEC: Decidable (vvalid g l)},
  vvalid g x ->
  Included (reachable g l) (reachable g x) ->
  (graph x g: pred) |-- graph l g *
   ((EX g': Graph, !! mark g l g' && graph l g') -*
    (EX g': Graph, !! mark g l g' && graph x g')).
Proof.
  intros.
  apply graph_ramify_aux1; auto.
  + apply RGF.
  + intros; apply RGF.
  + intros g' ?.
    split; [split |].
    - destruct H1 as [[? _] _].
      rewrite <- H1; auto.
    - destruct H1 as [? _].
      intro; unfold Ensembles.In; rewrite <- H1.
      apply H0.
    - split; [| split].
      * destruct H1 as [H1 _].
        unfold unreachable_partial_spatialgraph.
        simpl; rewrite H1.
        reflexivity.
      * intros; simpl in *.
        destruct H1 as [? [_ ?]].
        specialize (H4 v).
        destruct H2; unfold Complement, Ensembles.In in H5; rewrite reachable_through_set_single in H5.
        spec H4; [intro HH; apply reachable_by_is_reachable in HH; auto |].
        unfold gamma; simpl in H4.
        destruct H1 as [? [? [? ?]]].
        assert (true <> false) by congruence.
        assert (false <> true) by congruence.
        assert (dst g (v, L) = dst g' (v, L)) by (apply H8; apply (left_valid g) in H2; [| rewrite H6 in H2]; auto).
        assert (dst g (v, R) = dst g' (v, R)) by (apply H8; apply (right_valid g) in H2; [| rewrite H6 in H2]; auto).
        destruct (vlabel g v), (vlabel g' v); simpl in H4.
        1: rewrite H11, H12; auto.
        1: tauto.
        1: tauto.
        1: rewrite H11, H12; auto.
      * intros; simpl; auto.
Qed.

Lemma graph_ramify_aux1_left: forall (g: Graph) x d l r,
  vvalid g x ->
  vgamma g x = (d, l, r) ->
  (graph x g: pred) |-- graph l g *
   ((EX g': Graph, !! mark g l g' && graph l g') -*
    (EX g': Graph, !! mark g l g' && graph x g')).
Proof.
  intros.
  apply graph_ramify_aux1; auto.
  + pose proof (gamma_left_weak_valid g x d l r H H0).
    apply weak_valid_vvalid_dec; auto.
  + eapply gamma_left_reachable_included; eauto.
Qed.

Lemma graph_ramify_aux1_right: forall (g: Graph) x d l r,
  vvalid g x ->
  vgamma g x = (d, l, r) ->
  (graph x g: pred) |-- graph r g *
   ((EX g': Graph, !! mark g r g' && graph r g') -*
    (EX g': Graph, !! mark g r g' && graph x g')).
Proof.
  intros.
  apply graph_ramify_aux1; auto.
  + pose proof (gamma_right_weak_valid g x d l r H H0).
    apply weak_valid_vvalid_dec; auto.
  + eapply gamma_right_reachable_included; eauto.
Qed.

Lemma gamma_marks: forall (g g' : Graph) x l r,
    mark1 g x g' -> gamma g x = (false, l, r) -> vvalid g' x -> gamma g' x = (true, l, r).
Proof.
  intros.
  unfold gamma in *.
  inversion H0; subst; f_equal; [f_equal |].
  + destruct H as [_ ?].
    destruct H as [_ [? _]].
    simpl in H.
    auto.
  + destruct H as [? _].
    destruct H as [_ [? [_ ?]]].
    apply (left_valid g') in H1.
    assert (evalid g (x, L)) by (rewrite <- H in H1; auto).
    symmetry; apply H2; auto.
  + destruct H as [? _].
    destruct H as [_ [? [_ ?]]].
    apply (right_valid g') in H1.
    assert (evalid g (x, R)) by (rewrite <- H in H1; auto).
    symmetry; apply H2; auto.
Qed.

(*
Section SpatialGraph.

  Context {SGA : SpatialGraphAssum}.

  Lemma graph_unfold_null: forall (g: Graph), graph null g = emp.
  Proof.
    intros. apply pred_ext; unfold graph.
    + apply andp_left2, exp_left. intros. apply derives_extract_prop. intro. destruct x.
      - simpl. apply derives_refl.
      - exfalso. assert (In a (a :: x)). apply in_eq. rewrite (H a) in H0. apply reachable_head_valid in H0.
        apply valid_not_null in H0. auto.
        rewrite is_null_def; auto.
    + apply andp_right.
      - apply prop_right. left; auto.
      - apply (exp_right nil). simpl. apply andp_right.
        * apply prop_right. intro. split; intro. inversion H. apply reachable_head_valid in H.
          apply valid_not_null in H. exfalso; auto. rewrite is_null_def; auto.
        * apply derives_refl.
  Qed.

  Lemma graph_unfold_valid:
    forall x (g: Graph) d l r, vvalid x -> gamma g x = (d, l, r) ->
                         graph x g = trinode x (d, l, r) ⊗ graph l g ⊗ graph r g.
  Proof.
    intros. assert (TRI: trinode x (d, l, r) = iter_sepcon (x :: nil) (graph_cell g)). {
      unfold iter_sepcon. rewrite sepcon_comm, emp_sepcon. unfold graph_cell. rewrite H0. auto.
    } apply pred_ext.
    + unfold graph. apply andp_left2, exp_left. intro li.
      rewrite (add_andp _ _ (iter_sepcon_unique_nodup li (sepcon_unique_graph_cell g))). normalize_overlap.
      rename H2 into NODUPLi.
      assert (step g x l).
      Focus 1. {
        unfold gamma in H0.
        inversion H0; subst. clear H0.
        rewrite step_spec; exists (left_out_edge x); rewrite left_sound.
        pose proof left_valid x; tauto.
      } Unfocus.
      assert (step g x r).
      Focus 1. {
        unfold gamma in H0.
        inversion H0; subst. clear H0.
        rewrite step_spec; exists (right_out_edge x); rewrite right_sound.
        pose proof right_valid x; tauto.
      } Unfocus.
      destruct (compute_neighbor g x li H H1 l H2) as [leftL [? ?]].
      destruct (compute_neighbor g x li H H1 r H3) as [rightL [? ?]].
      apply (exp_right rightL). normalize_overlap. apply (exp_right leftL). normalize_overlap. apply andp_right.
      - rewrite <- !prop_and. apply prop_right. do 2 (split; auto).
        split.
        * rewrite <- is_null_def. destruct (valid_step _ _ _ H3). auto.
        * rewrite <- is_null_def. destruct (valid_step _ _ _ H2). auto.
      - rewrite TRI, ocon_assoc.
        rewrite !(iter_sepcon_ocon t_eq_dec); auto.
        2: repeat constructor; simpl; tauto.
        2: apply remove_dup_nodup.
        2: apply precise_graph_cell.
        2: apply joinable_graph_cell.
        2: apply precise_graph_cell.
        2: apply joinable_graph_cell.
        rewrite iter_sepcon_permutation with (l2 := remove_dup t_eq_dec ((x :: nil) ++ remove_dup t_eq_dec (leftL ++ rightL))).
        * apply derives_refl.
        * apply (eq_as_set_permutation t_eq_dec); auto.
          apply remove_dup_nodup. apply eq_as_set_spec. intro y.
          rewrite <- remove_dup_in_inv. simpl.
          rewrite <- remove_dup_in_inv.
          rewrite in_app_iff. rewrite (H1 y).
          apply (reachable_list_bigraph_in l r); auto.
          eapply gamma_step; eauto.
    + unfold graph. normalize_overlap. intro rightL. normalize_overlap. intro leftL. normalize_overlap.
      apply (exp_right (remove_dup t_eq_dec ((x :: nil) ++ remove_dup t_eq_dec (leftL ++ rightL)))). rewrite <- andp_assoc.
      rewrite <- prop_and. rewrite TRI.
      rewrite (add_andp _ _ (iter_sepcon_unique_nodup leftL (sepcon_unique_graph_cell g))).
      rewrite (add_andp _ _ (iter_sepcon_unique_nodup rightL (sepcon_unique_graph_cell g))).
      normalize_overlap. apply andp_right.
      - apply prop_right. split. right; auto. intro.
        rewrite <- remove_dup_in_inv. simpl. rewrite <- remove_dup_in_inv.
        rewrite in_app_iff. symmetry. apply (reachable_list_bigraph_in l r); auto.
        eapply gamma_step; eauto.
      - rewrite ocon_assoc. rewrite !(iter_sepcon_ocon t_eq_dec); auto.
        * repeat constructor; simpl; tauto.
        * apply remove_dup_nodup.
        * apply precise_graph_cell.
        * apply joinable_graph_cell.
        * apply precise_graph_cell.
        * apply joinable_graph_cell.
  Qed.

  Lemma graph_root_nv: forall x g, graph x g |-- !!(x = null \/ vvalid x).
  Proof. intros. unfold graph. apply andp_left1, prop_left. intros. apply TT_prop_right; auto. Qed.

  Lemma graph_unfold':
    forall x g,
      graph x g = (!!(x = null) && emp) ||
          EX d:bool, EX l:Addr, EX r:Addr, !!(gamma g x = (d, l, r) /\ vvalid x) &&
                                                        (trinode x (d, l, r) ⊗ graph l g ⊗ graph r g).
  Proof.
    intros. apply pred_ext.
    + destruct (t_eq_dec x null).
      - subst. apply orp_right1. rewrite graph_unfold_null. normalize.
      - apply orp_right2. destruct (gamma g x) as [[dd ll] rr] eqn:? .
        apply (exp_right dd), (exp_right ll), (exp_right rr).
        rewrite (add_andp _ _ (graph_root_nv x g)). apply andp_right.
        * apply andp_left2, prop_left; intros. apply TT_prop_right. destruct H. tauto. split; auto.
        * normalize. destruct H; [tauto | rewrite (graph_unfold_valid _ _ dd ll rr); auto].
    + apply orp_left.
      - normalize. rewrite graph_unfold_null. auto.
      - normalize. intros d l r [? ?]. rewrite <- (graph_unfold_valid _ _ d l r); auto.
  Qed.

  Lemma graph_unfold:
    forall x (g: Graph) d l r, gamma g x = (d, l, r) ->
                         graph x g = !!(x = null) && emp ||
                                        !!(vvalid x) && (trinode x (d, l, r) ⊗ graph l g ⊗ graph r g).
  Proof.
    intros. apply pred_ext.
    + rewrite (add_andp _ _ (graph_root_nv x g)). normalize. destruct H0.
      - subst. rewrite graph_unfold_null. apply orp_right1. normalize.
      - apply orp_right2. rewrite (graph_unfold_valid _ _ d l r H0 H). normalize.
    + apply orp_left.
      - normalize. rewrite graph_unfold_null. auto.
      - normalize. rewrite (graph_unfold_valid _ _ d l r H0 H). auto.
  Qed.

  Lemma precise_graph: forall x g, precise (graph x g).
  Proof.
    intros. apply precise_andp_right. apply precise_exp_iter_sepcon.
    + apply sepcon_unique_graph_cell.
    + apply classic.
    + apply precise_graph_cell.
    + apply reachable_list_permutation.
  Qed.

  Fixpoint graphs (l : list Addr) g :=
    match l with
      | nil => emp
      | v :: l' => graph v g ⊗ graphs l' g
    end.

  Lemma precise_graphs: forall S g, precise (graphs S g).
  Proof. intros; induction S; simpl. apply precise_emp. apply precise_ocon. apply precise_graph. apply IHS. Qed.

  Lemma graphs_list_well_defined: forall S g, graphs S g |-- !!well_defined_list g S.
  Proof.
    induction S; intros; unfold well_defined_list in *; simpl.
    + apply prop_right. intros; tauto.
    + unfold graph.
      rewrite (add_andp _ _ (IHS _)).
      normalize_overlap.
      apply prop_right.
      intro y; intros. destruct H1.
      - rewrite <- is_null_def in H. subst; auto.
      - specialize (H0 _ H1). apply H0.
  Qed.

  Lemma graphs_unfold: forall S g, graphs S g =
                                      !!(well_defined_list g S) &&
                                      EX l: list Addr, !!reachable_set_list pg S l &&
                                                       iter_sepcon l (graph_cell g).
  Proof.
    induction S; intros.
    + unfold graphs. apply pred_ext.
      - apply andp_right.
        * apply prop_right. hnf. intros. inversion H.
        * apply (exp_right nil). simpl. apply andp_right; auto. apply prop_right. hnf.
          intros. split; intros. unfold reachable_through_set in H. destruct H as [s [? _]]. inversion H. inversion H.
      - normalize. destruct l. simpl; auto. hnf in H0. specialize (H0 a).
        assert (In a (a :: l)) by apply in_eq.
        rewrite <- H0 in H1. unfold reachable_through_set in H1. destruct H1 as [? [? _]]. inversion H1.
    + unfold graphs. fold graphs. rewrite IHS. unfold graph. apply pred_ext. clear IHS.
      - normalize_overlap. rename x into la.
        normalize_overlap. rename x into lS.
        normalize_overlap.
        rewrite (add_andp _ _ (iter_sepcon_unique_nodup la (sepcon_unique_graph_cell g))).
        rewrite (add_andp _ _ (iter_sepcon_unique_nodup lS (sepcon_unique_graph_cell g))).
        normalize_overlap.
        rewrite (iter_sepcon_ocon t_eq_dec); auto. apply (exp_right (remove_dup t_eq_dec (la ++ lS))).
        rewrite <- andp_assoc, <- prop_and. apply andp_right.
        * apply prop_right. split.
          Focus 1. {
            unfold well_defined_list in *. intros. simpl in H5.
            rewrite <- is_null_def in H.
            destruct H5; [subst | apply H0]; auto. } Unfocus.
          Focus 1. {
            unfold reachable_set_list in *.
            unfold reachable_list in *. intros.
            rewrite <- remove_dup_in_inv.
            rewrite reachable_through_set_eq.
            specialize (H1 x). specialize (H2 x).
            split; intro; [apply in_or_app | apply in_app_or in H5];
            destruct H5; [left | right | left | right]; tauto.
          } Unfocus.
        * auto.
        * apply precise_graph_cell.
        * apply joinable_graph_cell.
      - normalize.
        assert (In a (a :: S)) by apply in_eq.
        assert (weak_valid a). Focus 1. {
          unfold well_defined_list in H.
          specialize (H a). auto.
        } Unfocus.
        destruct (reachable_through_single_reachable g _ _ H0 a H1 H2) as [la [? ?]].
        normalize_overlap. apply (exp_right la).
        assert (Sublist S (a :: S)) by (intro s; intros; apply in_cons; auto).
        assert (well_defined_list g S) by (unfold well_defined_list in *; intros; apply H; apply in_cons; auto).
        destruct (reachable_through_sublist_reachable _ _ _ H0 _ H5 H6) as [lS [? ?]].
        normalize_overlap. apply (exp_right lS). normalize_overlap.
        rewrite <- !prop_and. apply andp_right.
        * apply prop_right. rewrite <- is_null_def. auto.
        * rewrite (add_andp _ _ (iter_sepcon_unique_nodup l (sepcon_unique_graph_cell g))).
          normalize.
          rewrite (iter_sepcon_ocon t_eq_dec); auto.
          2: apply precise_graph_cell.
          2: apply joinable_graph_cell.
          rewrite iter_sepcon_permutation with (l2 := remove_dup t_eq_dec (la ++ lS)); auto.
          apply NoDup_Permutation; auto. apply remove_dup_nodup.
          intros. rewrite <- remove_dup_in_inv. clear -H7 H3 H0.
          specialize (H0 x). specialize (H7 x). specialize (H3 x). rewrite <- H0.
          rewrite reachable_through_set_eq. rewrite in_app_iff. tauto.
  Qed.

  Lemma reachable_eq_graphs_eq:
    forall S S' (g: Graph), Same_set (reachable_through_set pg S) (reachable_through_set pg S') ->
                      well_defined_list g S -> well_defined_list g S' ->  graphs S g = graphs S' g.
  Proof.
    intros; apply pred_ext; rewrite !graphs_unfold; normalize; apply (exp_right l);
    normalize; apply andp_right; auto; apply prop_right; unfold reachable_set_list in *;
    destruct H; unfold Included in * |- ; intros; rewrite <- H2; split; unfold Ensembles.In in *; auto.
  Qed.
(*
  Lemma single_graph_growth_double:
    forall x d (H: x <> null), trinode x (d, x, x) |-- graph x (single_graph_double x d H).
  Proof.
    intros. unfold graph. apply andp_right.
    + apply prop_right. right. hnf; auto.
    + apply (exp_right (x :: nil)). apply andp_right.
      - apply prop_right. hnf. intros. split; intros.
        * simpl in H0. destruct H0; try tauto. subst.
          apply reachable_by_reflexive. split; hnf; auto.
        * apply reachable_foot_valid in H0. hnf in H0. subst. apply in_eq.
      - unfold iter_sepcon. unfold graph_cell. rewrite sepcon_emp.
        unfold gamma. unfold biEdge. unfold only_two_neighbours. simpl. auto.
  Qed.

  Lemma single_graph_growth_left:
    forall x d (H: x <> null), trinode x (d, x, null) |-- graph x (single_graph_left x d H).
  Proof.
    intros. unfold graph. apply andp_right.
    + apply prop_right. right. hnf; auto.
    + apply (exp_right (x :: nil)). apply andp_right.
      - apply prop_right. hnf. intros. split; intros.
        * simpl in H0. destruct H0; try tauto. subst.
          apply reachable_by_reflexive. split; hnf; auto.
        * apply reachable_foot_valid in H0. hnf in H0. subst. apply in_eq.
      - unfold iter_sepcon. unfold graph_cell. rewrite sepcon_emp.
        unfold gamma. unfold biEdge. unfold only_two_neighbours. simpl. auto.
  Qed.

  Lemma single_graph_growth_right:
    forall x d (H: x <> null), trinode x (d, null, x) |-- graph x (single_graph_right x d H).
  Proof.
    intros. unfold graph. apply andp_right.
    + apply prop_right. right. hnf; auto.
    + apply (exp_right (x :: nil)). apply andp_right.
      - apply prop_right. hnf. intros. split; intros.
        * simpl in H0. destruct H0; try tauto. subst.
          apply reachable_by_reflexive. split; hnf; auto.
        * apply reachable_foot_valid in H0. hnf in H0. subst. apply in_eq.
      - unfold iter_sepcon. unfold graph_cell. rewrite sepcon_emp.
        unfold gamma. unfold biEdge. unfold only_two_neighbours. simpl. auto.
  Qed.
*)
  Lemma trinode_iter_sepcon_not_in:
    forall x d l r li g, trinode x (d, l, r) * iter_sepcon li (graph_cell g) |-- !!(~ In x li).
  Proof.
    intros; induction li.
    + apply prop_right. auto.
    + unfold iter_sepcon. fold (iter_sepcon li (graph_cell g)).
      rewrite <- sepcon_assoc. rewrite (sepcon_comm (trinode x (d, l, r))). rewrite sepcon_assoc.
      rewrite (add_andp _ _ IHli). normalize. rewrite <- sepcon_assoc. unfold graph_cell at 1.
      destruct (t_eq_dec a x).
      - subst.
        assert (trinode x (gamma g x) * trinode x (d, l, r) |-- FF). {
          apply mapsto_conflict. simpl. unfold addr_eqb. destruct (addr_eq_dec x x); auto.
        } rewrite (add_andp _ _ H0). normalize.
      - apply prop_right. simpl. intro. destruct H0; auto.
  Qed.

  Lemma trinode_graphs_unreachable:
    forall x d l r S g, x <> null ->
                        trinode x (d, l, r) * graphs S g |-- !!(forall s, In s S -> ~ reachable g s x /\ s <> x).
  Proof.
    intros. rewrite graphs_unfold. normalize. intro li; intros.
    rewrite (add_andp _ _ (trinode_iter_sepcon_not_in _ _ _ _ _ _)).
    normalize. apply prop_right. intros. split.
    + intro; apply H2. clear H2. specialize (H1 x). rewrite <- H1. exists s. split; auto.
    + intro. subst. unfold reachable_set_list in H1. unfold reachable_through_set in H1.
      apply H2. rewrite <- H1. exists x. split; auto.
      apply reachable_by_reflexive. specialize (H0 x). apply H0 in H3. split.
      - destruct H3. rewrite is_null_def in H3. tauto. auto.
      - hnf; auto.
  Qed.

  Lemma reachable_subgraph_derives:
    forall (g1 g2: Graph) x,
      ((reachable_sub_markedgraph g1 (x :: nil)) -=- (reachable_sub_markedgraph g2 (x :: nil))) ->
      graph x g1 |-- graph x g2.
  Proof.
    Implicit Arguments vvalid [[Vertex] [Edge]].
    intros. destruct H as [? ?]. rewrite (add_andp _ _ (graph_root_nv _ _)).
    normalize. destruct H1.
    + subst. rewrite !graph_unfold_null; auto.
    + unfold graph. normalize. apply (exp_right l).
      rewrite <- andp_assoc, <- prop_and. apply andp_right.
      - apply prop_right. simpl in H. unfold reachable_valid in H. split.
        * right. destruct H as [? _]. specialize (H x).
          assert (vvalid g1 x /\ reachable_through_set g1 (x :: nil) x). {
            split. auto. exists x. split.
            + apply in_eq.
            + apply reachable_by_reflexive. split; auto.
          } rewrite H in H3. simpl in H3. unfold reachable_valid in H3. tauto.
        * unfold reachable_list in *. intros. specialize (H2 y).
          rewrite H2. split; intros.
          Focus 1. {
            apply reachable_valid_and_through_single in H3.
            destruct H as [? _].
            specialize (H y).
            simpl in H.
            unfold reachable_valid in H.
            rewrite H in H3.
            destruct H3. destruct H4 as [s [? ?]].
            simpl in H4. destruct H4; [| tauto]. subst; auto.
          } Unfocus.
          Focus 1. {
            apply reachable_valid_and_through_single in H3.
            destruct H as [? _].
            specialize (H y).
            simpl in H.
            unfold reachable_valid in H.
            rewrite <- H in H3.
            destruct H3. destruct H4 as [s [? ?]].
            simpl in H4. destruct H4; [| tauto]. subst; auto.
          } Unfocus.
      - assert (forall z, In z l -> vvalid (reachable_subgraph g1 (x :: nil)) z). {
          intros. simpl. hnf. hnf in H2. rewrite H2 in H3. split.
          + apply reachable_foot_valid in H3; auto.
          + exists x. split. apply in_eq. auto.
        } clear H2. induction l. simpl. auto.
        unfold iter_sepcon.
        fold (iter_sepcon l (graph_cell g1)).
        fold (iter_sepcon l (graph_cell g2)).
        apply derives_trans with (graph_cell g1 a * iter_sepcon l (graph_cell g2));
          apply sepcon_derives; auto.
        * apply IHl. intros. apply H3. apply in_cons; auto.
        * clear IHl.
          specialize (H3 a).
          spec H3; [left; auto |].
          destruct H as [? [? [? ?]]].
          pose proof (H a).
          simpl in H6, H3.
          pose proof H3; rewrite H6 in H3; clear H6.
          unfold graph_cell. replace (gamma g1 a) with (gamma g2 a); [auto |].
          unfold gamma.
          specialize (H0 a H7 H3).
          simpl in H5.
          rewrite !H5.
          rewrite !left_out_edge_def, !right_out_edge_def.
          f_equal.
          f_equal.
          change (marked (reachable_sub_markedgraph g1 (x :: nil)) a) with (marked g1 a) in H0.
          change (marked (reachable_sub_markedgraph g2 (x :: nil)) a) with (marked g2 a) in H0.
          destruct (node_pred_dec (marked g2) a), (node_pred_dec (marked g1) a); tauto.
    Implicit Arguments vvalid [[Vertex] [Edge] [PreGraph]].
  Qed.

  Lemma reachable_subgraph_eq:
    forall (g1 g2 : Graph) x,
      ((reachable_sub_markedgraph g1 (x :: nil)) -=- (reachable_sub_markedgraph g2 (x :: nil))) -> graph x g1 = graph x g2.
  Proof.
    intros. apply pred_ext.
    + apply reachable_subgraph_derives; auto.
    + apply reachable_subgraph_derives; apply vi_sym; auto.
  Qed.

  Lemma reachable_vi_eq:
    forall (g1 g2 : Graph) x, g1 -=- g2 -> graph x g1 = graph x g2.
  Proof.
  Arguments vvalid {_} {_} _ _.
    intros.
    apply reachable_subgraph_eq.
    destruct H.
    split.
    + simpl.
      apply si_reachable_subgraph.
      auto.
    + intro; intros.
      apply H0.
      - destruct H1; tauto.
      - destruct H2; tauto.
  Arguments vvalid {_} {_} {_} _.
  Qed.

  Lemma reachable_remove_perm:
    forall (g: Graph) x l, vvalid x -> reachable_list g x l -> NoDup l ->
                           Permutation (map (Gamma g) l) (Gamma g x :: map (Gamma g) (remove t_eq_dec x l)).
  Proof.
    intros. change (Gamma g x :: map (Gamma g) (remove t_eq_dec x l)) with (map (Gamma g) (x :: (remove t_eq_dec x l))).
    apply Permutation_map. assert (In x l) by (rewrite (H0 x); apply reachable_by_reflexive; auto).
    apply nodup_remove_perm; auto.
  Qed.

  Lemma reachable_subtract_perm:
    forall (g: Graph) x l l1 l2, Included (reachable g l) (reachable g x) ->
                                 reachable_list g x l1 -> NoDup l1 -> reachable_list g l l2 -> NoDup l2 ->
                                 Permutation (map (Gamma g) l1) (map (Gamma g) l2 ++ map (Gamma g) (subtract t_eq_dec l1 l2)).
  Proof.
    intros. rewrite <- (compcert.lib.Coqlib.list_append_map (Gamma g)).
    apply Permutation_map. apply perm_trans with (subtract t_eq_dec l1 l2 ++ l2).
    + apply subtract_permutation; auto.
      intro y. rewrite (H0 y). rewrite (H2 y). 
      specialize (H y). auto.
    + apply Permutation_app_comm.
  Qed.

  Lemma subgraph_update:
    forall (g g': Graph) (S1 S1' S2: list Addr),
      Included (reachable_through_set g S1) (reachable_through_set g' S1') ->
      (unreachable_subgraph g S1) ~=~ (unreachable_subgraph g' S1') ->
      graphs S1 g ⊗ graphs S2 g |-- graphs S1 g * (graphs S1' g' -* graphs S1' g' ⊗ graphs S2 g').
  Proof.
  Abort.
  
  Lemma graph_ramify_aux0: forall (g: Graph) x d l r,
                             vvalid x -> gamma g x = (d, l, r) ->
                             graph x g |-- trinode x (d, l, r) * (trinode x (d, l, r) -* graph x g).
  Proof.
    intros. assert (x = null \/ vvalid x) by auto.
    rewrite (graph_eq x g H1). destruct (graph_reachable_list g x H1) as [f [?H ?H]]. unfold proj1_sig.
    clear H1. rewrite <- H0.
    replace (trinode x (gamma g x)) with (iter_sepcon (Gamma g x :: nil) Graph_cell) by (simpl; rewrite sepcon_emp; auto).
    apply iter_sepcon_ramification. exists (map (Gamma g) (remove t_eq_dec x f)).
    assert (Permutation (map (Gamma g) f) ((Gamma g x :: nil) ++ map (Gamma g) (remove t_eq_dec x f))); [|tauto].
    rewrite <- app_comm_cons, app_nil_l. apply reachable_remove_perm; auto.
  Qed.

  Lemma graph_ramify_aux1: forall (g g': Graph) x,
                             mark1 g x g' -> graph x g |-- trinode x (gamma g x) * (trinode x (gamma g' x) -* graph x g').
  Proof.
    intros. assert (@vvalid _ _ g x) by (destruct H as [_ [? _]]; auto).
    assert (x = null \/ @vvalid _ _ g x) by auto.
    assert (@vvalid _ _ g' x) by (destruct H as [[? _] _]; rewrite <- H; auto).
    assert (x = null \/ @vvalid _ _ g' x) by auto.
    rewrite (graph_eq x g H1). rewrite (graph_eq x g' H3).
    destruct (graph_reachable_list g x H1) as [lg [?H ?H]].
    destruct (graph_reachable_list g' x H3) as [lg' [?H ?H]].
    unfold proj1_sig. clear H1 H3.
    replace (trinode x (gamma g x)) with (iter_sepcon (Gamma g x :: nil) Graph_cell) by (simpl; rewrite sepcon_emp; auto).
    replace (trinode x (gamma g' x)) with (iter_sepcon (Gamma g' x :: nil) Graph_cell) by (simpl; rewrite sepcon_emp; auto).
    apply iter_sepcon_ramification. exists (map (Gamma g) (remove t_eq_dec x lg)).
    rewrite <- !app_comm_cons, !app_nil_l. split.
    + apply reachable_remove_perm; auto.
    + rewrite (compcert.lib.Coqlib.list_map_exten (Gamma g') (Gamma g) (remove t_eq_dec x lg)).
      - apply perm_trans with (Gamma g' x :: map (Gamma g') (remove t_eq_dec x lg')).
        * apply reachable_remove_perm; auto.
        * change (Gamma g' x :: map (Gamma g') (remove t_eq_dec x lg')) with (map (Gamma g') (x :: (remove t_eq_dec x lg'))).
          change (Gamma g' x :: map (Gamma g') (remove t_eq_dec x lg)) with (map (Gamma g') (x :: (remove t_eq_dec x lg))).
          apply Permutation_map.
          assert (In x lg) by (rewrite (H4 x); apply reachable_by_reflexive; auto).
          assert (In x lg') by (rewrite (H6 x); apply reachable_by_reflexive; auto).
          apply perm_trans with lg'. apply Permutation_sym, nodup_remove_perm; auto.
          apply perm_trans with lg. apply NoDup_Permutation; auto.
          intro y; intros. rewrite (H4 y). rewrite (H6 y). symmetry. apply (reachable_mark1 g g' x); auto.
          apply nodup_remove_perm; auto.
      - intro y; intros. unfold Gamma. f_equal. unfold gamma.
        destruct H as [[? [? [? ?]]] [? [? ?]]].
        assert (x <> y) by (intro; subst; apply (remove_In t_eq_dec lg y); auto).
        specialize (H12 y H13). f_equal; [f_equal | ].
        * destruct (node_pred_dec (marked g')); destruct (node_pred_dec (marked g)); tauto.
        * rewrite !left_out_edge_def. rewrite H9. auto.
        * rewrite !right_out_edge_def. rewrite H9. auto.
  Qed.

  Lemma graph_ramify_aux2: forall (g1 g2: Graph) x l,
                             @vvalid _ _ g1 x -> @weak_valid _ _ g1 _ l ->
                             Included (reachable g1 l) (reachable g1 x) ->
                             mark g1 l g2 -> graph x g1 |-- graph l g1 * (graph l g2 -* graph x g2).
  Proof.
    intros.
    rename H into Vg1x.
    unfold weak_valid in H0.
    rewrite is_null_def in H0.
    assert (Vg2x: @vvalid _ _ g2 x) by (destruct H2 as [[? _] _]; rewrite <- H; auto).
    assert (Hg1x: x = null \/ @vvalid _ _ g1 x) by auto.
    rename H0 into Hg1l.
    assert (Hg2x: x = null \/ @vvalid _ _ g2 x) by auto.
    assert (Hg2l: l = null \/ @vvalid _ _ g2 l) by
        (destruct Hg1l; [left | right]; auto; destruct H2 as [[? _] _]; rewrite <- H0; auto).
    rewrite (graph_eq x g1 Hg1x).
    rewrite (graph_eq l g1 Hg1l).
    rewrite (graph_eq x g2 Hg2x).
    rewrite (graph_eq l g2 Hg2l).
    destruct (graph_reachable_list g1 x Hg1x) as [lg1x [?H ?H]].
    destruct (graph_reachable_list g1 l Hg1l) as [lg1l [?H ?H]].
    destruct (graph_reachable_list g2 x Hg2x) as [lg2x [?H ?H]].
    destruct (graph_reachable_list g2 l Hg2l) as [lg2l [?H ?H]].
    unfold proj1_sig. clear Hg1x Hg2x.
    apply iter_sepcon_ramification.
    exists (map (Gamma g1) (subtract t_eq_dec lg1x lg1l)). split.
    + apply (reachable_subtract_perm g1 x l); auto.
    + assert (Included (reachable g2 l) (reachable g2 x)) by
          (intro y; intros; destruct H2 as [? _]; generalize (si_reachable_direct g1 g2 x y H2); intro;
           rewrite <- H10; apply H1; generalize (si_reachable_direct g1 g2 l y H2); intro; intuition).
      assert (Sublist lg1l lg1x) by (intro y; rewrite (H y); rewrite (H3 y); apply H1).
      assert (Sublist lg2l lg2x) by (intro y; rewrite (H5 y); rewrite (H7 y); apply H9).
      apply perm_trans with (map (Gamma g2) lg2l ++ map (Gamma g2) (subtract t_eq_dec lg2x lg2l)).
      - apply (reachable_subtract_perm g2 x l); auto.
      - apply Permutation_app_head. apply perm_trans with (map (Gamma g2) (subtract t_eq_dec lg1x lg1l)).
        * apply Permutation_map. apply Permutation_app_inv_r with lg1l.
          apply perm_trans with lg1x. 2: apply subtract_permutation; auto.
          apply perm_trans with (subtract t_eq_dec lg2x lg2l ++ lg2l).
          apply Permutation_app_head. apply NoDup_Permutation; auto.
          intro y. rewrite (H3 y). rewrite (H7 y). apply si_reachable_direct. destruct H2; auto.
          apply perm_trans with lg2x. apply Permutation_sym. apply subtract_permutation; auto.
          apply NoDup_Permutation; auto. intro y. rewrite (H y). rewrite (H5 y). apply si_reachable_direct.
          symmetry. destruct H2; auto.
        * rewrite (compcert.lib.Coqlib.list_map_exten (Gamma g2) (Gamma g1)).
          apply Permutation_refl. intro y; intros.
          rewrite <- subtract_property in H12. destruct H12.
          unfold Gamma. f_equal. unfold gamma. rewrite !left_out_edge_def, !right_out_edge_def.
          destruct H2 as [[? [? [? ?]]] [? ?]]. rewrite !H16. f_equal. f_equal.
          assert (~ g1 |= l ~o~> y satisfying (unmarked g1)). {
                   intro. apply H13. rewrite (H3 y).
                   apply reachable_by_is_reachable in H19; auto.
          } specialize (H18 _ H19).
          destruct (node_pred_dec (marked g2) y), (node_pred_dec (marked g1) y); tauto.
  Qed.
  
*)
*)
End SpatialGraph_Mark_Bi.

