function [F_out, p] = DEJMPS(A1,B1,C1,D1,A2,B2,C2,D2)
% Computes the output fidelity and success probability of DEJMPS when the
% input states are Bell diagonal with diagonal entries [A1,B1,C1,D1] and
% [A2,B2,C2,D2]. The basis elements are (phi+, psi+, psi-, phi-).
%
% See Deutsch, D., Ekert, A., Jozsa, R., Macchiavello, C., Popescu, S.,
% & Sanpera, A. (1996). Quantum privacy amplification and the security of
% quantum cryptography over noisy channels. Physical review letters, 
% 77(13), 2818.
%
    p = (A1+C1)*(A2+C2) + (B1+D1)*(B2+D2);
    F_out = (A1*A2+C1*C2)/p;
end