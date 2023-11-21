function fidCTMC_1G1B(jump_function, Gamma, F_new, gen_rate, cons_rate, purif_prob, purif_success, sim_time, N_samples, randomseed, trans_method, varargin)
%
%   This function calculates fidelity time traces from simulation data.
%
%   IMPORTANT: when there is a fidelity jump in the middle of a time step,
%   we apply decoherence for half the step, then jump, then decoherence
%   for half the step. This should not affect the resoults if the step
%   size (variable name: dt) is small enough.
%
%   --- Inputs ---
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
%   data_time:  (array) times at which we record the fidelities.
%   data_F: (cell array of dimension N_samples)
%           data_F{i} is an array with the fidelity at each recorded time,
%           corresponding to the i-th sample. The array is hztal: (1,x).
%           In the empty state, the fidelity is 0.
%

%% INITIAL CHECKS (RE DATA)
    % Check if data folder exists (otherwise, create)
    if ~exist('data_ctmc', 'dir')
       mkdir('data_ctmc')
    end

    % Check if N_samples and randomseed were provided
    if nargin < 7
        error('Not enough inputs')
    elseif nargin == 7
        N_samples = 100;
        randomseed = 2;
        trans_method = 'natural';
    elseif nargin == 8
        randomseed = 2;
        trans_method = 'natural';
    elseif nargin == 9
        trans_method = 'natural';
    end

    % Check inputs
    mustBeGreaterThanOrEqual(purif_prob,0)
    mustBeLessThanOrEqual(purif_prob,1)
    mustBeGreaterThanOrEqual(purif_success,0)
    mustBeLessThanOrEqual(purif_success,1)
    mustBeInteger(N_samples)
    mustBeInteger(sim_time)
    mustBeInteger(randomseed)

    % Check if data exists and load
    filename = sprintf(['data_ctmc/ctmc-g%.3f-c%.3f-p%.3f-ps%.3f-t%.0f' ...
                        '-N%.0f-rs%.0f-%s.mat'], ...
                        gen_rate, cons_rate, purif_prob, purif_success, ...
                        sim_time, N_samples, randomseed, trans_method);
    if ~exist(filename, 'file')
       error('Data does not exist!')
    else
       load(filename, 'data');
    end

%% INITIAL CHECKS (RE FIDELITY CALCULATION)
    % Check if data folder exists (otherwise, create)
    if ~exist('data_fid', 'dir')
       mkdir('data_fid')
    end

    % Check if data exists
    filename = sprintf('data_fid/fid-%s',func2str(jump_function));
    varargin_array = [];
    for ii = 1:length(varargin)
        filename = strcat(filename,sprintf('-%.3f',varargin{ii}));
        varargin_array = [varargin_array, varargin{ii}];
    end
    filename = strcat(filename,sprintf(['-G%.3f-F%.3f-g%.3f-c%.3f' ...
                        '-p%.3f-ps%.3f-t%.0f-N%.0f-rs%.0f-%s.mat'], ...
                        Gamma, F_new, gen_rate, cons_rate, purif_prob, ...
                        purif_success, sim_time, N_samples, ...
                        randomseed, trans_method));
                        
    if exist(filename, 'file')
        disp('Data already exists!')
        return
    end

%% CALCULATIONS
    % Take time step as 1/10 of the shortest time spent on any state
    interval_fraction = 100;
    dt = sim_time/interval_fraction;
    for sample = 1:N_samples
        dt = min([dt, min(data{sample}(1,:))/interval_fraction]);
    end
    total_steps = ceil(sim_time/dt);

    % Initialize data
    data_time = linspace(0,dt*total_steps,total_steps);
    data_F = cell(1, N_samples);
    data_state = cell(1, N_samples);

    for sample = 1:N_samples
        data_F{sample} = zeros(total_steps,1);
        current_time = 0;
        current_situation = 1;
        current_state = data{sample}(2,current_situation);
        next_deadline = data{sample}(1,current_situation);

        % Move forward in time
        for ii = 1:length(data_time)
            % If we change state
            if current_time >= next_deadline
                current_situation = current_situation + 1;
                prev_state = current_state;
                current_state = data{sample}(2,current_situation);
                next_deadline = next_deadline + data{sample}(1,current_situation);
                if current_state == -1
                    % No link
                    data_F{sample}(ii) = 0;
                elseif prev_state == -1 && current_state == 0
                    % Create new link and depolarize during dt/2
                    data_F{sample}(ii) = depolarize(F_new, Gamma, dt/2);
                else
                    % Depolarize during dt/2, jump, depolarize during dt/2
                    % ISSUE: WE KNOW THE EXACT TIME OF THE JUMP!!!
                    data_F{sample}(ii) = depolarize(data_F{sample}(ii-1), ...
                                                    Gamma, dt/2);
                    data_F{sample}(ii) = jump_function(data_F{sample}(ii), ...
                                                    F_new, varargin_array);
                    data_F{sample}(ii) = depolarize(data_F{sample}(ii), ...
                                                    Gamma, dt/2);
                end
            % If we remain in the same state
            else
                % Record data
                if current_state == -1
                    % No link
                    data_F{sample}(ii) = 0;
                else
                    % Decohere
                    data_F{sample}(ii) = depolarize(data_F{sample}(ii-1), ...
                                                    Gamma, dt);
                end

            end
            data_state{sample}(ii) = current_state;
            current_time = current_time + dt;
        end
    end
    %jump_function(F1,F2,varargin)
   
%% SAVE DATA
    % Save the data to the file
    % Should save fidelities and times
    save(filename, 'data_F', 'data_state', 'data_time');
    

return

















