%% Inputs
close all
clc

% Gen/cons/purif rates
gen_rate = 1;
cons_rate = 0.1;
purif_prob = 0;
    purif_prob_vec = linspace(0,1,50);
purif_success = 0.75;

% Jump
Gamma = 1/40;

F_new = 0.8;
jump_function = @linear_jump;
a0 = 1/3;
a1 = 1/3;
a2 = 1/3;

% Average
constraint = 'nonempty';

% Other
paper_formatting = true;
savefig = true;

%% PLOT VS PURIFICATION PROBABILITY

% Calculations
avgfid = zeros(1,length(purif_prob_vec));
availability = zeros(1,length(purif_prob_vec));
for ii = 1:length(purif_prob_vec)
    purif_prob = purif_prob_vec(ii);
    avgfid(ii) = THEORYavgfid_1G1B(constraint, jump_function, Gamma, F_new, ...
                gen_rate, cons_rate, purif_prob, purif_success, ...
                a0, a1, a2);
    availability(ii) = THEORYavailab_1G1B(gen_rate, cons_rate, ...
                            purif_prob, purif_success);
end

% Plot specs
    % Colors
    orange = [0.8500 0.3250 0.0980];
    blue = [0 0.4470 0.7410];
    black = [0 0 0];

    % Figure
    fig = figure('Name','Performance vs purif. probability q');
    if paper_formatting
        x0 = 0;
        y0 = 0;
        width = 10; % cm
        height = 6; % cm
        set(gcf,'units','centimeters','position',[x0,y0,width,height])
    end

    % Labels and line width
    if paper_formatting
        fontsize = 8;
        linewidth = 1;
    else
        fontsize = 14;
        linewidth = 2;
    end

    xlabel('Purification probability', 'FontSize', fontsize)

% Plot fidelity
yyaxis left
set(gca, 'ycolor', black, 'FontSize', fontsize, 'TickDir', 'out', ...
    'TickLength', [0.015, 0.025], 'LineWidth', linewidth)
plot(purif_prob_vec, avgfid, 'LineWidth', linewidth, 'Color', black); hold on;
plot([0,1],[F_new,F_new], '--', 'LineWidth', linewidth, 'Color', black); hold on;
ylabel('Avg. consumed fidelity', 'FontSize', fontsize)
ylim([0.6,0.9])

% Plot availability
yyaxis right
set(gca, 'ycolor', orange, 'FontSize', fontsize, 'TickDir', 'out');
plot(purif_prob_vec, availability, 'LineWidth', linewidth, 'Color', orange); hold on;
ylabel('Availability', 'FontSize', fontsize)
ylim([0.7,1])

% Save
if savefig
    if ~exist('figs', 'dir')
       mkdir('figs')
    end
    filename = sprintf('figs/avgfidANDavailab-%s-%s', ...
                        num2str(constraint), func2str(jump_function));
    varargin_array = [a0,a1,a2];
    for ii = 1:length(varargin_array)
        filename = strcat(filename,sprintf('-%.3f',varargin_array(ii)));
    end
    filename = strcat(filename,sprintf(['-G%.3f-F%.3f-g%.3f-c%.3f' ...
                        '-p%.3f-ps%.3f.pdf'], ...
                        Gamma, F_new, gen_rate, cons_rate, ...
                        purif_prob, purif_success));
    %saveas(fig,filename)
    %system(['pdfcrop ',filename,'.pdf ',filename,'.pdf']);
    set(fig,'Units','centimeters');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto',...
        'PaperUnits','centimeters','PaperSize',[pos(3)*1.05, pos(4)*1.05]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    print(fig,filename,'-dpdf')
end


%% CHECK STEADY STATE FOR ONE CASE
% Numerical inputs
sim_time = 10;
N_samples = 50;
randomseed = 2;
trans_method = 'natural';

    % SIMULATION
    simCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, ...
                    N_samples, randomseed, trans_method)
    
    % FIDELITY CALCULATION
    fidCTMC_1G1B(jump_function, Gamma, F_new, gen_rate, cons_rate, ...
                  purif_prob, purif_success, sim_time, N_samples, ...
                  randomseed, trans_method, a0, a1, a2)
              
    avgfidCTMC_1G1B(constraint,jump_function, Gamma, F_new, gen_rate, ...
                    cons_rate, purif_prob, purif_success, sim_time, ...
                    N_samples, randomseed, trans_method, a0, a1, a2)
    
    % PLOT FIDELITY TRACES
    plotfidCTMC_1G1B(constraint, jump_function, Gamma, F_new, gen_rate, ...
                        cons_rate, purif_prob, purif_success, sim_time, ...
                        N_samples, randomseed, trans_method, a0, a1, a2)
    disp(['PLEASE visually check if the steady state has been reached,' ...
            ' we have no steady state detection algorithm yet.'])




















