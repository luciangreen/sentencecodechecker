:- module(normalise, [canonical_form/2]).

:- use_module(ontology, [synonym/2]).

canonical_form(Expression, Canonical) :-
    (   var(Expression)
    ->  Canonical = Expression
    ;   atomic(Expression)
    ->  canonical_atomic(Expression, Canonical)
    ;   Expression =.. [F|Args],
        canonical_atomic(F, CF),
        maplist(canonical_form, Args, CArgs),
        Canonical =.. [CF|CArgs]
    ).

canonical_atomic(A, C) :-
    ( synonym(A, S) -> canonical_atomic(S, C)
    ; C = A
    ).
