function plotfidCTMC_1G1B(constraint, jump_function, Gamma, F_new, gen_rate, cons_rate, purif_prob, purif_success, sim_time, N_samples, randomseed, trans_method, varargin)
%
%   This function plots the fidelity time traces of the CTMC_1G1B.
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
%   NOTE: we limit the maximum number of lines to the first 20 samples
%   to avoid a very data-heavy image:
max_samples_plot = min(N_samples,20);
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
       error('Fidelity data does not exist!')
    else
       load(filename, 'data_F', 'data_time');
    end

    % Check if average data exists
    if ~strcmp(constraint,'none')
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
                            
        if ~exist(filename, 'file')
            error('Avg data does not exist!')
        else
           load(filename, 'F_avg', 'F_2stderr', 'data_time');
        end
    end

%% PLOT
    % Plot specs
    line_transparency = 0.3;
    stderr_transparency = 0.2;
    avg_color = [0.8500 0.3250 0.0980]; % Orange
    theory_color = [0 0.4470 0.7410]; % Blue

    % Create figure
    f = figure('Name','Fidelity time traces');

    % Plot average
    if ~strcmp(constraint,'none')
        curve1 = F_avg + F_2stderr;
        curve2 = F_avg - F_2stderr;
        x2 = [data_time, fliplr(data_time)];
        inBetween = [curve1, fliplr(curve2)];
        fill(x2, inBetween, avg_color, 'EdgeColor', avg_color, ...
            'Facealph', stderr_transparency);
        hold on;
        plot(data_time, F_avg, 'Color', avg_color, 'LineWidth', 2);
    end

    % Plot theory (FOR LINEAR JUMP)
    alph = cons_rate + gen_rate * purif_prob;
    F_theory = zeros(1,length(data_time)) ...
                + THEORYavgfid_1G1B(constraint, jump_function, Gamma, ...
                F_new, gen_rate, cons_rate, purif_prob, purif_success, ...
                varargin{1}, varargin{2}, varargin{3});
    plot(data_time, F_theory, 'Color', theory_color, 'LineWidth', 2);
    hold on;

    % Plot time traces
    x = data_time;
    for i = 1:max_samples_plot
        y = data_F{i};
        % Plot (we use patch to be able to change line transparency)
        % (for more details see Vary Patch Object Transparency in
        % https://nl.mathworks.com/help/matlab/creating_plots...
        % /add-transparency-to-graphics-objects.html
        patch([x, NaN], [y; NaN], 'black', 'EdgeColor', 'black',...
                'Edgealph',line_transparency)
        %plot(x,y, 'Color', line_transparency*[1,1,1]);
        hold on;
    end

    % Plot limits
    xlim([0, sim_time]);
    ylim([0,1])

    % Labels
    legend('', 'Sample average', ...
            'Expected value in steady state (linear jump)')
    xlabel('Time (a.u.)')
    ylabel('Fidelity')

end



















