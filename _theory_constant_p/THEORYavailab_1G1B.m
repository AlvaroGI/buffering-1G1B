function availability = THEORYavailab_1G1B(gen_rate, cons_rate, purif_prob, purif_success)
%
%   This function calculates the analytical solution for the availability
%   in the steady state.
%
%   --- Inputs ---
%   gen_rate:   (float) entanglement generation rate.
%   cons_rate:  (float) consumption rate.
%   purif_prob: (float) probability of performing purification immediately
%               after generation (otherwise link generated is discarded).
%   purif_success:  (float) probability of successful purification (if
%                   failed, both links are discarded).
%

%% INITIAL CHECKS

    % Check inputs
    mustBeGreaterThanOrEqual(purif_prob,0)
    mustBeLessThanOrEqual(purif_prob,1)
    mustBeGreaterThanOrEqual(purif_success,0)
    mustBeLessThanOrEqual(purif_success,1)

%% CALCULATION

    availability = gen_rate / (gen_rate + cons_rate ...
                    + gen_rate*purif_prob*(1-purif_success));

end



















