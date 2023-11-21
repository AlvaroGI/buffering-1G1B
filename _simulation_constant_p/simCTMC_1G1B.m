function simCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, N_samples, randomseed, trans_method)
%
% 
% This function simulates ...
%
%   --- Inputs ---
%   gen_rate:   (float) entanglement generation rate.
%   cons_rate:  (float) consumption rate.
%   purif_prob: (float) probability of performing purification immediately
%               after generation (otherwise link generated is discarded).
%   purif_success:  (float) probability of successful purification (if
%                   failed, both links are discarded).
%   sim_time:   (int) simulation time.
%   N_samples:  (int) number of samples.
%   randomseed: (int) random seed.
%   trans_method:   'natural' - we sample from exponential distributions
%                   the transition time to each possible state, and then we
%                   keep the fastest transition.
%                   '1exp' - we sample the transition time from an
%                   exponential distribution with rate equal to the sum of
%                   all rates and then calculate the state to which we
%                   transition using a Bernoulli. The probability of
%                   transitioning to state A is P(A) = rate_to_A /
%                   sum_of_all_rates.
%
%   --- Outputs (saved directly to a file) ---
%   data:   (cell array of dimension N_samples)
%           data{i} corresponds to sample i. The chain spends some time
%           T_j in state k, then jumps and spends some time T_jj in state
%           kk, and so on. The sum over all T_j is at least sim_time.
%           Each tuple of T_j and state k is stored in order in
%           data{i}(1,j) and data{i}(2,j), respectively.
%           State -1 is the empty state. State k is a state with a link
%           that has been purified k times.
%

%% INITIAL CHECKS
    % Check if data folder exists (otherwise, create)
    if ~exist('data_ctmc', 'dir')
       mkdir('data_ctmc')
    end

    % Check if N_samples and randomseed were provided
    if nargin < 4
        error('Not enough inputs')
    elseif nargin == 5
        N_samples = 100;
        randomseed = 2;
        trans_method = 'natural';
    elseif nargin == 6
        randomseed = 2;
        trans_method = 'natural';
    elseif nargin == 7
        trans_method = 'natural';
    end

    % Check if data exists
    filename = sprintf('data_ctmc/ctmc-g%.3f-c%.3f-p%.3f-ps%.3f-t%.0f-N%.0f-rs%.0f-%s.mat', ...
                        gen_rate, cons_rate, purif_prob, purif_success, ...
                        sim_time, N_samples, randomseed, trans_method);
    if exist(filename, 'file')
       disp('Data already exists!')
       return
    end
    
    % Check inputs
    mustBeGreaterThanOrEqual(purif_prob,0)
    mustBeLessThanOrEqual(purif_prob,1)
    mustBeGreaterThanOrEqual(purif_success,0)
    mustBeLessThanOrEqual(purif_success,1)
    mustBeInteger(N_samples)
    mustBeInteger(sim_time)
    mustBeInteger(randomseed)

    % Random seed
    rng(randomseed)

%% CALCULATIONS
    % Initialize data
    data = cell(N_samples, 1);

    % Run many samples
    for sample = 1:N_samples
        % Initialize variables
        state = -1;
        time = 0;
        timetrace_times = [];
        timetrace_states = [];

        % Run until sim_time is reached
        while time < sim_time
            % Find next transition (we have two equivalent methods)
            if strcmp(trans_method,'natural')
                if state == -1
                    % Time spent in this state
                    time_to_transition = exprnd(1 / gen_rate);
                    % New state
                    old_state = state;
                    state = 0;
                else
                    time_to_transition_fwd = exprnd(1 / (gen_rate * ...
                                              purif_prob * purif_success));
                    time_to_transition_bck = exprnd(1 / (cons_rate + ...
                               gen_rate * purif_prob * (1-purif_success)));
                    if time_to_transition_fwd < time_to_transition_bck
                        % Time spent in this state
                        time_to_transition = time_to_transition_fwd;
                        % New state
                        old_state = state;
                        state = old_state+1;
                    else
                        % Time spent in this state
                        time_to_transition = time_to_transition_bck;
                        % New state
                        old_state = state;
                        state = -1;
                    end
                end

            elseif strcmp(trans_method,'1exp')
                error('Transition method not implemented')
            else
                error('Transition method unknown')
            end
            
            % Update variables
            time = time + time_to_transition;
            timetrace_times = [timetrace_times, time_to_transition];
            timetrace_states = [timetrace_states, old_state];
        end

        % Save time traces
        data{sample} = [timetrace_times; timetrace_states];
    end

%% SAVE DATA
    
    % Save the data to the file
    save(filename, 'data');

return

















