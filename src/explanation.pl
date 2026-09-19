:- module(explanation, [explain_result/2]).

explain_result(correct(Proof), Text) :-
    format(string(Text), "The statement is supported: ~w", [Proof]).
explain_result(incorrect(CounterProof), Text) :-
    format(string(Text), "The statement is incorrect: ~w", [CounterProof]).
explain_result(unsupported(Missing), Text) :-
    format(string(Text), "The statement is unsupported: ~w", [Missing]).
explain_result(inconsistent(P1,P2), Text) :-
    format(string(Text), "The statement is inconsistent. For: ~w Against: ~w", [P1,P2]).
explain_result(ambiguous(Interpretations), Text) :-
    format(string(Text), "Ambiguous sentence: ~w", [Interpretations]).
