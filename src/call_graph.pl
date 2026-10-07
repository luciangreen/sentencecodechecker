:- module(call_graph,
    [ analyse_code_atom/1,
      analyse_code_file/1
    ]).

:- use_module(ontology,
    [ calls/2,
      directly_calls/2,
      recursive/1,
      directly_recursive/1,
      mutually_recursive/2,
      base_case/1
    ]).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(readutil)).

analyse_code_file(File) :-
    read_file_to_string(File, Source, []),
    analyse_code_atom(Source).

analyse_code_atom(Source) :-
    open_string(Source, Stream),
    read_terms(Stream, Terms),
    close(Stream),
    maplist(analyse_clause, Terms),
    derive_recursive_predicates,
    derive_base_cases(Terms).

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
          (P == Q -> assertz(directly_recursive(P)) ; true)
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
    findall(A-B, (reachable(A,B), reachable(B,A), A \= B), Pairs0),
    sort(Pairs0, Pairs),
    forall(member(A-B, Pairs), assertz(mutually_recursive(A,B))).

derive_recursive_predicates :-
    findall(P, reachable(P,P), Predicates0),
    sort(Predicates0, Predicates),
    forall(member(P, Predicates), assertz(recursive(P))),
    derive_mutual_recursion.

reachable(From, To) :-
    reachable_(From, To, []).

reachable_(From, To, _) :-
    calls(From, To).
reachable_(From, To, Visited) :-
    calls(From, Next),
    \+ memberchk(Next, Visited),
    reachable_(Next, To, [From|Visited]).

derive_base_cases(Terms) :-
    forall(( member(Clause, Terms),
             clause_predicate_calls(Clause, Predicate, Calls),
             recursive(Predicate),
             \+ (member(Dependency, Calls),
                 (Predicate == Dependency ; mutually_recursive(Predicate, Dependency)))
           ),
           assertz(base_case(Predicate))).

clause_predicate_calls((Head :- Body), Predicate, Calls) :-
    !,
    pred_id(Head, Predicate),
    body_calls(Body, BodyCalls),
    findall(Dependency, (member(Call, BodyCalls), pred_id(Call, Dependency)), Calls).
clause_predicate_calls(Fact, Predicate, []) :-
    pred_id(Fact, Predicate).
