function avgfidCTMC_1G1B(constraint,jump_function, Gamma, F_new, gen_rate, cons_rate, purif_prob, purif_success, sim_time, N_samples, randomseed, trans_method, varargin)
%
%   This function calculates the average fidelity over time (CTMC_1G1B).
%
%   --- Inputs ---
%   constraint:     (str) we calculate the average fidelity given that we
%                   are in some specific state.
%                   'all': average over all states.
%                   'nonempty': average over all states with a link.
%                   x: (int) average over state x.
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

%% INITIAL CHECKS
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
    if ~(strcmp(constraint,'all') || strcmp(constraint,'nonempty'))
        mustBeInteger(constraint)
    end

    % Check if data folder exists (otherwise, create)
    if ~exist('data_fid', 'dir')
       mkdir('data_fid')
    end

    % Check if fidelity data exists
    filename = sprintf('data_fid/fid-%s',func2str(jump_function));
    for ii = 1:length(varargin)
        filename = strcat(filename,sprintf('-%.3f',varargin{ii}));
    end
    filename = strcat(filename,sprintf(['-G%.3f-F%.3f-g%.3f-c%.3f' ...
                        '-p%.3f-ps%.3f-t%.0f-N%.0f-rs%.0f-%s.mat'], ...
                        Gamma, F_new, gen_rate, cons_rate, purif_prob, ...
                        purif_success, sim_time, N_samples, ...
                        randomseed, trans_method));
                        
    if ~exist(filename, 'file')
       error('Data does not exist!')
    else
       load(filename, 'data_F', 'data_state', 'data_time');
    end

    % Check if avg data exists
    filename = sprintf('data_fid/avgfid-%s-%s', ...
                        num2str(constraint), func2str(jump_function));
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

%% CALCULATION
    
    if strcmp(constraint,'all')
        F_avg = (sum(cat(2,data_F{:}),2)/N_samples).';
        F_2stderr = (2 * std(cat(2,data_F{:}),0,2) / sqrt(N_samples)).';

    elseif strcmp(constraint,'nonempty')
        F_avg = zeros(1,length(data_F{1}));
        F_2stderr = zeros(1,length(data_F{1}));
        for t = 1:length(data_F{1})
            F_samples = [];
            for sample = 1:N_samples
                if ~(data_state{sample}(t) == -1)
                    F_samples = [F_samples, data_F{sample}(t)];
                end
            end
            F_avg(t) = sum(F_samples)/length(F_samples);
            F_2stderr(t) = 2 * std(F_samples) / sqrt(length(F_samples));
        end

    else
        F_avg = zeros(1,length(data_F{1}));
        F_2stderr = zeros(1,length(data_F{1}));
        for t = 1:length(data_F{1})
            F_samples = [];
            for sample = 1:N_samples
                if data_state{sample}(t) == constraint
                    F_samples = [F_samples, data_F{sample}(t)];
                end
            end
            F_avg(t) = sum(F_samples)/length(F_samples);
            F_2stderr(t) = 2 * std(F_samples) / sqrt(length(F_samples));

           % if mod(t,500)==0; disp(length(F_samples)); disp(F_2stderr); end

        end

    end

%% SAVE DATA
    % Save the data to the file
    % Should save fidelities and times
    save(filename, 'F_avg', 'F_2stderr', 'data_time');

end



















