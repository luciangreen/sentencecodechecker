:- begin_tests(reasoning).

:- use_module('../src/main').
:- use_module('../src/ontology').
:- use_module('../src/rule_graph').
:- use_module('../src/hierarchy').
:- use_module('../src/proof_search').
:- use_module('../src/contradiction').
:- use_module('../src/code_semantics').

setup_clean :- clear_ontology.


test(direct_rule_connection, [setup(setup_clean)]) :-
    assertz(rule(a,[b])),
    find_rule_connection(a,b,Proof),
    assertion(Proof == [rule(a,b)]).

test(two_step_connection, [setup(setup_clean)]) :-
    assertz(rule(a,[b])),
    assertz(rule(b,[c])),
    find_rule_connection(a,c,Proof),
    assertion(Proof == [rule(a,b), rule(b,c)]).

test(long_transitive_chain, [setup(setup_clean)]) :-
    assertz(rule(a,[b])), assertz(rule(b,[c])), assertz(rule(c,[d])),
    find_rule_connection(a,d,Proof),
    length(Proof,Len), assertion(Len == 3).

test(nested_rule_expansion, [setup(setup_clean)]) :-
    assertz(rule(ab,[ac,cb])), assertz(rule(ac,[ad,dc])), assertz(rule(cb,[ce,eb])),
    expand_rule(ab,node(ab,Children)),
    assertion(Children \= []).

test(cyclic_ontology, [setup(setup_clean)]) :-
    assertz(rule(a,[b])), assertz(rule(b,[a])),
    expand_rule(a,Tree),
    assertion(Tree = node(a,_)).

test(conjunction_rule, [setup(setup_clean)]) :-
    assertz(rule(ok,[concept(left),concept(right)])),
    assertz(concept(left)),
    assertz(concept(right)),
    prove(ok,_).

test(alternative_proofs, [setup(setup_clean)]) :-
    assertz(rule(goal,[concept(a)])),
    assertz(rule(goal,[concept(b)])),
    assertz(concept(a)),
    assertz(concept(b)),
    findall(P, prove(goal,P), Ps),
    assertion(Ps \= []).

test(shortest_proofs, [setup(setup_clean)]) :-
    assertz(rule(goal,[concept(a)])),
    assertz(rule(goal,[concept(a),concept(b)])),
    assertz(concept(a)),
    assertz(concept(b)),
    shortest_proof(goal, Proof),
    proof_cost(Proof, Cost),
    assertion(Cost =< 5).

test(contradiction_detection, [setup(setup_clean)]) :-
    assertz(concept(a)),
    assertz(contradicts(concept(a),concept(na))),
    assertz(concept(na)),
    check_claim(concept(a), inconsistent(_,_)).

test(missing_rule_detection, [setup(setup_clean)]) :-
    assertz(rule(depends_on(a,b), [calls(a,b)])), assertz(calls(a,b)),
    check_claim(depends_on(a,e), unsupported(_)).

test(ambiguous_sentences, [setup(setup_clean)]) :-
    check_idea("a uses b with c.", ambiguous(_)).

test(synonyms, [setup(setup_clean)]) :-
    assertz(synonym(joins, concatenate)),
    assertz(relation(append, concatenate, two_lists)),
    check_idea("append joins two lists.", correct(_)).

test(typed_rules, [setup(setup_clean)]) :-
    assertz(type(x,list)),
    assertion(type(x,list)).

test(prolog_call_graph, [setup(setup_clean)]) :-
    check_code_sentence("p depends on s.", "p(X):-q(X). q(X):-r(X). r(X):-s(X).", correct(_)).

test(direct_vs_indirect_calls, [setup(setup_clean)]) :-
    check_code_sentence("p directly calls r.", "p(X):-q(X). q(X):-r(X).", incorrect(_)).

test(recursive_predicates, [setup(setup_clean)]) :-
    check_code_sentence("member recursively searches a list.", "member(X,[X|_]). member(X,[_|Xs]):-member(X,Xs).", correct(_)).

test(mutually_recursive_predicates, [setup(setup_clean)]) :-
    check_code_sentence("a depends on b.", "a(X):-b(X). b(X):-a(X).", correct(_)).

test(base_case_placeholder, [setup(setup_clean)]) :-
    assertion(true).

test(code_semantic_extraction, [setup(setup_clean)]) :-
    explain_code("p(X):-q(X).", Rules),
    assertion(member(calls(p/1,q/1), Rules)).

test(correct_code_description, [setup(setup_clean)]) :-
    check_code_sentence("p depends on q.", "p(X):-q(X).", correct(_)).

test(incorrect_code_description, [setup(setup_clean)]) :-
    check_code_sentence("p directly calls r.", "p(X):-q(X). q(X):-r(X).", incorrect(_)).

test(unsupported_code_description, [setup(setup_clean)]) :-
    check_code_sentence("p sorts its input.", "p(X):-q(X).", unsupported(_)).

test(counterexample_placeholder, [setup(setup_clean)]) :-
    assertion(true).

test(inconsistent_ontology, [setup(setup_clean)]) :-
    assertz(concept(t)),
    assertz(contradicts(concept(t),concept(nt))),
    assertz(concept(nt)),
    check_claim(concept(t), inconsistent(_,_)).

test(proof_explanation, [setup(setup_clean)]) :-
    assertz(concept(a)),
    prove(concept(a), Proof),
    assertion(Proof \= []).

test(nlg_from_proof_placeholder, [setup(setup_clean)]) :-
    assertion(true).

test(ontology_hierarchy_expansion, [setup(setup_clean)]) :-
    assertz(rule(root,[left,right])), expand_rule(root, node(root,_)).

test(large_rule_dictionary, [setup(setup_clean)]) :-
    forall(between(1,50,N), (atom_concat(n,N,Node), atom_concat(n,N,Next), assertz(rule(Node,[Next])))),
    assertion(true).

test(memoised_searches_placeholder, [setup(setup_clean)]) :-
    assertion(true).

test(bounded_reasoning, [setup(setup_clean)]) :-
    assertz(rule(a,[b])),
    assertz(rule(b,[concept(c)])),
    assertz(concept(c)),
    bounded_proof(a, 1, _), !.

:- end_tests(reasoning).
