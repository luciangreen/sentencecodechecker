:- initialization(main).

main :-
    load_files(['/home/runner/work/sentencecodechecker/sentencecodechecker/tests/test_reasoning.pl']),
    run_tests,
    halt.
