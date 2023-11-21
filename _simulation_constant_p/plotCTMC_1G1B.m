function plotCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, N_samples, randomseed, trans_method)
%
%   This function plots the time traces of the CTMC_1G1B.
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
%   NOTE: we limit the maximum number of lines to the first 20 samples
%   to avoid a very data-heavy image:
max_samples_plot = min(N_samples,20);
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
    
    % Check inputs
    mustBeGreaterThanOrEqual(purif_prob,0)
    mustBeLessThanOrEqual(purif_prob,1)
    mustBeGreaterThanOrEqual(purif_success,0)
    mustBeLessThanOrEqual(purif_success,1)
    mustBeInteger(N_samples)
    mustBeInteger(sim_time)
    mustBeInteger(randomseed)

    % Check if data exists and load
    filename = sprintf('data_ctmc/ctmc-g%.3f-c%.3f-p%.3f-ps%.3f-t%.0f-N%.0f-rs%.0f-%s.mat', ...
                        gen_rate, cons_rate, purif_prob, purif_success, ...
                        sim_time, N_samples, randomseed, trans_method);
    if ~exist(filename, 'file')
       error('Data does not exist!')
    else
       load(filename, 'data');
    end

%% PLOT
    % Plot specs
    line_transparency = 0.3;

    % Create figure
    f = figure('Name','Time traces (states)');

    % Plot time traces
    for i = 1:max_samples_plot
        % Create x and y arrays
        x = 0;
        y = -1;
        for j = 1:length(data{i}(1,:))
            x = [x, x(end)+data{i}(1,j), x(end)+data{i}(1,j)];
            y = [y, y(end), data{i}(2,j)];
        end
        
        % Plot (we use patch to be able to change line transparency)
        % (for more details see Vary Patch Object Transparency in
        % https://nl.mathworks.com/help/matlab/creating_plots...
        % /add-transparency-to-graphics-objects.html
        patch([x,NaN], [y, NaN], 'black', 'EdgeColor', 'black',...
                'EdgeAlpha',line_transparency)
        %plot(x,y, 'Color', line_transparency*[1,1,1]);
        hold on;
    end

    % Plot limits
    xlim([0, sim_time]);
    maxvalue = 0;
    for sample = 1:N_samples
        maxvalue = max([maxvalue, max(data{sample}(2,:))]);
    end
    ylim([-1, maxvalue+1])

    % Labels
    xlabel('Time (a.u.)')
    ylabel('State')

end



















