function avgfid = THEORYavgfid_1G1B(constraint, jump_function, Gamma, F_new, gen_rate, cons_rate, purif_prob, purif_success, varargin)
%
%   This function calculates the analytical solution for the avg fidelity
%   in the steady state.
%
%   --- Inputs ---
%   constraint:     (str) we calculate the average fidelity given that we
%                   are in some specific state.
%                   'all': average over all states.
%                   'nonempty': average over all states with a link.
%                   x: (int) average over state x.
%                   'none': do not plot any average.
%   jump_function:  (function) jump function that takes as input two
%                   fidelities and maybe some extra arguments.
%                   The jump function must be input as
%                   fidCTMC_1G1B(@my_function, gen_rate, ...).
%                   Extra arguments must be provided as varargin.
%   Gamma:  (float) coherence rate (inverse of coherence time).
%   F_new:  (float) fidelity of newly generated links.
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

    alph = cons_rate + gen_rate * purif_prob;

    if strcmp(num2str(constraint),'0')
        avgfid = 0.25 + (F_new-0.25) * alph / (alph + Gamma);

    elseif isstring(jump_function)
        if strcmp(num2str(constraint),'nonempty') && strcmp(jump_function,"linear_upper_bound_alvaro")
            m = 4*(1-F_new)/3;
            n = (4*F_new-1)/3;
            gamma = alph / (alph + Gamma);
            avgfid = 0.25 + gamma * (m/4 + n - 1/4) / (1-m*gamma) ...
                    + gamma * (cons_rate + gen_rate*purif_prob*(1-purif_success)) ...
                        * (F_new - 1/4 - (m/4 + n - 1/4)/(1-m*gamma)) ...
                        / (cons_rate + gen_rate*purif_prob - gen_rate*purif_prob*purif_success*m*gamma);
            if cons_rate == 0 && purif_prob == 0
                avgfid = 0.25;
            end
    
        elseif strcmp(num2str(constraint),'nonempty') && strcmp(jump_function,"linear_lower_bound")
            m = 4*(F_new-1/4)/3;
            n = (1-F_new)/3;
            gamma = alph / (alph + Gamma);
            avgfid = 0.25 + gamma * (m/4 + n - 1/4) / (1-m*gamma) ...
                    + gamma * (cons_rate + gen_rate*purif_prob*(1-purif_success)) ...
                        * (F_new - 1/4 - (m/4 + n - 1/4)/(1-m*gamma)) ...
                        / (cons_rate + gen_rate*purif_prob - gen_rate*purif_prob*purif_success*m*gamma);
            if cons_rate == 0 && purif_prob == 0
                avgfid = 0.25;
            end

        elseif strcmp(num2str(constraint),'nonempty') && strcmp(jump_function,"linear_mn")
            m = varargin{1};
            n = varargin{2};
            avgfid = (0.25*Gamma + n*gen_rate*purif_prob*purif_success + ...
                      F_new * (cons_rate + gen_rate*purif_prob*(1-purif_success)) ) / ...
                      (Gamma + cons_rate + gen_rate*purif_prob*(1-purif_success*m));
            %gamma = alph / (alph + Gamma);
            %avgfid = 0.25 + gamma * (m/4 + n - 1/4) / (1-m*gamma) ...
            %        + gamma * (cons_rate + gen_rate*purif_prob*(1-purif_success)) ...
            %            * (F_new - 1/4 - (m/4 + n - 1/4)/(1-m*gamma)) ...
            %            / (cons_rate + gen_rate*purif_prob - gen_rate*purif_prob*purif_success*m*gamma);
            if cons_rate == 0 && purif_prob == 0
                avgfid = 0.25;
            end
        else
            error('Theory unknown for this jump function or constraint')
        end

    else
        if strcmp(num2str(constraint),'1') && strcmp(func2str(jump_function),'linear_jump')
            if varargin{1} == varargin{2} && varargin{2} == varargin{3} && varargin{2} == 1/3
                avgfid = 0.25 + (4*F_new + 2) * alph / (12 * (alph+Gamma)) ...
                            + (4*F_new - 1) * alph.^2 / (12 * (alph+Gamma).^2);
            else
                error('Theory unknown for this jump function')
            end
    
        elseif strcmp(num2str(constraint),'nonempty') && strcmp(func2str(jump_function),'linear_jump')
            if varargin{1} == varargin{2} && varargin{2} == varargin{3}
                a = varargin{1};
                gamma = alph / (alph + Gamma);
                avgfid = 0.25 + gamma * (a*F_new + 3/4 - 7*a/4) / (1-a*gamma) ...
                        + gamma * (cons_rate + gen_rate*purif_prob*(1-purif_success)) ...
                            * (F_new - 1/4 - (a*F_new + 3/4 - 7*a/4)/(1-a*gamma)) ...
                            / (cons_rate + gen_rate*purif_prob - gen_rate*purif_prob*purif_success*a*gamma);
                if cons_rate == 0 && purif_prob == 0
                    avgfid = 0.25;
                end
            else
                error('Theory unknown for this jump function')
            end
    
        else
            error('Theory unknown for this jump function or constraint')
        end
    end

end



















