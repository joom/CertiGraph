(* Orders & Boolean algebras
   Aquinas Hobor
*)

Require Import Setoid.
Require Import EquivDec.

(* Orders *)
Delimit Scope ord with ord.
Open Scope ord.

Class Ord (A : Type) : Type :=
  { ord : A -> A -> Prop;
    ord_refl : forall x, ord x x;
    ord_trans : forall x y z, ord x y -> ord y z -> ord x z;
    ord_antisym : forall x y, ord x y -> ord y x -> x = y
    }.
Notation "x <= y" := (ord x y) (at level 70, no associativity) : ord.
Notation "x <= y <= z" := ((x <= y) /\ (y <= z)) (at level 70, y at next level) : ord.

Add Parametric Relation {A} `{Ord A} : A ord
  reflexivity proved by ord_refl
  transitivity proved by ord_trans
  as ord_rel.

Implicit Arguments ord_refl [[A] [Ord]].
Implicit Arguments ord_trans [[A] [Ord]].
Implicit Arguments ord_antisym [[A] [Ord]].

Hint Resolve @ord_refl @ord_antisym @ord_trans : ord.

(* Comparability *)

Definition comparable {A} `{Ord A} (a b: A) : Prop :=
  a <= b \/ b <= a.
Notation "x ~ y" := (comparable x y) (at level 70, no associativity) : ord.

Lemma comparable_leq {A} `{Ord A}: forall a b,
  a <= b -> 
  a ~ b.
Proof. left. trivial. Qed.

Lemma comparable_refl {A} `{Ord A}: forall a : A,
  a ~ a.
Proof.
  left. reflexivity.
Qed.

Lemma comparable_symm {A} `{Ord A}: forall a b,
  a ~ b ->
  b ~ a.
Proof.
  unfold comparable. intros. tauto.
Qed.

Add Parametric Relation {A} `{Ord A} : A comparable
  reflexivity proved by comparable_refl
  symmetry proved by comparable_symm
  as comparable_rel.

Hint Resolve @comparable_leq @comparable_refl @comparable_symm : ord.

Class ComparableTrans (A : Type) `{O: Ord A} : Type :=
  comparable_trans : forall a b c, a ~ b -> b ~ c -> a ~ c.
Implicit Arguments comparable_trans [[A] [O] [ComparableTrans]].

Add Parametric Relation {A} `{ComparableTrans A} : A comparable
(*  reflexivity proved by comparable_refl
  symmetry proved by comparable_symm *)
  transitivity proved by comparable_trans
  as comparable_rel'.

Hint Resolve @comparable_trans : ord.

Class TOrd (A : Type) `{O: Ord A} : Type :=
  ord_total : forall x y : A, x ~ y.
Implicit Arguments TOrd [[O]].

Instance tord_ctrans {A} `{O : TOrd A} : ComparableTrans A.
  repeat intro.
  apply ord_total.
Qed.

Hint Resolve @ord_total : ord.

Definition sord {A} `{Ord A} (a1 a2 : A) : Prop :=
  a1 <= a2 /\ a1 <> a2.
Notation "x < y" := (sord x y) (at level 70, no associativity) : ord.
Notation "x < y < z" := ((x < y) /\ (y < z)) (at level 70, y at next level) : ord.
Notation "x <= y < z" := ((x <= y) /\ (y < z)) (at level 70, y at next level) : ord.
Notation "x < y <= z" := ((x < y) /\ (y <= z)) (at level 70, y at next level) : ord.

Lemma sord_trans {A} `{Ord A}: forall (x y z : A), x < y -> y < z -> x < z.
Proof.
  intros ? ? ? [? ?] [? ?].
  split. eauto with ord.
  intro. subst x. eauto with ord.
Qed.

Add Parametric Relation {A} `{Ord A} : A sord 
  transitivity proved by sord_trans
  as sord_rel.

Lemma sord_neq {A} `{Ord A} : forall x y : A, 
  (x < y) -> ~ x = y.
Proof.
  intros. destruct H0. trivial.
Qed.

Lemma sord_leq {A} `{Ord A} : forall x y : A, 
  (x < y) -> (x <= y).
Proof.
  intros. destruct H0. trivial.
Qed.

Lemma sord_ord_trans1 {A} `{Ord A} : forall x y z: A, 
  (x < y <= z) -> (x < z).
Proof.
  intros. destruct H0 as [[? ?] ?]. split.
  eauto with ord. intro. subst. eauto with ord.
Qed.

Lemma sord_ord_trans2 {A} `{Ord A} : forall x y z: A, 
  (x <= y < z) -> (x < z).
Proof.
  intros. destruct H0 as [? [? ?]]. split.
  eauto with ord. intro. subst. eauto with ord.
Qed.

Lemma sord_antirefl {A} `{Ord A} : forall x : A, ~(x < x).
Proof.
  repeat intro. destruct H0. tauto.
Qed.

(* EqDec is a little too strong; we only need
     forall x y, x = y \/ x <> y
*)
Lemma sord_total {A} `{TOrd A} `{EqDec A eq} : forall x y, x < y \/ x = y \/ y < x.
Proof.
  intros. destruct (H0 x y).
  right. left. trivial.
  destruct (ord_total x y);
  [left | right; right]; split; trivial. intro. subst. apply c. reflexivity.
Qed.

Hint Resolve @sord_neq @sord_leq @sord_ord_trans1 @sord_ord_trans2 @sord_antirefl: ord.

(* Decidability *)

Class COrd (A : Type) `{Ord A} : Type :=
  ord_dec: forall a b, {a <= b} + {~ a <= b}.

Instance cord_eqdec {A} `{COrd A} : EqDec A eq.
  do 2 intro.
  case (ord_dec x y); intro.
  case (ord_dec y x); intro.
  left. red. eauto with ord.
  right. intro. apply n. red in H1. subst. eauto with ord.
  right. intro. apply n. red in H1. subst. eauto with ord.
Qed.

Lemma sord_dec {A : Type} `{O : Ord A} `{@COrd A O} :
  forall a b, {a < b} + {~ a < b}.
Proof.
  intros. case (equiv_dec a b); intro.
  * red in e. subst. right. auto with ord.
  * case (ord_dec a b).
    + left. split; trivial.
    + right. intro. destruct H0. auto.
Qed.

Lemma comp_dec {A : Type} `{COrd A}:
  forall a b, {a ~ b} + {~ (a ~ b)}.
Proof.
  intros.
  case (ord_dec a b); intro.
  left. left. trivial.
  case (ord_dec b a); intro.
  left. right. trivial.
  right. intro.
  destruct H1; contradiction.
Qed.

Lemma tord_dec {A : Type} `{O : Ord A} `{@TOrd A O} `{@COrd A O} :
  forall a b, {a <= b} + {b <= a}.
Proof.
  intros.
  case (ord_dec a b). left. trivial.
  right. specialize (H a b). destruct H; auto. contradiction.
Qed.

Lemma tsord_dec {A : Type} `{O : Ord A} `{@TOrd A O} `{@COrd A O} :
  forall a b, {a < b} + {a = b} + {b < a}.
Proof.
  intros. case (equiv_dec a b); intro.
  tauto.
  case (tord_dec a b); intro.
  left. left. split; trivial.
  right. split; trivial. symmetry in c. trivial.
Qed.

(* Examples of orders *)

Definition trivial_ord A : Ord A.
  refine (Build_Ord _ eq _ _ _); auto.
  intros. congruence.
Defined.

Lemma trivial_not_total: exists A,
  ~@TOrd A (trivial_ord A).
Proof.
  exists nat. intro.
  specialize (H 0 1). simpl in H. destruct H; inversion H.
Qed.

Instance trivial_cord {A} `{EqDec A eq}: @COrd A (trivial_ord A).
Proof.
  apply H.
Qed.

Instance trivial_comptrans {A} : @ComparableTrans A (trivial_ord A).
Proof.
  repeat intro. unfold comparable in *. simpl in *. left. destruct H; destruct H0; congruence.
Qed.

Definition lex_ord A B `{Ord A} `{Ord B} : Ord (A * B).
  refine (Build_Ord _ (fun p1 p2 => match p1, p2 with
                        (x1,x2), (y1,y2) => 
                               (x1 < y1) \/
                               (x1 = y1 /\ x2 <= y2) end) _ _ _).
  + intros. destruct x. right. split; reflexivity.
  + intros [? ?] [? ?] [? ?]. intros. destruct H1; destruct H2.
    * left. rewrite H1. trivial.
    * destruct H2. subst. auto.
    * destruct H1. subst. auto.
    * destruct H1. destruct H2. subst. right. eauto with ord.
  + intros [? ?] [? ?] [? | [? ?]] [? | [? ?]].
    * destruct H1. destruct H2. destruct H3. apply ord_antisym; auto.
    * subst. destruct H1. destruct H2. auto.
    * subst. destruct H3. destruct H3. auto.
    * subst a0. f_equal. apply ord_antisym; auto.
Defined.

Instance lex_tord {A} {B} `{TOrd A} `{EqDec A eq} `{TOrd B} : @TOrd _ (lex_ord A B).
Proof.
  intros [? ?] [? ?].
  destruct (sord_total a a0).
  left. left. trivial.
  destruct H2. subst.
  destruct (ord_total b b0);
  [left | right]; right; auto.
  right. left. trivial.
Qed.

Instance lex_cord {A} {B} `{COrd A} `{COrd B} : @COrd _ (lex_ord A B).
Proof.
  intros [? ?] [? ?]. simpl.
  destruct (equiv_dec a a0).
  * red in e. subst a0.
    destruct (ord_dec b b0); auto.
    right. intro. destruct H3; destruct H3; tauto.
  * destruct (ord_dec a a0); auto.
    + left. left. split; auto.
    + right. intro. destruct H3; destruct H3; auto.
Qed.

(* It seems we require that B have a total ordering here.  Otherwise:

      H1: (a1, b1) <= (a2, b2)
      H2: (a1, b1) <= (a2, b3)
      --------- wts
      (a2, b2) <= (a2, b3) \/ (a2, b3) <= (a2, b2)

      which is the same as

      b2 <= b3 \/ b3 <= b2

      But that does not follow from H1 and H2 when a1 < a2.

      One possibility is that we can strengthen the first case of the definition of <=:

      (a1, b1) <= (a2, b2) == (a1 < a2 /\ b1 ~ b2) \/ (a1 = a2 /\ b1 <= b2)

      Not clear if that's better or worse, as a definition. *)
Instance lex_comptrans {A} {B} `{EqDec A eq} `{ComparableTrans A} `{TOrd B} : @ComparableTrans _ (lex_ord A B).
Proof.
  intros [? ?] [? ?] [? ?] ? ?. unfold comparable in *; simpl in *; unfold sord in *.
  assert (a ~ a1). {
    eapply comparable_trans with a0; red; 
    intuition; 
    repeat (subst; auto with ord). }
  red in H4.
  destruct (equiv_dec a a1); unfold equiv, complement in *; subst.
  2: clear H2 H3; assert (a1 <> a); auto; tauto.
  destruct (ord_total b b1); tauto.
Qed.

Require Import Arith.
Require Import Omega.

Instance nat_ord : Ord nat := 
 {| ord := le ; ord_refl := le_refl ; ord_trans := le_trans ; ord_antisym := le_antisym |}.

Instance nat_tord : TOrd nat.
Proof.
  intros x y. red. simpl. omega.
Qed.

Instance nat_comptrans : ComparableTrans nat.
Proof.
  intros a b c ? ?. unfold comparable, ord in *. simpl in *. omega.
Qed.

Instance nat_orddec : COrd nat.
Proof.
  intros ? ?. simpl.
  case (le_gt_dec a b); intro;
  [left | right]; omega.
Qed.

Instance Z_ord : Ord Z.
  refine (Build_Ord _ (fun x z => (x <= z)%Z) _ _ _); intros; omega.
Defined.

Instance Z_tord : TOrd Z.
Proof.
  intros ? ?. red. simpl. omega.
Qed.

Instance Z_comptrans : ComparableTrans Z.
Proof.
  intros a b c ? ?. unfold comparable, ord in *. simpl in *. omega.
Qed.

Instance Z_cord : COrd Z.
Proof.
  intros ? ?. simpl.
  case (Ztrichotomy_inf a b);
  [left; destruct s | right]; omega.
Qed.


(*
Other material, for another day... 

(* improved version of what is in msl/sepalg.v *)
Lemma join_sub_antisym' {A} `{J: Join A} `{PA: @Perm_alg A J} `{SA: @Sep_alg A J} : forall x y,
  join_sub x y ->
  join_sub y x ->
  x = y.
Proof.
  intros. unfold join_sub in *. destruct H. destruct H0.
  apply (join_positivity H H0).
Qed.

Instance join_ord {A} `{J: Join A} `{PA: @Perm_alg A J} `{SA: @Sep_alg A J}: Ord A :=
 {| ord := join_sub; ord_refl := join_sub_refl; ord_trans := join_sub_trans; ord_antisym := join_sub_antisym' |}.

(* Boolean algebras *)

Class BA (A : Type) `{O : Ord  A} : Type := 
  { top : A;
    bot : A;
    lub : A -> A -> A;
    glb : A -> A -> A;
    comp : A -> A;
    lub_upper1 : forall x y, x <= lub x y;
    lub_upper2 : forall x y, y <= lub x y;
    lub_least : forall x y z, x <= z -> y <= z -> lub x y <= z;
    glb_lower1 : forall x y, (glb x y) <= x;
    glb_lower2 : forall x y, (glb x y) <= y;
    glb_greatest : forall x y z, z <= x -> z <= y -> z <= (glb x y);
    top_correct : forall x, x <= top;
    bot_correct : forall x, bot <= x;
    distrib1 : forall x y z, glb x (lub y z) = lub (glb x y) (glb x z);
    comp1 : forall x, lub x (comp x) = top;
    comp2 : forall x, glb x (comp x) = bot;
    nontrivial : top <> bot
}.
Implicit Arguments top [A O BA].
Implicit Arguments bot [A O BA].
Implicit Arguments lub [A O BA].
Implicit Arguments glb [A O BA].
Implicit Arguments comp [A O BA].
Implicit Arguments lub_upper1 [A O BA].
Implicit Arguments lub_upper2 [A O BA].
Implicit Arguments lub_least [A O BA].
Implicit Arguments glb_lower1 [A O BA].
Implicit Arguments glb_lower2 [A O BA].
Implicit Arguments glb_greatest [A O BA].
Implicit Arguments top_correct [A O BA].
Implicit Arguments bot_correct [A O BA].
Implicit Arguments distrib1 [A O BA].
Implicit Arguments comp1 [A O BA].
Implicit Arguments comp2 [A O BA].
Implicit Arguments nontrivial [A O BA].

Hint Resolve @lub_upper1 @lub_upper2 @lub_least
             @glb_lower1 @glb_lower2 @glb_greatest 
             @top_correct @bot_correct
             @ord_trans : ord.

(* Rob's lemmas *)

Lemma ord_spec1 {A} `{O : Ord A} `{@BA A O}: forall x y, x <= y <-> x = glb x y.
Proof.
  split; intros.
  eauto with ord.
  rewrite H0. auto with ord.
Qed.

Lemma ord_spec2 {A} `{O : Ord A} `{@BA A O}: forall x y, x <= y <-> lub x y = y.
Proof.
  intros; split; intros.
  eauto with ord.
  rewrite <- H0; auto with ord.
Qed.

Lemma lub_idem {A} `{O : Ord A} `{@BA A O}: forall x, lub x x = x.
Proof. eauto with ord. Qed.

Lemma glb_idem {A} `{O : Ord A} `{@BA A O}: forall x, glb x x = x.
Proof. eauto with ord. Qed.

Lemma lub_commute {A} `{O : Ord A} `{@BA A O}: forall x y, lub x y = lub y x.
Proof. eauto with ord. Qed.

Lemma glb_commute {A} `{O : Ord A} `{@BA A O}: forall x y, glb x y = glb y x.
Proof. eauto with ord. Qed.

Lemma lub_absorb {A} `{O : Ord A} `{@BA A O}: forall x y, lub x (glb x y) = x.
Proof. eauto with ord. Qed.

Lemma glb_absorb {A} `{O : Ord A} `{@BA A O}: forall x y, glb x (lub x y) = x.
Proof. eauto with ord. Qed.

Lemma lub_assoc {A} `{O : Ord A} `{@BA A O}: forall x y z, lub (lub x y) z = lub x (lub y z).
Proof.
  intros; apply ord_antisym; eauto with ord.
Qed.

Lemma glb_assoc {A} `{O : Ord A} `{@BA A O}: forall x y z, glb (glb x y) z = glb x  (glb y z).
Proof.
  intros; apply ord_antisym; eauto with ord.
Qed.

Lemma glb_bot {A} `{O : Ord A} `{@BA A O}: forall x, glb x bot = bot.
Proof. eauto with ord. Qed.

Lemma lub_top {A} `{O : Ord A} `{@BA A O}: forall x, lub x top = top.
Proof. eauto with ord. Qed.

Lemma lub_bot {A} `{O : Ord A} `{@BA A O}: forall x, lub x bot = x.
Proof. eauto with ord. Qed.

Lemma glb_top {A} `{O : Ord A} `{@BA A O}: forall x, glb x top = x.
Proof. eauto with ord. Qed.

Lemma distrib2 {A} `{O : Ord A} `{@BA A O}: forall x y z,
  lub x (glb y z) = glb (lub x y) (lub x z).
Proof.
  intros.
  apply ord_antisym.
  apply lub_least.
  rewrite distrib1. eauto with ord. eauto with ord.
  rewrite distrib1. 
  apply lub_least. eauto with ord.
  rewrite glb_commute.
  rewrite distrib1.
  apply lub_least;
  eauto with ord. 
Qed.

Lemma distrib_spec {A} `{O : Ord A} `{@BA A O}: forall x y1 y2,
  lub x y1 = lub x y2 ->
  glb x y1 = glb x y2 ->
  y1 = y2.
Proof.
  intros.
  rewrite <- (lub_absorb y2 x).
  rewrite glb_commute.
  rewrite <- H1.
  rewrite distrib2.
  rewrite lub_commute.
  rewrite <- H0.
  rewrite (lub_commute x y1).
  rewrite (lub_commute y2 y1).
  rewrite <- distrib2.
  rewrite <- H1.
  rewrite glb_commute.
  rewrite lub_absorb.
  auto.
Qed.

Lemma comp_inv {A} `{O : Ord A} `{@BA A O}: forall x, comp (comp x) = x.
Proof.
  intro x.
  apply distrib_spec with (comp x).
  rewrite comp1.
  rewrite lub_commute.
  rewrite comp1.
  auto.
  rewrite comp2.
  rewrite glb_commute.
  rewrite comp2.
  auto.
Qed.

Lemma demorgan1 {A} `{O : Ord A} `{@BA A O}: forall x y, comp (lub x y) = glb (comp x) (comp y).
Proof.
  intros x y.
  apply distrib_spec with (lub x y).
  rewrite comp1.
  rewrite distrib2.
  rewrite (lub_assoc x y (comp y)).
  rewrite comp1.
  rewrite lub_top.
  rewrite glb_top.
  rewrite (lub_commute x y).
  rewrite lub_assoc.
  rewrite comp1.
  rewrite lub_top.
  auto.
  rewrite comp2.
  rewrite glb_commute.
  rewrite distrib1.
  rewrite (glb_commute (comp x) (comp y)).
  rewrite glb_assoc.
  rewrite (glb_commute (comp x) x).
  rewrite comp2.
  rewrite glb_bot.
  rewrite lub_commute.
  rewrite lub_bot.
  rewrite (glb_commute (comp y) (comp x)).
  rewrite glb_assoc.
  rewrite (glb_commute (comp y) y).
  rewrite comp2.
  rewrite glb_bot.
  auto.
Qed.

Lemma demorgan2 {A} `{O : Ord A} `{@BA A O}: forall x y, comp (glb x y) = lub (comp x) (comp y).
Proof.
  intros x y.
  apply distrib_spec with (glb x y).
  rewrite comp1.
  rewrite lub_commute.
  rewrite distrib2.
  rewrite (lub_commute (comp x) (comp y)).
  rewrite lub_assoc.
  rewrite (lub_commute (comp x) x).
  rewrite comp1.
  rewrite lub_top.
  rewrite glb_commute.
  rewrite glb_top.
  rewrite (lub_commute (comp y) (comp x)).
  rewrite lub_assoc.
  rewrite (lub_commute (comp y) y).
  rewrite comp1.
  rewrite lub_top.
  auto.
  rewrite comp2.
  rewrite distrib1.
  rewrite (glb_commute x y).
  rewrite glb_assoc.
  rewrite comp2.
  rewrite glb_bot.
  rewrite lub_commute.
  rewrite lub_bot.
  rewrite (glb_commute y x).
  rewrite glb_assoc.
  rewrite comp2.
  rewrite glb_bot.
  auto.
Qed.

(* Aquinas's lemmas *)

Lemma lub_leq {A} `{O : Ord A} `{@BA A O}: forall l1 l2 u1 u2 : A,
  l1 <= u1 ->
  l2 <= u2 ->
  lub l1 l2 <= lub u1 u2.
Proof. eauto with ord. Qed.

(*
  intros.
  apply Share.lub_least.
  transitivity u1...
  apply sh.lub_upper1.
  transitivity u2...
  apply sh.lub_upper2.
Qed.
*)

Lemma glb_leq {A} `{O : Ord A} `{@BA A O}: forall l1 l2 u1 u2 : A,
  l1 <= u1 ->
  l2 <= u2 ->
  glb l1 l2 <= glb u1 u2.
Proof. eauto with ord. Qed.

(*
 with auto.
  intros.
  apply sh.glb_greatest.
  transitivity l1...
  apply sh.glb_lower1.
  transitivity l2...
  apply sh.glb_lower2.
Qed.
*)

Lemma leq_top {A} `{O : Ord A} `{@BA A O}: forall s : A,
  top <= s ->
  s = top.
Proof. eauto with ord. Qed.
(*
  intros.
  apply ord_antisym.
  apply sh.top_top.
  trivial.
Qed.
*)

Lemma leq_bot {A} `{O : Ord A} `{@BA A O}: forall s : A,
  s <= bot ->
  s = bot.
Proof. eauto with ord. Qed.
(*
  intros.
  apply ord_antisym.
  trivial.
  apply sh.bot_bot.
Qed.
*)

Lemma comp_leq {A} `{O : Ord A} `{@BA A O}: forall l u : A,
  l <= u ->
  comp u <= comp l.
Proof with (eauto with ord).
  intros.
  assert (lub l (comp l) <= lub u (comp l)) by (eauto with ord).
  rewrite comp1 in H1.
  apply leq_top in H1.
  assert (glb (comp u) (lub u (comp l)) = glb (comp u) top) by congr.
  rewrite glb_top in H2.
  rewrite distrib1 in H2.
  rewrite (glb_commute _ u) in H2.
  rewrite comp2 in H2.
  rewrite lub_commute in H2.
  rewrite lub_bot in H2.
  rewrite <- H2...
Qed.

Lemma lub_leq_comp {A} `{O : Ord A} `{@BA A O}: forall l u : A,
  l <= u ->
  lub (comp l) u = top.
Proof with (eauto with ord).
  intros.
  apply comp_leq in H0.
  assert (lub u (comp u) <= lub u (comp l)) by (eauto with ord).
  rewrite comp1 in H1.
  apply leq_top...
Qed.

Lemma comp_bot {A} `{O : Ord A} `{@BA A O}: comp bot = top.
Proof with (auto with ord).
  apply ord_antisym...
  rewrite <- (comp_inv top).
  apply comp_leq...
Qed.

Lemma comp_top {A} `{O : Ord A} `{@BA A O}: comp top = bot.
Proof with (auto with ord).
  apply ord_antisym...
  rewrite <- (comp_inv bot).
  apply comp_leq...
Qed.

Lemma glb_comp_leq {A} `{O : Ord A} `{@BA A O}: forall l u,
  l <= u ->
  glb l (comp u) = bot.
Proof with (eauto with ord).
  intros.
  apply ord_antisym. 2: apply bot_correct.
  transitivity (glb u (comp u)).
  apply glb_leq...
  rewrite comp2...
Qed.

Lemma lub_comp_leq {A} `{O : Ord A} `{@BA A O}: forall l u,
  l <= u ->
  lub (comp l) u = top.
Proof with (auto with ord).
  intros.
  apply ord_antisym...
  transitivity (lub l (comp l)).
  rewrite comp1...
  rewrite (lub_commute l).
  apply lub_leq...
Qed.

Lemma leq_comp_join {A} `{O : Ord A} `{@BA A O}: forall a b,
  glb a b = bot -> 
  a <= comp b.
Proof with (auto with ord).
  intros.
  transitivity (glb a (lub b (comp b))).
  rewrite comp1...
  rewrite distrib1, H0...
Qed.

Lemma lub_sub {A} `{O : Ord A} `{@BA A O}: forall a b,
  glb (lub a b) (comp b) <= a.
Proof with (auto with ord).
  intros.
  rewrite glb_commute, distrib1, (glb_commute _ b), comp2...
Qed.

Lemma neg_tighten {A} `{O : Ord A} `{@BA A O}: forall l u l' u' : A,
  ~(l <= u) ->
  ~(lub l l' <= glb u u').
Proof with (auto with ord).
  repeat intro. apply H0.
  transitivity (glb u u')...
  transitivity (lub l l')...
Qed.

(* Connect the BA structure in shares to the BA typeclass *)

Instance share_ba : BA share.
  exists Share.top Share.bot Share.lub Share.glb Share.comp;
  simpl; intros;
  try rewrite <- leq_join_sub in *;
  auto with ba.
  apply Share.distrib1.
  apply Share.comp1.
  apply Share.comp2.
  apply Share.nontrivial.
Defined.
*)

Close Scope ord.