:- module(sentence_parser, [parse_sentence/2]).

:- use_module(library(dcg/basics)).
:- use_module(library(apply)).

parse_sentence(Sentence, Semantics) :-
    string_lower(Sentence, Lower),
    split_string(Lower, " ", ".,!?", Tokens0),
    exclude(=(""), Tokens0, Tokens1),
    maplist(atom_string, Tokens2, Tokens1),
    maplist(number_word, Tokens2, Tokens),
    (   denial(Tokens, Positive)
    ->  phrase(sentence_semantics(Claim), Positive),
        Semantics = neg(Claim)
    ;   phrase(sentence_semantics(Semantics), Tokens)
    ), !.
parse_sentence(Sentence, ambiguous([claim(A, uses, B), claim(A, uses_with(B,C))])) :-
    string_lower(Sentence, Lower),
    split_string(Lower, " ", ".,!?", [A0,"uses",B0,"with",C0]),
    maplist(atom_string, [A,B,C], [A0,B0,C0]).
parse_sentence(Sentence, claim(subject(Sentence), unknown, unknown)).

% Digits are read as number words, so "2 lists" is "two lists".
number_word(T, W) :-
    nth1(N, [one,two,three,four,five,six,seven,eight,nine,ten], W),
    atom_number(T, N), !.
number_word(T, T).

% "X does not V ..." and "X doesn't V ..." deny "X Vs ...".
denial([S, does, not, V|Rest], [S, Vs|Rest]) :- third_person(V, Vs).
denial([S, 'doesn\'t', V|Rest], [S, Vs|Rest]) :- third_person(V, Vs).
denial([S, is, not|Rest], [S, is|Rest]).

third_person(V, Vs) :- atom_concat(_, s, V), atom_concat(V, es, Vs), !.
third_person(V, Vs) :- atom_concat(_, ch, V), atom_concat(V, es, Vs), !.
third_person(V, Vs) :- atom_concat(V, s, Vs).

sentence_semantics(claim(P, directly_calls, Q)) --> [P, directly, calls, Q].
sentence_semantics(claim(P, depends_on, Q)) --> [P, depends, on, Q].
sentence_semantics(claim(P, depends_on, Q)) --> [P, ultimately, depends, on, Q].
sentence_semantics(claim(P, depends_on, Q)) --> [P, eventually, calls, Q].
sentence_semantics(and(recursive(P), searches_list(P))) --> [P, recursively, searches, a, list].
sentence_semantics(claim(P, has_base_case, true)) --> [P, has, a, base, case].
sentence_semantics(claim(append, joins, two_lists)) --> [append, joins, two, lists].
