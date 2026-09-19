:- module(proof_search,
    [ prove/2,
      depth_first_proof/2,
      breadth_first_proof/2,
      shortest_proof/2,
      bounded_proof/3,
      proof_cost/2
    ]).

:- use_module(library(lists)).
:- use_module(normalise, [canonical_form/2]).
:- use_module(ontology,
    [ rule/2,
      rule/3,
      equivalent/2,
      contradicts/2,
      relation/3,
      implies/2,
      predicate_semantics/2,
      calls/2,
      directly_calls/2,
      depends_on/2,
      recursive/1,
      directly_recursive/1,
      mutually_recursive/2,
      examines_elements/1,
      concept/1,
      type/2,
      definition/2
    ]).

depth_first_proof(Claim, Proof) :- prove(Claim, Proof).

breadth_first_proof(Claim, Proof) :- shortest_proof(Claim, Proof).

bounded_proof(Claim, MaxDepth, Proof) :-
    canonical_form(Claim, Canonical),
    prove_(Canonical, [], Proof, 0, MaxDepth).

prove(Claim, Proof) :-
    shortest_proof(Claim, Proof), !.

shortest_proof(Claim, Proof) :-
    canonical_form(Claim, Canonical),
    findall(P, prove_(Canonical, [], P, 0, 12), Proofs),
    Proofs \= [],
    sort_by_cost(Proofs, [Proof|_]).

sort_by_cost(Proofs, Sorted) :-
    map_list_to_pairs(proof_cost, Proofs, Pairs),
    keysort(Pairs, SortedPairs),
    pairs_values(SortedPairs, Sorted).

pairs_values([], []).
pairs_values([_-V|T], [V|R]) :- pairs_values(T, R).

prove_(not(C), Visited, proof(not(C), [Step]), Depth, MaxDepth) :-
    Depth =< MaxDepth,
    canonical_form(C, Canonical),
    (   contradicts(Canonical, Other), prove_(Other, Visited, Step, Depth, MaxDepth)
    ;   contradicts(Other, Canonical), prove_(Other, Visited, Step, Depth, MaxDepth)
    ).
prove_(and(A,B), Visited, proof(and(A,B), [PA,PB]), Depth, MaxDepth) :-
    D1 is Depth + 1,
    prove_(A, Visited, PA, D1, MaxDepth),
    prove_(B, Visited, PB, D1, MaxDepth).
prove_(or(A,_), Visited, proof(or(A,_), [PA]), Depth, MaxDepth) :-
    D1 is Depth + 1,
    prove_(A, Visited, PA, D1, MaxDepth).
prove_(or(_,B), Visited, proof(or(_,B), [PB]), Depth, MaxDepth) :-
    D1 is Depth + 1,
    prove_(B, Visited, PB, D1, MaxDepth).
prove_(Claim, _, proof(Claim, [Fact]), _, _) :-
    known_fact(Claim, Fact).
prove_(Claim, Visited, proof(Claim, [equivalent(Claim,EqProof)]), Depth, MaxDepth) :-
    \+ memberchk(Claim, Visited),
    D1 is Depth + 1,
    (equivalent(Claim, Eq) ; equivalent(Eq, Claim)),
    prove_(Eq, [Claim|Visited], EqProof, D1, MaxDepth).
prove_(Claim, Visited, proof(Claim, [rule(Name,BodyProofs)]), Depth, MaxDepth) :-
    Depth =< MaxDepth,
    \+ memberchk(Claim, Visited),
    ( rule(Name, Head, Body)
    ; Name = anonymous, rule(Head, Body)
    ),
    copy_term(Head-Body, Head1-Body1),
    canonical_form(Head1, CanonicalHead),
    CanonicalHead = Claim,
    D1 is Depth + 1,
    prove_all(Body1, [Claim|Visited], BodyProofs, D1, MaxDepth).

prove_all([], _, [], _, _).
prove_all([H|T], Visited, [PH|PT], Depth, MaxDepth) :-
    prove_(H, Visited, PH, Depth, MaxDepth),
    prove_all(T, Visited, PT, Depth, MaxDepth).

known_fact(Claim, fact(Claim)) :-
    call_fact(Claim), !.

call_fact(Claim) :-
    callable(Claim),
    functor(Claim, F, A),
    F \= not,
    current_predicate(ontology:F/A),
    catch(call(ontology:Claim), _, fail).

proof_cost(Proof, Cost) :-
    proof_cost_(Proof, Cost).

proof_cost_(proof(_, Steps), Cost) :-
    maplist(proof_cost_step, Steps, Costs),
    sum_list(Costs, Cost0),
    Cost is Cost0 + 1.
proof_cost_step(rule(_, BodyProofs), Cost) :-
    maplist(proof_cost_, BodyProofs, Costs),
    sum_list(Costs, Sum),
    Cost is Sum + 1.
proof_cost_step(equivalent(_, P), Cost) :-
    proof_cost_(P, C0),
    Cost is C0 + 1.
proof_cost_step(proof(_, _), Cost) :-
    proof_cost_(proof(_, []), Base),
    Cost is Base + 1.
proof_cost_step(_, 1).
