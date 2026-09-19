:- module(rule_graph,
    [ find_rule_connection/3,
      find_rule_connection/4
    ]).

:- use_module(ontology,
    [ relation/3,
      rule/2,
      implies/2,
      equivalent/2,
      calls/2,
      directly_calls/2,
      depends_on/2
    ]).

find_rule_connection(A, B, Proof) :-
    find_rule_connection(A, B, Proof, [max_depth(20)]).

find_rule_connection(A, B, Proof, Options) :-
    option(max_depth(Max), Options, 20),
    bfs([[A, []]], B, [A], Max, RevProof),
    reverse(RevProof, Proof).

bfs([[Node, Proof]|_], Node, _, _, Proof).
bfs([[Node, Proof]|Queue], Goal, Visited, Max, Result) :-
    length(Proof, Depth),
    Depth < Max,
    findall([Next, [Step|Proof]],
        ( edge(Node, Next, Step),
          \+ memberchk(Next, Visited)
        ),
        NextNodes),
    pairs_keys(NextNodes, NewVisited),
    append(Visited, NewVisited, Visited1),
    append(Queue, NextNodes, Queue1),
    bfs(Queue1, Goal, Visited1, Max, Result).

pairs_keys([], []).
pairs_keys([[K,_]|T], [K|R]) :- pairs_keys(T, R).

edge(A, B, relation(A,R,B)) :- relation(A, R, B).
edge(A, B, rule(A,B)) :- rule(A, Body), member(B, Body).
edge(A, B, implies(A,B)) :- implies(A, B).
edge(A, B, equivalent(A,B)) :- equivalent(A, B).
edge(A, B, equivalent(B,A)) :- equivalent(B, A).
edge(A, B, calls(A,B)) :- calls(A, B).
edge(A, B, directly_calls(A,B)) :- directly_calls(A, B).
edge(A, B, depends_on(A,B)) :- depends_on(A, B).
