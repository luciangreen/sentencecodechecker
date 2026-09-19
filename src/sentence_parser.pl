:- module(sentence_parser, [parse_sentence/2]).

:- use_module(library(dcg/basics)).

parse_sentence(Sentence, Semantics) :-
    string_lower(Sentence, Lower),
    split_string(Lower, " ", ".,!?", Tokens0),
    exclude(=(""), Tokens0, Tokens1),
    maplist(atom_string, Tokens, Tokens1),
    phrase(sentence_semantics(Semantics), Tokens), !.
parse_sentence(Sentence, ambiguous([claim(A, uses, B), claim(A, uses_with(B,C))])) :-
    string_lower(Sentence, Lower),
    split_string(Lower, " ", ".,!?", [A0,"uses",B0,"with",C0]),
    maplist(atom_string, [A,B,C], [A0,B0,C0]).
parse_sentence(Sentence, claim(subject(Sentence), unknown, unknown)).

sentence_semantics(claim(P, directly_calls, Q)) --> [P, directly, calls, Q].
sentence_semantics(claim(P, depends_on, Q)) --> [P, depends, on, Q].
sentence_semantics(claim(P, depends_on, Q)) --> [P, ultimately, depends, on, Q].
sentence_semantics(claim(P, depends_on, Q)) --> [P, eventually, calls, Q].
sentence_semantics(and(recursive(P), searches_list(P))) --> [P, recursively, searches, a, list].
sentence_semantics(claim(append, joins, two_lists)) --> [append, joins, two, lists].
