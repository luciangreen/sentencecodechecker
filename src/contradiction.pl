:- module(contradiction, [check_claim/2]).

:- use_module(proof_search, [prove/2]).
:- use_module(rule_graph, [find_rule_connection/3]).

check_claim(Claim, Result) :-
    ( prove(Claim, Proof) -> Provable = yes ; Provable = no ),
    ( prove(not(Claim), CounterProof) -> Disprovable = yes ; Disprovable = no ),
    classify(Claim, Provable, Proof, Disprovable, CounterProof, Result).

classify(_, yes, Proof, no, _, correct(Proof)).
classify(_, no, _, yes, CounterProof, incorrect(CounterProof)).
classify(Claim, no, _, no, _, unsupported(Missing)) :-
    missing_knowledge(Claim, Missing).
classify(_, yes, Proof, yes, CounterProof, inconsistent(Proof, CounterProof)).

missing_knowledge(depends_on(A,B), missing_connection(X,B)) :-
    find_rule_connection(A, X, _),
    X \= B,
    !.
missing_knowledge(Claim, missing_knowledge(Claim)).
