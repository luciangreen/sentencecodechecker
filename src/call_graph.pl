:- module(call_graph,
    [ analyse_code_atom/1,
      analyse_code_file/1
    ]).

:- use_module(ontology,
    [ calls/2,
      directly_calls/2,
      recursive/1,
      directly_recursive/1,
      mutually_recursive/2
    ]).

analyse_code_file(File) :-
    read_file_to_string(File, Source, []),
    analyse_code_atom(Source).

analyse_code_atom(Source) :-
    open_string(Source, Stream),
    read_terms(Stream, Terms),
    close(Stream),
    maplist(analyse_clause, Terms),
    derive_mutual_recursion.

read_terms(Stream, Terms) :-
    read_term(Stream, Term, []),
    ( Term == end_of_file -> Terms = []
    ; Terms = [Term|Rest],
      read_terms(Stream, Rest)
    ).

analyse_clause((Head :- Body)) :-
    !,
    pred_id(Head, P),
    body_calls(Body, Calls),
    forall(member(G, Calls),
        ( pred_id(G, Q),
          assertz(directly_calls(P,Q)),
          assertz(calls(P,Q)),
          (P == Q -> assertz(recursive(P)), assertz(directly_recursive(P)) ; true)
        )).
analyse_clause(Fact) :-
    pred_id(Fact, P),
    ( calls(P,_) -> true ; true ).

body_calls((A,B), Calls) :- !,
    body_calls(A, C1),
    body_calls(B, C2),
    append(C1, C2, Calls).
body_calls((A;B), Calls) :- !,
    body_calls(A, C1),
    body_calls(B, C2),
    append(C1, C2, Calls).
body_calls(Goal, [Goal]).

pred_id(Term, Name/Arity) :-
    callable(Term),
    functor(Term, Name, Arity).

derive_mutual_recursion :-
    forall((calls(A,B), calls(B,A), A \= B),
           assertz(mutually_recursive(A,B))).
