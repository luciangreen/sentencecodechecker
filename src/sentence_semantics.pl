:- module(sentence_semantics,
    [ sentence_semantics/2,
      sentence_claims/2
    ]).

:- use_module(sentence_parser, [parse_sentence/2]).

sentence_semantics(Sentence, [subject(S), predicate(P), object(O)]) :-
    parse_sentence(Sentence, claim(S,P,O)).
sentence_semantics(Sentence, [subject(P), property(recursive), action(search), object(list)]) :-
    parse_sentence(Sentence, and(recursive(P), searches_list(P))).
sentence_semantics(Sentence, [ambiguous(Interpretations)]) :-
    parse_sentence(Sentence, ambiguous(Interpretations)).

sentence_claims(Sentence, Interpretations) :-
    parse_sentence(Sentence, ambiguous(Interpretations)), !.
sentence_claims(Sentence, [Claim]) :-
    parse_sentence(Sentence, Claim).
