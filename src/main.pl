:- module(main,
    [ reason/4,
      check_sentence/2,
      check_idea/2,
      find_rule_connection/3,
      expand_rule/2,
      explain_code/2,
      check_code_sentence/3
    ]).

:- use_module(ontology).
:- use_module(rule_graph).
:- use_module(hierarchy).
:- use_module(proof_search).
:- use_module(contradiction).
:- use_module(sentence_parser).
:- use_module(sentence_semantics).
:- use_module(code_semantics).
:- use_module(explanation).

reason(Sentence, OntologyFile, _CodeDictionary, Result) :-
    clear_ontology,
    ( nonvar(OntologyFile), exists_file(OntologyFile) -> load_ontology(OntologyFile) ; true ),
    check_idea(Sentence, Result).

check_sentence(Sentence, Result) :-
    check_idea(Sentence, Result).

check_idea(Sentence, Result) :-
    sentence_claims(Sentence, Claims),
    ( Claims = [Only] -> check_single_claim(Only, Result)
    ; Result = ambiguous(Claims)
    ).

check_single_claim(claim(S,P,O), Result) :-
    claim_goal(claim(S,P,O), Goal),
    check_claim(Goal, Result).
check_single_claim(and(A,B), Result) :-
    check_claim(and(A,B), Result).
check_single_claim(Claim, Result) :-
    check_claim(Claim, Result).

claim_goal(claim(S, directly_calls, O), directly_calls(SA/1, OA/1)) :-
    !,
    as_atom(S, SA),
    as_atom(O, OA).
claim_goal(claim(S, depends_on, O), depends_on(SA/1, OA/1)) :-
    !,
    as_atom(S, SA),
    as_atom(O, OA).
claim_goal(claim(S, P, O), relation(S, P, O)).

as_atom(V, A) :- atom(V), !, A = V.
as_atom(V, A) :- string(V), !, atom_string(A, V).

load_defaults :-
    clear_ontology,
    load_if_exists('/home/runner/work/sentencecodechecker/sentencecodechecker/ontology/core_rules.pl'),
    load_if_exists('/home/runner/work/sentencecodechecker/sentencecodechecker/ontology/code_rules.pl'),
    load_if_exists('/home/runner/work/sentencecodechecker/sentencecodechecker/ontology/language_rules.pl').

load_if_exists(File) :-
    ( exists_file(File) -> load_ontology(File) ; true ).

main :-
    current_prolog_flag(argv, Argv0),
    normalize_argv(Argv0, Argv),
    ( Argv = [] -> true ; run_cli(Argv) ).

normalize_argv([], []).
normalize_argv(['--'|T], R) :- !, normalize_argv(T, R).
normalize_argv([H|T], [HS|R]) :-
    ( string(H) -> HS = H ; atom(H) -> atom_string(H, HS) ; term_string(H, HS) ),
    normalize_argv(T, R).

run_cli(["check", Sentence]) :-
    load_defaults,
    check_idea(Sentence, Result),
    writeln(Result).
run_cli(["connect", A, B]) :-
    load_defaults,
    find_rule_connection(A, B, Proof),
    writeln(Proof).
run_cli(["explain", CodeFile, Sentence]) :-
    code_semantics:check_code_sentence(Sentence, CodeFile, Result),
    explain_result(Result, Text),
    writeln(Text).
run_cli(_) :-
    writeln('Usage: check "sentence" | connect "a" "b" | explain file "sentence"').

:- initialization(main, program).
