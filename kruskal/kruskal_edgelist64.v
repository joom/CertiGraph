From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Floats AST Ctypes Cop Clight Clightdefs.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Module Info.
  Definition version := "3.11".
  Definition build_number := "".
  Definition build_tag := "".
  Definition build_branch := "".
  Definition arch := "x86".
  Definition model := "64".
  Definition abi := "standard".
  Definition bitsize := 64.
  Definition big_endian := false.
  Definition source_file := "kruskal/kruskal_edgelist.c".
  Definition normalized := true.
End Info.

Definition _E : ident := $"E".
Definition _Is_block : ident := $"Is_block".
Definition _Is_from : ident := $"Is_from".
Definition _MAX_EDGES : ident := $"MAX_EDGES".
Definition _MAX_SPACE_SIZE : ident := $"MAX_SPACE_SIZE".
Definition _Union : ident := $"Union".
Definition _V : ident := $"V".
Definition __139 : ident := $"_139".
Definition __140 : ident := $"_140".
Definition __213 : ident := $"_213".
Definition __214 : ident := $"_214".
Definition __215 : ident := $"_215".
Definition __Bigint : ident := $"_Bigint".
Definition ___assert_func : ident := $"__assert_func".
Definition ___builtin_annot : ident := $"__builtin_annot".
Definition ___builtin_annot_intval : ident := $"__builtin_annot_intval".
Definition ___builtin_bswap : ident := $"__builtin_bswap".
Definition ___builtin_bswap16 : ident := $"__builtin_bswap16".
Definition ___builtin_bswap32 : ident := $"__builtin_bswap32".
Definition ___builtin_bswap64 : ident := $"__builtin_bswap64".
Definition ___builtin_clz : ident := $"__builtin_clz".
Definition ___builtin_clzl : ident := $"__builtin_clzl".
Definition ___builtin_clzll : ident := $"__builtin_clzll".
Definition ___builtin_ctz : ident := $"__builtin_ctz".
Definition ___builtin_ctzl : ident := $"__builtin_ctzl".
Definition ___builtin_ctzll : ident := $"__builtin_ctzll".
Definition ___builtin_debug : ident := $"__builtin_debug".
Definition ___builtin_expect : ident := $"__builtin_expect".
Definition ___builtin_fabs : ident := $"__builtin_fabs".
Definition ___builtin_fabsf : ident := $"__builtin_fabsf".
Definition ___builtin_fmadd : ident := $"__builtin_fmadd".
Definition ___builtin_fmax : ident := $"__builtin_fmax".
Definition ___builtin_fmin : ident := $"__builtin_fmin".
Definition ___builtin_fmsub : ident := $"__builtin_fmsub".
Definition ___builtin_fnmadd : ident := $"__builtin_fnmadd".
Definition ___builtin_fnmsub : ident := $"__builtin_fnmsub".
Definition ___builtin_fsqrt : ident := $"__builtin_fsqrt".
Definition ___builtin_membar : ident := $"__builtin_membar".
Definition ___builtin_memcpy_aligned : ident := $"__builtin_memcpy_aligned".
Definition ___builtin_read16_reversed : ident := $"__builtin_read16_reversed".
Definition ___builtin_read32_reversed : ident := $"__builtin_read32_reversed".
Definition ___builtin_sel : ident := $"__builtin_sel".
Definition ___builtin_sqrt : ident := $"__builtin_sqrt".
Definition ___builtin_unreachable : ident := $"__builtin_unreachable".
Definition ___builtin_va_arg : ident := $"__builtin_va_arg".
Definition ___builtin_va_copy : ident := $"__builtin_va_copy".
Definition ___builtin_va_end : ident := $"__builtin_va_end".
Definition ___builtin_va_start : ident := $"__builtin_va_start".
Definition ___builtin_write16_reversed : ident := $"__builtin_write16_reversed".
Definition ___builtin_write32_reversed : ident := $"__builtin_write32_reversed".
Definition ___cleanup : ident := $"__cleanup".
Definition ___compcert_i64_dtos : ident := $"__compcert_i64_dtos".
Definition ___compcert_i64_dtou : ident := $"__compcert_i64_dtou".
Definition ___compcert_i64_sar : ident := $"__compcert_i64_sar".
Definition ___compcert_i64_sdiv : ident := $"__compcert_i64_sdiv".
Definition ___compcert_i64_shl : ident := $"__compcert_i64_shl".
Definition ___compcert_i64_shr : ident := $"__compcert_i64_shr".
Definition ___compcert_i64_smod : ident := $"__compcert_i64_smod".
Definition ___compcert_i64_smulh : ident := $"__compcert_i64_smulh".
Definition ___compcert_i64_stod : ident := $"__compcert_i64_stod".
Definition ___compcert_i64_stof : ident := $"__compcert_i64_stof".
Definition ___compcert_i64_udiv : ident := $"__compcert_i64_udiv".
Definition ___compcert_i64_umod : ident := $"__compcert_i64_umod".
Definition ___compcert_i64_umulh : ident := $"__compcert_i64_umulh".
Definition ___compcert_i64_utod : ident := $"__compcert_i64_utod".
Definition ___compcert_i64_utof : ident := $"__compcert_i64_utof".
Definition ___compcert_va_composite : ident := $"__compcert_va_composite".
Definition ___compcert_va_float64 : ident := $"__compcert_va_float64".
Definition ___compcert_va_int32 : ident := $"__compcert_va_int32".
Definition ___compcert_va_int64 : ident := $"__compcert_va_int64".
Definition ___count : ident := $"__count".
Definition ___getreent : ident := $"__getreent".
Definition ___locale_t : ident := $"__locale_t".
Definition ___sFILE64 : ident := $"__sFILE64".
Definition ___sbuf : ident := $"__sbuf".
Definition ___sdidinit : ident := $"__sdidinit".
Definition ___sf : ident := $"__sf".
Definition ___sglue : ident := $"__sglue".
Definition ___stringlit_1 : ident := $"__stringlit_1".
Definition ___stringlit_10 : ident := $"__stringlit_10".
Definition ___stringlit_11 : ident := $"__stringlit_11".
Definition ___stringlit_12 : ident := $"__stringlit_12".
Definition ___stringlit_13 : ident := $"__stringlit_13".
Definition ___stringlit_14 : ident := $"__stringlit_14".
Definition ___stringlit_15 : ident := $"__stringlit_15".
Definition ___stringlit_2 : ident := $"__stringlit_2".
Definition ___stringlit_3 : ident := $"__stringlit_3".
Definition ___stringlit_4 : ident := $"__stringlit_4".
Definition ___stringlit_5 : ident := $"__stringlit_5".
Definition ___stringlit_6 : ident := $"__stringlit_6".
Definition ___stringlit_7 : ident := $"__stringlit_7".
Definition ___stringlit_8 : ident := $"__stringlit_8".
Definition ___stringlit_9 : ident := $"__stringlit_9".
Definition ___tm : ident := $"__tm".
Definition ___tm_hour : ident := $"__tm_hour".
Definition ___tm_isdst : ident := $"__tm_isdst".
Definition ___tm_mday : ident := $"__tm_mday".
Definition ___tm_min : ident := $"__tm_min".
Definition ___tm_mon : ident := $"__tm_mon".
Definition ___tm_sec : ident := $"__tm_sec".
Definition ___tm_wday : ident := $"__tm_wday".
Definition ___tm_yday : ident := $"__tm_yday".
Definition ___tm_year : ident := $"__tm_year".
Definition ___value : ident := $"__value".
Definition ___wch : ident := $"__wch".
Definition ___wchb : ident := $"__wchb".
Definition __add : ident := $"_add".
Definition __asctime_buf : ident := $"_asctime_buf".
Definition __atexit : ident := $"_atexit".
Definition __atexit0 : ident := $"_atexit0".
Definition __base : ident := $"_base".
Definition __bf : ident := $"_bf".
Definition __blksize : ident := $"_blksize".
Definition __close : ident := $"_close".
Definition __cookie : ident := $"_cookie".
Definition __cvtbuf : ident := $"_cvtbuf".
Definition __cvtlen : ident := $"_cvtlen".
Definition __data : ident := $"_data".
Definition __dso_handle : ident := $"_dso_handle".
Definition __emergency : ident := $"_emergency".
Definition __errno : ident := $"_errno".
Definition __file : ident := $"_file".
Definition __flags : ident := $"_flags".
Definition __flags2 : ident := $"_flags2".
Definition __fnargs : ident := $"_fnargs".
Definition __fns : ident := $"_fns".
Definition __fntypes : ident := $"_fntypes".
Definition __freelist : ident := $"_freelist".
Definition __gamma_signgam : ident := $"_gamma_signgam".
Definition __getdate_err : ident := $"_getdate_err".
Definition __glue : ident := $"_glue".
Definition __h_errno : ident := $"_h_errno".
Definition __inc : ident := $"_inc".
Definition __ind : ident := $"_ind".
Definition __iobs : ident := $"_iobs".
Definition __is_cxa : ident := $"_is_cxa".
Definition __k : ident := $"_k".
Definition __l64a_buf : ident := $"_l64a_buf".
Definition __lb : ident := $"_lb".
Definition __lbfsize : ident := $"_lbfsize".
Definition __locale : ident := $"_locale".
Definition __localtime_buf : ident := $"_localtime_buf".
Definition __lock : ident := $"_lock".
Definition __maxwds : ident := $"_maxwds".
Definition __mblen_state : ident := $"_mblen_state".
Definition __mbrlen_state : ident := $"_mbrlen_state".
Definition __mbrtowc_state : ident := $"_mbrtowc_state".
Definition __mbsrtowcs_state : ident := $"_mbsrtowcs_state".
Definition __mbstate : ident := $"_mbstate".
Definition __mbtowc_state : ident := $"_mbtowc_state".
Definition __mult : ident := $"_mult".
Definition __nbuf : ident := $"_nbuf".
Definition __new : ident := $"_new".
Definition __next : ident := $"_next".
Definition __nextf : ident := $"_nextf".
Definition __niobs : ident := $"_niobs".
Definition __nmalloc : ident := $"_nmalloc".
Definition __offset : ident := $"_offset".
Definition __on_exit_args : ident := $"_on_exit_args".
Definition __p : ident := $"_p".
Definition __p5s : ident := $"_p5s".
Definition __r : ident := $"_r".
Definition __r48 : ident := $"_r48".
Definition __rand48 : ident := $"_rand48".
Definition __rand_next : ident := $"_rand_next".
Definition __read : ident := $"_read".
Definition __reent : ident := $"_reent".
Definition __result : ident := $"_result".
Definition __result_k : ident := $"_result_k".
Definition __seed : ident := $"_seed".
Definition __seek : ident := $"_seek".
Definition __seek64 : ident := $"_seek64".
Definition __sig_func : ident := $"_sig_func".
Definition __sign : ident := $"_sign".
Definition __signal_buf : ident := $"_signal_buf".
Definition __size : ident := $"_size".
Definition __stderr : ident := $"_stderr".
Definition __stdin : ident := $"_stdin".
Definition __stdout : ident := $"_stdout".
Definition __strtok_last : ident := $"_strtok_last".
Definition __ub : ident := $"_ub".
Definition __ubuf : ident := $"_ubuf".
Definition __unspecified_locale_info : ident := $"_unspecified_locale_info".
Definition __unused : ident := $"_unused".
Definition __unused_rand : ident := $"_unused_rand".
Definition __up : ident := $"_up".
Definition __ur : ident := $"_ur".
Definition __w : ident := $"_w".
Definition __wcrtomb_state : ident := $"_wcrtomb_state".
Definition __wcsrtombs_state : ident := $"_wcsrtombs_state".
Definition __wctomb_state : ident := $"_wctomb_state".
Definition __wds : ident := $"_wds".
Definition __write : ident := $"_write".
Definition __x : ident := $"_x".
Definition _a : ident := $"a".
Definition _abort_with : ident := $"abort_with".
Definition _active : ident := $"active".
Definition _alloc : ident := $"alloc".
Definition _args : ident := $"args".
Definition _arr : ident := $"arr".
Definition _build_heap : ident := $"build_heap".
Definition _create_heap : ident := $"create_heap".
Definition _create_space : ident := $"create_space".
Definition _depth : ident := $"depth".
Definition _do_generation : ident := $"do_generation".
Definition _do_scan : ident := $"do_scan".
Definition _dst : ident := $"dst".
Definition _edge : ident := $"edge".
Definition _edge_list : ident := $"edge_list".
Definition _empty_graph : ident := $"empty_graph".
Definition _exch : ident := $"exch".
Definition _exit : ident := $"exit".
Definition _fi : ident := $"fi".
Definition _fill_edge : ident := $"fill_edge".
Definition _find : ident := $"find".
Definition _first_available : ident := $"first_available".
Definition _forward : ident := $"forward".
Definition _forward_roots : ident := $"forward_roots".
Definition _fprintf : ident := $"fprintf".
Definition _free : ident := $"free".
Definition _freeSet : ident := $"freeSet".
Definition _free_graph : ident := $"free_graph".
Definition _free_heap : ident := $"free_heap".
Definition _from : ident := $"from".
Definition _from_limit : ident := $"from_limit".
Definition _from_start : ident := $"from_start".
Definition _garbage_collect : ident := $"garbage_collect".
Definition _graph : ident := $"graph".
Definition _graph_E : ident := $"graph_E".
Definition _graph_V : ident := $"graph_V".
Definition _graph__1 : ident := $"graph__1".
Definition _greater : ident := $"greater".
Definition _h : ident := $"h".
Definition _hd : ident := $"hd".
Definition _heap : ident := $"heap".
Definition _heapsort : ident := $"heapsort".
Definition _hi : ident := $"hi".
Definition _i : ident := $"i".
Definition _init_empty_graph : ident := $"init_empty_graph".
Definition _int_or_ptr_to_int : ident := $"int_or_ptr_to_int".
Definition _int_or_ptr_to_ptr : ident := $"int_or_ptr_to_ptr".
Definition _int_to_int_or_ptr : ident := $"int_to_int_or_ptr".
Definition _j : ident := $"j".
Definition _k : ident := $"k".
Definition _kruskal : ident := $"kruskal".
Definition _limit : ident := $"limit".
Definition _lo : ident := $"lo".
Definition _main : ident := $"main".
Definition _makeSet : ident := $"makeSet".
Definition _make_tinfo : ident := $"make_tinfo".
Definition _malloc : ident := $"malloc".
Definition _mallocK : ident := $"mallocK".
Definition _mst : ident := $"mst".
Definition _n : ident := $"n".
Definition _new : ident := $"new".
Definition _next : ident := $"next".
Definition _num_allocs : ident := $"num_allocs".
Definition _p : ident := $"p".
Definition _parent : ident := $"parent".
Definition _ptr_to_int_or_ptr : ident := $"ptr_to_int_or_ptr".
Definition _rank : ident := $"rank".
Definition _reset_heap : ident := $"reset_heap".
Definition _resume : ident := $"resume".
Definition _roots : ident := $"roots".
Definition _s : ident := $"s".
Definition _scan : ident := $"scan".
Definition _sink : ident := $"sink".
Definition _size : ident := $"size".
Definition _space : ident := $"space".
Definition _spaces : ident := $"spaces".
Definition _src : ident := $"src".
Definition _start : ident := $"start".
Definition _subset : ident := $"subset".
Definition _subsets : ident := $"subsets".
Definition _summatrix : ident := $"summatrix".
Definition _sz : ident := $"sz".
Definition _tag : ident := $"tag".
Definition _test_int_or_ptr : ident := $"test_int_or_ptr".
Definition _thread_info : ident := $"thread_info".
Definition _ti : ident := $"ti".
Definition _tinfo : ident := $"tinfo".
Definition _to : ident := $"to".
Definition _twobytwo : ident := $"twobytwo".
Definition _u : ident := $"u".
Definition _ufind : ident := $"ufind".
Definition _v : ident := $"v".
Definition _va : ident := $"va".
Definition _vfind : ident := $"vfind".
Definition _w : ident := $"w".
Definition _wedge : ident := $"wedge".
Definition _weight : ident := $"weight".
Definition _x : ident := $"x".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_MAX_EDGES := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 8) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition f_init_empty_graph := {|
  fn_return := (tptr (Tstruct _graph noattr));
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_empty_graph, (tptr (Tstruct _graph noattr))) ::
               (_edge_list, (tptr (Tstruct _edge noattr))) ::
               (_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _mallocK (Tfunction (Tcons tint Tnil) (tptr tvoid) cc_default))
      ((Esizeof (Tstruct _graph noattr) tulong) :: nil))
    (Sset _empty_graph
      (Ecast (Etempvar _t'1 (tptr tvoid)) (tptr (Tstruct _graph noattr)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _MAX_EDGES tint))
        (Scall (Some _t'2)
          (Evar _mallocK (Tfunction (Tcons tint Tnil) (tptr tvoid)
                           cc_default))
          ((Ebinop Omul (Esizeof (Tstruct _edge noattr) tulong)
             (Etempvar _t'3 tint) tulong) :: nil)))
      (Sset _edge_list
        (Ecast (Etempvar _t'2 (tptr tvoid)) (tptr (Tstruct _edge noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _empty_graph (tptr (Tstruct _graph noattr)))
            (Tstruct _graph noattr)) _V tint) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _empty_graph (tptr (Tstruct _graph noattr)))
              (Tstruct _graph noattr)) _E tint)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _empty_graph (tptr (Tstruct _graph noattr)))
                (Tstruct _graph noattr)) _edge_list
              (tptr (Tstruct _edge noattr)))
            (Etempvar _edge_list (tptr (Tstruct _edge noattr))))
          (Sreturn (Some (Etempvar _empty_graph (tptr (Tstruct _graph noattr))))))))))
|}.

Definition f_fill_edge := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_wedge, (tptr (Tstruct _edge noattr))) :: (_w, tint) ::
                (_u, tint) :: (_v, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _wedge (tptr (Tstruct _edge noattr)))
        (Tstruct _edge noattr)) _weight tint) (Etempvar _w tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _wedge (tptr (Tstruct _edge noattr)))
          (Tstruct _edge noattr)) _src tint) (Etempvar _u tint))
    (Sassign
      (Efield
        (Ederef (Etempvar _wedge (tptr (Tstruct _edge noattr)))
          (Tstruct _edge noattr)) _dst tint) (Etempvar _v tint))))
|}.

Definition f_exch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_j, tuint) :: (_k, tuint) ::
                (_arr, (tptr (Tstruct _edge noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_weight, tint) :: (_src, tint) :: (_dst, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _weight
    (Efield
      (Ederef
        (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
          (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
        (Tstruct _edge noattr)) _weight tint))
  (Ssequence
    (Sset _src
      (Efield
        (Ederef
          (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
            (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
          (Tstruct _edge noattr)) _src tint))
    (Ssequence
      (Sset _dst
        (Efield
          (Ederef
            (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
              (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
            (Tstruct _edge noattr)) _dst tint))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
                  (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
                (Tstruct _edge noattr)) _weight tint))
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
                  (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
                (Tstruct _edge noattr)) _weight tint) (Etempvar _t'3 tint)))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef
                  (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
                    (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
                  (Tstruct _edge noattr)) _src tint))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
                    (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
                  (Tstruct _edge noattr)) _src tint) (Etempvar _t'2 tint)))
          (Ssequence
            (Ssequence
              (Sset _t'1
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _arr (tptr (Tstruct _edge noattr)))
                      (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
                    (Tstruct _edge noattr)) _dst tint))
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _arr (tptr (Tstruct _edge noattr)))
                      (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
                    (Tstruct _edge noattr)) _dst tint) (Etempvar _t'1 tint)))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _arr (tptr (Tstruct _edge noattr)))
                      (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
                    (Tstruct _edge noattr)) _weight tint)
                (Etempvar _weight tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _arr (tptr (Tstruct _edge noattr)))
                        (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
                      (Tstruct _edge noattr)) _src tint)
                  (Etempvar _src tint))
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _arr (tptr (Tstruct _edge noattr)))
                        (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
                      (Tstruct _edge noattr)) _dst tint)
                  (Etempvar _dst tint))))))))))
|}.

Definition f_greater := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_j, tuint) :: (_k, tuint) ::
                (_arr, (tptr (Tstruct _edge noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef
        (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
          (Etempvar _j tuint) (tptr (Tstruct _edge noattr)))
        (Tstruct _edge noattr)) _weight tint))
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef
          (Ebinop Oadd (Etempvar _arr (tptr (Tstruct _edge noattr)))
            (Etempvar _k tuint) (tptr (Tstruct _edge noattr)))
          (Tstruct _edge noattr)) _weight tint))
    (Sreturn (Some (Ebinop Oge (Etempvar _t'1 tint) (Etempvar _t'2 tint)
                     tint)))))
|}.

Definition f_sink := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_k, tuint) :: (_arr, (tptr (Tstruct _edge noattr))) ::
                (_first_available, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_j, tuint) :: (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               nil);
  fn_body :=
(Swhile
  (Ebinop Olt
    (Ebinop Oadd
      (Ebinop Omul (Econst_int (Int.repr 2) tuint) (Etempvar _k tuint) tuint)
      (Econst_int (Int.repr 1) tuint) tuint)
    (Etempvar _first_available tuint) tint)
  (Ssequence
    (Sset _j
      (Ebinop Oadd
        (Ebinop Omul (Econst_int (Int.repr 2) tuint) (Etempvar _k tuint)
          tuint) (Econst_int (Int.repr 1) tuint) tuint))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Olt
                       (Ebinop Oadd (Etempvar _j tuint)
                         (Econst_int (Int.repr 1) tint) tuint)
                       (Etempvar _first_available tuint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _greater (Tfunction
                               (Tcons tuint
                                 (Tcons tuint
                                   (Tcons (tptr (Tstruct _edge noattr)) Tnil)))
                               tint cc_default))
              ((Ebinop Oadd (Etempvar _j tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Etempvar _j tuint) ::
               (Etempvar _arr (tptr (Tstruct _edge noattr))) :: nil))
            (Sset _t'1 (Ecast (Etempvar _t'2 tint) tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'1 tint)
          (Sset _j
            (Ebinop Oadd (Etempvar _j tuint) (Econst_int (Int.repr 1) tint)
              tuint))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'3)
            (Evar _greater (Tfunction
                             (Tcons tuint
                               (Tcons tuint
                                 (Tcons (tptr (Tstruct _edge noattr)) Tnil)))
                             tint cc_default))
            ((Etempvar _k tuint) :: (Etempvar _j tuint) ::
             (Etempvar _arr (tptr (Tstruct _edge noattr))) :: nil))
          (Sifthenelse (Etempvar _t'3 tint) Sbreak Sskip))
        (Ssequence
          (Scall None
            (Evar _exch (Tfunction
                          (Tcons tuint
                            (Tcons tuint
                              (Tcons (tptr (Tstruct _edge noattr)) Tnil)))
                          tvoid cc_default))
            ((Etempvar _k tuint) :: (Etempvar _j tuint) ::
             (Etempvar _arr (tptr (Tstruct _edge noattr))) :: nil))
          (Sset _k (Etempvar _j tuint)))))))
|}.

Definition f_build_heap := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arr, (tptr (Tstruct _edge noattr))) :: (_size, tuint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_start, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _start
    (Ebinop Odiv
      (Ebinop Osub (Etempvar _size tuint) (Econst_int (Int.repr 1) tuint)
        tuint) (Econst_int (Int.repr 2) tuint) tuint))
  (Sloop
    (Ssequence
      Sskip
      (Ssequence
        (Scall None
          (Evar _sink (Tfunction
                        (Tcons tuint
                          (Tcons (tptr (Tstruct _edge noattr))
                            (Tcons tuint Tnil))) tvoid cc_default))
          ((Etempvar _start tuint) ::
           (Etempvar _arr (tptr (Tstruct _edge noattr))) ::
           (Etempvar _size tuint) :: nil))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _start tuint)
                         (Econst_int (Int.repr 0) tint) tint)
            Sbreak
            Sskip)
          (Sset _start
            (Ebinop Osub (Etempvar _start tuint)
              (Econst_int (Int.repr 1) tint) tuint)))))
    Sskip))
|}.

Definition f_heapsort := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arr, (tptr (Tstruct _edge noattr))) :: (_sz, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_size, tuint) :: (_active, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _sz tint) (Econst_int (Int.repr 0) tint)
                 tint)
    (Sreturn None)
    Sskip)
  (Ssequence
    (Sset _size (Ecast (Etempvar _sz tint) tuint))
    (Ssequence
      (Scall None
        (Evar _build_heap (Tfunction
                            (Tcons (tptr (Tstruct _edge noattr))
                              (Tcons tuint Tnil)) tvoid cc_default))
        ((Etempvar _arr (tptr (Tstruct _edge noattr))) ::
         (Etempvar _size tuint) :: nil))
      (Ssequence
        (Sset _active (Etempvar _size tuint))
        (Swhile
          (Ebinop Ogt (Etempvar _active tuint) (Econst_int (Int.repr 1) tint)
            tint)
          (Ssequence
            (Sset _active
              (Ebinop Osub (Etempvar _active tuint)
                (Econst_int (Int.repr 1) tint) tuint))
            (Ssequence
              (Scall None
                (Evar _exch (Tfunction
                              (Tcons tuint
                                (Tcons tuint
                                  (Tcons (tptr (Tstruct _edge noattr)) Tnil)))
                              tvoid cc_default))
                ((Econst_int (Int.repr 0) tuint) ::
                 (Etempvar _active tuint) ::
                 (Etempvar _arr (tptr (Tstruct _edge noattr))) :: nil))
              (Scall None
                (Evar _sink (Tfunction
                              (Tcons tuint
                                (Tcons (tptr (Tstruct _edge noattr))
                                  (Tcons tuint Tnil))) tvoid cc_default))
                ((Econst_int (Int.repr 0) tuint) ::
                 (Etempvar _arr (tptr (Tstruct _edge noattr))) ::
                 (Etempvar _active tuint) :: nil)))))))))
|}.

Definition f_free_graph := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graph__1, (tptr (Tstruct _graph noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _edge noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
          (Tstruct _graph noattr)) _edge_list (tptr (Tstruct _edge noattr))))
    (Scall None
      (Evar _free (Tfunction (Tcons (tptr tvoid) Tnil) tvoid cc_default))
      ((Etempvar _t'1 (tptr (Tstruct _edge noattr))) :: nil)))
  (Scall None
    (Evar _free (Tfunction (Tcons (tptr tvoid) Tnil) tvoid cc_default))
    ((Etempvar _graph__1 (tptr (Tstruct _graph noattr))) :: nil)))
|}.

Definition f_kruskal := {|
  fn_return := (tptr (Tstruct _graph noattr));
  fn_callconv := cc_default;
  fn_params := ((_graph__1, (tptr (Tstruct _graph noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_graph_V, tint) :: (_graph_E, tint) ::
               (_subsets, (tptr (Tstruct _subset noattr))) ::
               (_mst, (tptr (Tstruct _graph noattr))) :: (_i, tint) ::
               (_u, tint) :: (_v, tint) :: (_ufind, tint) ::
               (_vfind, tint) :: (_w, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, (tptr (Tstruct _graph noattr))) ::
               (_t'1, (tptr (Tstruct _subset noattr))) ::
               (_t'11, (tptr (Tstruct _edge noattr))) ::
               (_t'10, (tptr (Tstruct _edge noattr))) ::
               (_t'9, (tptr (Tstruct _edge noattr))) ::
               (_t'8, (tptr (Tstruct _edge noattr))) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _edge noattr))) :: (_t'5, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _graph_V
    (Efield
      (Ederef (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
        (Tstruct _graph noattr)) _V tint))
  (Ssequence
    (Sset _graph_E
      (Efield
        (Ederef (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
          (Tstruct _graph noattr)) _E tint))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _makeSet (Tfunction (Tcons tint Tnil)
                           (tptr (Tstruct _subset noattr)) cc_default))
          ((Etempvar _graph_V tint) :: nil))
        (Sset _subsets (Etempvar _t'1 (tptr (Tstruct _subset noattr)))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _init_empty_graph (Tfunction Tnil
                                      (tptr (Tstruct _graph noattr))
                                      cc_default)) nil)
          (Sset _mst (Etempvar _t'2 (tptr (Tstruct _graph noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _mst (tptr (Tstruct _graph noattr)))
                (Tstruct _graph noattr)) _V tint) (Etempvar _graph_V tint))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
                    (Tstruct _graph noattr)) _edge_list
                  (tptr (Tstruct _edge noattr))))
              (Scall None
                (Evar _heapsort (Tfunction
                                  (Tcons (tptr (Tstruct _edge noattr))
                                    (Tcons tint Tnil)) tvoid cc_default))
                ((Etempvar _t'11 (tptr (Tstruct _edge noattr))) ::
                 (Etempvar _graph_E tint) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _i (Econst_int (Int.repr 0) tint))
                (Sloop
                  (Ssequence
                    (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                   (Etempvar _graph_E tint) tint)
                      Sskip
                      Sbreak)
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
                              (Tstruct _graph noattr)) _edge_list
                            (tptr (Tstruct _edge noattr))))
                        (Sset _u
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'10 (tptr (Tstruct _edge noattr)))
                                (Etempvar _i tint)
                                (tptr (Tstruct _edge noattr)))
                              (Tstruct _edge noattr)) _src tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
                                (Tstruct _graph noattr)) _edge_list
                              (tptr (Tstruct _edge noattr))))
                          (Sset _v
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'9 (tptr (Tstruct _edge noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _edge noattr)))
                                (Tstruct _edge noattr)) _dst tint)))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _find (Tfunction
                                            (Tcons
                                              (tptr (Tstruct _subset noattr))
                                              (Tcons tint Tnil)) tint
                                            cc_default))
                              ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
                               (Etempvar _u tint) :: nil))
                            (Sset _ufind (Etempvar _t'3 tint)))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'4)
                                (Evar _find (Tfunction
                                              (Tcons
                                                (tptr (Tstruct _subset noattr))
                                                (Tcons tint Tnil)) tint
                                              cc_default))
                                ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
                                 (Etempvar _v tint) :: nil))
                              (Sset _vfind (Etempvar _t'4 tint)))
                            (Sifthenelse (Ebinop One (Etempvar _ufind tint)
                                           (Etempvar _vfind tint) tint)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'8
                                    (Efield
                                      (Ederef
                                        (Etempvar _graph__1 (tptr (Tstruct _graph noattr)))
                                        (Tstruct _graph noattr)) _edge_list
                                      (tptr (Tstruct _edge noattr))))
                                  (Sset _w
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'8 (tptr (Tstruct _edge noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _edge noattr)))
                                        (Tstruct _edge noattr)) _weight tint)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'6
                                      (Efield
                                        (Ederef
                                          (Etempvar _mst (tptr (Tstruct _graph noattr)))
                                          (Tstruct _graph noattr)) _edge_list
                                        (tptr (Tstruct _edge noattr))))
                                    (Ssequence
                                      (Sset _t'7
                                        (Efield
                                          (Ederef
                                            (Etempvar _mst (tptr (Tstruct _graph noattr)))
                                            (Tstruct _graph noattr)) _E tint))
                                      (Scall None
                                        (Evar _fill_edge (Tfunction
                                                           (Tcons
                                                             (tptr (Tstruct _edge noattr))
                                                             (Tcons tint
                                                               (Tcons tint
                                                                 (Tcons tint
                                                                   Tnil))))
                                                           tvoid cc_default))
                                        ((Ebinop Oadd
                                           (Etempvar _t'6 (tptr (Tstruct _edge noattr)))
                                           (Etempvar _t'7 tint)
                                           (tptr (Tstruct _edge noattr))) ::
                                         (Etempvar _w tint) ::
                                         (Etempvar _u tint) ::
                                         (Etempvar _v tint) :: nil))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'5
                                        (Efield
                                          (Ederef
                                            (Etempvar _mst (tptr (Tstruct _graph noattr)))
                                            (Tstruct _graph noattr)) _E tint))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _mst (tptr (Tstruct _graph noattr)))
                                            (Tstruct _graph noattr)) _E tint)
                                        (Ebinop Oadd (Etempvar _t'5 tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint)))
                                    (Scall None
                                      (Evar _Union (Tfunction
                                                     (Tcons
                                                       (tptr (Tstruct _subset noattr))
                                                       (Tcons tint
                                                         (Tcons tint Tnil)))
                                                     tvoid cc_default))
                                      ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
                                       (Etempvar _u tint) ::
                                       (Etempvar _v tint) :: nil)))))
                              Sskip))))))
                  (Sset _i
                    (Ebinop Oadd (Etempvar _i tint)
                      (Econst_int (Int.repr 1) tint) tint))))
              (Ssequence
                (Scall None
                  (Evar _freeSet (Tfunction
                                   (Tcons (tptr (Tstruct _subset noattr))
                                     Tnil) tvoid cc_default))
                  ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
                   nil))
                (Sreturn (Some (Etempvar _mst (tptr (Tstruct _graph noattr)))))))))))))
|}.

Definition composites : list composite_definition :=
(Composite _subset Struct
   (Member_plain _parent tint :: Member_plain _rank tuint :: nil)
   noattr ::
 Composite _edge Struct
   (Member_plain _weight tint :: Member_plain _src tint ::
    Member_plain _dst tint :: nil)
   noattr ::
 Composite _graph Struct
   (Member_plain _V tint :: Member_plain _E tint ::
    Member_plain _edge_list (tptr (Tstruct _edge noattr)) :: nil)
   noattr :: nil).

Definition global_definitions : list (ident * globdef fundef type) :=
((___compcert_va_int32,
   Gfun(External (EF_runtime "__compcert_va_int32"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons (tptr tvoid) Tnil) tuint cc_default)) ::
 (___compcert_va_int64,
   Gfun(External (EF_runtime "__compcert_va_int64"
                   (mksignature (AST.Tlong :: nil) AST.Tlong cc_default))
     (Tcons (tptr tvoid) Tnil) tulong cc_default)) ::
 (___compcert_va_float64,
   Gfun(External (EF_runtime "__compcert_va_float64"
                   (mksignature (AST.Tlong :: nil) AST.Tfloat cc_default))
     (Tcons (tptr tvoid) Tnil) tdouble cc_default)) ::
 (___compcert_va_composite,
   Gfun(External (EF_runtime "__compcert_va_composite"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons (tptr tvoid) (Tcons tulong Tnil))
     (tptr tvoid) cc_default)) ::
 (___compcert_i64_dtos,
   Gfun(External (EF_runtime "__compcert_i64_dtos"
                   (mksignature (AST.Tfloat :: nil) AST.Tlong cc_default))
     (Tcons tdouble Tnil) tlong cc_default)) ::
 (___compcert_i64_dtou,
   Gfun(External (EF_runtime "__compcert_i64_dtou"
                   (mksignature (AST.Tfloat :: nil) AST.Tlong cc_default))
     (Tcons tdouble Tnil) tulong cc_default)) ::
 (___compcert_i64_stod,
   Gfun(External (EF_runtime "__compcert_i64_stod"
                   (mksignature (AST.Tlong :: nil) AST.Tfloat cc_default))
     (Tcons tlong Tnil) tdouble cc_default)) ::
 (___compcert_i64_utod,
   Gfun(External (EF_runtime "__compcert_i64_utod"
                   (mksignature (AST.Tlong :: nil) AST.Tfloat cc_default))
     (Tcons tulong Tnil) tdouble cc_default)) ::
 (___compcert_i64_stof,
   Gfun(External (EF_runtime "__compcert_i64_stof"
                   (mksignature (AST.Tlong :: nil) AST.Tsingle cc_default))
     (Tcons tlong Tnil) tfloat cc_default)) ::
 (___compcert_i64_utof,
   Gfun(External (EF_runtime "__compcert_i64_utof"
                   (mksignature (AST.Tlong :: nil) AST.Tsingle cc_default))
     (Tcons tulong Tnil) tfloat cc_default)) ::
 (___compcert_i64_sdiv,
   Gfun(External (EF_runtime "__compcert_i64_sdiv"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_udiv,
   Gfun(External (EF_runtime "__compcert_i64_udiv"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tulong Tnil)) tulong
     cc_default)) ::
 (___compcert_i64_smod,
   Gfun(External (EF_runtime "__compcert_i64_smod"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_umod,
   Gfun(External (EF_runtime "__compcert_i64_umod"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tulong Tnil)) tulong
     cc_default)) ::
 (___compcert_i64_shl,
   Gfun(External (EF_runtime "__compcert_i64_shl"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tint Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_shr,
   Gfun(External (EF_runtime "__compcert_i64_shr"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tint Tnil)) tulong
     cc_default)) ::
 (___compcert_i64_sar,
   Gfun(External (EF_runtime "__compcert_i64_sar"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tint Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_smulh,
   Gfun(External (EF_runtime "__compcert_i64_smulh"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___compcert_i64_umulh,
   Gfun(External (EF_runtime "__compcert_i64_umulh"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tulong (Tcons tulong Tnil)) tulong
     cc_default)) ::
 (___builtin_bswap64,
   Gfun(External (EF_builtin "__builtin_bswap64"
                   (mksignature (AST.Tlong :: nil) AST.Tlong cc_default))
     (Tcons tulong Tnil) tulong cc_default)) ::
 (___builtin_bswap,
   Gfun(External (EF_builtin "__builtin_bswap"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tuint cc_default)) ::
 (___builtin_bswap32,
   Gfun(External (EF_builtin "__builtin_bswap32"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tuint cc_default)) ::
 (___builtin_bswap16,
   Gfun(External (EF_builtin "__builtin_bswap16"
                   (mksignature (AST.Tint :: nil) AST.Tint16unsigned
                     cc_default)) (Tcons tushort Tnil) tushort cc_default)) ::
 (___builtin_clz,
   Gfun(External (EF_builtin "__builtin_clz"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_clzl,
   Gfun(External (EF_builtin "__builtin_clzl"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_clzll,
   Gfun(External (EF_builtin "__builtin_clzll"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_ctz,
   Gfun(External (EF_builtin "__builtin_ctz"
                   (mksignature (AST.Tint :: nil) AST.Tint cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_ctzl,
   Gfun(External (EF_builtin "__builtin_ctzl"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_ctzll,
   Gfun(External (EF_builtin "__builtin_ctzll"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_fabs,
   Gfun(External (EF_builtin "__builtin_fabs"
                   (mksignature (AST.Tfloat :: nil) AST.Tfloat cc_default))
     (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_fabsf,
   Gfun(External (EF_builtin "__builtin_fabsf"
                   (mksignature (AST.Tsingle :: nil) AST.Tsingle cc_default))
     (Tcons tfloat Tnil) tfloat cc_default)) ::
 (___builtin_fsqrt,
   Gfun(External (EF_builtin "__builtin_fsqrt"
                   (mksignature (AST.Tfloat :: nil) AST.Tfloat cc_default))
     (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_sqrt,
   Gfun(External (EF_builtin "__builtin_sqrt"
                   (mksignature (AST.Tfloat :: nil) AST.Tfloat cc_default))
     (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_memcpy_aligned,
   Gfun(External (EF_builtin "__builtin_memcpy_aligned"
                   (mksignature
                     (AST.Tlong :: AST.Tlong :: AST.Tlong :: AST.Tlong ::
                      nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid)
       (Tcons (tptr tvoid) (Tcons tulong (Tcons tulong Tnil)))) tvoid
     cc_default)) ::
 (___builtin_sel,
   Gfun(External (EF_builtin "__builtin_sel"
                   (mksignature (AST.Tint :: nil) AST.Tvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (Tcons tbool Tnil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot,
   Gfun(External (EF_builtin "__builtin_annot"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (Tcons (tptr tschar) Tnil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tint
                     cc_default)) (Tcons (tptr tschar) (Tcons tint Tnil))
     tint cc_default)) ::
 (___builtin_membar,
   Gfun(External (EF_builtin "__builtin_membar"
                   (mksignature nil AST.Tvoid cc_default)) Tnil tvoid
     cc_default)) ::
 (___builtin_va_start,
   Gfun(External (EF_builtin "__builtin_va_start"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (___builtin_va_arg,
   Gfun(External (EF_builtin "__builtin_va_arg"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tvoid
                     cc_default)) (Tcons (tptr tvoid) (Tcons tuint Tnil))
     tvoid cc_default)) ::
 (___builtin_va_copy,
   Gfun(External (EF_builtin "__builtin_va_copy"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tvoid
                     cc_default))
     (Tcons (tptr tvoid) (Tcons (tptr tvoid) Tnil)) tvoid cc_default)) ::
 (___builtin_va_end,
   Gfun(External (EF_builtin "__builtin_va_end"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (___builtin_unreachable,
   Gfun(External (EF_builtin "__builtin_unreachable"
                   (mksignature nil AST.Tvoid cc_default)) Tnil tvoid
     cc_default)) ::
 (___builtin_expect,
   Gfun(External (EF_builtin "__builtin_expect"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil) AST.Tlong
                     cc_default)) (Tcons tlong (Tcons tlong Tnil)) tlong
     cc_default)) ::
 (___builtin_fmax,
   Gfun(External (EF_builtin "__builtin_fmax"
                   (mksignature (AST.Tfloat :: AST.Tfloat :: nil) AST.Tfloat
                     cc_default)) (Tcons tdouble (Tcons tdouble Tnil))
     tdouble cc_default)) ::
 (___builtin_fmin,
   Gfun(External (EF_builtin "__builtin_fmin"
                   (mksignature (AST.Tfloat :: AST.Tfloat :: nil) AST.Tfloat
                     cc_default)) (Tcons tdouble (Tcons tdouble Tnil))
     tdouble cc_default)) ::
 (___builtin_fmadd,
   Gfun(External (EF_builtin "__builtin_fmadd"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fmsub,
   Gfun(External (EF_builtin "__builtin_fmsub"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fnmadd,
   Gfun(External (EF_builtin "__builtin_fnmadd"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fnmsub,
   Gfun(External (EF_builtin "__builtin_fnmsub"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     AST.Tfloat cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_read16_reversed,
   Gfun(External (EF_builtin "__builtin_read16_reversed"
                   (mksignature (AST.Tlong :: nil) AST.Tint16unsigned
                     cc_default)) (Tcons (tptr tushort) Tnil) tushort
     cc_default)) ::
 (___builtin_read32_reversed,
   Gfun(External (EF_builtin "__builtin_read32_reversed"
                   (mksignature (AST.Tlong :: nil) AST.Tint cc_default))
     (Tcons (tptr tuint) Tnil) tuint cc_default)) ::
 (___builtin_write16_reversed,
   Gfun(External (EF_builtin "__builtin_write16_reversed"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tvoid
                     cc_default)) (Tcons (tptr tushort) (Tcons tushort Tnil))
     tvoid cc_default)) ::
 (___builtin_write32_reversed,
   Gfun(External (EF_builtin "__builtin_write32_reversed"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tvoid
                     cc_default)) (Tcons (tptr tuint) (Tcons tuint Tnil))
     tvoid cc_default)) ::
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Tint :: nil) AST.Tvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (Tcons tint Tnil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (_find,
   Gfun(External (EF_external "find"
                   (mksignature (AST.Tlong :: AST.Tint :: nil) AST.Tint
                     cc_default))
     (Tcons (tptr (Tstruct _subset noattr)) (Tcons tint Tnil)) tint
     cc_default)) ::
 (_Union,
   Gfun(External (EF_external "Union"
                   (mksignature (AST.Tlong :: AST.Tint :: AST.Tint :: nil)
                     AST.Tvoid cc_default))
     (Tcons (tptr (Tstruct _subset noattr)) (Tcons tint (Tcons tint Tnil)))
     tvoid cc_default)) ::
 (_makeSet,
   Gfun(External (EF_external "makeSet"
                   (mksignature (AST.Tint :: nil) AST.Tlong cc_default))
     (Tcons tint Tnil) (tptr (Tstruct _subset noattr)) cc_default)) ::
 (_freeSet,
   Gfun(External (EF_external "freeSet"
                   (mksignature (AST.Tlong :: nil) AST.Tvoid cc_default))
     (Tcons (tptr (Tstruct _subset noattr)) Tnil) tvoid cc_default)) ::
 (_MAX_EDGES, Gvar v_MAX_EDGES) ::
 (_mallocK,
   Gfun(External (EF_external "mallocK"
                   (mksignature (AST.Tint :: nil) AST.Tlong cc_default))
     (Tcons tint Tnil) (tptr tvoid) cc_default)) ::
 (_free, Gfun(External EF_free (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (_init_empty_graph, Gfun(Internal f_init_empty_graph)) ::
 (_fill_edge, Gfun(Internal f_fill_edge)) ::
 (_exch, Gfun(Internal f_exch)) :: (_greater, Gfun(Internal f_greater)) ::
 (_sink, Gfun(Internal f_sink)) ::
 (_build_heap, Gfun(Internal f_build_heap)) ::
 (_heapsort, Gfun(Internal f_heapsort)) ::
 (_free_graph, Gfun(Internal f_free_graph)) ::
 (_kruskal, Gfun(Internal f_kruskal)) :: nil).

Definition public_idents : list ident :=
(_kruskal :: _free_graph :: _heapsort :: _build_heap :: _sink :: _greater ::
 _exch :: _fill_edge :: _init_empty_graph :: _free :: _mallocK :: _freeSet ::
 _makeSet :: _Union :: _find :: ___builtin_debug ::
 ___builtin_write32_reversed :: ___builtin_write16_reversed ::
 ___builtin_read32_reversed :: ___builtin_read16_reversed ::
 ___builtin_fnmsub :: ___builtin_fnmadd :: ___builtin_fmsub ::
 ___builtin_fmadd :: ___builtin_fmin :: ___builtin_fmax ::
 ___builtin_expect :: ___builtin_unreachable :: ___builtin_va_end ::
 ___builtin_va_copy :: ___builtin_va_arg :: ___builtin_va_start ::
 ___builtin_membar :: ___builtin_annot_intval :: ___builtin_annot ::
 ___builtin_sel :: ___builtin_memcpy_aligned :: ___builtin_sqrt ::
 ___builtin_fsqrt :: ___builtin_fabsf :: ___builtin_fabs ::
 ___builtin_ctzll :: ___builtin_ctzl :: ___builtin_ctz :: ___builtin_clzll ::
 ___builtin_clzl :: ___builtin_clz :: ___builtin_bswap16 ::
 ___builtin_bswap32 :: ___builtin_bswap :: ___builtin_bswap64 ::
 ___compcert_i64_umulh :: ___compcert_i64_smulh :: ___compcert_i64_sar ::
 ___compcert_i64_shr :: ___compcert_i64_shl :: ___compcert_i64_umod ::
 ___compcert_i64_smod :: ___compcert_i64_udiv :: ___compcert_i64_sdiv ::
 ___compcert_i64_utof :: ___compcert_i64_stof :: ___compcert_i64_utod ::
 ___compcert_i64_stod :: ___compcert_i64_dtou :: ___compcert_i64_dtos ::
 ___compcert_va_composite :: ___compcert_va_float64 ::
 ___compcert_va_int64 :: ___compcert_va_int32 :: nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


