:- module(code_parser, [parse_code/2]).

parse_code(Code, terms(Terms)) :-
    open_string(Code, Stream),
    read_terms(Stream, Terms),
    close(Stream).

read_terms(Stream, Terms) :-
    read_term(Stream, Term, []),
    ( Term == end_of_file -> Terms = []
    ; Terms = [Term|Rest],
      read_terms(Stream, Rest)
    ).
