:- module(proof_minimise, [minimise_proof/2]).

:- use_module(proof_search, [shortest_proof/2]).

minimise_proof(Claim, Proof) :- shortest_proof(Claim, Proof).
