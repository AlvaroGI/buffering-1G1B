function F_final = depolarize(F_init,Gamma,Dt)
%
%   This function calculates fidelity after depolarizing noise.
%   F_final = 1/4 + (F_init - 1/4) * exp(-Gamma*Dt)
%
%   --- Inputs ---
%   F_init:  (float) initial fidelity.
%   Gamma:  (float) coherence rate (inverse of coherence time).
%   Dt:     (float) interval of time.
%
%   --- Outputs ---
%   F_final: (float) final fidelity.
%

%% INITIAL CHECKS
    % Check inputs
    mustBeGreaterThanOrEqual(F_init,0)
    mustBeLessThanOrEqual(F_init,1)

%% CALCULATE
    F_final = 1/4 + (F_init - 1/4) * exp(-Gamma*Dt);
    % Check output
    mustBeGreaterThanOrEqual(F_final,0)
    mustBeLessThanOrEqual(F_final,1)

end

