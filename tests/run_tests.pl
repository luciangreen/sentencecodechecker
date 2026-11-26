:- use_module(library(plunit)).

:- dynamic tests_dir/1.
:- initialization(main).

:- prolog_load_context(directory, Dir), assertz(tests_dir(Dir)).

main :-
    tests_dir(Dir),
    atomic_list_concat([Dir, '/test_reasoning.pl'], File),
    load_files([File]),
    run_tests,
    halt.
