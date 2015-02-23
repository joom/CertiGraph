Require Import FunctionalExtensionality.
Require Import List.
Require Import Omega.
Require Import Setoid.
Require Import utilities.

Class EqDec (T: Type) := {t_eq_dec: forall t1 t2 : T, {t1 = t2} + {t1 <> t2}}.

Fixpoint judgeNoDup {A} {EA : EqDec A} (l : list A) : bool :=
  match l with
    | nil => true
    | s :: ls => if in_dec t_eq_dec s ls then false else judgeNoDup ls
  end.

Lemma judgeNoDup_ok {A} {EA : EqDec A}: forall (l : list A), judgeNoDup l = true <-> NoDup l.
Proof.
  induction l; intros; split; intros. apply NoDup_nil. simpl; auto.
  simpl in H; destruct (in_dec t_eq_dec a l); [discriminate H | apply NoDup_cons; auto; rewrite <- IHl; auto].
  simpl; destruct (in_dec t_eq_dec a l).
  change (a :: l) with (nil ++ a :: l) in H; apply NoDup_remove_2 in H; simpl in H; contradiction.
  change (a :: l) with (nil ++ a :: l) in H; apply NoDup_remove_1 in H; simpl in H; rewrite IHl; auto.
Qed.

Lemma nodup_dec {A} {EA : EqDec A}: forall (l : list A), {NoDup l} + {~ NoDup l}.
Proof.
  intros; destruct (judgeNoDup l) eqn : Hnodup;
  [left; rewrite judgeNoDup_ok in Hnodup; assumption |
   right; intro H; rewrite <- judgeNoDup_ok in H; rewrite Hnodup in H; discriminate H].
Qed.

Class PreGraph (Vertex: Type) Data {EV: EqDec Vertex} :=
  {
    valid : Vertex -> Prop;
    node_label : Vertex -> Data;
    edge_func : Vertex -> list Vertex
  }.

Class MathGraph (Vertex : Type) Data (nV : Vertex) {EV: EqDec Vertex} :=
  {
    m_pg :> PreGraph Vertex Data;
    valid_graph: forall x, valid x -> forall y, In y (edge_func x) -> y = nV \/ valid y;
    valid_not_null: forall x, valid x -> x <> nV
  }.

Class BiGraph (Vertex Data: Type) {EV: EqDec Vertex} :=
  {
    b_pg :> PreGraph Vertex Data;
    only_two_neighbours : forall v : Vertex, {v1 : Vertex & {v2 : Vertex | edge_func v = v1 :: v2 :: nil}}
  }.

Class BiMathGraph (Vertex Data : Type) (nV : Vertex) {EV: EqDec Vertex} :=
  {
    bm_bi :> BiGraph Vertex Data;
    bm_ma :> MathGraph Vertex Data nV;
    pg_the_same: m_pg = b_pg      
  }.

Definition biEdge {Vertex Data : Type} {EV: EqDec Vertex} (BG: BiGraph Vertex Data) (v: Vertex) : Vertex * Vertex.
  specialize (only_two_neighbours v); intro.
  destruct X as [v1 [v2 ?]].
  apply (v1, v2).
Defined.

Lemma biEdge_only2 {Vertex Data : Type} {EV: EqDec Vertex} (BG: BiGraph Vertex Data) :
  forall v v1 v2 n, biEdge BG v = (v1 ,v2) -> In n (edge_func v) -> n = v1 \/ n = v2.
Proof.
  intros; unfold biEdge in H.
  revert H; case_eq (only_two_neighbours v); intro x1; intros.
  revert H1; case_eq s; intro x2; intros. inversion H2. subst.
  rewrite e in *. clear -H0. apply in_inv in H0. destruct H0. left; auto.
  right. apply in_inv in H. destruct H; auto. apply in_nil in H. exfalso; trivial.
Qed.

Definition gamma {Vertex Data: Type} {EV: EqDec Vertex} (BG: BiGraph Vertex Data) (v: Vertex) : Data * Vertex * Vertex :=
  let (v1, v2) := biEdge BG v in (node_label v, v1, v2).

Definition Dup {A} (L : list A) : Prop := ~ NoDup L.
Lemma Dup_unfold {A} {EA : EqDec A}: forall (a : A) (L : list A), Dup (a :: L) -> In a L \/ Dup L.
Proof.
  intros; destruct (in_dec t_eq_dec a L);
  [left; trivial | right; intro; apply H; constructor; auto].
Qed.

Lemma Dup_cyclic {A} {EA : EqDec A} : forall (L : list A), Dup L -> exists a L1 L2 L3, L = L1 ++ (a :: L2) ++ (a :: L3).
Proof.
  induction L. destruct 1. constructor. intros. apply Dup_unfold in H. destruct H. apply in_split in H.
  destruct H as [L1 [L2 ?]]. exists a. exists nil. exists L1. exists L2. rewrite H. simpl. trivial.
  destruct (IHL H) as [a' [L1 [L2 [L3 ?]]]]. rewrite H0. exists a'. exists (a :: L1). exists L2. exists L3. trivial.
Qed.

Definition structurally_identical {V D1 D2 : Type} {EV: EqDec V}
           (G1 : @PreGraph V D1 EV) (G2 : @PreGraph V D2 EV) : Prop :=
  forall v : V, (@valid V D1 EV G1 v <-> @valid V D2 EV G2 v) /\
                (@edge_func V D1 EV G1 v) ~= (@edge_func V D2 EV G2 v).

Notation "g1 '~=~' g2" := (structurally_identical g1 g2) (at level 1).

Lemma si_refl: forall (V D : Type) (EV : EqDec V) (G : PreGraph V D), G ~=~ G.
Proof. intros; intro; split; reflexivity. Qed.

Lemma si_sym: forall (V D1 D2 : Type) (EV: EqDec V) (G1 : @PreGraph V D1 EV)
                     (G2 : @PreGraph V D2 EV), G1 ~=~ G2 -> G2 ~=~ G1.
Proof. intros; intro; specialize (H v); destruct H; split; [split; intuition | destruct H0; split; auto]. Qed.

Lemma si_trans: forall {V D1 D2 D3 : Type} {EV : EqDec V} {G1 : @PreGraph V D1 EV}
                       {G2 : @PreGraph V D2 EV} {G3 : @PreGraph V D3 EV}, G1 ~=~ G2 -> G2 ~=~ G3 -> G1 ~=~ G3.
Proof.
  intros; intro; specialize (H v); specialize (H0 v); destruct H, H0; split;
  [intuition | transitivity (@edge_func V D2 EV G2 v); trivial].
Qed.

Definition edge {V D : Type} {EV : EqDec V} (G : PreGraph V D) (n n' : V) : Prop :=
  valid n /\ valid n' /\ In n' (edge_func n).

Notation " g |= n1 ~> n2 " := (edge g n1 n2) (at level 1).

Lemma edge_si {V D1 D2 : Type} {EV: EqDec V} :
  forall (g1 : @PreGraph V D1 EV) (g2 : @PreGraph V D2 EV) (n n' : V), g1 ~=~ g2 -> g1 |= n ~> n' -> g2 |= n ~> n'.
Proof.
  intros; hnf in *; generalize (H n); intro; specialize (H n'); destruct H, H1; clear H2; destruct H0 as [? [? ?]];
  destruct H3; split; intuition.
Qed.

Fixpoint foot {A} (L : list A) : option A :=
  match L with
    | nil => None
    | a :: nil => Some a
    | a :: L' => foot L'
  end.

Lemma foot_simpl: forall A (a1 a2 : A) (L : list A), foot (a1 :: a2 :: L) = foot (a2 :: L).
Proof. intros. simpl. destruct L; auto. Qed.

Lemma foot_last: forall A (L : list A) (a : A), foot (L +:: a) = Some a.
Proof.
  induction L; auto; intros; destruct L; auto; rewrite <- (IHL a0); simpl; destruct (L +:: a0); simpl; auto.
Qed.

Lemma foot_app: forall A (L1 L2 : list A), L2 <> nil -> foot (L1 ++ L2) = foot L2.
Proof.
  induction L1. auto. intros. rewrite <- app_comm_cons. simpl. case_eq (L1 ++ L2).
  intro. apply app_eq_nil in H0. destruct H0. contradiction. intros. rewrite <- H0. apply IHL1. trivial.
Qed.

Tactic Notation "spec" hyp(H) :=
  match type of H with ?a -> _ =>
    let H1 := fresh in (assert (H1: a); [|generalize (H H1); clear H H1; intro H]) end.
Tactic Notation "disc" := (try discriminate).
Tactic Notation "contr" := (try contradiction).
Tactic Notation "congr" := (try congruence).
Tactic Notation "inv" hyp(H) := inversion H; clear H; subst.
Tactic Notation  "icase" constr(v) := (destruct v; disc; contr; auto).
Tactic Notation "copy" hyp(H) := (generalize H; intro).

Lemma foot_explicit {A}: forall L (a : A), foot L = Some a -> exists L', L = L' +:: a.
Proof.
  induction L. inversion 1. intros. simpl in H. icase L. inv H. exists nil. trivial.
  specialize (IHL a0 H). destruct IHL. exists (a :: x). rewrite <- app_comm_cons. congr.
Qed.

Lemma foot_in {A}: forall (a : A) L, foot L = Some a -> In a L.
Proof. induction L. inversion 1. icase L. simpl. inversion 1. auto. rewrite foot_simpl. right. auto. Qed.

Fixpoint valid_path {A D : Type} {EV: EqDec A} (g: PreGraph A D) (p : list A) : Prop :=
  match p with
    | nil => True
    | n :: nil => valid n
    | n1 :: ((n2 :: _) as p') => g |= n1 ~> n2 /\ valid_path g p'
  end.

Definition graph_is_acyclic {A D : Type} {EV: EqDec A} (g: PreGraph A D) : Prop :=
  forall p : list A, valid_path g p -> NoDup p.

Definition set (A : Type) : Type := A -> Prop.
Definition subset {A} (S1 S2 : set A) : Prop := forall a, S1 a -> S2 a.
Definition set_eq {A} (S1 S2 : set A) : Prop := subset S1 S2 /\ subset S2 S1.
Definition empty_set (A : Type) : set A := fun _ => False.
Definition set_finite {A} (S : set A) : Prop := exists l : list A, forall x : A, (In x l -> S x) /\ (~ In x l -> ~ S x).

Lemma set_eq_refl: forall A (S : set A), set_eq S S. Proof. intros; split; intro; tauto. Qed.

Lemma set_eq_sym: forall A (S1 S2 : set A), set_eq S1 S2 -> set_eq S2 S1. Proof. intros; destruct H; split; auto. Qed.

Lemma set_eq_trans: forall A (S1 S2 S3: set A), set_eq S1 S2 -> set_eq S2 S3 -> set_eq S1 S3.
Proof. intros; destruct H, H0; split; repeat intro; [apply H0, H, H3 | apply H1, H2, H3]. Qed.

Add Parametric Relation {A} : (set A) set_eq
    reflexivity proved by (set_eq_refl A)
    symmetry proved by (set_eq_sym A)
    transitivity proved by (set_eq_trans A) as set_eq_rel.

Definition node_prop {A D : Type} {EV: EqDec A} (g: PreGraph A D) (P : set D) : set A :=
  fun n => P (node_label n).

Definition path_prop {A D : Type} {EV: EqDec A} (g: PreGraph A D) (P : set D) : (list A -> Prop) :=
  fun p => forall n, In n p -> node_prop g P n.

Definition good_path {A D : Type} {EV: EqDec A} (g: PreGraph A D) (P : set D) : (list A -> Prop) :=
    fun p => valid_path g p /\ path_prop g P p.

Definition path_endpoints {N} (p : list N) (n1 n2 : N) : Prop := head p = Some n1 /\ foot p = Some n2.

Definition reachable_by_path {A D : Type} {EV: EqDec A} (g: PreGraph A D) (p : list A)
           (n : A) (P : set D) : set A := fun n' => path_endpoints p n n' /\ good_path g P p.
Notation " g '|=' p 'is' n1 '~o~>' n2 'satisfying' P" := (reachable_by_path g p n1 P n2) (at level 1).

Definition reachable_by {A D : Type} {EV: EqDec A} (g: PreGraph A D) (n : A) (P : set D) : set A :=
  fun n' => exists p, g |= p is n ~o~> n' satisfying P.
Notation " g '|=' n1 '~o~>' n2 'satisfying' P " := (reachable_by g n1 P n2) (at level 1).

Definition reachable_by_acyclic {A D : Type} {EV: EqDec A}
           (g: PreGraph A D) (n : A) (P : set D) : set A :=
  fun n' => exists p, NoDup p /\ g |= p is n ~o~> n' satisfying P.
Notation " g '|=' n1 '~~>' n2 'satisfying' P " := (reachable_by_acyclic g n1 P n2) (at level 1).

Definition reachable {A D : Type} {EV: EqDec A} (g: PreGraph A D) (n : A) : set A:=
  reachable_by g n (fun _ => True).

Section GraphPath.
  Variable N : Type.
  Variable D : Type.
  Variable EDN : EqDec N.
  Let Gph := @PreGraph N D EDN.

  Definition path : Type := list N.
  Definition paths_meet_at (p1 p2 : path) := fun n => foot p1 = Some n /\ head p2 = Some n.
  Definition paths_meet (p1 p2 : path) : Prop := exists n, paths_meet_at p1 p2 n.

  Lemma path_endpoints_meet: forall p1 p2 n1 n2 n3,
    path_endpoints p1 n1 n2 ->
    path_endpoints p2 n2 n3 ->
    paths_meet p1 p2.
  Proof.
    unfold path_endpoints, paths_meet; intros.
    destruct H, H0. exists n2. red. tauto.
  Qed.

  Lemma paths_foot_head_meet: forall p1 p2 n, paths_meet (p1 +:: n) (n :: p2).
  Proof. intros. exists n. split. apply foot_last. trivial. Qed.

  Definition path_glue (p1 p2 : path) : path := p1 ++ (tail p2).
  Notation "p1 '+++' p2" := (path_glue p1 p2) (at level 20, left associativity).

  Lemma path_glue_nil_l: forall p, nil +++ p = tail p.
  Proof.
    unfold path_glue.  trivial.
  Qed.

  Lemma path_glue_nil_r: forall p, p +++ nil = p.
  Proof.
    unfold path_glue. simpl. intro. rewrite app_nil_r. trivial.
  Qed.

  Lemma path_glue_assoc: forall p1 p2 p3 : path,
    paths_meet p1 p2 -> paths_meet p2 p3 -> (p1 +++ p2) +++ p3 = p1 +++ (p2 +++ p3).
  Proof.
    unfold path_glue.
    induction p1; simpl; intros. icase H. icase H.
    icase p2. icase H. icase H. icase p3.
    do 2 rewrite app_nil_r. trivial.
    icase p2. simpl. rewrite app_nil_r. trivial. simpl.
    rewrite <- app_assoc. f_equal.
  Qed.

  Lemma path_glue_comm_cons: forall n p1 p2, (n :: p1 +++ p2) = ((n :: p1) +++ p2).
  Proof.
    unfold path_glue. intros. rewrite app_comm_cons. trivial.
  Qed.

  Lemma path_endpoints_glue: forall n1 n2 n3 p1 p2,
    path_endpoints p1 n1 n2 -> path_endpoints p2 n2 n3 -> path_endpoints (p1 +++ p2) n1 n3.
  Proof.
    split; destruct H, H0.
    icase p1. unfold path_glue.
    icase p2. icase p2. inv H0. inv H2. simpl. rewrite app_nil_r. trivial.
    rewrite foot_app; disc. apply H2.
  Qed.

  Lemma valid_path_tail: forall (g : Gph) p, valid_path g p -> valid_path g (tail p).
  Proof.
    destruct p; auto. simpl. destruct p; auto.
    intro; simpl; auto. intros [? ?]; auto.
  Qed.

  Lemma valid_path_split: forall (g : Gph) p1 p2, valid_path g (p1 ++ p2) -> valid_path g p1 /\ valid_path g p2.
  Proof.
    induction p1. simpl. tauto.
    intros. rewrite <- app_comm_cons in H.
    simpl in H. revert H. case_eq (p1 ++ p2); intros.
    apply app_eq_nil in H. destruct H. subst. simpl. tauto.
    destruct H0. rewrite <- H in H1.
    apply IHp1 in H1. destruct H1.
    split; trivial.
    simpl. destruct p1; auto.
    destruct H0; auto.
    rewrite <- app_comm_cons in H. inv H. tauto.
  Qed.

  Lemma valid_path_merge: forall (g : Gph) p1 p2,
                            paths_meet p1 p2 -> valid_path g p1 -> valid_path g p2 -> valid_path g (p1 +++ p2).
  Proof.
    induction p1. simpl. intros. apply valid_path_tail. trivial.
    intros. rewrite <- path_glue_comm_cons.
    simpl.
    case_eq (p1 +++ p2); auto.
    intros. simpl in H0. destruct p1; auto; destruct H0; destruct H0; auto.
    intros. rewrite <- H2.
    split.
    icase p1. unfold path_glue in H2. simpl in H2.
    icase p2. inv H. simpl in H2. subst p2.
    simpl in H1. destruct H3. rewrite <- H in H2. simpl in H2. inv H2. tauto.
    rewrite <- path_glue_comm_cons in H2. inv H2.
    simpl in H0. tauto.
    icase p1.
    rewrite path_glue_nil_l. apply valid_path_tail; auto.
    apply IHp1; auto.
    change (n0 :: p1) with (tail (a :: n0 :: p1)). apply valid_path_tail; auto.
  Qed.

  Lemma valid_path_si {V D1 D2 : Type} {EV: EqDec V}:
    forall (g1 : @PreGraph V D1 EV) (g2 : @PreGraph V D2 EV),
      structurally_identical g1 g2 -> forall p, valid_path g1 p -> valid_path g2 p.
  Proof.
    induction p; simpl; auto.
    icase p.
    intro; destruct (H a); rewrite <- H1; auto.
    intros [? ?]. split; auto.
    apply (edge_si g1 g2 a v H H0).
  Qed.

  Lemma valid_path_acyclic:
    forall (g : Gph) (p : path) n1 n2,
      path_endpoints p n1 n2 -> valid_path g p ->
      exists p', Sublist p' p /\ path_endpoints p' n1 n2 /\ NoDup p' /\ valid_path g p'.
  Proof.
    intros until p. remember (length p). assert (length p <= n) by omega. clear Heqn. revert p H. induction n; intros.
    icase p; icase H0. inv H0. inv H. destruct (nodup_dec p) as [? | H2]. exists p. split. reflexivity. tauto.
    apply Dup_cyclic in H2. destruct H2 as [a [L1 [L2 [L3 ?]]]]. subst p. specialize (IHn (L1 ++ a :: L3)).
    spec IHn. do 2 rewrite app_length in H. rewrite app_length. simpl in *. omega. specialize (IHn n1 n2).
    spec IHn. destruct H0. split. icase L1. repeat (rewrite foot_app in *; disc). trivial.
    spec IHn. change (L1 ++ a :: L3) with (L1 ++ (a :: nil) ++ tail (a :: L3)).
    rewrite app_assoc. change (a :: L2) with ((a :: nil) ++ L2) in H1.
    do 2 rewrite app_assoc in H1. apply valid_path_split in H1. destruct H1.
    apply valid_path_merge; auto. apply paths_foot_head_meet. apply valid_path_split in H1. tauto.
    destruct IHn as [p' [? [? [? ?]]]]. exists p'. split. 2: tauto. transitivity (L1 ++ a :: L3); auto.
    apply Sublist_app. reflexivity. pattern (a :: L3) at 1. rewrite <- (app_nil_l (a :: L3)).
    apply Sublist_app. apply Sublist_nil. reflexivity.
  Qed.

  Lemma node_prop_label_eq: forall g1 g2 n P,
    @node_label _ D _ g1 n = @node_label _ _ _ g2 n -> node_prop g1 P n -> node_prop g2 P n.
  Proof. intros; hnf in *; rewrite <- H; trivial.  Qed.

  Lemma node_prop_weaken: forall g (P1 P2 : set D) n, (forall d, P1 d -> P2 d) -> node_prop g P1 n -> node_prop g P2 n.
  Proof. intros; hnf in *; auto. Qed.

  Lemma path_prop_weaken: forall g (P1 P2 : set D) p,
    (forall d, P1 d -> P2 d) -> path_prop g P1 p -> path_prop g P2 p.
  Proof. intros; hnf in *; intros; hnf in *; apply H; apply H0; auto. Qed.

  Lemma path_prop_sublist: forall (g: Gph) P p1 p2, Sublist p1 p2 -> path_prop g P p2 -> path_prop g P p1.
  Proof. repeat intro; apply H0; apply H; trivial. Qed.

  Lemma path_prop_tail: forall (g: Gph) P n p, path_prop g P (n :: p) -> path_prop g P p.
  Proof. repeat intro; specialize (H n0); apply H; apply in_cons; trivial. Qed.

  Lemma good_path_split: forall (g: Gph) p1 p2 P, good_path g P (p1 ++ p2) -> (good_path g P p1) /\ (good_path g P p2).
  Proof.
    intros. destruct H. apply valid_path_split in H. destruct H. unfold good_path. unfold path_prop in *. intuition.
  Qed.

  Lemma good_path_merge: forall (g: Gph) p1 p2 P,
                           paths_meet p1 p2 -> good_path g P p1 -> good_path g P p2 -> good_path g P (p1 +++ p2).
  Proof.
    intros. destruct H0. destruct H1. split. apply valid_path_merge; auto. unfold path_prop in *. intros.
    unfold path_glue in H4. apply in_app_or in H4. destruct H4. auto. apply H3. apply In_tail; auto.
  Qed.

  Lemma good_path_weaken: forall (g: Gph) p (P1 P2 : set D),
                            (forall d, P1 d -> P2 d) -> good_path g P1 p -> good_path g P2 p.
  Proof.
    split; destruct H0; auto.
    apply path_prop_weaken with P1; auto.
  Qed.

  Lemma good_path_acyclic:
    forall (g: Gph) P p n1 n2,
      path_endpoints p n1 n2 -> good_path g P p -> exists p', path_endpoints p' n1 n2 /\ NoDup p' /\ good_path g P p'.
  Proof.
    intros. destruct H0. apply valid_path_acyclic with (n1 := n1) (n2 := n2) in H0; trivial.
    destruct H0 as [p' [? [? [? ?]]]]. exists p'. split; trivial. split; trivial.
    split; trivial. apply path_prop_sublist with p; trivial.
  Qed.

  Lemma reachable_by_path_nil: forall (g : Gph) n1 n2 P, ~ g |= nil is n1 ~o~> n2 satisfying P.
  Proof. repeat intro. destruct H as [[? _] _]. disc. Qed.

  Lemma reachable_by_path_head: forall (g: Gph) p n1 n2 P, g |= p is n1 ~o~> n2 satisfying P -> head p = Some n1.
  Proof. intros. destruct H as [[? _] _]. trivial. Qed.

  Lemma reachable_by_path_foot: forall (g: Gph) p n1 n2 P, g |= p is n1 ~o~> n2 satisfying P -> foot p = Some n2.
  Proof. intros. destruct H as [[_ ?] _]. trivial. Qed.

  Lemma reachable_by_path_merge: forall (g: Gph) p1 n1 n2 p2 n3 P,
                                   g |= p1 is n1 ~o~> n2 satisfying P ->
                                   g |= p2 is n2 ~o~> n3 satisfying P ->
                                   g |= (p1 +++ p2) is n1 ~o~> n3 satisfying P.
  Proof.
    intros. destruct H. destruct H0.
    split. apply path_endpoints_glue with n2; auto.
    apply good_path_merge; auto.
    eapply path_endpoints_meet; eauto.
  Qed.

  Lemma reachable_by_path_split_glue:
    forall (g: Gph) P p1 p2 n1 n2 n, paths_meet_at p1 p2 n ->
                                     g |= (p1 +++ p2) is n1 ~o~> n2 satisfying P ->
                                     g |= p1 is n1 ~o~> n satisfying P /\
                                     g |= p2 is n ~o~> n2 satisfying P.
  Proof.
    intros. unfold path_glue in H0. destruct H0.
    destruct H.
    destruct (foot_explicit _ _ H) as [L' ?]. subst p1.
    icase p2. inv H2.
    copy H1. apply good_path_split in H1. destruct H1 as [? _].
    rewrite <- app_assoc in H2, H0. simpl in H2, H0.
    apply good_path_split in H2. destruct H2 as [_ ?].
    destruct H0. rewrite foot_app in H3; disc.
    repeat (split; trivial). icase L'.
  Qed.

  Lemma reachable_by_path_split_in: forall (g : Gph) P p n n1 n2,
    g |= p is n1 ~o~> n2 satisfying P ->
    In n p -> exists p1 p2,
                p = p1 +++ p2 /\
                g |= p1 is n1 ~o~> n satisfying P /\
                g |= p2 is n ~o~> n2 satisfying P.
  Proof.
    intros. destruct (in_split _ _ H0) as [p1 [p2 ?]]. subst p. clear H0.
    replace (p1 ++ n :: p2) with ((p1 ++ (n :: nil)) +++ (n :: p2)) in H.
    2: unfold path_glue; rewrite <- app_assoc; auto.
    apply reachable_by_path_split_glue with (n := n) in H.
    exists (p1 ++ n :: nil). exists (n :: p2).
    split; trivial.
    unfold path_glue. rewrite <- app_assoc. trivial.
    split; trivial. rewrite foot_app; disc. trivial.
  Qed.

  Lemma reachable_by_path_In_prop: forall (g: Gph) p n1 n2 P n,
    g |= p is n1 ~o~> n2 satisfying P -> In n p -> node_prop g P n.
  Proof. intros. destruct H as [_ [_ ?]]. apply H. trivial. Qed.

  Lemma reachable_by_reflexive: forall (g : Gph) n P, @valid _ _ _ g n /\ node_prop g P n -> g |= n ~o~> n satisfying P.
  Proof.
    intros.
    exists (n :: nil). split. compute. auto.
    split. simpl. trivial. destruct H; auto.
    intros ? ?. icase H0. subst n0. destruct H; trivial.
  Qed.

  Lemma reachable_by_merge: forall (g: Gph) n1 n2 n3 P,
    g |= n1 ~o~> n2 satisfying P ->
    g |= n2 ~o~> n3 satisfying P ->
    g |= n1 ~o~> n3 satisfying P.
  Proof. do 2 destruct 1. exists (x +++ x0). apply reachable_by_path_merge with n2; auto. Qed.

  Lemma reachable_by_head_prop: forall (g: Gph) n1 n2 P, g |= n1 ~o~> n2 satisfying P -> node_prop g P n1.
  Proof.
    intros. destruct H as [p ?]. eapply reachable_by_path_In_prop; eauto.
    apply reachable_by_path_head in H. icase p. inv H. simpl. auto.
  Qed.

  Lemma reachable_by_foot_prop: forall (g: Gph) n1 n2 P, g |= n1 ~o~> n2 satisfying P -> node_prop g P n2.
  Proof.
    intros. destruct H as [p ?]. eapply reachable_by_path_In_prop; eauto.
    apply reachable_by_path_foot in H. apply foot_in. trivial.
  Qed.

  Lemma reachable_by_cons:
    forall (g: Gph) n1 n2 n3 P, g |= n1 ~> n2 -> node_prop g P n1 ->
                                g |= n2 ~o~> n3 satisfying P ->
                                g |= n1 ~o~> n3 satisfying P.
  Proof.
    intros. apply reachable_by_merge with n2; auto.
    apply reachable_by_head_prop in H1.
    exists (n1 :: n2 :: nil). split. split; auto.
    split. simpl. split; auto. destruct H as [? [? ?]]. auto.
    intros n ?. simpl in H2.
    icase H2. subst; trivial.
    icase H2. subst; trivial.
  Qed.

  Lemma reachable_acyclic: forall (g: Gph) n1 P n2,
    g |= n1 ~o~> n2 satisfying P <->
    g |= n1 ~~> n2 satisfying P.
  Proof.
    split; intros.
    destruct H as [p [? ?]].
    apply (good_path_acyclic g P p n1 n2 H) in H0.
    destruct H0 as [p' [? ?]].
    exists p'. destruct H1. split; auto. split; auto.
    destruct H as [p [? ?]].
    exists p. trivial.
  Qed.

  Lemma reachable_by_subset_reachable: forall (g: Gph) n P,
    subset (reachable_by g n P) (reachable g n).
  Proof.
    repeat intro. unfold reachable.
    destruct H as [p [? [? ?]]]. exists p.
    split; trivial.
    split; trivial. apply path_prop_weaken with P; auto.
  Qed.

  Lemma valid_path_valid: forall (g : Gph) p, valid_path g p -> Forall (@valid _ _ _ g) p.
  Proof.
    induction p; intros; simpl in *. apply Forall_nil.
    destruct p; constructor; auto; destruct H as [[? ?] ?]; [| apply IHp]; auto.
  Qed.

  Lemma reachable_foot_valid: forall (g : Gph) n1 n2, reachable g n1 n2 -> @valid _ _ _ g n2.
  Proof.
    repeat intro. destruct H as [l [[? ?] [? ?]]]. apply foot_in in H0. apply valid_path_valid in H1.
    rewrite Forall_forall in H1. apply H1. auto.
  Qed.

  (* START OF MARK *)
  Variable marked : set D.
  Definition unmarked (d : D) : Prop := ~ marked d.

  Definition mark1 (g1 : Gph) (n : N) (g2 : Gph) : Prop :=
    structurally_identical g1 g2 /\ @valid _ _ _ g1 n /\
    node_prop g2 marked n /\
    forall n', n <> n' -> @node_label _ _ _ g1 n' = @node_label _ _ _ g2 n'.

  (* The first subtle lemma *)
  Lemma mark1_unmarked : forall g1 root g2 n,
    mark1 g1 root g2 ->
    g1 |= root ~o~> n satisfying unmarked ->
      n = root \/
      exists child,
        edge g1 root child /\
        g2 |= child ~o~> n satisfying unmarked.
  Proof.
    intros.
    (* Captain Hammer *)
    rewrite reachable_acyclic in H0.
    destruct H0 as [p [? ?]].
    icase p. exfalso. eapply reachable_by_path_nil; eauto.
    assert (n0 = root) by (apply reachable_by_path_head in H1; inv H1; trivial). subst n0.
    icase p. apply reachable_by_path_foot in H1. inv H1; auto.
    right. exists n0.
    change (root :: n0 :: p) with ((root :: n0 :: nil) +++ (n0 :: p)) in H1.
    apply reachable_by_path_split_glue with (n := n0) in H1. 2: red; auto. destruct H1.
    split. destruct H1 as [_ [? _]]. apply valid_path_si with (g4 := g2) in H1. 2: destruct H; trivial.
    simpl in H1. destruct H. apply si_sym in H. apply edge_si with g2; tauto.
    exists (n0 :: p). destruct H2 as [? [? ?]].
    split; trivial.
    destruct H as [? [_ ?]]. split. eapply valid_path_si; eauto.
    intros ? ?. specialize (H4 n1 H6).
    (* Hammertime! *)
    assert (root <> n1). intro. inversion H0. subst. contr.
    destruct H5.
    specialize (H8 n1 H7). eapply node_prop_label_eq; eauto.
  Qed.

  (* Not the best name in the world... *)
  Lemma mark1_reverse_unmark: forall g1 root g2,
    mark1 g1 root g2 ->
    forall n1 n2,
      g2 |= n1 ~o~> n2 satisfying unmarked ->
      g1 |= n1 ~o~> n2 satisfying unmarked.
  Proof.
    intros. destruct H0 as [p [? ?]]. exists p. split; trivial.
    destruct H1. destruct H as [? [? ?]].
    split. eapply valid_path_si; eauto. apply si_sym; trivial. (* clear -H3 H0 H2. *)
    intros ? ?. specialize (H2 n H5). destruct H4. specialize (H6 n).
    spec H6. intro. subst n. hnf in H3. hnf in H2. specialize (H2 H4). inv H2.
    apply node_prop_label_eq with g2; auto.
  Qed.

  Definition mark (g1 : Gph) (root : N) (g2 : Gph) : Prop :=
    structurally_identical g1 g2 /\
    (forall n,  g1 |= root ~o~> n satisfying unmarked -> node_prop g2 marked n) /\
    (forall n, ~g1 |= root ~o~> n satisfying unmarked -> @node_label _ _ _ g1 n = @node_label _ _ _ g2 n).

  Require Import Classical.
  Tactic Notation "LEM" constr(v) := (destruct (classic v); auto).
  (* Sanity condition 1 *)
  Lemma mark_reachable: forall g1 root g2,
    mark g1 root g2 ->
    subset (reachable g1 root) (reachable g2 root).
  Proof.
    repeat intro. destruct H as [? [? ?]].
    destruct H0 as [p ?]. destruct H0.
    exists p. split. tauto.
    destruct H3. split. eapply valid_path_si; eauto.
    clear -H1 H2 H4. induction p; repeat intro. inv H. simpl in H. destruct H. subst a.
    LEM (g1 |= root ~o~> n satisfying unmarked).
    specialize (H1 n H). apply node_prop_weaken with marked; auto.
    specialize (H2 n H). eapply node_prop_label_eq; eauto. apply H4. left. trivial.
    apply IHp; auto. intros ? ?. apply H4. right. trivial.
  Qed.

  (* The second subtle lemma.  Maybe needs a better name? *)
  Lemma mark_unmarked: forall g1 root g2 n1 n2,
    mark g1 root g2 ->
    g1 |= n1 ~o~> n2 satisfying unmarked ->
    (g2 |= n1 ~o~> n2 satisfying unmarked) \/ (node_prop g2 marked n2).
  Proof.
    intros. destruct H0 as [p ?].
    (* This is a very handy LEM. *)
    LEM (exists n, In n p /\ g1 |= root ~o~> n satisfying unmarked).
    right. destruct H as [_ [? _]]. apply H.
    destruct H1 as [n [? ?]]. apply reachable_by_merge with n; trivial.
    destruct (reachable_by_path_split_in _ _ _ _ _ _ H0 H1) as [p1 [p2 [? [? ?]]]].
    exists p2. trivial.
    left. exists p. destruct H0. split; trivial. clear H0.
    destruct H2. destruct H as [? [_ ?]]. split. eapply valid_path_si; eauto.
    intros ? ?. specialize (H2 n H4). specialize (H3 n).
    spec H3. intro. apply H1. exists n. tauto.
    eapply node_prop_label_eq; eauto.
  Qed.

  Lemma mark_marked: forall g1 root g2,
    mark g1 root g2 ->
    forall n,
      node_prop g1 marked n->
      node_prop g2 marked n.
  Proof.
    intros. destruct H as [_ [? ?]].
    LEM (g1 |= root ~o~> n satisfying unmarked).
    specialize (H1 n H2). eapply node_prop_label_eq; eauto.
  Qed.

  (* Maybe a better name? *)
  Lemma mark_reverse_unmarked: forall g1 root g2,
    mark g1 root g2 ->
    forall n1 n2,
      g2 |= n1 ~o~> n2 satisfying unmarked ->
      g1 |= n1 ~o~> n2 satisfying unmarked.
  Proof.
    intros. destruct H0 as [p [? ?]]. exists p. split; trivial. clear H0.
    destruct H as [? [? ?]]. destruct H1.
    split. eapply valid_path_si; eauto. apply si_sym; trivial. clear -H3 H0 H2.
    intros ? ?. specialize (H3 n H). specialize (H0 n). specialize (H2 n).
    LEM (g1 |= root ~o~> n satisfying unmarked).
    specialize (H0 H1). clear H2 H1. exfalso.
    hnf in H3. hnf in H0. apply H3. auto.
    specialize (H2 H1). apply node_prop_label_eq with g2; auto.
  Qed.

  (* Here is where we specialize to bigraphs, at least at root *)
  Definition node_connected_two (g : Gph) (root left right : N) : Prop :=
    edge g root left /\
    edge g root right /\
    forall n', edge g root n' -> n' = left \/ n' = right.

  (* The main lemma *)
  Lemma mark_mark_mark1: forall g1 g2 g3 g4 root left right,
    node_prop g1 unmarked root -> (* Oh no!  We forgot this precondition in the paper!! *)
    node_connected_two g1 root left right ->
    mark1 g1 root g2 ->
    mark g2 left g3 ->
    mark g3 right g4 ->
    mark g1 root g4.
  Proof.
    split. destruct H1, H2, H3. generalize (si_trans H1 H2); intro. generalize (si_trans H7 H3). tauto.
    split; intros.
    (* Need subtle lemma 1 *)
    destruct (mark1_unmarked _ _ _ _ H1 H4); clear H4.
    subst n. eapply mark_marked; eauto. eapply mark_marked; eauto. red in H1; tauto.
    destruct H5 as [child [? ?]]. destruct H0 as [_ [_ ?]]. apply H0 in H4. clear H0.
    destruct H4; subst child.
    eapply mark_marked; eauto.
    destruct H2 as [_ [? _]]. auto.
    (* Need subtle lemma 2 *)
    destruct (mark_unmarked _ _ _ _ _ H2 H5).
    destruct H3 as [_ [? _]]. auto.
    eapply mark_marked; eauto.
    (* *** *)
    assert (root <> n). intro. subst n. apply H4. apply reachable_by_reflexive; split; auto.
    destruct H1; destruct H5; auto.
    assert (~ g2 |= left ~o~> n satisfying unmarked).
      intro. apply H4. apply reachable_by_cons with left; auto. red in H0; tauto.
      eapply mark1_reverse_unmark; eauto.
    assert (~ g3 |= right ~o~> n satisfying unmarked).
      intro. apply H4. apply mark_reverse_unmarked with (root := left) (g1 := g2) in H7; auto.
      apply reachable_by_cons with right; auto. red in H0; tauto.
      eapply mark1_reverse_unmark; eauto.
    destruct H1 as [? [_ ?]]. destruct H8 as [? H88]. rewrite H88; auto.
    destruct H2 as [? [_ ?]]. rewrite H9; auto.
    destruct H3 as [? [_ ?]]. rewrite H10; auto.
  Qed.

  Lemma mark_unreachable: forall g1 root g2,
    mark g1 root g2 ->
    forall n, ~ (reachable g1 root n) -> @node_label _ _ _ g1 n = @node_label _ _ _ g2 n.
  Proof.
    intros. destruct H as [? [? ?]].
    apply H2.
    intro. apply H0.
    generalize (reachable_by_subset_reachable g1 root unmarked n); intro.
    intuition.
  Qed.
End GraphPath.

Definition reachable_through_set {A D : Type} {EV: EqDec A} (g: PreGraph A D) (S : list A) : set A:=
  fun n => exists s, In s S /\ reachable g s n.

Lemma reachable_set_eq {A D : Type} {EV: EqDec A} (g: PreGraph A D) (S1 S2 : list A):
  S1 ~= S2 -> set_eq (reachable_through_set g S1) (reachable_through_set g S2).
Proof. intros; destruct H; split; repeat intro; destruct H1 as [x [HIn Hrch]]; exists x; split; auto. Qed.

Definition reachable_valid {A D : Type} {EV: EqDec A} (g: PreGraph A D) (S : list A) : A -> Prop :=
  fun n => @valid _ _ _ _ n /\ reachable_through_set g S n.

Definition reachable_subgraph {A D : Type} {EV: EqDec A} (g: PreGraph A D) (S : list A) :=
  Build_PreGraph A D EV (reachable_valid g S) node_label edge_func.

Definition unreachable_valid {A D : Type} {EV: EqDec A} (g: PreGraph A D) (S : list A) : A -> Prop :=
  fun n => @valid _ _ _ _ n /\ ~ reachable_through_set g S n.

Definition unreachable_subgraph {A D : Type} {EV: EqDec A} (g: PreGraph A D) (S : list A) :=
  Build_PreGraph A D EV (unreachable_valid g S) node_label edge_func.

Lemma reachable_through_empty {A D : Type} {EV: EqDec A} (g: PreGraph A D):
  set_eq (reachable_through_set g nil) (empty_set A).
Proof.
  split; repeat intro.
  destruct H; destruct H; apply in_nil in H; tauto.
  hnf in H; tauto.
Qed.

Lemma reachable_is_valid {A D : Type} {EV: EqDec A} (g: PreGraph A D):
  forall a x, reachable g x a -> valid x.
Proof.
  intros. destruct H as [l [? [? ?]]].
  destruct l. destruct H; discriminate H.
  destruct H; inversion H; rewrite H4 in *; clear H4 H2 a0;
  simpl in H0; destruct l; trivial; destruct H0 as [[? _] _]; trivial.
Qed.

Definition well_defined_list {A D : Type} {EV : EqDec A} {null : A} (mg : MathGraph A D null) (l : list A) :=
  forall x, In x l -> x = null \/ valid x.

Tactic Notation "LEM" constr(v) := (destruct (classic v); auto).

Lemma reachable_through_empty_eq {A D : Type} {EV: EqDec A} (g: PreGraph A D):
  forall S, set_eq (reachable_through_set g S) (empty_set A) <-> S = nil \/ forall y, In y S -> ~ valid y.
Proof.
  intros; split.
  induction S; intros. left; trivial. right; intros; LEM (valid a).
  destruct H. exfalso; apply (H a); exists a; split; [apply in_eq | apply reachable_by_reflexive; split;[|hnf]; trivial].
  destruct (in_inv H0). rewrite H2 in H1; trivial.
  assert (set_eq (reachable_through_set g (a :: S)) (reachable_through_set g S)).
  split; intro x; intro; destruct H3 as [s [? ?]]. destruct (in_inv H3). rewrite H5 in *; clear H5 a.
  apply reachable_is_valid in H4; tauto. exists s; split; trivial.
  exists s; split; trivial; apply in_cons; trivial. rewrite <- H3 in IHS. destruct (IHS H).
  rewrite H4 in *; inversion H0. rewrite H5 in H1. trivial. inversion H5. apply H4; trivial.

  intros; destruct H. rewrite H. apply reachable_through_empty. split; repeat intro.
  destruct H0 as [x [? ?]]. apply H in H0. apply reachable_is_valid in H1; tauto. hnf in H0; tauto.
Qed.

Definition change_valid {A D: Type} {EV: EqDec A} (g: PreGraph A D) (v: A): A -> Prop :=
  fun n => valid n \/ n = v.

Definition change_node_label {A D: Type} {EV: EqDec A} (g: PreGraph A D) (v: A) (d: D): A -> D :=
  fun n => if t_eq_dec n v then d else node_label n.

Definition change_edge_func {A D: Type} {EV: EqDec A} (g: PreGraph A D) (v l r: A): A -> list A :=
  fun n => if t_eq_dec n v then (l:: r:: nil) else edge_func n.

Definition update_PreGraph {A D: Type} {EV: EqDec A} (g: PreGraph A D) v d l r :=
  Build_PreGraph A D EV (change_valid g v) (change_node_label g v d) (change_edge_func g v l r).

Definition update_BiGraph {A D: Type} {EV: EqDec A} (g: BiGraph A D) (v: A) (d: D) (l r: A): BiGraph A D.
  refine (Build_BiGraph A D EV (update_PreGraph b_pg v d l r) _).
  intro n. destruct (t_eq_dec n v). exists l, r. subst. simpl. unfold change_edge_func. destruct (t_eq_dec v v).
  auto. exfalso. auto. destruct (only_two_neighbours n) as [vv1 [vv2 ?]]. exists vv1, vv2. simpl. unfold change_edge_func.
  destruct (t_eq_dec n v). exfalso; auto. auto.
Defined.

Definition in_math {A D: Type} {nV: A} {EV: EqDec A} (g: MathGraph A D nV) (v: A) (l r: A) : Prop :=
  forall e, In e (l :: r :: nil) -> valid e \/ e = v \/ e = nV.

Definition update_MathGraph {A D: Type} {nV: A} {EV: EqDec A} (g: MathGraph A D nV)
           (v: A) (d: D) (l r: A) (Hi: in_math g v l r) (Hn: v <> nV): MathGraph A D nV.
  refine (Build_MathGraph A D nV EV (update_PreGraph m_pg v d l r) _ _).
  intros. simpl in H0. unfold change_edge_func in H0. simpl in H; simpl. unfold change_valid in *. destruct (t_eq_dec x v).
  subst. specialize (Hi y H0). destruct Hi as [? | [? | ?]]; [right; left | right; right | left]; auto.
  destruct H. apply (valid_graph x H y) in H0. destruct H0; [left | right; left]; auto. exfalso; auto.
  intros. simpl in H. unfold change_valid in H. destruct H; [apply valid_not_null | subst]; auto.
Defined.

Definition update_graph {A D: Type} {nV: A} {EV: EqDec A} (g: BiMathGraph A D nV)
           (v: A) (d: D) (l r: A) (Hi: in_math bm_ma v l r) (Hn: v <> nV): BiMathGraph A D nV.
  refine (Build_BiMathGraph A D nV EV (update_BiGraph bm_bi v d l r) (update_MathGraph bm_ma v d l r Hi Hn) _).
  simpl. rewrite pg_the_same. auto.
Defined.

Definition single_PreGraph {A D: Type} (EV: EqDec A) (v : A) (d : D) (l r : A) : PreGraph A D :=
  Build_PreGraph A D EV (fun n => n = v) (fun n => d) (fun n => (l :: r :: nil)).

Definition single_BiGraph {A D: Type} (EV: EqDec A) (v: A) (d: D) (l r : A) : BiGraph A D.
  refine (Build_BiGraph A D EV (single_PreGraph EV v d l r) _).
  intros. exists l, r. simpl. auto.
Defined.

Definition single_MathGraph_double {A D: Type} (nV: A) (EV: EqDec A) (v: A) (d: D) (Hn: v <> nV): MathGraph A D nV.
  refine (Build_MathGraph A D nV EV (single_PreGraph EV v d v v) _ _).
  intros. simpl in H. subst. simpl in H0. simpl. destruct H0 as [? | [? | ?]]; [right | right | exfalso]; auto.
  intros. simpl in H. subst. auto.
Defined.

Definition single_MathGraph_left {A D: Type} (nV: A) (EV: EqDec A) (v: A) (d: D) (Hn: v <> nV): MathGraph A D nV.
  refine (Build_MathGraph A D nV EV (single_PreGraph EV v d v nV) _ _).
  intros. simpl in H. subst. simpl in H0. simpl. destruct H0 as [? | [? | ?]]; [right | left | exfalso]; auto.
  intros. simpl in H. subst. auto.
Defined.

Definition single_MathGraph_right {A D: Type} (nV: A) (EV: EqDec A) (v: A) (d: D) (Hn: v <> nV): MathGraph A D nV.
  refine (Build_MathGraph A D nV EV (single_PreGraph EV v d nV v) _ _).
  intros. simpl in H. subst. simpl in H0. simpl. destruct H0 as [? | [? | ?]]; [left | right | exfalso]; auto.
  intros. simpl in H. subst. auto.
Defined.


Definition single_graph_double {A D: Type} (nV: A) (EV: EqDec A) (v: A) (d: D) (Hn: v <> nV): BiMathGraph A D nV.
  refine (Build_BiMathGraph A D nV EV (single_BiGraph EV v d v v) (single_MathGraph_double nV EV v d Hn) _); simpl; auto.
Defined.

Definition single_graph_left {A D: Type} (nV: A) (EV: EqDec A) (v: A) (d: D) (Hn: v <> nV): BiMathGraph A D nV.
  refine (Build_BiMathGraph A D nV EV (single_BiGraph EV v d v nV) (single_MathGraph_left nV EV v d Hn) _); simpl; auto.
Defined.

Definition single_graph_right {A D: Type} (nV: A) (EV: EqDec A) (v: A) (d: D) (Hn: v <> nV): BiMathGraph A D nV.
  refine (Build_BiMathGraph A D nV EV (single_BiGraph EV v d nV v) (single_MathGraph_right nV EV v d Hn) _); simpl; auto.
Defined.
