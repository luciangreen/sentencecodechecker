:- module(code_semantics,
    [ explain_code/2,
      check_code_sentence/3
    ]).

:- use_module(call_graph, [analyse_code_atom/1, analyse_code_file/1]).
:- use_module(ontology,
    [ recursive/1,
      calls/2,
      directly_calls/2,
      depends_on/2,
      predicate_semantics/2,
      examines_elements/1,
      relation/3,
      rule/2,
      clear_ontology/0
    ]).
:- use_module(contradiction, [check_claim/2]).
:- use_module(sentence_parser, [parse_sentence/2]).
:- use_module(proof_search, [prove/2]).

explain_code(Code, Rules) :-
    setup_call_cleanup(
        true,
        (   analyse(Code),
            findall(recursive(P), recursive(P), Rs1),
            findall(calls(P,Q), calls(P,Q), Rs2),
            findall(directly_calls(P,Q), directly_calls(P,Q), Rs3),
            append([Rs1,Rs2,Rs3], Rules)
        ),
        true).

analyse(Code) :-
    ( exists_file(Code) -> analyse_code_file(Code)
    ; analyse_code_atom(Code)
    ).

check_code_sentence(Sentence, Code, Result) :-
    clear_ontology,
    analyse(Code),
    assertz(rule(depends_on(A,B), [calls(A,B)])),
    assertz(rule(depends_on(A,C), [calls(A,B), depends_on(B,C)])),
    assertz(rule(searches_list(P), [predicate_semantics(P,traverses_list), examines_elements(P)])),
    assertz(predicate_semantics(member/2, traverses_list)),
    assertz(examines_elements(member/2)),
    parse_sentence(Sentence, Parsed),
    sentence_claim_to_goal(Parsed, Goal),
    classify_code_claim(Goal, Result).

sentence_claim_to_goal(claim(P, directly_calls, Q), directly_calls(PredP, PredQ)) :-
    as_atom(P, Ap), as_atom(Q, Aq),
    PredP = Ap/1,
    PredQ = Aq/1.
sentence_claim_to_goal(claim(P, depends_on, Q), depends_on(PredP, PredQ)) :-
    as_atom(P, Ap), as_atom(Q, Aq),
    PredP = Ap/1,
    PredQ = Aq/1.
sentence_claim_to_goal(and(recursive(P), searches_list(P)), and(recursive(Pred), searches_list(Pred))) :-
    as_atom(P, Ap), Pred = Ap/2.
sentence_claim_to_goal(Goal, Goal).

as_atom(V, A) :- atom(V), !, A = V.
as_atom(V, A) :- string(V), !, atom_string(A, V).

classify_code_claim(directly_calls(P,Q), incorrect(reason(indirect_dependency_not_direct_call,[P,Mid,Q]))) :-
    \+ directly_calls(P,Q),
    prove(depends_on(P,Q), _),
    calls(P, Mid),
    P \= Q,
    !.
classify_code_claim(Goal, Result) :-
    check_claim(Goal, Result).
