Require Import CertiGraph.dijkstra.env_dijkstra_arr.
Require Import CertiGraph.dijkstra.MathDijkGraph.
Require Import CertiGraph.dijkstra.SpaceDijkGraph.
Require Import CertiGraph.dijkstra.dijkstra_spec.
Require Import CertiGraph.dijkstra.path_cost.

Require Import VST.floyd.sublist.
(* seems this has to be imported after the others *)

Require Import CertiGraph.priq.priq_arr_utils.
(* remove once a better PQ is in place *)

Local Open Scope Z_scope.

(** CONSTANTS AND RANGES **)

Ltac trilia := trivial; lia.
Ltac ulia := unfold V, E, DE in *; trilia.

Lemma inf_eq: 1879048192 = inf.
Proof. compute; trivial. Qed.

Lemma inf_eq2: Int.sub (Int.repr 2147483647)
                       (Int.divs (Int.repr 2147483647)
                                 (Int.repr 8)) = Int.repr inf.
Proof. compute; trivial. Qed.

Opaque inf.

Definition inrange_prev prev_contents :=
  Forall (fun x => 0 <= x < SIZE \/ x = inf) prev_contents.

Definition inrange_priq priq_contents :=
  Forall (fun x => 0 <= x <= inf+1) priq_contents.

Definition inrange_dist dist_contents :=
  Forall (fun x => 0 <= x <= inf) dist_contents.

Lemma Forall_upd_Znth: forall (l: list Z) i new F,
    0 <= i < Zlength l ->
    Forall F l -> F new ->
    Forall F (upd_Znth i l new).
Proof.
  intros. rewrite Forall_forall in *. intros.
  destruct (eq_dec x new); [rewrite e; trivial|].
  rewrite upd_Znth_unfold in H2; auto.
  apply in_app_or in H2; destruct H2.
  - apply sublist_In in H2. apply (H0 x H2).
  - simpl in H2. destruct H2; [lia|].
    apply sublist_In in H2. apply (H0 x H2).
Qed.

Lemma Znth_dist_cases:
  forall i dist,
    0 <= i < Zlength dist ->
    inrange_dist dist ->
    Znth i dist = inf \/
    Znth i dist < inf.
Proof.
  intros.
  apply (Forall_Znth _ _ _ H) in H0.
  simpl in H0. lia.
Qed.
  
(** MISC HELPER LEMMAS **)

Lemma sublist_nil: forall lo hi A,
    sublist lo hi (@nil A) = (@nil A).
Proof.
  intros. unfold sublist.
  rewrite firstn_nil.
  apply sublist.skipn_nil.
Qed.

Lemma sublist_cons:
  forall a (l: list Z) i,
    0 < i < Zlength (a :: l) ->
    sublist 0 i (a :: l) = a :: sublist 0 (i-1) l.
Proof.
  intros.
  rewrite (sublist_split 0 1 i) by lia.
  rewrite sublist_one by lia.
  simpl. rewrite Znth_0_cons.
  rewrite sublist_1_cons; trivial.
Qed.

Lemma sublist_cons':
  forall a (l: list (Z*Z)) i,
    0 < i < Zlength (a :: l) ->
    sublist 0 i (a :: l) = a :: sublist 0 (i-1) l.
Proof.
  intros.
  rewrite (sublist_split 0 1 i) by lia.
  rewrite sublist_one by lia. simpl.
  rewrite Znth_0_cons.
  rewrite sublist_1_cons. reflexivity.
Qed.

Lemma combine_same_length:
  forall (l1 l2 : list Z),
    Zlength l1 = Zlength l2 ->
    Zlength (combine l1 l2) = Zlength l1.
Proof.
  intros.
  repeat rewrite Zlength_correct in *.
  rewrite combine_length.
  rewrite min_l. reflexivity. rep_lia.
Qed.

Lemma sublist_skip: forall A lo (l: list A) a,
    0 < lo ->
    sublist lo (Z.succ (Zlength l)) (a::l) =
    sublist (lo - 1) (Zlength l) l.
Proof.
  intros. unfold sublist.
  destruct (Z.to_nat lo) eqn:?.
  - exfalso.
    unfold Z.to_nat in Heqn.
    destruct lo; try inversion H.
    pose proof (Pos2Nat.is_pos p); lia.
  - assert (Z.to_nat (lo - 1) = n) by
        now rewrite <- (juicy_mem_lemmas.nat_of_Z_lem1 n lo).
    rewrite H0.
    assert (Z.to_nat (Z.succ(Zlength l)) = S (Z.to_nat (Zlength l))). {
      rewrite Z2Nat.inj_succ; auto. apply Zlength_nonneg. }
    rewrite H1. now simpl.
Qed.

Lemma combine_sublist_gen:
  forall (l1 l2 : list Z) lo,
    0 <= lo < Zlength l1 + 1 ->
    Zlength l1 = Zlength l2 ->
    combine (sublist lo (Zlength l1) l1) (sublist lo (Zlength l2) l2) =
    sublist lo (Zlength (combine l1 l2)) (combine l1 l2).
Proof.
  induction l1, l2; intros; simpl; autorewrite with sublist.
  - rewrite !sublist_nil. easy.
  - rewrite Zlength_nil in H0. rewrite Zlength_cons in H0.
    pose proof (Zlength_nonneg l2). exfalso. lia.
  - rewrite Zlength_nil in H0. rewrite Zlength_cons in H0.
    pose proof (Zlength_nonneg l1). exfalso. lia.
  - destruct (Z.eq_dec 0 lo).
    + subst lo. autorewrite with sublist. now simpl.
    + assert (0 < lo) by lia. rewrite !sublist_skip; auto.
      rewrite !Zlength_cons in *. apply IHl1; lia.
Qed.

Lemma combine_sublist_specific:
  forall (l1 l2: list Z) i,
    Zlength l1 = Zlength l2 ->
    0 <= i < Zlength l1 ->
    combine (sublist 0 i l1) (sublist 0 i l2) =
    sublist 0 i (combine l1 l2).
Proof.
  induction l1, l2; intros; simpl; autorewrite with sublist.
  - rewrite !sublist_nil. easy.
  - rewrite Zlength_nil in H0. lia.
  - rewrite Zlength_nil in H. rewrite Zlength_cons in H.
    pose proof (Zlength_nonneg l1). lia.
  - destruct (Z.eq_dec i 0).
    + subst i. autorewrite with sublist. now simpl.
    + rewrite !Zlength_cons in *. repeat rewrite sublist_cons.
      * simpl. rewrite sublist_cons'.
        -- f_equal. apply IHl1; lia.
        -- rewrite Zlength_cons. rewrite combine_same_length; lia.
      * rewrite Zlength_cons. lia.
      * rewrite Zlength_cons. lia.
Qed.

Lemma combine_upd_Znth:
  forall (l1 l2: list Z) i new,
    Zlength l1 = Zlength l2 ->
    0 <= i < Zlength l1 ->
    combine (upd_Znth i l1 new) l2 =
    upd_Znth i (combine l1 l2) (new , Znth i l2).
Proof.
  intros.
  rewrite <- (sublist_same 0 (Zlength l2) l2) at 1 by reflexivity.
  repeat rewrite (sublist_split 0 i (Zlength l2) l2) by lia.
  rewrite !upd_Znth_unfold; auto. 2: now rewrite combine_same_length.
  rewrite combine_app.
  2: { repeat rewrite <- ZtoNat_Zlength.
       f_equal. repeat rewrite Zlength_sublist; lia. }
  f_equal.
  1: apply combine_sublist_specific; assumption.
  rewrite (sublist_split i (i+1) (Zlength l2) l2) by lia.
  rewrite sublist_len_1 by lia. simpl.
  simpl combine. f_equal.
  apply combine_sublist_gen. lia. lia.
Qed.

Lemma Znth_combine:
  forall (l1 l2 : list Z) i,
    Zlength l1 = Zlength l2 ->
    0 <= i < Zlength l1 ->
    Znth i (combine l1 l2) = (Znth i l1, Znth i l2).
Proof.
  intros. generalize dependent i.
  generalize dependent l2.
  induction l1.
  - intros. rewrite Zlength_nil in H0; exfalso; lia.
  - intros.
    rewrite <- (sublist_same 0 (Zlength l2) l2) by lia.
    rewrite (sublist_split 0 1 (Zlength l2) l2) by lia.
    rewrite sublist_len_1 by lia.
    simpl. destruct (Z.eq_dec i 0).
    1: subst i; repeat rewrite Znth_0_cons; reflexivity.
    repeat rewrite Znth_pos_cons by lia.
    apply IHl1.
    rewrite Zlength_sublist by lia.
    rewrite Zlength_cons in H; rep_lia.
    rewrite Zlength_cons in H0; rep_lia.
Qed.

Lemma behead_list:
  forall (l: list Z),
    0 < Zlength l -> l = Znth 0 l :: tl l.
Proof.
  intros. destruct l.
  - rewrite Zlength_nil in H. inversion H.
  - simpl. rewrite Znth_0_cons. reflexivity.
Qed.

Lemma nat_inc_list_hd:
  forall n,
    0 < n ->
    Znth 0 (nat_inc_list (Z.to_nat n)) = 0.
Proof.
  intros. induction (Z.to_nat n); trivial.
  simpl. destruct n0; trivial.
  rewrite app_Znth1; [lia|].
  rewrite nat_inc_list_Zlength.
  rewrite <- Nat2Z.inj_0.
  apply inj_lt; lia.
Qed.

Lemma tl_app:
  forall (l1 l2: list Z),
    0 < Zlength l1 ->
    tl (l1 ++ l2) = tl l1 ++ l2.
Proof.
  intros. destruct l1; trivial. inversion H.
Qed.

Lemma in_tl_nat_inc_list:
  forall i n,
    In i (tl (nat_inc_list n)) -> 1 <= i.
Proof.
  destruct n. inversion 1.
  induction n. inversion 1.
  intros. simpl in H.
  rewrite Zpos_P_of_succ_nat in H.
  rewrite tl_app in H.
  2: { rewrite Zlength_app.
       replace (Zlength [Z.of_nat n]) with 1 by reflexivity.
       rep_lia.
  }
  apply in_app_or in H; destruct H.
  - apply IHn. simpl. assumption.
  - simpl in H. destruct H; lia.
Qed.

Lemma nat_inc_list_app:
  forall n m p i,
    0 <= i < m ->
    0 <= n ->
    n + m <= p ->
    Znth i (nat_inc_list (Z.to_nat m)) =
    Znth i (sublist n (n + m)
                    (nat_inc_list (Z.to_nat p))) - n.
Proof.
  symmetry. rewrite Znth_sublist by rep_lia.
  repeat rewrite nat_inc_list_i by rep_lia. lia.
Qed.

Lemma nat_inc_list_sublist:
  forall n m,
    0 <= n ->
    n <= m ->
    sublist 0 n (nat_inc_list (Z.to_nat m)) =
    nat_inc_list (Z.to_nat n).
Proof.
  intros.
  apply Zle_lt_or_eq in H0. destruct H0.
  2: { subst. rewrite sublist_same; trivial.
       rewrite nat_inc_list_Zlength; lia.
  }
  apply Znth_eq_ext.
  1: { rewrite Zlength_sublist;
       try rewrite nat_inc_list_Zlength; lia.
  }
  intros. rewrite nat_inc_list_i.
  2: { rewrite Zlength_sublist in H1; 
       try rewrite nat_inc_list_Zlength; lia.
  }
  rewrite <- Z.sub_0_r at 1.
  replace n with (0 + n) by lia.
  rewrite Zlength_sublist in H1.
  rewrite <- nat_inc_list_app.
  rewrite nat_inc_list_i.
  all: try rewrite nat_inc_list_Zlength; lia.
Qed.

Lemma Int_repr_eq_small:
  forall a b,
    0 <= a < Int.modulus ->
    0 <= b < Int.modulus ->
    Int.repr a = Int.repr b ->
    a = b.
Proof.
  intros.
  apply Int_eqm_unsigned_repr',
  Int_eqm_unsigned_spec in H1.
  rewrite Int.unsigned_repr_eq in H1.
  rewrite Z.mod_small in H1; trivial.
  pose proof (Int.eqm_small_eq _ _ H1 H H0); trivial.
Qed.


(** LEMMAS ABOUT GET_POPPED **)

Lemma popped_noninf_has_path:
  forall {g mom src popped prev dist},
    dijkstra_correct g src popped prev dist ->
    In mom popped ->
    Znth mom dist < inf ->
    vvalid g mom ->
    exists p2mom : path,
      path_correct g prev dist src mom p2mom /\
      (forall step : Z,
          In_path g step p2mom ->
          In step popped /\
          Znth step dist < inf) /\
      path_globally_optimal g src mom p2mom.
Proof.
  intros.
  destruct (H _ H2) as [? _].
  specialize (H3 H0).
  destruct H3; [ulia|].
  apply H3; trivial.
Qed.
                  
Lemma path_leaving_popped:
  forall (g: DijkGG) links s u popped,
    valid_path g (s, links) ->
    path_ends g (s, links) s u ->
    In s popped ->
    ~ In u popped ->
    exists (p1 : path) (mom' child' : Z) (p2 : path),
      path_glue p1 (path_glue (mom', [(mom', child')]) p2) = (s, links) /\
      valid_path g p1 /\
      valid_path g p2 /\
      path_ends g p1 s mom' /\
      path_ends g p2 child' u /\
      In mom' popped /\
      ~ In child' popped /\
      evalid g (mom', child').
Proof.
  intros.
  generalize dependent s.
  induction links.
  - intros. destruct H0. simpl in H0, H3.
    exfalso. apply H2.
    rewrite <- H3; trivial.
  - intros.
    assert (evalid g a). {
      apply (valid_path_evalid _ _ _ _ H).
      simpl; left; trivial.
    }
    assert (s = fst a). {
      simpl in H. destruct H as [? _].
      rewrite (edge_src_fst g) in H; trivial.
    }
    remember (snd a) as t.
    assert (a = (s,t)). {
      rewrite (surjective_pairing a).
      subst; trivial.
    }
  
    destruct (in_dec (ZIndexed.eq) t popped).
    + assert (valid_path g (t, links)). {
        rewrite Heqt, <- (edge_dst_snd g); trivial.
        apply valid_path_cons with (v := s); trivial.
      }
      assert (path_ends g (t, links) t u). {
        split; trivial.
        destruct H0.
        rewrite Heqt, <- (edge_dst_snd g); trivial.
        rewrite <- H7. symmetry. apply pfoot_cons.
      }
      specialize (IHlinks _ H6 H7 i).
      destruct IHlinks as [p2m [m [c [p2u [? [? [? [? [? [? [? ?]]]]]]]]]]].
      exists (path_glue (s, [(s,t)]) p2m), m, c, p2u.
      assert (evalid g (s,t)). {
        rewrite H5 in H3; trivial.
      }
      assert (paths_meet g (s, [(s, t)]) p2m). {
        apply (path_ends_meet _ _ _ s t m); trivial.
        split; simpl; trivial.
        rewrite (edge_dst_snd g); trivial.
      }
      assert (fst p2u = c). {
        destruct H12.
        rewrite (surjective_pairing p2u) in H12.
        simpl in H12. lia.
      }
      assert (fst p2m = t). {
        destruct H11.
        rewrite (surjective_pairing p2m) in H11.
        simpl in H11. lia.
      } 

      split3; [| |split3; [| | split3; [| |split]]]; trivial.
      * rewrite (path_glue_assoc g); trivial.
        -- unfold E, V in *. rewrite H8.
           unfold path_glue; trivial.
           simpl. rewrite H5; trivial.
        -- apply (path_ends_meet _ _ _ t m u); trivial.
           split; trivial.
           unfold path_glue.
           simpl fst; simpl snd; simpl app.
           destruct H12. rewrite <- H20.
           rewrite (surjective_pairing p2u) at 2.
           assert (c = dst g (m, c)). {
             rewrite (edge_dst_snd g); trivial.
           }
           rewrite H18. rewrite H21 at 2.
           apply pfoot_cons.
      * apply valid_path_merge; trivial.
        simpl; unfold strong_evalid.
        rewrite (edge_dst_snd g), (edge_src_fst g); trivial;
          simpl; split3; trivial.
        split.
        -- apply (valid_path_valid _ _ _ H).
           rewrite in_path_or_cons; trivial.
           left; trivial.
           rewrite (edge_src_fst g); trivial.
        -- apply (valid_path_valid _ _ _ H6).
           unfold In_path. left; trivial.
      * split; trivial.
        unfold path_glue.
        simpl fst; simpl snd; simpl app.
        destruct H11. rewrite <- H20.
        rewrite (surjective_pairing p2m) at 2.
        rewrite H19.
        assert (t = dst g (s, t)). {
          rewrite (edge_dst_snd g); trivial.
        }
        rewrite H21 at 2.
        apply pfoot_cons.
    + clear IHlinks. 
      exists (s, []), s, t, (t, links).
      assert (evalid g (s,t)). {
        rewrite H5 in H3; trivial.
      }

      split3; [| |split3; [| | split3; [| |split]]]; trivial.
      * rewrite path_glue_nil_l. simpl.
        rewrite H5; trivial.
      * simpl. apply (valid_path_valid _ _ _ H).
        unfold In_path. left; trivial.
      * rewrite Heqt.
        rewrite <- (edge_dst_snd g); trivial.
        apply valid_path_cons with (v := s); trivial.
      * split; trivial.
      * destruct H0. split; trivial.
        rewrite <- H7. symmetry.
        rewrite Heqt, <- (edge_dst_snd g); trivial.
        apply pfoot_cons.
Qed.

Lemma path_ends_In_path_src:
  forall (g: @PreGraph V E V_EqDec E_EqDec) a b a2b,
    path_ends g a2b a b ->
    In_path g a a2b.
Proof.
  intros. left. destruct H.
  rewrite (surjective_pairing a2b) in H.
  simpl in H. symmetry; trivial.
Qed.

Lemma path_ends_In_path_dst:
  forall (g: @PreGraph V E V_EqDec E_EqDec) a b a2b,
    path_ends g a2b a b ->
    In_path g b a2b.
Proof.
  intros. destruct H. apply pfoot_in; trivial.
Qed.

Lemma path_ends_valid_src:
  forall (g: @PreGraph V E V_EqDec E_EqDec) a b a2b,
    valid_path g a2b ->
    path_ends g a2b a b ->
    vvalid g a.
Proof.
  intros.
  apply (valid_path_valid g _ _ H),
  (path_ends_In_path_src _ _ b); trivial.
Qed.

Lemma path_ends_valid_dst:
  forall (g: @PreGraph V E V_EqDec E_EqDec) a b a2b,
    valid_path g a2b ->
    path_ends g a2b a b ->
    vvalid g b.
Proof.
  intros.
  apply (valid_path_valid g _ _ H),
  (path_ends_In_path_dst _ a); trivial.
Qed.

Lemma path_ends_one_step:
  forall (g: DijkGG) a b,
    path_ends g (a, [(a, b)]) a b.
Proof.
  intros. split; trivial.
  simpl. rewrite (edge_dst_snd g); trivial.
Qed. 

Lemma path_leaving_popped_stronger:
  forall (g: DijkGG) links s u popped,
    valid_path g (s, links) ->
    path_ends g (s, links) s u ->
    In s popped ->
    ~ In u popped ->
    path_cost g (s, links) < inf ->
    exists (p1 : path) (mom' child' : Z) (p2 : path),
      path_glue p1 (path_glue (mom', [(mom', child')]) p2) = (s, links) /\
      valid_path g p1 /\
      valid_path g p2 /\
      path_ends g p1 s mom' /\
      path_ends g p2 child' u /\
      In mom' popped /\
      ~ In child' popped /\
      strong_evalid g (mom', child') /\
      path_cost g p1 < inf /\
      0 <= elabel g (mom', child') < inf /\
      path_cost g p2 + elabel g (mom', child') < inf.
Proof.
  intros.
  destruct (path_leaving_popped g links s u popped H H0 H1 H2)
        as [p1 [mom' [child' [p2 [? [? [? [? [? [? [? ? ]]]]]]]]]]].
      exists p1, mom', child', p2.
      assert (valid_path g (path_glue (mom', [(mom', child')]) p2)). {
        apply valid_path_merge; trivial.
        apply (path_ends_meet _ _ _ mom' child' u); trivial.
        apply path_ends_one_step.
        simpl. rewrite (edge_src_fst g); split; trivial.
        split3; trivial.
        rewrite (edge_src_fst g); simpl; trivial.
        apply (path_ends_valid_dst _ s _ p1); trivial.
        rewrite (edge_dst_snd g); simpl; trivial.
        apply (path_ends_valid_src _ _ u p2); trivial.
      }

      assert (elabel g (mom', child') < inf). {
        apply Z.le_lt_trans with (m := Int.max_signed / SIZE).
        apply valid_edge_bounds; trivial.
        rewrite <- inf_eq. compute; trivial.
      }
      
      split3; [| |split3; [| |split3; [| |split3; [| |split3]]]]; trivial.
  - apply strong_evalid_dijk; trivial.
    + apply (path_ends_valid_dst _ s _ p1); trivial.
    + apply (path_ends_valid_src _ _ u p2); trivial.
  - rewrite <- H4 in H3.
    apply path_cost_path_glue_lt in H3; trivial.
    destruct H3; trivial.
  - split; trivial. apply edge_cost_pos.
  - rewrite <- H4 in H3.
    apply path_cost_path_glue_lt in H3; trivial.
    destruct H3 as [_ ?].
    rewrite path_cost_path_glue in H3; trivial.
    apply careful_add_inf_clean; trivial.
    apply path_cost_pos; trivial.
    apply edge_cost_pos.
    rewrite careful_add_comm; trivial.
Qed.

Lemma evalid_dijk:
  forall (g: DijkGG) a b cost,
    cost = elabel g (a,b) ->
    0 <= cost <= Int.max_signed / SIZE ->
    evalid g (a,b).
Proof.
  intros.
  rewrite (evalid_meaning g); split.
  1: apply edge_representable.
  apply not_eq_sym, Zaux.Zgt_not_eq.
  destruct H0.
  apply Z.le_lt_trans with (m := Int.max_signed / SIZE);
    trivial.
  rewrite H in H1; trivial.
  rewrite <- inf_eq. compute; trivial.
Qed.


(*
Lemma get_popped_empty:
  forall l,
    Forall (fun x => x <> inf + 1) l ->
    get_popped l = [].
Proof.
  intros. unfold get_popped.
  replace (filter (fun x : Z * Z => (fst x) =? (inf + 1))
                  (combine l (nat_inc_list (Z.to_nat (Zlength l)))))
    with (@nil (Z*Z)).
  trivial. symmetry.
  remember (nat_inc_list (Z.to_nat (Zlength l))) as l2.
  clear Heql2.
  generalize dependent l2. induction l; trivial.
  intros. simpl. destruct l2; trivial. simpl.
  pose proof (Forall_inv H). pose proof (Forall_tl _ _ _ H).
  simpl in H0. destruct (a =? inf + 1) eqn:?.
  1: rewrite Z.eqb_eq in Heqb; lia.
  apply IHl; assumption.
Qed.

Lemma get_popped_unchanged:
  forall l new i,
    0 <= i < Zlength l ->
    new <> inf + 1 ->
    Znth i l <> inf + 1 ->
    get_popped (upd_Znth i l new) = get_popped l.
Proof.
  intros. unfold get_popped.
  remember (fun x : Z * Z => fst x =? inf + 1) as F.
  rewrite upd_Znth_Zlength by lia.
  remember (nat_inc_list (Z.to_nat (Zlength l))) as l2.
  assert (Zlength l = Zlength l2). {
    rewrite Heql2. rewrite nat_inc_list_Zlength; lia.
  }
  f_equal. pose proof (combine_same_length l l2 H2).
  rewrite combine_upd_Znth by assumption.
  unfold_upd_Znth_old.
  rewrite <- (sublist_same 0 (Zlength (combine l l2)) (combine l l2))
          at 4 by reflexivity.
  rewrite (sublist_split 0 i (Zlength (combine l l2))
                         (combine l l2)) by lia.
  do 2 rewrite filter_app.
  f_equal. rewrite H3.
  rewrite (sublist_split i (i+1) (Zlength l)) by lia.
  rewrite (sublist_one i (i+1) (combine l l2)) by lia.
  rewrite filter_app. f_equal. simpl.
  destruct (F (new, Znth i l2)) eqn:?; rewrite HeqF in Heqb; simpl in Heqb.
  - exfalso. apply H1. rewrite <- inf_eq.
    simpl. rewrite Z.eqb_eq in Heqb. rewrite <- inf_eq in *. lia.
  - destruct (F (Znth i (combine l l2))) eqn:?; trivial.
    rewrite HeqF, Znth_combine, Z.eqb_eq in Heqb0 by lia.
    simpl in Heqb0. exfalso. apply H1. rewrite <- inf_eq. lia.
Qed.

Lemma in_get_popped:
  forall i l1 l2,
    0 <= i < Zlength l1 + Zlength l2 ->
    Zlength l1 <= i  ->
    In i (get_popped (l1 ++ l2)) <-> In (i - Zlength l1) (get_popped l2).
Proof.
  intros.
  split; unfold get_popped; intros.
  - rewrite In_map_snd_iff in H1; destruct H1.
    rewrite filter_In in H1; destruct H1; simpl in H2.
    rewrite In_map_snd_iff.
    exists x.
    rewrite filter_In; split; trivial. clear H2.
    rewrite <-
            (sublist_same 0 (Zlength (l1 ++ l2))
                          (nat_inc_list (Z.to_nat (Zlength (l1 ++ l2))))) in H1.
    rewrite (sublist_split 0 (Zlength l1) (Zlength (l1 ++ l2))) in H1.
    5,3: rewrite (Zlength_correct (nat_inc_list (Z.to_nat
                                                   (Zlength (l1 ++ l2)))));
      rewrite nat_inc_list_length;
      rewrite Z2Nat.id; trivial.
    3: rewrite Zlength_app.
    all: try rep_lia.
    rewrite combine_app in H1.
    2: { rewrite Zlength_correct.
         repeat rewrite <- ZtoNat_Zlength.
         f_equal.
         pose proof (Zlength_nonneg l1).
         rewrite Zlength_sublist.
         all: rewrite Z2Nat.id.
         all: try lia.
         rewrite Zlength_app.
         rewrite nat_inc_list_Zlength.
         rewrite Z2Nat.id by lia. lia.
    }
    apply in_app_or in H1. destruct H1.
    + exfalso.
      pose proof (in_combine_r _ _ _ _ H1).
      clear H1.
      rewrite nat_inc_list_sublist in H2.
      2: apply Zlength_nonneg.
      2: rewrite Zlength_app; lia.
      apply nat_inc_list_in_iff in H2.
      rewrite Z2Nat.id in H2 by (apply Zlength_nonneg). lia.
    + apply In_Znth_iff in H1. destruct H1 as [? [? ?]].
      rewrite In_Znth_iff. exists x0.
      split.
      * rewrite combine_same_length in *; trivial.
        rewrite Zlength_sublist.
        rewrite Zlength_app. lia.
        rewrite Zlength_app. rep_lia.
        rewrite nat_inc_list_Zlength.
        rewrite Z2Nat.id. reflexivity.
        apply Zlength_nonneg.
        rewrite nat_inc_list_Zlength.
        rewrite Z2Nat.id. reflexivity.
        apply Zlength_nonneg.
      * rewrite Znth_combine in *; trivial.
        2: {
          rewrite Zlength_sublist.
          rewrite Zlength_app. lia.
          rewrite Zlength_app. rep_lia.
          rewrite nat_inc_list_Zlength.
          rewrite Z2Nat.id. reflexivity. rep_lia.
        }
        2, 4: rewrite combine_same_length in H1; trivial.
        2, 3: rewrite Zlength_sublist, Zlength_app; [|rewrite Zlength_app|]; try rep_lia;
          repeat rewrite Zlength_correct;
          rewrite nat_inc_list_length;
          rewrite Nat2Z.id; lia.
        2: repeat rewrite nat_inc_list_Zlength; rep_lia.
        inversion H2.
        rewrite Zlength_app.
        rewrite <- nat_inc_list_app; trivial.
        rewrite combine_same_length in H1. lia.
        rewrite Zlength_sublist. rewrite Zlength_app. lia.
        rewrite Zlength_app. rep_lia.
        rewrite nat_inc_list_Zlength.
        rewrite Z2Nat.id; trivial. reflexivity.
        rep_lia. rep_lia. reflexivity.
  - rewrite In_map_snd_iff in H1; destruct H1.
    rewrite filter_In in H1; destruct H1; simpl in H2.
    rewrite In_map_snd_iff. exists x.
    rewrite filter_In; split; trivial. clear H2.
    rewrite <-
            (sublist_same 0 (Zlength (l1 ++ l2))
                          (nat_inc_list (Z.to_nat (Zlength (l1 ++ l2))))).
    rewrite (sublist_split 0 (Zlength l1) (Zlength (l1 ++ l2))).
    5,3: rewrite (Zlength_correct
                    (nat_inc_list (Z.to_nat (Zlength (l1 ++ l2)))));
      rewrite nat_inc_list_length;
      rewrite Z2Nat.id; trivial.
    3: rewrite Zlength_app.
    all: try rep_lia.
    rewrite combine_app.
    2: { repeat rewrite <- ZtoNat_Zlength. f_equal.
         rewrite Zlength_sublist. lia.
         pose proof (Zlength_nonneg l1); lia.
         rewrite Zlength_app.
         repeat rewrite Zlength_correct.
         rewrite nat_inc_list_length.
         rewrite Z2Nat.id; lia.
    }
    rewrite in_app_iff. right.
    rewrite In_Znth_iff in H1; destruct H1 as [? [? ?]].
    rewrite In_Znth_iff.
    exists x0. split.
    1: { rewrite combine_same_length in *.
         assumption.
         repeat rewrite Zlength_correct.
         rewrite nat_inc_list_length.
         rewrite Z2Nat.id. reflexivity.
         lia.
         rewrite Zlength_sublist.
         rewrite Zlength_app. lia.
         rewrite Zlength_app.
         pose proof (Zlength_nonneg l2).
         rep_lia.
         repeat rewrite Zlength_correct.
         rewrite nat_inc_list_length.
         rewrite Z2Nat.id. reflexivity.
         lia.
    }
    rewrite Znth_combine in *.
    2: repeat rewrite Zlength_correct;
      rewrite nat_inc_list_length;
      rewrite Nat2Z.id; lia.
    3: rewrite Zlength_sublist, Zlength_app;
      [|rewrite Zlength_app|]; try rep_lia;
      repeat rewrite Zlength_correct;
      rewrite nat_inc_list_length;
      rewrite Nat2Z.id; lia.
    2, 3: rewrite combine_same_length in H1; [rep_lia|].
    2, 3: repeat rewrite Zlength_correct;
      rewrite nat_inc_list_length;
      rewrite Nat2Z.id; lia.
    inversion H2.
    rewrite (nat_inc_list_app (Zlength l1) _ (Zlength (l1 ++ l2))) in H5.
    rewrite Z.sub_cancel_r in H5.
    rewrite Zlength_app at 1.
    rewrite H5. reflexivity.
    rewrite combine_same_length in H1. lia.
    repeat rewrite Zlength_correct.
    rewrite nat_inc_list_length.
    rewrite Z2Nat.id. reflexivity.
    lia. rep_lia.
    rewrite Zlength_app. rep_lia.
Qed.
 *)

(* The above can be deleted, but I'm keeping them until my new PQ comes in *)

(* HIGHLY TEMPORARY *)
(* Definition get_unpopped pq : list VType := *)
  (* map snd (filter (fun x => (fst x) <? (inf + 1)) *)
                  (* (combine pq (nat_inc_list (Z.to_nat (Zlength pq))))). *)

Lemma get_popped_meaning:
  forall popped priq i,
    0 <= i < Zlength priq ->
    In i popped <-> Znth i priq = inf + 1.
Admitted.


(** PROOF BEGINS **)

Lemma body_dijkstra: semax_body Vprog Gprog f_dijkstra dijkstra_spec.
Proof.
  start_function.
  forward_for_simple_bound
    SIZE
    (EX i : Z,
     PROP ()
     LOCAL (temp _dist (pointer_val_val dist);
            temp _prev (pointer_val_val prev);
            temp _src (Vint (Int.repr src));
            lvar _pq (tarray tint SIZE) v_pq;
            temp _graph (pointer_val_val arr))
     SEP (data_at Tsh
                  (tarray tint SIZE)
                  ((list_repeat (Z.to_nat i)
                                (Vint (Int.repr inf)))
                     ++ (list_repeat (Z.to_nat (SIZE-i))
                                     Vundef)) v_pq;
          data_at Tsh
                  (tarray tint SIZE)
                  ((list_repeat (Z.to_nat i)
                                (Vint (Int.repr inf)))
                     ++ (list_repeat (Z.to_nat (SIZE-i))
                                     Vundef)) (pointer_val_val prev);
          data_at Tsh
                  (tarray tint SIZE)
                  ((list_repeat (Z.to_nat i) (Vint (Int.repr inf)))
                     ++ (list_repeat (Z.to_nat (SIZE-i))
                                     Vundef)) (pointer_val_val dist);
          DijkGraph sh g (pointer_val_val arr))).
  - unfold SIZE. rep_lia.
  - unfold data_at, data_at_, field_at_, SIZE; entailer!.
  - forward. forward.
    forward_call (v_pq, i, inf,
                  (list_repeat (Z.to_nat i)
                               (Vint (Int.repr inf)) ++
                               list_repeat (Z.to_nat (SIZE - i)) Vundef)).
    rewrite inf_eq2.
    assert ((upd_Znth i (list_repeat (Z.to_nat i) (Vint (Int.repr inf))
                                     ++ list_repeat (Z.to_nat (SIZE - i))
                                     Vundef) (Vint (Int.repr inf))) =
            (list_repeat (Z.to_nat (i + 1)) (Vint (Int.repr inf))
                         ++ list_repeat (Z.to_nat (SIZE - (i + 1))) Vundef)). {
      rewrite upd_Znth_app2 by
          (repeat rewrite Zlength_list_repeat by lia; lia).
      rewrite Zlength_list_repeat by lia.
      replace (i-i) with 0 by lia.
      rewrite <- list_repeat_app' by lia.
      rewrite app_assoc_reverse; f_equal.
      rewrite upd_Znth0_old. 2: rewrite Zlength_list_repeat; lia.
      rewrite Zlength_list_repeat by lia.
      rewrite sublist_list_repeat by lia.
      replace (SIZE - (i + 1)) with (SIZE - i - 1) by lia.
      replace (list_repeat (Z.to_nat 1) (Vint (Int.repr inf))) with
          ([Vint (Int.repr inf)]) by reflexivity. easy.
    }
    rewrite H2. entailer!.
  - (* At this point we are done with the
       first for loop. The arrays are all set to INF. *)
    replace (SIZE - SIZE) with 0 by lia;
      rewrite list_repeat_0, <- (app_nil_end).
    forward. forward. 
    forward_call (v_pq, src, 0, (list_repeat (Z.to_nat SIZE) (inf: V))).
    do 2 rewrite map_list_repeat.
    assert (H_valid_src: vvalid g src). {
      rewrite (vvalid_meaning g); trivial.
    }

    (* Special values for src have been inserted *)

    (* We will now enter the main while loop.
       We state the invariant just below, in PROP.

       VST will first ask us to first show the
       invariant at the start of the loop
     *)
  
    forward_loop
      (EX prev_contents : list V,
       EX priq_contents : list V,
       EX dist_contents : list V,
       EX popped_verts : list V,
       PROP (
           (* The overall correctness condition *)
           dijkstra_correct g src popped_verts prev_contents dist_contents;

           (* Some special facts about src *)
           Znth src dist_contents = 0;
           Znth src prev_contents = src;
           (* Znth src priq_contents <> inf; *)
      
           (* A fact about the relationship b/w 
              dist and priq arrays *)
           forall dst, vvalid g dst ->
                       ~ In dst popped_verts ->
                       Znth dst priq_contents = Znth dst dist_contents;

           (* Information about the ranges of the three arrays *)
           inrange_prev prev_contents;
           inrange_dist dist_contents;
           inrange_priq priq_contents)
       LOCAL (temp _dist (pointer_val_val dist);
              temp _prev (pointer_val_val prev);
              temp _src (Vint (Int.repr src));
              lvar _pq (tarray tint SIZE) v_pq;
              temp _graph (pointer_val_val arr))
       SEP (data_at Tsh
                    (tarray tint SIZE)
                    (map Vint (map Int.repr prev_contents))
                    (pointer_val_val prev);
            data_at Tsh
                    (tarray tint SIZE)
                    (map Vint (map Int.repr priq_contents)) v_pq;
       data_at Tsh
                    (tarray tint SIZE)
                    (map Vint (map Int.repr dist_contents))
                    (pointer_val_val dist);
            DijkGraph sh g (pointer_val_val arr)))
      break:
      (EX prev_contents: list V,
       EX priq_contents: list V,
       EX dist_contents: list V,
       EX popped_verts: list V,
       PROP (
           (* This fact comes from breaking while *)
           Forall (fun x => x >= inf) priq_contents;
           (* And the correctness condition is established *)
           dijkstra_correct g src popped_verts prev_contents dist_contents)
       LOCAL (lvar _pq (tarray tint SIZE) v_pq)
       SEP (data_at Tsh
                    (tarray tint SIZE)
                    (map Vint (map Int.repr prev_contents))
                    (pointer_val_val prev);
            (data_at Tsh
                     (tarray tint SIZE)
                     (map Vint (map Int.repr priq_contents)) v_pq);
            data_at Tsh
                    (tarray tint SIZE)
                    (map Vint (map Int.repr dist_contents))
                    (pointer_val_val dist);
            DijkGraph sh g (pointer_val_val arr))).
    + Exists (upd_Znth src (@list_repeat V (Z.to_nat SIZE) inf) src).
      Exists (upd_Znth src (@list_repeat V (Z.to_nat SIZE) inf) 0).
      Exists (upd_Znth src (@list_repeat V (Z.to_nat SIZE) inf) 0).
      Exists (@nil V).
      repeat rewrite <- upd_Znth_map; entailer!.
      assert (Zlength (list_repeat (Z.to_nat SIZE) inf) = SIZE). {
        rewrite Zlength_list_repeat; [|unfold SIZE]; lia.
      }
      split.
      (* We take care of the easy items first... *)
      2: {
        assert (inrange_prev (list_repeat (Z.to_nat SIZE) inf)). {
          unfold inrange_prev. rewrite Forall_forall.
          intros ? new. apply in_list_repeat in new. right; trivial.
        }
        assert (inrange_dist (list_repeat (Z.to_nat SIZE) inf)). {
          unfold inrange_dist. rewrite Forall_forall.
          intros ? new. apply in_list_repeat in new.
          rewrite new. compute. split; inversion 1.
        }
        assert (inrange_priq (list_repeat (Z.to_nat SIZE) inf)). {
          unfold inrange_priq. rewrite Forall_forall.
          intros ? new. apply in_list_repeat in new.
          rewrite new. compute. split; inversion 1.
        }
        split3; [| |split3];
        try apply Forall_upd_Znth;
        try rewrite upd_Znth_same; try lia; trivial.
        all: rewrite <- inf_eq; unfold SIZE in *; lia.
      }
      (* And now we must show dijkstra_correct for the initial arrays *)
      (* First, worth noting that _nothing_ has been popped so far *)
      (* Now we get into the proof of dijkstra_correct proper.
         This is not very challenging... *)
      unfold dijkstra_correct, inv_popped, inv_unpopped, inv_unseen;
        split3; intros; [inversion H13 | | inversion H16].
      left.
      destruct (Z.eq_dec dst src); [trivial | exfalso].
      assert (0 <= dst < SIZE) by (rewrite <- (vvalid_meaning g); trivial).
      apply (vvalid_meaning g) in H12. 
      rewrite upd_Znth_diff, Znth_list_repeat_inrange in H14; ulia.

    + (* Now the body of the while loop begins. *)
      Intros prev_contents priq_contents dist_contents popped_verts.
      assert_PROP (Zlength priq_contents = SIZE).
      { entailer!. now repeat rewrite Zlength_map in *. }
      assert_PROP (Zlength prev_contents = SIZE).
      { entailer!. now repeat rewrite Zlength_map in *. }
      assert_PROP (Zlength dist_contents = SIZE).
      { entailer!. now repeat rewrite Zlength_map in *. }

      forward_call (v_pq, priq_contents).
      forward_if. (* checking if it's time to break *)
      * (* No, don't break. *)
        rename H11 into Htemp.
        
        assert (isEmpty priq_contents = Vzero). {
          destruct (isEmptyTwoCases priq_contents);
            rewrite H11 in Htemp; simpl in Htemp;
              now inversion Htemp.
        }
        clear Htemp.
        forward_call (v_pq, priq_contents). Intros u.
        rename H12 into Hequ.
        (* u is the minimally chosen item from the
           "seen but not popped" category of vertices *)

        (* We prove a few useful facts about u: *)
        assert (H_valid_u: vvalid g u). {
          apply (vvalid_meaning g); trivial.
          subst u.
          replace SIZE with (Zlength priq_contents).
          apply find_range.
          apply min_in_list. apply incl_refl.
          destruct priq_contents. rewrite Zlength_nil in H8.
          inversion H8. simpl. left; trivial.
        }
        
        assert (0 <= u < SIZE). {
          apply (vvalid_meaning g) in H_valid_u; trivial.
        }
        
        assert (~ (In u popped_verts)). {
          intro.
          rewrite (get_popped_meaning _ priq_contents _) in H13.
          2: ulia.
          rewrite <- isEmpty_in' in H11.
          destruct H11 as [? [? ?]].
          subst u.
          rewrite Znth_find in H13.
          1: pose proof (fold_min _ _ H11); lia.
          rewrite <- Znth_0_hd by ulia.
          apply min_in_list;
            [ apply incl_refl | apply Znth_In; ulia].
        }
        assert (H_inf_reppable: Int.min_signed <= inf <= Int.max_signed). {
          split; rewrite <- inf_eq; compute; inversion 1.
        }

        rewrite Znth_0_hd.
        2: ulia. 
        do 2 rewrite upd_Znth_map.
        
        
        (* but u could be either 
           - unseen, in which case the min-popped
             was unseen, which means we will break
           - seen, in which case there is a 
             whole lot of ground to cover   
         *)
        unfold V in *.
        
        forward.
        forward_if. 
        1: { 
          (* dist[u] = inf. We will break. *)
          rewrite inf_eq2 in H14.
          
          assert (Htemp : inf < Int.modulus). {
            rewrite <- inf_eq; compute; trivial.
          }
          apply Int_repr_eq_small in H14.
          2: { assert (0 <= u < Zlength dist_contents) by lia.
               apply (Forall_Znth _ _ _ H15) in H6.
               simpl in H6. lia.
          }
          2: rewrite <- inf_eq; compute; split; [inversion 1 | trivial]. 
          clear Htemp.
          
          forward.  
          Exists prev_contents (upd_Znth u priq_contents (inf + 1)) dist_contents (u :: popped_verts).
          entailer!.
          remember (find priq_contents
                         (fold_right Z.min
                                     (hd 0 priq_contents) priq_contents) 0) as u.
          clear H15 H16 H17 H18 Pv_pq HPv_pq Pv_pq0 H19 H20 H21
                H22 H23 H24 H25 H26 H27.
          split.
          - rewrite Forall_forall; intros.
            apply In_Znth_iff in H15.
            destruct H15 as [index [? ?]].
            destruct (Z.eq_dec index u).
            + subst index. rewrite upd_Znth_same in H16; lia.
            + rewrite upd_Znth_Zlength in H15; trivial; [|lia].
              rewrite upd_Znth_diff in H16; trivial; [|lia].
              rewrite <- H16.
              rewrite Hequ, <- H4, Znth_find in H14.
              * rewrite <- H14.
                apply Z.le_ge, fold_min, Znth_In; trivial.
              * apply min_in_list. apply incl_refl.
                   rewrite <- Znth_0_hd; [apply Znth_In|]; lia.
              * apply (vvalid_meaning g); trivial.
                replace SIZE with (Zlength priq_contents).
                apply find_range.
                apply min_in_list. apply incl_refl.
                rewrite <- Znth_0_hd; [apply Znth_In|]; lia.
              * rewrite <- Hequ; trivial.
          - unfold dijkstra_correct in H1 |- *.
            intros. specialize (H1 _ H15).
            destruct H1 as [? [? ?]].
            split3.
            + unfold inv_popped in *.
              intros.
              destruct (Z.eq_dec dst u).
              * subst dst. left.
                split; trivial.
                intros.
                assert (Znth u priq_contents = inf). {
                  rewrite H4; trivial.
                }
                unfold inv_unseen in H17.
                rewrite H4 in H20; trivial.
                specialize (H17 H13 H20).
                split.
                --
                  destruct (in_dec
                              (ZIndexed.eq)
                              m
                              popped_verts).
                  1: intuition.
                  assert ((Znth m dist_contents) = inf). {
                    rewrite <- H4, Hequ in H20; trivial.
                    rewrite Znth_find in H20.
                    2: { apply min_in_list.
                         apply incl_refl.
                         rewrite <- Znth_0_hd; [apply Znth_In|]; lia.
                    }
                    pose proof (fold_min priq_contents (Znth m dist_contents)).
                    rewrite H20 in H21.
                    assert (0 <= m < Zlength dist_contents).
                    { apply (vvalid_meaning g) in H19; trivial.
                      ulia.
                    }
                    destruct (Znth_dist_cases m dist_contents H22); trivial.
                    exfalso.
                    - apply Zlt_not_le in H23.
                      apply H23. apply H21.
                      rewrite <- H4; trivial.
                      apply Znth_In. lia.
                  }
                  unfold V in *. rewrite H21.
                  rewrite careful_add_comm, careful_add_inf; trivial.
                  apply edge_cost_pos; trivial.
                -- intros.
                   assert (0 <= m < SIZE). {
                     apply (vvalid_meaning g) in H19; trilia.
                   }
                   destruct (Z.eq_dec m u).
                   1: rewrite e; trivial.
                   apply not_in_cons in H21. destruct H21 as [_ ?].
                   assert (Hrem:= H21).
                   rewrite (get_popped_meaning _ priq_contents) in H21 by lia.
                   rewrite <- H4; trivial.
                   rewrite <- H4, Hequ, Znth_find in H20; trivial.
                   2: apply fold_min_in_list; lia.
                   pose proof (fold_min priq_contents (Znth m priq_contents)).
                   rewrite H20 in H23.
                   assert (In (Znth m priq_contents) priq_contents). {
                     apply Znth_In. lia.
                   }
                   specialize (H23 H24).
                   apply Z.le_antisymm; trivial.
                   apply (Forall_Znth _ _ m) in H7.
                   simpl in H7.
                   all: ulia.
              * apply in_inv in H18; destruct H18; [lia|].
                destruct (H1 H18); [left | right].
                -- destruct H19; split; trivial. 
                   intros. destruct (Z.eq_dec m u).
                   ++ unfold V in *; rewrite e, H14, careful_add_comm,
                                     careful_add_inf; [split; trivial|].
                      subst m. apply edge_cost_pos; trivial.
                   ++ split.
                      1: apply H20; trivial.
                      intros.
                      apply not_in_cons in H22. destruct H22 as [_ ?].
                      destruct (H20 _ H21).
                      apply H24; trivial.
                -- destruct H19 as [p2dst [? [? ?]]].
                   exists p2dst. split3; trivial.
                   unfold path_in_popped in *.
                   intros.
                   specialize (H20 _ H22).
                   destruct H20; split; trivial.
                   destruct (Z.eq_dec step u).
                   ++ rewrite e. apply in_eq.
                   ++ apply in_cons; trivial.
            + unfold inv_unpopped in *.
              intros.
              assert (n0: dst <> u). {
                intro. apply H18.
                rewrite H20.
                apply in_eq.
              }
              apply not_in_cons in H18; destruct H18 as [_ ?].
              specialize (H16 H18 H19).
              destruct H16; [left | right]; trivial.
              remember (Znth dst prev_contents) as mom.
              destruct H16 as [? [? [? [? [? [? ?]]]]]].
              split3; [| |split3; [| |split3]]; trivial.
              1: destruct (Z.eq_dec mom u);
                subst mom; apply in_cons; trivial.
              intros. destruct (Z.eq_dec mom' u).
              * rewrite e in *.
                unfold V in *.
                rewrite H14.
                rewrite careful_add_comm, careful_add_inf; trivial.
                lia.
                apply edge_cost_pos; trivial.
              * apply H25; trivial.
                simpl in H27; destruct H27; [lia|]; trivial.
            + unfold inv_unseen in *. intros.
              assert (n: dst <> u). {
                intro contra. apply H18.
                rewrite contra; apply in_eq.
              }
              apply not_in_cons in H18; destruct H18 as [_ ?].
              specialize (H17 H18 H19).
              destruct (Z.eq_dec m u).
              1: { unfold V in *; rewrite e, H14, careful_add_comm,
                                  careful_add_inf; trivial.
                   subst m. apply edge_cost_pos; trivial.
              }
              apply H17; trivial.
              simpl in H21; destruct H21; [lia | trivial].
        }
        
        (* Now we're in the main proof. We will run through
           the for loop and relax u's neighbors when possible.
         *)
        rename H14 into Htemp.
        assert (H14: Znth u dist_contents < inf). {
          rewrite inf_eq2 in Htemp.
          apply repr_neq_e in Htemp.
          pose proof (Znth_dist_cases u dist_contents).
          destruct H14; trilia.
        }
        clear Htemp.
        
        remember (upd_Znth u priq_contents (inf+1)) as priq_contents_popped.
        (* This is the priq array with which
           we will enter the for loop.
           The dist and prev arrays are the same.
           Naturally, going in with this new priq
           and the old dist and prev means that
           dijkstra_correct is currently broken.
           The for loop will repair this and restore
           dijkstra_correct.
         *)
        forward_for_simple_bound
          SIZE
          (EX i : Z,
           EX prev_contents' : list V,
           EX priq_contents' : list V,
           EX dist_contents' : list V,
           EX popped_verts' : list V,
           PROP (
               (* inv_popped is not affected *)
               forall dst,
                 vvalid g dst ->
                 inv_popped g src popped_verts' prev_contents'
                            dist_contents' dst;

                 (* and, because we broke out when dist[u] = inf,
                    we know that none of the popped items have dist inf.
                    Essentially, the first disjunct of inv_popped
                    is impossible inside the for loop.
                  *)
               forall dst,
                 vvalid g dst ->
                 In dst popped_verts' ->
                 Znth dst dist_contents' <> inf;
                 
                 (* inv_unpopped is restored for those vertices
                 that the for loop has scanned and repaired *)
               forall dst,
                 0 <= dst < i ->
                 inv_unpopped g src popped_verts' prev_contents'
                              dist_contents' dst;
                 
                 (* a weaker version of inv_popped is
                    true for those vertices that the
                    for loop has not yet scanned *)
               forall dst,
                 i <= dst < SIZE ->
                 inv_unpopped_weak g src popped_verts' prev_contents'
                                   dist_contents' dst u;
                       
                   (* similarly for inv_unseen,
                      the invariant has been
                      restored until i:
                      u has been taken into account *)
               forall dst,
                 0 <= dst < i ->
                 inv_unseen g popped_verts'
                            dist_contents' dst;

                 (* and a weaker version of inv_unseen is
                    true for those vertices that the
                    for loop has not yet scanned *)
               forall dst,
                 i <= dst < SIZE ->
                 inv_unseen_weak g popped_verts' 
                                 dist_contents' dst u;
                 (* further, some useful facts about src... *)
                 Znth src dist_contents' = 0;
                 Znth src prev_contents' = src;
                 (* Znth src priq_contents' <> inf; *)
                 
                 (* a useful fact about u *)
                 In u popped_verts';
                 
                 (* A fact about the relationship b/w 
                    dist and priq arrays *)
               forall dst,
                 vvalid g dst ->
                 ~ In dst popped_verts' ->
                 Znth dst priq_contents' = Znth dst dist_contents';
                       
                 (* and ranges of the three arrays *)
                 inrange_prev prev_contents';
                 inrange_priq priq_contents';
                 inrange_dist dist_contents')
                
                 LOCAL (temp _u (Vint (Int.repr u));
                        temp _dist (pointer_val_val dist);
                        temp _prev (pointer_val_val prev);
                        temp _src (Vint (Int.repr src));
                        lvar _pq (tarray tint SIZE) v_pq;
                        temp _graph (pointer_val_val arr))
                 SEP (data_at Tsh
                              (tarray tint SIZE)
                              (map Vint (map Int.repr prev_contents'))
                              (pointer_val_val prev);
                      data_at Tsh
                              (tarray tint SIZE)
                              (map Vint (map Int.repr priq_contents')) v_pq;
                      data_at Tsh
                             (tarray tint SIZE)
                             (map Vint (map Int.repr dist_contents'))
                             (pointer_val_val dist);
                     DijkGraph sh g (pointer_val_val arr))).
        -- unfold SIZE; rep_lia.
        -- (* We start the for loop as planned --
              with the old dist and prev arrays,
              and with a priq array where u has been popped *)
          (* We must prove the for loop's invariants for i = 0 *)
          Exists prev_contents.
          Exists priq_contents_popped.
          Exists dist_contents.
          Exists (u :: popped_verts).
          repeat rewrite <- upd_Znth_map.
          entailer!.
          remember (find priq_contents
                         (fold_right Z.min (hd 0 priq_contents)
                                     priq_contents) 0) as u.
          clear H15 H16 H17 H18 H19 H20 H21 H22
                H23 H24 H25 H26 H27 Pv_pq HPv_pq Pv_pq0.
          split3; [| | split3; [| |split3]]; trivial.
          ++ (* We must show inv_popped for all
                dst that are in range. *)
            
Set Nested Proofs Allowed.
            
Lemma inv_popped_add_u_dst_neq_u:
  forall (g: DijkGG) src dst u popped prev dist,
    dijkstra_correct g src popped prev dist ->
    vvalid g dst ->
    dst <> u ->
    inv_popped g src (u :: popped) prev dist dst.
Proof.
  intros. intro. simpl in H2; destruct H2; [lia|].
  destruct (H _ H0) as [? _].
  specialize (H3 H2); destruct H3 as [[? ?]|[? [? [? ?]]]];
         [left | right]; trivial.
  - split; trivial.
    intros. destruct (H4 _ H5).
    destruct (Z.eq_dec m u); [subst m|];
      split; trivial; intro;
        apply not_in_cons in H8; destruct H8 as [_ ?];
          apply H7; trivial.
  - exists x; split3; trivial.
    unfold path_in_popped. intros.
    destruct (H4 _ H6); split; [simpl; right|]; trivial.
Qed.

Lemma inv_popped_add_src:
  forall (g: DijkGG) src popped prev dist,
    dijkstra_correct g src popped prev dist ->
    vvalid g src ->
    Znth src dist = 0 ->
    inv_popped g src (src :: popped) prev dist src.
Proof.
  intros. right.
  exists (src, []); split3; trivial.
  - split3; [| | split3]; trivial.
    + split; trivial.
    + split; trivial.
    + rewrite Forall_forall; intros; simpl in H3; lia.
  - unfold path_in_popped. intros. destruct H3 as [? | [? [? _]]].
    + simpl in H3. unfold V, E in *.
      rewrite H3, H1; split; trivial.
      rewrite <- inf_eq; compute; trivial.
    + simpl in H3; lia.
  - unfold path_globally_optimal; intros.
    unfold path_cost at 1; simpl.
    apply path_cost_pos; trivial.
Qed.  

Lemma path_correct_app_cons:
  forall (g: DijkGG) src u mom p2mom prev dist,
  path_correct g prev dist src mom p2mom ->
  Znth u dist = Znth mom dist + elabel g (mom, u) ->
  Znth mom dist + elabel g (mom, u) < inf ->
  strong_evalid g (mom, u) ->
  Znth u prev = mom ->
  path_correct g prev dist src u (fst p2mom, snd p2mom +:: (mom, u)).
Proof.
  intros.
  destruct H as [? [[? ?] [? [? ?]]]].
  assert (path_cost g p2mom + elabel g (mom, u) < inf) by
      ulia. 
  split3; [| | split3]; trivial.
  - apply valid_path_app_cons; trivial; try rewrite <- surjective_pairing; trivial.
  - apply path_ends_app_cons with (a' := src); trivial.
    split; trivial.
    rewrite <- (surjective_pairing p2mom); trivial.
  - destruct H2; rewrite path_cost_app_cons; trivial; ulia.
  - destruct H2; rewrite path_cost_app_cons; trivial; try ulia.
  - rewrite Forall_forall. intros.
    rewrite Forall_forall in H8.
    apply in_app_or in H10. destruct H10.
    + apply H8; trivial.
    + simpl in H10. destruct H10; [| lia].
      rewrite (surjective_pairing x) in *.
      inversion H10.
      simpl. rewrite <- H12, <- H13. ulia.
Qed.

Lemma inv_popped_add_u:
  forall (g: DijkGG) src dst popped prev priq dist,
 let u :=
      find priq (fold_right Z.min (hd 0 priq) priq) 0 in
    dijkstra_correct g src popped prev dist ->
    Znth src dist = 0 ->
    (forall dst : Z,
        vvalid g dst ->
        ~ In dst popped -> Znth dst priq = Znth dst dist) ->
    inrange_dist dist ->
    Zlength priq = SIZE ->
    Zlength dist = SIZE ->
    ~ In u popped ->
    vvalid g u ->
    Znth u dist < inf ->
    vvalid g dst ->
    inv_popped g src (u :: popped) prev dist dst.
Proof.
  intros.
  destruct (Z.eq_dec dst u).
  (* the easy case where dst is old, and not the new u *)
  2: apply inv_popped_add_u_dst_neq_u; trivial.

  (* now we must show that u is a valid entrant *)
  subst dst. clear H8.
  destruct (H _ H6) as [_ [? _]].
  specialize (H8 H5 H7).
  destruct H8 as [? | [_ [? [? [? [? [? ?]]]]]]].

  (* the easy case where src itself is being poppped *)
  1: subst src; apply inv_popped_add_src; trivial.

  (* now we are in the main proof: 
     u <> src, and u is the exact new entrant.
     Main point: there is some mom in popped.
     the best path to u is:
     (the optimal path to mom) + (mom, u)
   *)

  remember (Znth u prev) as mom.
  destruct (popped_noninf_has_path H H9) as [p2mom [? [? ?]]]; trivial.
  1: pose proof (edge_cost_pos g (mom, u)); ulia.

  right. clear H17.
  exists (fst p2mom, snd p2mom +:: (mom, u)).              
  assert (Hg: evalid g (mom, u)). {
    rewrite (evalid_meaning g); split.
    apply edge_representable.
    apply not_eq_sym, Zaux.Zgt_not_eq; trivial.
  }
  assert (strong_evalid g (mom, u)). {
    split3; trivial.
    rewrite (edge_src_fst g); simpl; trivial.
    rewrite (edge_dst_snd g); simpl; trivial.
  }
    
  split3.
  - apply path_correct_app_cons; trivial. lia.
  - unfold path_in_popped. intros.
    destruct H14 as [? [? _]].
    apply (in_path_app_cons _ _ _ src) in H18; trivial.
    destruct H18.
    + destruct (H15 _ H18).
      split; trivial.
      simpl. right; trivial.
    + subst step. split; simpl; [left|]; trivial.

  - (* Heart of the proof:
       we must show that the locally optimal path via mom
       is actually the globally optimal path to u *)
    unfold path_globally_optimal in H16.
    destruct H14 as [? [? [? [? ?]]]].
    unfold path_globally_optimal; intros.
    rewrite path_cost_app_cons; trivial; [|ulia].
    destruct (Z_le_gt_dec
                (path_cost g p2mom + elabel g (mom, u))
                (path_cost g p')); auto.
    apply Z.gt_lt in g0.
    destruct (zlt (path_cost g p') inf); [|ulia].

    (* p' claims to be a strictly better path
       from src to u (see g0).
       We will show that this is impossible. *)
    exfalso. apply Zlt_not_le in g0. apply g0.
    
    rewrite (surjective_pairing p') in *.
    remember (snd p') as links.
    replace (fst p') with src in *.
    2: destruct H23; simpl in H23; lia.

    assert (Htemp: In src popped). {
      destruct H23. apply H15; trivial.
      left. rewrite (surjective_pairing p2mom) in *.
      simpl. destruct H18. simpl in H18. lia.
    } 

    (* we can split p' into three segments:
       the part inside popped, 
       the hop from popped to unpopped,
       and the part outside popped 
     *)
    destruct (path_leaving_popped_stronger g links src u popped)
      as [p1 [mom' [child' [p2 [? [? [? [? [? [? [? [? [? [? ?]]]]]]]]]]]]]]; trivial.
    clear Htemp.

    (* We will clean up the goal later *)
    replace (path_cost g (src, links)) with
        (path_cost g p1 +
         elabel g (mom', child') +
         path_cost g p2).
    2: shelve.
    
    assert (vvalid g mom'). {
      destruct H31 as [_ [? _]].
      rewrite (edge_src_fst g) in H31.
      simpl in H31; trivial.
    }

    assert (vvalid g child'). {
      destruct H31 as [_ [_ ?]].
      rewrite (edge_dst_snd g) in H31;
        simpl in H31; trivial.
    }

    (* mom' is optimal, and so we know that there exists a 
       path optp2mom', the global minimum from src to mom' *)
    destruct (H mom' H35) as [? _].
    destruct (H37 H29) as [[? ?] | [optp2mom' [? [? ?]]]].
    1: {
      destruct (H39 u); trivial.
      specialize (H41 H5). ulia.
    }
    (* and path_cost of optp2mom' will be <= that of p1 *)
    pose proof (H40 p1 H25 H27).

    (* so now we can prove something quite a bit stronger *)
    apply Z.le_trans with
        (m := path_cost g optp2mom' + elabel g (mom', child')).
    2: pose proof (path_cost_pos _ _ H26); lia.

    (* Intuitionally this is clear: 
       u was chosen for being the cheapest 
       of the unpopped vertices. child' cannot beat it.
       However, for the purposes of the proof, 
       we must take cases on the status of child'
     *)
    assert (Znth mom' dist + elabel g (mom', child') < inf). {
      destruct H38 as [_ [_ [_ [? _]]]].
      rewrite H38.
      apply Z.le_lt_trans
        with (m := path_cost g p1 + elabel g (mom', child')); [lia|].
      rewrite <- H24 in l.
      replace (path_glue p1 (path_glue (mom', [(mom', child')]) p2))
        with
          (path_glue (path_glue p1 (mom', [(mom', child')])) p2) in l.
      2: { apply (path_glue_assoc g).
           apply (path_ends_meet _ _ _ src mom' child');
             trivial.
           apply path_ends_one_step.
           apply (path_ends_meet _ _ _ mom' child' u);
             trivial.
           apply path_ends_one_step.
      }
      apply path_cost_path_glue_lt in l; trivial.
      2: { apply valid_path_merge; trivial.
           apply (path_ends_meet _ _ _ src mom' child');
             trivial.
           apply path_ends_one_step.
           simpl; split; trivial.
           rewrite (edge_src_fst g); trivial.
      }
      destruct l as [l _].
      rewrite path_cost_path_glue in l; trivial.
      apply careful_add_inf_clean.
      apply path_cost_pos; trivial.
      apply edge_cost_pos.
      rewrite one_step_path_Znth in l. lia.
      apply H31.
    }
    
    assert (0 <= Znth mom' dist). {
      rewrite (vvalid_meaning g) in H35.
      apply (Forall_Znth _ _ mom') in H2; [|ulia].
      apply H2. }

    assert (Htemp: 0 <= child' < Zlength dist). {
      apply (vvalid_meaning g) in H36; trivial; lia.
    }
    
    destruct (Znth_dist_cases child' dist); trivial; clear Htemp.
    + (* dist[child'] = inf. This is impossible *)
      exfalso.
      destruct (H _ H36) as [_ [_ ?]].
      specialize (H45 H30 H44 mom' H35 H29).
      rewrite careful_add_clean in H45; trivial. ulia.
      apply edge_cost_pos.

    + (* dist[child'] < inf. We use inv_unpopped *)
      destruct (H _ H36) as [_ [? _]].
      red in H45.
      specialize (H45 H30 H44).
      destruct H45 as [? | [_ [? [? [? [? [? ?]]]]]]].
      * (* child' = src. Again, impossible *)
        exfalso.
        subst child'.
        apply H30, H39.
        destruct H38 as [_ [[? _] _]]. left.
        rewrite (surjective_pairing optp2mom') in *; simpl.
        simpl in H38; lia.
      * specialize (H50 mom' H35 H29).
        rewrite careful_add_clean in H50; trivial; try lia.
        2: apply edge_cost_pos.

        apply Z.le_trans with (m := Znth child' dist); trivial.
        2: destruct H38 as [_ [_ [_ [? _]]]]; ulia.
        unfold V, E in *.
        rewrite <- H20, <- H12.
        repeat rewrite <- H1; trivial.
        subst u.
        rewrite Znth_find.
        1: { apply fold_min_general.
             apply Znth_In.
             apply (vvalid_meaning g) in H36; trivial; lia.
        }
        apply min_in_list.
        1: apply incl_refl.
        rewrite <- Znth_0_hd; [apply Znth_In|];
          rewrite H3; unfold SIZE; lia.

        Unshelve.

        assert (valid_path g (mom', [(mom', child')])).
        admit.
        
        assert (valid_path g (path_glue (mom', [(mom', child')]) p2)).
        admit.

        rewrite <- H24.
        rewrite path_cost_path_glue, careful_add_clean,
        path_cost_path_glue, careful_add_clean; trivial.
        rewrite one_step_path_Znth; [lia|].
        apply H31.
        
        3: rewrite <- H24 in l; apply careful_add_inf_clean; trivial.
        5: rewrite path_cost_path_glue in l; trivial.
        all: try apply path_cost_pos; trivial.
        2: rewrite one_step_path_Znth; [ulia | apply H31]. 
        2: { admit. }
        admit.
Admitted.

trivial.

apply inv_popped_add_u.

      

    


  
     

                

       


  (*
           
          ++ intros.
             destruct (Z.eq_dec dst u).
             1: subst dst; ulia.
             simpl in H16; destruct H16; [lia|].
             intro.
             
             destruct (H1 dst) as [? _]; trivial.
             specialize (H18 H16).
             destruct H18 as [[? ?] | [src2dst [? [? ?]]]].
             2: destruct H18 as [? [? [? [? ?]]]]; lia.
             assert (vvalid g u). {
               apply (vvalid_meaning g); trivial; lia.
             }
             destruct (H19 u H20).
             specialize (H22 H13). ulia.
          
          ++ (* ... in fact, any vertex that is
                 "seen but not popped"
                 is that way without the benefit of u.

                 We will be asked to provide a locally optimal
                 path to such a dst, and we will simply provide the
                 old one best-known path
              *)
            unfold inv_unpopped_weak. intros.
            apply not_in_cons in H16; destruct H16 as [_ ?].
            rewrite <- (vvalid_meaning g) in H15; trivial.
            destruct (H1 dst H15) as [_ [? _]].
            specialize (H18 H16 H17) as
                [? | [? [? [? [? [? [? ?]]]]]]]; [left | right]; trivial.
            
            unfold V in *.
            remember (Znth dst prev_contents) as mom.

            assert (evalid g (mom, dst)). {
                rewrite (evalid_meaning g). split.
                apply (edge_representable).
                intro. rewrite <- H25 in H21.
                apply Zlt_not_le in H21.
                apply H21; reflexivity.
            }

            assert (Znth mom dist_contents < inf) by
                (pose proof (valid_edge_bounds g _ H25); ulia).
            
            destruct (popped_noninf_has_path H1 H20 H26) as [p2mom [? [? ?]]]; trivial.
            
            (* Several of the proof obligations
               fall away easily, and those that remain
               boil down to showing that
               u was not involved in this
               locally optimal path.
             *)
            assert (mom <> u). {
              intro contra. rewrite contra in *. apply H13; trivial. 
            }

            split3; [|split3; [| |split3; [| |split]]|]; trivial.
            1: simpl; right; trivial.
            intros.
            apply H24; trivial.
            simpl in H33; destruct H33; trilia.
          ++ unfold inv_unseen_weak. intros.
             assert (e: dst <> u) by (simpl in H16; lia).
             apply not_in_cons in H16; destruct H16 as [_ ?].
             rewrite <- (vvalid_meaning g) in H15; trivial.
             destruct (H1 dst H15) as [_ [_ ?]].
             apply H21; trivial.
             simpl in H19; destruct H19; [lia | trivial].
          ++ apply in_eq.
          ++ intros.
             assert (dst <> u). {
               intro. subst dst. apply H16, in_eq.
             }
             assert (0 <= dst < Zlength priq_contents). {
               rewrite (vvalid_meaning g) in H15; lia.
             }
             rewrite upd_Znth_diff; trivial.
             apply H4; trivial.
             apply not_in_cons in H16; destruct H16 as [_ ?].
             trivial. ulia.
          ++ apply Forall_upd_Znth; trivial.
             ulia. rewrite <- inf_eq; rep_lia.
          ++ do 2 rewrite upd_Znth_map. cancel.

             
        -- (* We now begin with the for loop's body *)
          assert (0 <= u < Zlength (@graph_to_mat SIZE g id)). {
            rewrite graph_to_mat_Zlength; lia.
          }
          assert (Zlength (Znth u (@graph_to_mat SIZE g id)) = SIZE). {
            rewrite Forall_forall in H0. apply H0. apply Znth_In.
            ulia.
          }
          freeze FR := (data_at _ _ _ _) (data_at _ _ _ _) (data_at _ _ _ _).
          unfold DijkGraph.
          rewrite (SpaceAdjMatGraph_unfold _ _ id _ _ u).
          2: ulia.
          Intros.
          
          freeze FR2 := (iter_sepcon _ _) (iter_sepcon _ _).
          unfold list_rep.
          assert_PROP (force_val
                         (sem_add_ptr_int tint Signed
                                          (force_val (sem_add_ptr_int (tarray tint SIZE) Signed (pointer_val_val arr) (Vint (Int.repr u))))
                                          (Vint (Int.repr i))) = field_address (tarray tint SIZE) [ArraySubsc i] (@list_address SIZE CompSpecs (pointer_val_val arr) u)). {
            entailer!.
            unfold list_address. simpl.
            rewrite field_address_offset.
            1: rewrite offset_offset_val; simpl; f_equal; rep_lia.
            destruct H34 as [? [? [? [? ?]]]].
            unfold field_compatible; split3; [| | split3]; simpl; auto.
          } 
          forward. thaw FR2.
          gather_SEP (iter_sepcon _ _) (data_at _ _ _ _) (iter_sepcon _ _).
          rewrite sepcon_assoc.
          rewrite <- (@SpaceAdjMatGraph_unfold SIZE); trivial. thaw FR.
          remember (Znth i (Znth u (@graph_to_mat SIZE g id))) as cost.
          assert (H_i_valid: vvalid g i). {
            apply (vvalid_meaning g); trivial.
          }
          assert (H_u_valid: vvalid g u). {
            trivial.
          }
          (* todo: definitely refactor out *)
          rewrite <- elabel_Znth_graph_to_mat in Heqcost; trivial.
          
          assert_PROP (Zlength priq_contents' = SIZE). {
            entailer!. repeat rewrite Zlength_map in *. trivial. }
          assert_PROP (Zlength prev_contents' = SIZE). {
            entailer!. repeat rewrite Zlength_map in *. trivial. }
          assert_PROP (Zlength dist_contents' = SIZE). {
            entailer!. repeat rewrite Zlength_map in *. trivial. }
          assert (Zlength (@graph_to_mat SIZE g id) = SIZE). {
            rewrite graph_to_mat_Zlength; trivial. lia.
          }            
          forward_if.
          ++ rename H36 into Htemp.
             assert (0 <= cost <= Int.max_signed / SIZE). {
               pose proof (edge_representable g (u, i)).
               rewrite Heqcost in *.
               apply (valid_edge_bounds g).
               rewrite (evalid_meaning g). split; trivial.
               intro.
               rewrite inf_eq2 in Htemp.
               do 2 rewrite Int.signed_repr in Htemp; trivial.
               rewrite <- H37 in Htemp.
               apply Zlt_not_le in Htemp.
               apply Htemp; reflexivity. (* lemma-fy *)
             }
             clear Htemp.
             assert (evalid g (u,i)). {
               apply evalid_dijk with (cost := cost);
                 trivial.
             }
             
             assert (0 <= Znth u dist_contents' <= inf). {
               assert (0 <= u < Zlength dist_contents') by lia.
               apply (Forall_Znth _ _ _ H38) in H30.
               assumption.
             }
             assert (0 <= Znth i dist_contents' <= inf). {
               assert (0 <= i < Zlength dist_contents') by lia.
               apply (Forall_Znth _ _ _ H39) in H30.
               assumption.
             }
             assert (0 <= Znth u dist_contents' + cost <= Int.max_signed). {
               split; [lia|].
               assert (inf <= Int.max_signed - (Int.max_signed / SIZE)). {
                 rewrite <- inf_eq. compute; inversion 1.
               }
               rep_lia.
             }
             unfold V, DE in *.
             
             forward. forward. forward_if.
             ** rename H41 into improvement.
                (* We know that we are definitely
                   going to make edits in the arrays:
                   we have found a better path to i, via u *)
                
                assert (~ In i (popped_verts')).
                {
                  (* This useful fact is true because
                     the cost to i was just improved.
                     This is impossible for popped items.
                   *)
                  intro.
                  destruct (H18 _ H_i_valid H41).
                  - destruct H42.
                    destruct (H43 u H_u_valid).
                    unfold V, DE in *.
                    rewrite careful_add_clean in H44.
                    all: ulia.
                  - apply Zlt_not_le in improvement.
                    apply improvement.
                    destruct (H18 _ H_u_valid H26) as [[? ?] | [p2u [? [? ?]]]].
                    1: ulia.
                    destruct H43 as [? [? [? [? ?]]]].
                    destruct H42 as [p2i [? [? ?]]].
                    destruct H42 as [? [? [? [? ?]]]].
                    unfold V, E in *. rewrite H48, H54.
                    
                    unfold path_globally_optimal in H51.
                    specialize (H51 (fst p2u, snd p2u +:: (u,i))).

                    rewrite path_cost_app_cons in H51; trivial.
                    2: ulia.
                    rewrite Heqcost.
                    apply H51.
                    + apply valid_path_app_cons.
                      * rewrite <- surjective_pairing; trivial.
                      * rewrite (surjective_pairing p2u) in H46.
                        destruct H46; simpl in H46.
                        ulia.
                      * apply strong_evalid_dijk; trivial. ulia.
                    + apply path_ends_app_cons with (a' := src); trivial.
                      3: rewrite <- surjective_pairing; trivial.
                      all: rewrite (surjective_pairing p2u) in *;
                        destruct H46; simpl in H46; trivial.
                }
                 
                assert (Htemp : 0 <= i < Zlength dist_contents') by lia.
                pose proof (Znth_dist_cases i dist_contents' Htemp H30).
                clear Htemp.
                rename H42 into icases.
                rewrite <- H27 in icases; trivial.

                assert (0 <= i < Zlength (map Vint (map Int.repr dist_contents'))) by
                    (repeat rewrite Zlength_map; lia).
                forward. forward. forward.
                forward; rewrite upd_Znth_same; trivial.
                1: entailer!.
                unfold V, DE in *.
                forward_call (v_pq, i, (Znth u dist_contents' + cost), priq_contents').

(* Now we must show that the for loop's invariant
   holds if we take another step,
   ie when i increments
                
   We will provide the arrays as they stand now:
   with the i'th cell updated in all three arrays,
   to log a new improved path via u 
 *)
                clear H42. 
                Exists (upd_Znth i prev_contents' u).
                Exists (upd_Znth i priq_contents' (Znth u dist_contents' + cost)).
                Exists (upd_Znth i dist_contents' (Znth u dist_contents' + cost)).
                Exists popped_verts'.
                repeat rewrite <- upd_Znth_map. entailer!.
                remember (find priq_contents (fold_right Z.min (hd 0 priq_contents) priq_contents) 0) as u.
                assert (u <> i) by (intro; subst; lia).
                split3; [| | split3; [| | split3; [| | split3; [| | split]]]]; intros.
                --- unfold inv_popped; intros.
                    pose proof (H18 dst H55 H56).
                    assert (n: dst <> i). {
                      intro contra.
                      rewrite contra in *.
                      apply H41; trivial.
                    }
                    assert (0 <= dst < SIZE). {
                      apply (vvalid_meaning g) in H55; ulia.
                    }
                    repeat rewrite upd_Znth_diff; try lia.
                    destruct H57; [exfalso | right].
                    +++ destruct H57.
                        specialize (H19 _ H55 H56).
                        unfold V in *. lia.
                    +++ destruct H57 as [p2dst [? [? ?]]].
                        exists p2dst. split3; trivial.
                        *** 
                          destruct H57 as [? [? [? [? ?]]]].
                          split3; [| | split3]; trivial.
                          1: unfold V in *;
                            rewrite upd_Znth_diff; lia.
                          rewrite Forall_forall; intros.
                          assert (In_path g (snd x) p2dst). {
                            unfold In_path. right.
                            exists x. split; trivial.
                            right.
                            rewrite (edge_dst_snd g); trivial.
                          }

                          specialize (H59 _ H66).
                          rewrite Forall_forall in H64.
                          specialize (H64 _ H65).
                          destruct H59.
                          assert (snd x <> i). {
                            intro contra.
                            unfold V in *.
                            rewrite contra in *.
                            apply H41; trivial; lia.
                          }
                          unfold V in *.
                          rewrite upd_Znth_diff; try lia.
                          replace (Zlength prev_contents') with SIZE by lia.
                          rewrite <- (vvalid_meaning g); trivial.
                          apply (valid_path_valid _ p2dst); trivial.
                        ***
                          unfold path_in_popped. intros.
                          specialize (H59 _ H61).
                          destruct H59.
                          assert (step <> i). {
                            intro contra.
                            subst step.
                            apply H41; trivial; lia.
                          }
                          split; trivial.
                          rewrite upd_Znth_diff; trivial.
                          replace (Zlength dist_contents') with SIZE by lia.
                          rewrite <- (vvalid_meaning g); trivial.
                          destruct H57.
                          apply (valid_path_valid _ p2dst); trivial.
                          lia.
                    +++ unfold V in *; lia.
                    +++ unfold V in *; lia.
                --- 
                  destruct (Z.eq_dec dst i).
                    1: subst dst; rewrite upd_Znth_same; trivial; lia.
                    rewrite upd_Znth_diff.
                    apply H19; trivial.
                    all: trivial; try lia.
                    apply (vvalid_meaning g) in H55; ulia.
                --- intros.
                    destruct (Z.eq_dec dst i).
                    +++ subst dst.
               (* This is a key change --
                i will now be locally optimal,
                _thanks to the new path via u_.

                In other words, it is moving from
                the weaker inv_unpopped clause
                to the stronger
                *)
                        unfold inv_unpopped; intros.
                        destruct (Z.eq_dec i src).
                        1: left; trivial.
                        right; split; trivial.

                        assert (Hu: vvalid g u). {
                          apply (vvalid_meaning g); ulia.
                        }
                        
                        destruct (H18 _ Hu H26).
                        1: unfold V in *; lia.
                        clear H57.
                        unfold V in *.
                        rewrite upd_Znth_same by lia.
                        split3; [| |split3; [| |split]]; trivial.
                        *** ulia.
                        *** rewrite upd_Znth_diff; trivial; ulia.
                        *** rewrite upd_Znth_same; trivial; [|ulia].
                            rewrite upd_Znth_diff; trivial; ulia.
                        *** intros. rewrite upd_Znth_same; trivial; [|ulia].
                            
 (* This is another key point in the proof:
    we must show that the path via u is
    better than all other paths via
    other popped verices *)
                            assert (mom' <> i). {
                              intro. subst mom'.
                              apply H41; trivial.
                            }
                            rewrite upd_Znth_diff; trivial.
                            2: apply (vvalid_meaning g) in H57; ulia.
                            2: lia.
                            destruct (Znth_dist_cases mom' dist_contents'); trivial.
                            1: apply (vvalid_meaning g) in H57; ulia. 
                            1: { rewrite H61.
                                 rewrite careful_add_comm,
                                 careful_add_inf.
                                 1: lia.
                                 apply (edge_cost_pos g).
                            }
                            rename H61 into Hk.
                            
                            destruct (H18 _ H57 H59); trivial.
                            1: unfold V in *; lia.

                            
                            destruct H61 as [p2mom' [? [? ?]]].
                            destruct H61 as [? [? [? [? ?]]]].

                            assert (In_path g mom' p2mom'). {
                              destruct H64.
                              apply pfoot_in in H68.
                              trivial.
                            }

                            
                            destruct (zlt ((Znth mom' dist_contents') + elabel g (mom', i)) inf).
                              2: {
                                unfold V in *.
                                destruct (zlt (elabel g (mom', i)) inf).
                                - rewrite careful_add_dirty; trivial;
                                    lia.
                                - unfold careful_add.
                                  destruct (path_cost g p2mom' =? 0) eqn:?.
                                  + rewrite Z.eqb_eq in Heqb.
                                    unfold V in *.
                                    rewrite Heqb in H66.
                                    rewrite H66. simpl.
                                    lia.
                                  + unfold V in *.
                                    rewrite <- H66 in Heqb.
                                    rewrite Heqb.
                                    rewrite if_false_bool.
                                    rewrite if_false_bool.
                                    rewrite if_true_bool. lia.
                                    rewrite Z.leb_le. lia.
                                    rewrite orb_false_iff; split; rewrite Z.ltb_nlt.
                                    pose proof (path_cost_pos g p2mom' H61).
                                    unfold V in *.
                                    lia. lia. 
                                    rewrite Z.eqb_neq. lia.
                              }
                              assert (vvalid g i). {
                                trivial.
                              }

                              assert (careful_add (Znth mom' dist_contents') (elabel g (mom', i))
                                      = (Znth mom' dist_contents') + (elabel g (mom', i))). {
                                rewrite careful_add_clean; trivial.
                                - unfold V in *;
                                    rewrite H66;
                                    apply path_cost_pos; trivial.
                                - apply edge_cost_pos; trivial.
                              }
                              
                              assert (vvalid g i). {
                                trivial.
                              }


(* 
   The known conditions are:
   - dist[u] + graph[u][i] < dist[i]
   - i is an unpopped vertex.

   Now we prove for any other path p' which is from s to i
   and composed by popped vertices (INCLUDING u),
   dist[u] + graph[u][i] <= path_cost p'.
 
   There are two cases about p': In u p' \/ ~ In u p'
 *)


                            destruct (in_dec (ZIndexed.eq) u (epath_to_vpath g p2mom')).
                            ++++ (* Yes, the path p2mom' goes via u *) 
(*
  1. In u p': p' is the path from s to i.
  Consider the vertex mom' which is
  just before i. Again, there are two cases:
  mom' = u \/ ~ mom' = u.
 *)

                              apply in_path_eq_epath_to_vpath in i0.
                              2: trivial.

                              destruct (Z.eq_dec mom' u).
                              1: {
(*
  1.1 mom' = u: path_cost p' = path_cost [s to u] + graph[u][i].
  As we know, u is just popped, dist[u] is the
  global optimal, so dist[u] <= path_cost [s to u],
  so dist[u] + graph[u][i] <= path_cost p'.
 *)
                                unfold V in *.
                                rewrite H70.
                                subst mom'.
                                unfold path_globally_optimal in H64.
                                ulia.
                              }


(*
  1.2 ~ mom' = u: 
  p' can conceptually be split up as:
  path s to u ++ path u to mom' + edge (mom', i).
 *) 
                                                                    
(*
  Since p' is composed by popped vertex
  (including u) only, mom' must be a popped
  vertex. Then it satisfies inv_popped, which means
  dist[mom'] <= path_cost [s to u] + path_cost [u to mom']
  and the global optimal path from s to mom' is
  composed by popped vertices only. 
 *)

 (* Digression: a brief check to see if i was popped, 
    unseen, or just unpopped. 
  *)
                              destruct icases.
                              1: {
                                (* i was unseen *)
                                assert (i <= i < SIZE) by lia.
                                rewrite H27 in H72; trivial.
                                specialize (H23 _ H73 H56 H72).
                                rewrite H23; trivial.
                                ulia.
                              }

(* Now we know that i was seen but unpopped. 
   Great, now we can employ inv_unpopped_weak. *)
                              
                              unfold V in *.
                              rewrite H70.
                              

(* Because i is "seen", we know that 
   The best-known path to i via popped vertices is 
   already logged in dist[i]. 
   So dist[i] <= dist[mom'] + (mom', i).
 *)

                              assert (Znth i dist_contents' <= Znth mom' dist_contents' + elabel g (mom', i)). {
                                assert (i <= i < SIZE) by lia.
                                assert (0 <= mom' < SIZE). {
                                  apply (vvalid_meaning g) in H57; ulia.
                                }
                                rewrite H27 in H72; trivial.
                                destruct (H21 _ H73 H56 H72).
                                - lia.
                                - destruct H75 as [? [[? [? [? [? [? ?]]]]] ?]].
                                  unfold V in *.
                                  rewrite <- H70.
                                  apply H82; trivial.
                              }
                              
(*
  So we have 
  dist[u] + graph[u][i] <= dist[i]
                        <= dist[mom'] + (mom', i) 
                        <= path_cost p'.
 *)
                              unfold V in *.
                              lia.
                            ++++
(* Since u is not in the path, 
   we can just tango with
   the step <> u condition from 
   inv_unpopped_weak. 
   This case is okay.
 *)
                              assert (mom' <> u). {
                                intro. rewrite <- H72 in n0.
                                apply n0.
                                apply in_path_eq_epath_to_vpath; trivial.
                              }

                              destruct icases.
                              1: {
                                (* i was unseen *)
                                assert (i <= i < SIZE) by lia.
                                rewrite H27 in H73; trivial.
                                rewrite (H23 _ H74 H56 H73); ulia.
                              }
                              assert (i <= i < SIZE) by lia.
                              rewrite H27 in H73; trivial.
                              destruct (H21 i H74 H56 H73).
                              1: subst i; exfalso; lia.
                                destruct H75 as [? [[? [? [? [? [? ?]]]]] ?]].
                              apply Z.lt_le_incl.
                              apply Z.lt_le_trans with (m:=Znth i dist_contents').
                              1: lia.
                              apply H82; trivial.


                    +++ assert (0 <= dst < i) by lia.
(* We will proceed using the old best-known path for dst *)
                        unfold inv_unpopped in *.
                        intros.
                        unfold V in *;
                          rewrite upd_Znth_diff in * by lia.
                        specialize (H20 _ H56 H57). destruct H20; trivial.
                        1: left; trivial.
                        destruct H20 as [? [? [? [? [? [? ?]]]]]].
                        unfold V in *.
                        remember (Znth dst prev_contents') as mom. right.
                        split; trivial.

                        assert (Ha: Znth mom dist_contents' < inf). {
                          assert (0 <= elabel g (mom, dst)). {
                            apply edge_cost_pos; trivial.
                          }
                          ulia.
                        }
                        assert (vvalid g dst). {
                          apply (vvalid_meaning g); ulia.
                        }
                        assert (mom <> i). {
                          intro. subst i. 
                          apply H41; trivial.
                        }
                        assert (0 <= mom < Zlength priq_contents'). {
                          apply (vvalid_meaning g) in H59; ulia.
                        }
                        split3; [| |split3; [| |split]]; trivial.
                        *** rewrite upd_Znth_diff; lia.
                        *** repeat rewrite upd_Znth_diff; trivial; ulia.
                        *** intros.
                            assert (mom' <> i). {
                              intro contra. rewrite contra in H69.
                              rewrite (get_popped_meaning _ (upd_Znth i priq_contents'
                                                                      (Znth u dist_contents' + elabel g (u, i)))) in H69.
                              rewrite upd_Znth_same in H69; trivial.
                              ulia. lia. rewrite upd_Znth_Zlength; lia.
                            }
                            repeat rewrite upd_Znth_diff; trivial.
                            apply H64; trivial.
                            1: apply (vvalid_meaning g) in H68; ulia.
                            all: lia.
                --- unfold inv_unpopped_weak. intros.
                    assert (i <= dst < SIZE) by lia.
                    destruct (Z.eq_dec dst i).
                    1: subst dst; lia.
                    unfold V in *.
                    rewrite upd_Znth_diff in H57 by lia.
                    destruct (H21 _ H58 H56 H57); [left | right]; trivial.
                    destruct H59 as [? [[? [Ha [? [? [? ?]]]]] ?]].
                    unfold V in *.
                    rewrite upd_Znth_diff by lia.
                    remember (Znth dst prev_contents') as mom. 
                    (* rename H67 into Hrem. *)

                    assert (mom <> i). {
                      intro. subst i.
                      apply H41; trivial.
                    }
                    assert (0 <= mom < Zlength priq_contents'). {
                      apply (vvalid_meaning g) in Ha; ulia.
                    }
                    
                    split3; [| split3; [| | split3; [| |split]]|]; trivial.
                    +++ repeat rewrite upd_Znth_diff; trivial; lia.
                    +++ repeat rewrite upd_Znth_diff; trivial; try lia.
                    +++ intros.
                        assert (mom' <> i). intro contra.
                        rewrite contra in H70.
                        rewrite (get_popped_meaning _ (upd_Znth i priq_contents'
                                                                (Znth u dist_contents' + elabel g (u, i)))),
                        upd_Znth_same in H70; trivial.
                        ulia. ulia. rewrite upd_Znth_Zlength; lia.
                        repeat rewrite upd_Znth_diff; trivial.
                        apply H65; trivial; try lia.
                        apply (vvalid_meaning g) in H69; ulia.
                        all: lia.
                --- unfold inv_unseen; intros.
                    assert (dst <> i). {
                      intro. subst dst.
                      unfold V in *; rewrite upd_Znth_same in H57; lia.
                    }
                    assert (0 <= dst < i) by lia.
                    rewrite upd_Znth_diff in H57; try lia.
                    rewrite upd_Znth_diff; try lia.
                    apply H22; trivial.
                    +++ apply (vvalid_meaning g) in H58; ulia.
                    +++ ulia.
                    +++ intro contra. subst m.
                        rewrite (get_popped_meaning _ (upd_Znth i priq_contents'
                                                                (Znth u dist_contents' + elabel g (u, i)))) in H59.
                        rewrite upd_Znth_same in H59.
                         ulia. lia.
                         rewrite upd_Znth_Zlength; lia.
                    +++ ulia.
                    +++ ulia.
                --- unfold inv_unseen_weak; intros.
                    assert (dst <> i) by lia.
                    unfold V in *.
                    rewrite upd_Znth_diff in H57 by lia.
                    repeat rewrite upd_Znth_diff by lia.
                    assert (i <= dst < SIZE) by lia.
                    destruct (Z.eq_dec m i).
                    1: { exfalso. subst m.
                         rewrite (get_popped_meaning _ (upd_Znth i priq_contents'
                                                                 (Znth u dist_contents' + elabel g (u, i)))) in H59.
                         rewrite upd_Znth_same in H59.
                         ulia. lia.
                         rewrite upd_Znth_Zlength; lia.
                    }
                    rewrite upd_Znth_diff; trivial.
                    apply H23; trivial.
                    1: apply (vvalid_meaning g) in H58; ulia.
                    all: lia.
                --- rewrite upd_Znth_diff; try lia.
                    intro. subst src; lia.
                --- rewrite upd_Znth_diff; try lia.
                    intro. subst src; lia.
                --- destruct (Z.eq_dec dst i).
                    +++ rewrite e.
                        repeat rewrite upd_Znth_same; trivial; lia.
                    +++ rewrite (vvalid_meaning g) in H55; trivial.
                        repeat rewrite upd_Znth_diff; trivial; try lia.
                        apply H27; trivial.
                        rewrite (vvalid_meaning g); trivial.
                --- split3; apply Forall_upd_Znth; trivial; try lia.
                --- unfold DijkGraph.
                    admit. (* something small is wrong *)
                    
                    
             ** (* This is the branch where we didn't
                   make a change to the i'th vertex. *)
                rename H41 into improvement.
                forward. 
                (* The old arrays are just fine. *)
                Exists prev_contents' priq_contents' dist_contents' popped_verts'.
                entailer!.
                remember (find priq_contents (fold_right Z.min (hd 0 priq_contents) priq_contents) 0) as u.
                clear H51 H52.
                assert (elabel g (u, i) < inf). {
                  apply Z.le_lt_trans with (m := Int.max_signed / SIZE);
                    trivial.
                  apply H36.
                  rewrite <- inf_eq.
                  compute; trivial.
                }
                  
                split3; [| |split].
                --- intros.
                    (* Show that moving one more step
                       still preserves the for loop invariant *)
                    destruct (Z.eq_dec dst i).
                    (* when dst <> i, all is well *)
                    2: apply H20; lia.
                    (* things get interesting when dst = i
                       We must show that i is better off
                       NOT going via u *)
                    subst dst.
                    (* i already obeys the weaker inv_unpopped,
                       ie inv_unpopped without going via u.
                       Now I must show that it actually satisfies
                       inv_unpopped proper
                     *)
                    unfold inv_unpopped; intros.
                    assert (i <= i < SIZE) by lia.
                    destruct (H21 i H55 H53 H54).
                    1: left; trivial.
                    destruct H56 as [? [[? [? [? [? [? ?]]]]] ?]].
                    unfold V in *.
                    remember (Znth i prev_contents') as mom.
                    right.
                    split3; [| |split3; [| |split3]]; trivial.
                    intros.
                    pose proof (Znth_dist_cases mom' dist_contents').
                    rename H66 into e.
                    destruct e as [e | e]; trivial.
                    1: apply (vvalid_meaning g) in H64; ulia.
                    1: {
                      rewrite e.
                      rewrite careful_add_comm,
                      careful_add_inf.
                      lia.
                      apply edge_cost_pos.
                    }
                    destruct (H18 _ H64 H65); [unfold V in *; ulia|].
                    
                    destruct H66 as [p2mom' [? [? ?]]].
                    assert (Hrem := H66).

(*
  This time, we need to prove that since dist[u] +
  graph[u][i] > dist[i], the original path from s to i
  composed by popped vertices (excluding u) is still
  shortest in all paths from s to i composed by popped
  vertices (including u).

  In other words, it is to prove that for any path p' from
  s to i and composed by popped vertices (including u),
  dist[i] < path_cost p'.
 *)

                    (* We check if u is in the path p' *)
                        destruct (in_dec (ZIndexed.eq) u (epath_to_vpath g p2mom')).
                        
                    *** destruct H66 as [? [? [? [? ?]]]].
                        apply in_path_eq_epath_to_vpath in i0; trivial.
(*
  1. In u p': p' is from s to i, consider the
  vertex mom' which is just before i.
 *)
                        destruct (Z.eq_dec mom' u).
                        ----
(*
  1.1 mom' = u: dist[u] is global optimal. We have
  dist[i] < dist[u] + graph[u][i]
          <= path_cost [s to u of p'] + graph[u][i]
          = path_cost p'
                               *)
                              subst mom'.
                              specialize (H67 _ i0).
                              rename p2mom' into p2u.
                              unfold path_globally_optimal in H68.
                              apply Z.ge_le in improvement.

                              destruct (zlt (Znth u dist_contents' + elabel g (u, i)) inf).
                              ++++ rewrite careful_add_clean; try ulia; trivial.

                                   
                              ++++ rewrite careful_add_dirty; trivial.
                                   lia.
                        ----
                          destruct Hrem as [? [? [? [? ?]]]].
                          
                          assert (In_path g mom' p2mom'). {
                            destruct H74.
                            apply pfoot_in in H78. 
                            trivial.
                          }

                          destruct (zlt (Znth mom' dist_contents' + elabel g (mom', i)) inf).
                          2: {
                            unfold V in *.
                            destruct (zlt (elabel g (mom', i)) inf).
                            - rewrite careful_add_dirty; trivial;
                                lia.
                            - unfold careful_add.
                              destruct (Znth mom' dist_contents' =? 0) eqn:?.
                              + unfold V in *. lia.
                              + unfold V in *.
                                rewrite if_false_bool.
                                rewrite if_false_bool.
                                rewrite if_true_bool. lia.
                                rewrite Z.leb_le. lia.
                                rewrite orb_false_iff; split; rewrite Z.ltb_nlt.
                                pose proof (path_cost_pos g p2mom' H66).
                                unfold V in *.
                                lia. lia. 
                                rewrite Z.eqb_neq. lia.
                          }
                          assert (careful_add (Znth mom' dist_contents')
                                              (elabel g (mom', i)) = Znth mom' dist_contents' + elabel g (mom', i)). {
                            rewrite careful_add_clean; trivial.
                            - unfold V in *; rewrite H76. apply path_cost_pos; trivial.
                            - apply edge_cost_pos; trivial. 
                          }
                           
(*
  1.2 ~ mom' = u: 

  Since p2mom' is composed by popped vertex (including u) only,
  mom' must be a popped vertex.
  Then it satisfies inv_popped, which means
  dist[mom'] <= path_cost [s to u] + path_cost [u to mom']
  and the global optimal path from s to mom' is composed by
  popped vertices only.
  Thus dist[mom'] + (mom',i) <= path_cost p'.
 *)
                          unfold V in *.
                          rewrite H79.
                          
(* 
   Since i has been "seen", 
   we have dist[i] <= dist[mom'] + (mom', i)
   because of inv_unpopped_weak 
 *)
                          assert (0 <= mom' < SIZE). {
                            apply (vvalid_meaning g) in H64; ulia.
                          }
                          red in H21.

                          destruct (H21 _ H55 H53 H54).
                          1: lia.
                          destruct H81 as [? [[? [? [? [? [? ?]]]]]]?].
                          rewrite <- H79.
                          apply H88; trivial.
                    ***

(* 2. ~ In u p': This is an easy case.
   dist[i] < path_cost p' because of Inv2.
 *)
                      apply H63; trivial.
                      intro. apply n.
                      destruct H66 as [? [? [? [? ?]]]].
                      rewrite in_path_eq_epath_to_vpath; trivial.
                      destruct H70.
                      apply pfoot_in in H74. rewrite H69 in *. trivial.           
                --- intros. destruct (Z.eq_dec dst i).
                    +++ subst dst. lia.
                    +++ apply H21; lia.
                --- unfold inv_unseen; intros.
                    destruct (Z.eq_dec dst i).
                    2: apply H22; ulia.                     
                    subst dst.
                    assert (i <= i < SIZE) by lia.
                    destruct (Z.eq_dec m u).
                    2: apply H23; trivial.
                    subst m.
                    unfold V in *.
                    rewrite H54 in improvement.
                    assert (0 <= u < SIZE) by lia.
                    destruct (Znth_dist_cases u dist_contents'); trivial.
                    1: lia.
                    all: rename H59 into e.
                    1: { rewrite e.
                         rewrite careful_add_comm,
                         careful_add_inf; trivial.
                         apply edge_cost_pos.
                    }

                    destruct (zlt (elabel g (u, i)) inf).
                    1: apply careful_add_dirty; trivial; lia.
                    rewrite careful_add_dirty; trivial.
                --- intros.
                    assert (i <= dst < SIZE) by lia.
                    apply H23; trivial.
          ++  (* i was not a neighbor of u.
                 We must prove the for loop's invariant holds *)
            rewrite inf_eq2 in H36.
            forward.
            Exists prev_contents' priq_contents' dist_contents' popped_verts'.
            entailer!.
            remember (find priq_contents (fold_right Z.min (hd 0 priq_contents) priq_contents) 0) as u.
            (*
assert (elabel g (u, i) = inf). {
              assert (vvalid g i) by (apply (vvalid_meaning g); ulia).
              assert (vvalid g u) by (apply (vvalid_meaning g); ulia).
              assert (Int.max_signed / SIZE < inf) by now compute. 
              unfold inrange_graph in H1;
                destruct (H1 _ _ H11 H54); trivial.
              rewrite Int.signed_repr in H41.
              2: { unfold V in *. replace SIZE with 8 in H55, H56.
                   unfold Int.min_signed, Int.max_signed, Int.half_modulus in *.
                   simpl. simpl in H55, H56.
                   assert (2147483647 / 8 < 2147483647) by now compute.
                   admit.
              }
              rewrite Int.signed_repr in H41.
              2: rewrite <- inf_eq; rep_lia.
              ulia.
            }
             *)
            do 2 rewrite Int.signed_repr in H36.
            3,4: apply edge_representable.
            2: lia.
            clear H48.

            
            split3; [| |split]; intros.
            ** destruct (Z.eq_dec dst i).
               --- subst dst. 
(* Will need to use the second half of the 
   for loop's invariant.          
   Whatever path worked for i then will 
   continue to work for i now:
   i cannot be improved by going via u 
 *)
                   unfold inv_unpopped; intros.
                   assert (i <= i < SIZE) by lia.
                   destruct (H21 i H51 H49 H50).
                   1: left; trivial.
                   destruct H52 as [? [[? [? [? [? [? ?]]]]]?]].
                   unfold V in *.
                   remember (Znth i prev_contents') as mom.

                   assert (Ha: Znth mom dist_contents' < inf). {
                     assert (0 <= elabel g (mom, i)). {
                       apply edge_cost_pos; trivial.
                     }
                     ulia.
                   }
                   
                   right. split3; [| |split3; [| |split3]]; trivial.
                   
                   intros.
                   destruct (Znth_dist_cases mom' dist_contents') as [e | e]; trivial.
                   1: apply (vvalid_meaning g) in H60; ulia.
                   1: { rewrite e.
                        rewrite careful_add_comm, careful_add_inf.
                        lia.
                        apply edge_cost_pos; trivial.
                   }
                   unfold V in *.
                   
                   destruct (zlt (Znth mom' dist_contents' + elabel g (mom', i)) inf).
                   2: {
                     rewrite careful_add_dirty; trivial.
                     lia.
                     admit.
                     (* careful_add_dirty should not ask
                        that individual components be < inf *)
                   }
                   assert (careful_add (Znth mom' dist_contents') (elabel g (mom', i)) = Znth mom' dist_contents' + elabel g (mom', i)). {
                     rewrite careful_add_clean; trivial.
                     - apply (Forall_Znth _ _ mom') in H30.
                       simpl in H30; ulia.
                       apply (vvalid_meaning g) in H60; ulia.
                     - apply edge_cost_pos; trivial.
                   }
                   destruct (Z.eq_dec mom' u).
                   1: { subst mom'.
                        unfold V, E in *.
                        replace (careful_add (Znth u dist_contents') (elabel g (u, i))) with inf by admit.
                        (* see H36 *)
                        (* careful_add_inf should allow 
                           the inf to be >= inf *)
                           
                        lia.
                   }
                   apply H59; trivial.
               --- apply H20; lia.
            ** destruct (Z.eq_dec dst i).
               --- lia. 
               --- apply H21; lia.
            ** destruct (Z.eq_dec dst i).
               2: apply H22; lia.
               subst dst.
               assert (i <= i < SIZE) by lia.
               unfold inv_unseen; intros.
               destruct (Z.eq_dec m u).
               2: apply H23; trivial.
               subst m. unfold V, E in *.
               admit.
            (* see H36 *)
            (* careful_add_inf should allow 
               the inf to be >= inf *)

               
            ** apply H23; lia.
        -- (* From the for loop's invariant, 
              prove the while loop's invariant. *)
          Intros prev_contents' priq_contents' dist_contents' popped_verts'.
          Exists prev_contents' priq_contents' dist_contents' popped_verts'.
          entailer!.
          remember (find priq_contents (fold_right Z.min (hd 0 priq_contents) priq_contents) 0) as u.
          unfold dijkstra_correct.
          split3; [auto | apply H17 | apply H19];
            try rewrite <- (vvalid_meaning g); trivial.
      * (* After breaking, the while loop,
           prove break's postcondition *)
        assert (isEmpty priq_contents = Vone). {
          destruct (isEmptyTwoCases priq_contents); trivial.
            rewrite H12 in H11; simpl in H11; now inversion H11.
        }
        clear H11.
        forward. Exists prev_contents priq_contents dist_contents popped_verts.
        entailer!. apply (isEmptyMeansInf _ H12).
    + (* from the break's postcon, prove the overall postcon *)
      Intros prev_contents priq_contents dist_contents popped_verts. 
      forward. Exists prev_contents dist_contents popped_verts. entailer!.  *)
Admitted.

