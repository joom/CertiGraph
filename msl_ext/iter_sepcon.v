Require Import RamifyCoq.msl_ext.abs_addr.
Require Import RamifyCoq.msl_ext.seplog.
Require Import RamifyCoq.msl_ext.log_normalize.
Require Import RamifyCoq.Coqlib.
Require Import VST.msl.Extensionality.
Require Import VST.msl.simple_CCC.
Require Import VST.msl.seplog.
Require Import VST.msl.log_normalize.
Require Import Coq.Lists.List.
Require Import Coq.Sorting.Permutation.
Import RamifyCoq.msl_ext.seplog.OconNotation.

Local Open Scope logic.

Set Implicit Arguments.

Section IterSepCon.

  Variable A : Type.
  Variable B : Type.
  Variable ND : NatDed A.
  Variable SL : SepLog A.
  Variable ClS: ClassicalSep A.
  Variable PSL : PreciseSepLog A.
  Variable CoSL: CorableSepLog A.
  Variable OSL: OverlapSepLog A.
  Variable DSL : DisjointedSepLog A.

Fixpoint iter_sepcon (l : list B) (p : B -> A) : A :=
  match l with
    | nil => emp
    | x :: xl => p x * iter_sepcon xl p
  end.

Lemma iter_sepcon_app_sepcon:
  forall (l1 l2 : list B) (p : B -> A), iter_sepcon (l1 ++ l2) p = iter_sepcon l1 p * iter_sepcon l2 p.
Proof.
  induction l1; intros; simpl. rewrite emp_sepcon; auto. rewrite IHl1. rewrite sepcon_assoc. auto.
Qed.

Lemma iter_sepcon_app_comm: forall (l1 l2 : list B) (p : B -> A), iter_sepcon (l1 ++ l2) p = iter_sepcon (l2 ++ l1) p.
Proof. intros. do 2 rewrite iter_sepcon_app_sepcon. rewrite sepcon_comm. auto. Qed.

Lemma iter_sepcon_permutation: forall  (l1 l2 : list B) (p : B -> A), Permutation l1 l2 -> iter_sepcon l1 p = iter_sepcon l2 p.
Proof.
  intros. induction H; simpl; auto.
  + rewrite IHPermutation. auto.
  + do 2 rewrite <- sepcon_assoc. rewrite (sepcon_comm (p y)). auto.
  + rewrite IHPermutation1. auto.
Qed.

Lemma precise_iter_sepcon: forall (p : B -> A), (forall z, precise (p z)) -> forall (l : list B), precise (iter_sepcon l p).
Proof. intros; induction l; simpl. apply precise_emp. apply precise_sepcon; auto. Qed.

Lemma iter_sepcon_in_true: forall (p : B -> A) (l : list B) x, In x l -> iter_sepcon l p |-- p x * TT.
Proof.
  intros. apply in_split in H. destruct H as [l1 [l2 ?]]. subst.
  rewrite iter_sepcon_app_comm. rewrite <- app_comm_cons. simpl.
  apply sepcon_derives; auto. apply TT_right.
Qed.

Definition sepcon_unique (p : B -> A) :Prop := forall x, p x * p x |-- FF.

Lemma iter_sepcon_unique_nodup: forall (p : B -> A) (l : list B), sepcon_unique p -> iter_sepcon l p |-- !!(NoDup l).
Proof.
  intros. induction l.
  + apply prop_right. constructor.
  + simpl.
    assert (p a * iter_sepcon l p |-- !!(~ In a l)). {
      apply not_prop_right.
      intros. apply (iter_sepcon_in_true p) in H0.
      apply derives_trans with (p a * p a * TT).
      + rewrite sepcon_assoc. apply sepcon_derives. apply derives_refl. auto.
      + specialize (H a). apply derives_trans with (FF * TT).
        apply sepcon_derives; auto. rewrite sepcon_comm, sepcon_FF. apply derives_refl.
    }
  apply derives_trans with (!!(NoDup l) && !!(~ In a l)).
  - apply andp_right; auto. apply sepcon_left2_corable_right; auto with norm.
  - normalize. constructor; auto.
Qed.

Definition joinable (p : B -> A): Prop := forall x y, x <> y -> disjointed (p x) (p y).

Lemma iter_sepcon_joinable:
  forall (p : B -> A) (l : list B) (x : B), joinable p -> (~ In x l) -> disjointed (p x) (iter_sepcon l p).
Proof.
  intros. induction l; simpl.
  + apply disj_emp.
  + apply disj_sepcon_right.
    - apply H. intro. apply H0. subst. apply in_eq.
    - apply IHl. intro; apply H0. apply in_cons; auto.
Qed.

Lemma iter_sepcon_app_joinable:
  forall (p : B -> A) (l1 l2 : list B),
    joinable p -> (forall x, In x l1 -> ~ In x l2) -> disjointed (iter_sepcon l1 p) (iter_sepcon l2 p).
Proof.
  intros; induction l1; simpl; auto.
  + apply disj_comm, disj_emp.
  + apply disj_comm, disj_sepcon_right.
    - apply disj_comm, iter_sepcon_joinable; auto. apply H0, in_eq.
    - apply disj_comm, IHl1. intros; apply H0, in_cons; auto.
Qed.

(*
Fixpoint iter_ocon (l : list B) (p : B -> A) : A :=
  match l with
    | nil => emp
    | x :: xl => p x ⊗ iter_ocon xl p
  end.

Lemma iter_sepcon_iter_ocon: forall l p, iter_sepcon l p |-- iter_ocon l p.
Proof.
  induction l; intro; simpl.
  + apply derives_refl.
  + eapply derives_trans; [| apply sepcon_ocon].
    apply sepcon_derives; [apply derives_refl | apply IHl].
Qed.

Lemma iter_ocon_app_ocon:
  forall (l1 l2 : list B) (p : B -> A), iter_ocon (l1 ++ l2) p = ocon (iter_ocon l1 p) (iter_ocon l2 p).
Proof.
  induction l1; intros; simpl. rewrite emp_ocon; auto. rewrite (IHl1 l2). rewrite ocon_assoc. auto.
Qed.
*)

Lemma iter_sepcon_ocon' (eq_dec: forall x y : B, {x = y} + {x <> y}):
  forall l l1 l2 p,
    NoDup l -> NoDup l1 -> NoDup l2 ->
    (forall x, precise (p x)) -> joinable p ->
    (forall x, In x l <-> In x l1 \/ In x l2) ->
    iter_sepcon l p = iter_sepcon l1 p ⊗ iter_sepcon l2 p.
Proof.
  intros until p.
  intros NoDupl NoDupl1 NoDupl2 PRECISE EQUIV JOINABLE.
  assert (l ~= (l1 ++ l2)) by (apply eq_as_set_spec; intros; rewrite in_app_iff; auto).
  apply pred_ext.
  + destruct (tri_list_split eq_dec NoDupl NoDupl1 NoDupl2 H) as [i1 [i2 [i3 [? [? ?]]]]].
    rewrite (iter_sepcon_permutation _ H0).
    rewrite (iter_sepcon_permutation _ H1).
    rewrite (iter_sepcon_permutation _ H2).
    rewrite !iter_sepcon_app_sepcon. rewrite <- sepcon_assoc.
    apply tri_sepcon_ocon.
  + destruct (double_list_split eq_dec NoDupl1 NoDupl2) as [i1 [i2 [i3 [? [? ?]]]]].
    rewrite (iter_sepcon_permutation _ H0).
    rewrite (iter_sepcon_permutation _ H1).
    rewrite !iter_sepcon_app_sepcon.
    eapply derives_trans; [apply ocon_derives; apply sepcon_ocon |].
    rewrite ocon_assoc.
    rewrite <- (ocon_assoc (iter_sepcon i2 p)).
    rewrite <- precise_ocon_self by (apply precise_iter_sepcon; auto).
    assert (Permutation l (i1 ++ i2 ++ i3)).
    Focus 1. {
      apply eq_as_set_permutation; auto.
      rewrite H.
      apply eq_as_set_spec; intro x.
      unfold eq_as_set, Sublist.
      pose proof (Permutation_in x H0).
      pose proof (Permutation_in x H1).
      pose proof (Permutation_in x (Permutation_sym H0)).
      pose proof (Permutation_in x (Permutation_sym H1)).
      pose proof (in_app_iff i1 i2 x).
      pose proof (in_app_iff i2 i3 x).
      pose proof (in_app_iff i1 (i2 ++ i3) x).
      pose proof (in_app_iff l1 l2 x).
      tauto.
    } Unfocus.
    rewrite (iter_sepcon_permutation _ H3).
    rewrite !iter_sepcon_app_sepcon.
    eapply derives_trans;
    [ apply ocon_sepcon; apply disj_ocon_right
    | apply sepcon_derives; [auto | apply ocon_sepcon]];
    apply iter_sepcon_app_joinable; auto; intros;
    apply NoDup_app_eq in H2; destruct H2 as [? [? ?]];
    generalize (NoDup_app_not_in _ _ _  H5 x); intro; specialize (H6 x); auto;
    specialize (H6 H4); intro; apply H6; apply in_or_app; auto.
Qed.

Lemma iter_sepcon_ocon (eq_dec: forall x y : B, {x = y} + {x <> y}):
  forall l1 l2 p,
    NoDup l1 -> NoDup l2 ->
    (forall x, precise (p x)) -> joinable p ->
    iter_sepcon l1 p ⊗ iter_sepcon l2 p = iter_sepcon (remove_dup eq_dec (l1 ++ l2)) p.
Proof.
  intros.
  symmetry; apply iter_sepcon_ocon'; auto.
  + apply remove_dup_nodup; auto.
  + intros.
    rewrite <- remove_dup_in_inv.
    rewrite in_app_iff.
    tauto.
Qed.

End IterSepCon.

Implicit Arguments sepcon_unique [[A] [B] [ND] [SL]].
Implicit Arguments iter_sepcon [[A] [B] [ND] [SL]].
