Require Import Coq.Sets.Ensembles.
Require Import Coq.Sets.Finite_sets.
Require Import VST.msl.seplog.
Require Import VST.msl.log_normalize.
Require Import RamifyCoq.Coqlib.
Require Import RamifyCoq.msl_ext.abs_addr.
Require Import RamifyCoq.msl_ext.seplog.
Require Import RamifyCoq.msl_ext.log_normalize.
Require Import RamifyCoq.msl_ext.iter_sepcon.
Require Import RamifyCoq.graph.graph_model.
Require Import RamifyCoq.graph.path_lemmas.
Require Import RamifyCoq.graph.reachable_computable.
Require Import RamifyCoq.graph.reachable_ind.
Require Import RamifyCoq.graph.subgraph2.
Require Import Coq.Logic.Classical.
Import RamifyCoq.msl_ext.seplog.OconNotation.

Local Open Scope logic.

Class SpatialGraph (V E: Type) {VE: EqDec V eq} {EE: EqDec E eq} (DV DE: Type): Type := {
  pg: PreGraph V E;
  vgamma: V -> DV;
  egamma: E -> DE
}.

Arguments vgamma {V E _ _ DV DE} _ _.
Arguments egamma {V E _ _ DV DE} _ _.

Coercion pg : SpatialGraph >-> PreGraph.

Section GENERAL_SPATIAL_GRAPH.

Context {V : Type}.
Context {E : Type}.
Context {EV: EqDec V eq}.
Context {EE: EqDec E eq}.
Context {DV : Type}.
Context {DE : Type}.

Definition validly_identical (g1 g2: SpatialGraph V E DV DE) : Prop :=
  g1 ~=~ g2 /\
  (forall v, vvalid g1 v -> vvalid g2 v -> vgamma g1 v = vgamma g2 v) /\
  (forall e, evalid g1 e -> evalid g2 e -> egamma g1 e = egamma g2 e).

Notation "g1 '-=-' g2" := (validly_identical g1 g2) (at level 1).

Lemma vi_refl: forall (g : SpatialGraph V E DV DE), g -=- g.
Proof. intros. split; auto. apply si_refl. Qed.

Lemma vi_sym: forall (g1 g2 : SpatialGraph V E DV DE), g1 -=- g2 -> g2 -=- g1.
Proof.
  intros. destruct H as [? [? ?]]. split; [|split]; intros.
  + apply si_sym; auto.
  + specialize (H0 _ H3 H2). auto.
  + specialize (H1 _ H3 H2). auto.
Qed.

Lemma vi_trans: forall (g1 g2 g3: SpatialGraph V E DV DE), g1 -=- g2 -> g2 -=- g3 -> g1 -=- g3.
Proof.
  intros. destruct H as [? [? ?]]. destruct H0 as [? [? ?]].
  split; [| split]; intros.
  + apply si_trans with g2; auto.
  + assert (vvalid g2 v) by (destruct H; rewrite <- H; auto).
    specialize (H1 _ H5 H7). specialize (H3 _ H7 H6). transitivity (vgamma g2 v); auto.
  + assert (evalid g2 e) by (destruct H as [_ [? _]]; rewrite <- H; auto).
    specialize (H2 _ H5 H7). specialize (H4 _ H7 H6). transitivity (egamma g2 e); auto.
Qed.

Add Parametric Relation : (SpatialGraph V E DV DE) validly_identical
    reflexivity proved by vi_refl
    symmetry proved by vi_sym
    transitivity proved by vi_trans as vi_equal.
  
Definition predicate_sub_spatialgraph  (g: SpatialGraph V E DV DE: Type) (p: V -> Prop) :=
  Build_SpatialGraph V E _ _ DV DE (predicate_subgraph g p) (vgamma g) (egamma g).

Definition unreachable_sub_spatialgraph (g: SpatialGraph V E DV DE: Type) (S : list V) : SpatialGraph V E DV DE :=
  predicate_sub_spatialgraph g (fun n => ~ reachable_through_set g S n).

Class SpatialGraphPred (V E DV DE Pred: Type): Type := {
  vertex_at: V -> DV -> Pred;
  edge_at: E -> DE -> Pred
}.

Class SpatialGraphAssum {V E DV DE Pred: Type} (SGP: SpatialGraphPred V E DV DE Pred) := {
  SGP_ND: NatDed Pred;
  SGP_SL : SepLog Pred;
  SGP_ClSL: ClassicalSep Pred;
  SGP_CoSL: CorableSepLog Pred
}.

Existing Instances SGP_ND SGP_SL SGP_ClSL SGP_CoSL.

Class SpatialGraphStrongAssum {V E DV DE Pred: Type} (SGP: SpatialGraphPred V E DV DE Pred) := {
  SGA: SpatialGraphAssum SGP;
  SGP_PSL: PreciseSepLog Pred;
  SGP_OSL: OverlapSepLog Pred;
  SGP_DSL: DisjointedSepLog Pred;
  SGP_COSL: CorableOverlapSepLog Pred;

  AAV: AbsAddr V DV;
  VSELF_CONFLICT: forall x y, x = y <-> @addr_conflict _ _ AAV x y = true;
  AAE: AbsAddr E DE;
  VP_MSL: MapstoSepLog AAV vertex_at;
  VP_sMSL: StaticMapstoSepLog AAV vertex_at;
  EP_MSL: MapstoSepLog AAE edge_at;
  EP_sMSL: StaticMapstoSepLog AAE edge_at
}.

Existing Instances SGA SGP_PSL SGP_OSL SGP_DSL SGP_COSL VP_MSL VP_sMSL EP_MSL EP_sMSL.

Section SpatialGraph.

  Context {Pred: Type}.
  Context {SGP: SpatialGraphPred V E DV DE Pred}.
  (* Context {SGA: SpatialGraphAssum SGP}. *)
  Context {SGSA: SpatialGraphStrongAssum SGP}.
  Notation Graph := (SpatialGraph V E DV DE).

  Definition graph_cell (g: Graph) (v : V) : Pred := vertex_at v (vgamma g v).

  Lemma precise_graph_cell: forall g v, precise (graph_cell g v).
  Proof. intros. unfold graph_cell. apply (@mapsto_precise _ _ _ _ _ _ _ _ VP_MSL). Qed.  

  Lemma sepcon_unique_graph_cell: forall g, sepcon_unique (graph_cell g).
  Proof.
    repeat intro. unfold graph_cell.
    apply (@mapsto_conflict _ _ _ _ _ _ _ _ _ _ _ VP_sMSL).
    rewrite <- VSELF_CONFLICT; auto.
  Qed.

  Lemma joinable_graph_cell : forall g, joinable (graph_cell g).
  Proof.
    intros. unfold joinable; intros. unfold graph_cell. apply (@disj_mapsto _ _ AAV _ _ _ _ _ _ VP_MSL _ VP_sMSL).
    rewrite VSELF_CONFLICT in H. destruct (addr_conflict x y). exfalso; apply H; auto. auto.
  Qed.  
  
  Definition graph (x : V) (g: Graph) : Pred :=
    EX l : list V, !!reachable_list g x l && iter_sepcon l (graph_cell g).

  Fixpoint graphs (l : list V) (g: Graph) :=
    match l with
      | nil => emp
      | v :: l' => graph v g ⊗ graphs l' g
    end.

  Definition graphs' (S : list V) (g : Graph) :=
    EX l: list V, !!reachable_set_list pg S l &&
                    iter_sepcon l (graph_cell g).

  Definition single_reachable_contructable (S : list V) (g : Graph) : Prop :=
    forall s, In s S -> exists l, reachable_list g s l /\ NoDup l.

  Lemma single_reachable_contructable_cons: forall a S g,
      single_reachable_contructable (a :: S) g -> single_reachable_contructable S g.
  Proof.
    intros. unfold single_reachable_contructable in *. intros.
    assert (In s (a :: S)) by (apply in_cons; auto).
    specialize (H _ H1). auto.
  Qed.

  Definition set_reachable_contructable (S : list V) (g : Graph) : Prop :=
    forall s, Sublist s S -> exists l, reachable_set_list g s l /\ NoDup l.

  Lemma single_set_reachble_constructable: forall S g, single_reachable_contructable S g -> set_reachable_contructable S g.
  Proof.
    admit.
  Qed.
  
  Lemma graphs_graphs': forall S g, single_reachable_contructable S g -> graphs S g = graphs' S g.
  Proof.
    induction S; intros until g. intro Hs.
    + unfold graphs. unfold graphs'. apply pred_ext.
      - apply (exp_right nil). simpl. apply andp_right; auto.
        apply prop_right. intro x. split; intros.
        * unfold reachable_through_set in H. destruct H as [s [? _]]. inversion H.
        * inversion H.
      - normalize. intro l; intros. destruct l; simpl; auto.
        specialize (H v). assert (In v (v :: l)) by apply in_eq.
        rewrite <- H in H0. unfold reachable_through_set in H0.
        destruct H0 as [s [? _]]. inversion H0.
    + intro Hs. unfold graphs. fold graphs. rewrite (IHS _ (single_reachable_contructable_cons _ _ _ Hs)).
      unfold graphs'. unfold graph. clear IHS. apply pred_ext.
      - normalize_overlap. intros. rename x into la.
        normalize_overlap. rename x into lS. normalize_overlap.
        rewrite (add_andp _ _ (iter_sepcon_unique_nodup la (sepcon_unique_graph_cell g))).
        rewrite (add_andp _ _ (iter_sepcon_unique_nodup lS (sepcon_unique_graph_cell g))).
        normalize_overlap.
        rewrite (iter_sepcon_ocon equiv_dec); auto. apply (exp_right (remove_dup equiv_dec (la ++ lS))).
        apply andp_right.
        * apply prop_right.
          unfold reachable_set_list in *.
          unfold reachable_list in *. intros.
          rewrite <- remove_dup_in_inv.
          rewrite reachable_through_set_eq.
          specialize (H0 x). specialize (H x).
          split; intro; [apply in_or_app | apply in_app_or in H3];
          destruct H3; [left | right | left | right]; tauto.
        * auto.
        * apply precise_graph_cell.
        * apply joinable_graph_cell.
      - normalize. intro l; intros. assert (In a (a :: S)) by apply in_eq.
        destruct (Hs _ H0) as [la [? ?]].
        normalize_overlap. apply (exp_right la).
        assert (Sublist S (a :: S)) by (intro s; intros; apply in_cons; auto).
        destruct ((single_set_reachble_constructable _ _ Hs) _ H3) as [lS [? ?]].
        normalize_overlap. apply (exp_right lS). normalize_overlap.
        rewrite (add_andp _ _ (iter_sepcon_unique_nodup l (sepcon_unique_graph_cell g))).
        normalize. rewrite (iter_sepcon_ocon equiv_dec); auto.
        2: apply precise_graph_cell.
        2: apply joinable_graph_cell.
        rewrite iter_sepcon_permutation with (l2 := remove_dup equiv_dec (la ++ lS)); auto.
        apply NoDup_Permutation; auto. apply remove_dup_nodup.
        intros. rewrite <- remove_dup_in_inv. clear -H H1 H4.
        specialize (H x). specialize (H1 x). specialize (H4 x). rewrite <- H.
        rewrite reachable_through_set_eq. rewrite in_app_iff. tauto.
  Qed.

  Lemma subgraph_update:
    forall (g g': Graph) (S1 S1' S2: list V),
      Included (reachable_through_set g S1) (reachable_through_set g' S1') ->
      (unreachable_sub_spatialgraph g S1) -=- (unreachable_sub_spatialgraph g' S1') ->
      graphs' S1 g ⊗ graphs' S2 g |-- graphs' S1 g * (graphs' S1' g' -* graphs' S1' g' ⊗ graphs' S2 g').
  Proof.
  Abort.

End SpatialGraph.