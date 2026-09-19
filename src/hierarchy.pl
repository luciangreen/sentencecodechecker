:- module(hierarchy, [expand_rule/2]).

:- use_module(ontology, [rule/2]).

expand_rule(Rule, Tree) :-
    expand_rule(Rule, [], Tree).

expand_rule(Rule, Visited, node(Rule, Children)) :-
    (   memberchk(Rule, Visited)
    ->  Children = [node(cycle(Rule), [])]
    ;   findall(ChildTree,
            ( rule(Rule, Body),
              member(Child, Body),
              expand_rule(Child, [Rule|Visited], ChildTree)
            ),
            Children0),
        (Children0 = [] -> Children = [] ; Children = Children0)
    ).
