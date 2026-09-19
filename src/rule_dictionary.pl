:- module(rule_dictionary,
    [ known_rule/2,
      known_rule/3
    ]).

:- use_module(ontology, [rule/2, rule/3]).

known_rule(Head, Body) :- rule(Head, Body).
known_rule(Name, Head, Body) :- rule(Name, Head, Body).
