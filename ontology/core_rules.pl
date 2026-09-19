rule(depends_on(A,B), [calls(A,B)]).
rule(depends_on(A,C), [calls(A,B), depends_on(B,C)]).

rule(searches_list(P), [predicate_semantics(P, traverses_list), examines_elements(P)]).

relation_property(is_a, transitive).
relation_property(equivalent, symmetric).
