:- module(provenance, [derived_with_provenance/3]).

derived_with_provenance(Conclusion, Proof, derived(Conclusion, proof(Proof))).
