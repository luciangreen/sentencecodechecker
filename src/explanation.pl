:- module(explanation, [explain_result/2, proof_to_text/2]).

explain_result(correct(Proof), Text) :-
    proof_to_text(Proof, Explanation),
    format(string(Text), "The statement is supported: ~s", [Explanation]).
explain_result(incorrect(CounterProof), Text) :-
    proof_to_text(CounterProof, Explanation),
    format(string(Text), "The statement is incorrect: ~s", [Explanation]).
explain_result(unsupported(Missing), Text) :-
    format(string(Text), "The statement is unsupported: ~w", [Missing]).
explain_result(inconsistent(P1,P2), Text) :-
    proof_to_text(P1, For),
    proof_to_text(P2, Against),
    format(string(Text), "The statement is inconsistent. For: ~s Against: ~s", [For,Against]).
explain_result(ambiguous(Interpretations), Text) :-
    format(string(Text), "Ambiguous sentence: ~w", [Interpretations]).

proof_to_text(proof(not(Claim), Steps), Text) :-
    !,
    claim_to_text(Claim, ClaimText),
    steps_to_text(Steps, Reason),
    format(string(Text), "~s is contradicted because ~s", [ClaimText,Reason]).
proof_to_text(proof(Claim, Steps), Text) :-
    claim_to_text(Claim, ClaimText),
    steps_to_text(Steps, Reason),
    format(string(Text), "~s because ~s", [ClaimText,Reason]).

steps_to_text([], "there is no supporting evidence").
steps_to_text(Steps, Text) :-
    Steps \= [],
    maplist(step_to_text, Steps, Reasons),
    atomics_to_string(Reasons, " and ", Text).

step_to_text(fact(_), "it is recorded as a known fact").
step_to_text(rule(_, Proofs), Text) :-
    !,
    maplist(proof_to_text, Proofs, Explanations),
    ( Explanations = []
    -> Text = "a rule applies"
    ;  atomics_to_string(Explanations, " and ", Text)
    ).
step_to_text(equivalent(_, Proof), Text) :-
    !,
    proof_to_text(Proof, Explanation),
    format(string(Text), "an equivalent statement is supported because ~s", [Explanation]).
step_to_text(Proof, Text) :-
    Proof = proof(_, _),
    !,
    proof_to_text(Proof, Text).
step_to_text(Step, Text) :-
    term_string(Step, Text, [quoted(false)]).

claim_to_text(relation(Subject, concatenate, two_lists), Text) :-
    !,
    format(string(Text), "~w joins two lists", [Subject]).
claim_to_text(directly_calls(Caller, Callee), Text) :-
    !,
    format(string(Text), "~w directly calls ~w", [Caller,Callee]).
claim_to_text(depends_on(Caller, Callee), Text) :-
    !,
    format(string(Text), "~w depends on ~w", [Caller,Callee]).
claim_to_text(calls(Caller, Callee), Text) :-
    !,
    format(string(Text), "~w calls ~w", [Caller,Callee]).
claim_to_text(recursive(Predicate), Text) :-
    !,
    format(string(Text), "~w is recursive", [Predicate]).
claim_to_text(searches_list(Predicate), Text) :-
    !,
    format(string(Text), "~w searches a list", [Predicate]).
claim_to_text(base_case(Predicate), Text) :-
    !,
    format(string(Text), "~w has a base case", [Predicate]).
claim_to_text(and(Left, Right), Text) :-
    !,
    claim_to_text(Left, LeftText),
    claim_to_text(Right, RightText),
    format(string(Text), "~s and ~s", [LeftText,RightText]).
claim_to_text(Claim, Text) :-
    term_string(Claim, Text, [quoted(false)]).
