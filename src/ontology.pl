:- module(ontology,
    [ concept/1,
      relation/3,
      rule/2,
      rule/3,
      definition/2,
      implies/2,
      equivalent/2,
      contradicts/2,
      predicate_semantics/2,
      synonym/2,
      relation_property/2,
      type/2,
      calls/2,
      directly_calls/2,
      depends_on/2,
      recursive/1,
      directly_recursive/1,
      mutually_recursive/2,
      examines_elements/1,
      load_ontology/1,
      clear_ontology/0
    ]).

:- dynamic concept/1, relation/3, rule/2, rule/3, definition/2, implies/2,
           equivalent/2, contradicts/2, predicate_semantics/2, synonym/2,
           relation_property/2, type/2, calls/2, directly_calls/2,
           depends_on/2, recursive/1, directly_recursive/1, mutually_recursive/2,
           examines_elements/1.

load_ontology(File) :-
    exists_file(File),
    consult(File).

clear_ontology :-
    retractall(concept(_)),
    retractall(relation(_,_,_)),
    retractall(rule(_,_)),
    retractall(rule(_,_,_)),
    retractall(definition(_,_)),
    retractall(implies(_,_)),
    retractall(equivalent(_,_)),
    retractall(contradicts(_,_)),
    retractall(predicate_semantics(_,_)),
    retractall(synonym(_,_)),
    retractall(relation_property(_,_)),
    retractall(type(_,_)),
    retractall(calls(_,_)),
    retractall(directly_calls(_,_)),
    retractall(depends_on(_,_)),
    retractall(recursive(_)),
    retractall(directly_recursive(_)),
    retractall(mutually_recursive(_,_)),
    retractall(examines_elements(_)).
