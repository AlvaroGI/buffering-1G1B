% In this file we calculate the output fidelity and success probability
% of all bilocal Clifford protocols, following the
% enumeration methods from Jansen2022. For simplicity, we assume:
%       - Good memory = Werner state,
%       - Bad memory = Werner state or (twirled) R-state;
% although we can use any Bell diagonal state in both memories.
% For a particular combination of input fidelities, we use the methods from
% Jansen2022 (code in Python) to generate all possible combinations of
% output fidelity and probability of success. This data is contained
% in data_protocols_*.mat.

%% INPUTS
clear all

F_good = 0.6; % Fidelity of good memory
bad_memory_state = 'R'; % Werner or R
F_new = 0.8; % Fidelity of bad memory

% Other
paper_formatting = true;
savefig = true;


%% PLOT

% Read data
if strcmp(bad_memory_state,'Werner')
    load('data_protocols_Werner.mat');
elseif strcmp(bad_memory_state,'R')
    load('data_protocols_WernerR.mat');
end
fbad = sprintf('%.3f', F_new/10);
fgood = sprintf('%.3f', F_good/10);
variable_name = sprintf('protocols_F%s_F%s',fbad(3:end),fgood(3:end));
eval(strcat('succprob_vec = ',variable_name,'(1,:);'));
eval(strcat('Fout_vec = ',variable_name,'(2,:);'));

% DEJMPS performance
% The elements of the Bell diagonal of the second state are [A2,B2,C2,D2],
% and the basis elements are (phi+, psi+, psi-, phi-).
if strcmp(bad_memory_state,'Werner')
    A2 = F_new;
    B2 = (1-F_new)/3;
    C2 = (1-F_new)/3;
    D2 = (1-F_new)/3;
elseif strcmp(bad_memory_state,'R')
    A2 = F_new;
    B2 = (1-F_new)/2;
    C2 = (1-F_new)/2;
    D2 = 0;
end
A1 = F_good;
B1 = (1-F_good)/3;
C1 = (1-F_good)/3;
D1 = (1-F_good)/3;
[Fout_DEJMPS, succ_prob_DEJMPS] = DEJMPS(A1,B1,C1,D1,A2,B2,C2,D2);

% Delete other variables to avoid overheads
clear protocols*

% Plot specs
orange = [0.8500 0.3250 0.0980];
blue = [0 0.4470 0.7410];
black = [0 0 0];
cmap = copper(3);

% Figure
fig = figure('Name',sprintf(['Bilocal Clifford protocols,' ...
             ' input fidelities %.2f and %.2f'], F_good, F_new));
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
    markersize = 20;
else
    fontsize = 14;
    linewidth = 2;
    markersize = 80;
end

% Plot
scatter(Fout_vec, succprob_vec, markersize, '^',  ...
        'MarkerEdgeColor', black, 'MarkerFaceColor', black); hold on;
scatter(Fout_DEJMPS, succ_prob_DEJMPS, markersize, 'v', ...
        'MarkerEdgeColor', orange, 'MarkerFaceColor', orange); hold on;
plot([F_new,F_new], [0,1], '--', 'Color', black, 'LineWidth', linewidth)

% Axes
set(gca, 'ycolor', black, 'FontSize', fontsize, 'TickDir', 'out', ...
    'TickLength', [0.015, 0.025], 'LineWidth', linewidth)
xlabel('Output fidelity', 'FontSize', fontsize)
ylabel('Success probability', 'FontSize', fontsize)
xlim_up = floor(max(Fout_vec)+0.02) ...
          + ceil( (max(Fout_vec)+0.02-floor(max(Fout_vec)+0.02))/0.05) * 0.05;
xlim_low = floor(min(Fout_vec)-0.02) ...
           + floor( (min(Fout_vec)-0.02-floor(min(Fout_vec)-0.02))/0.05) * 0.05;
ylim_up = floor(max(succprob_vec)+0.02) ...
          + ceil( (max(succprob_vec)+0.02-floor(max(succprob_vec)+0.02))/0.05) * 0.05;
ylim_low = floor(min(succprob_vec)-0.02) ...
           + floor( (min(succprob_vec)-0.02-floor(min(succprob_vec)-0.02))/0.05) * 0.05;
xlim([xlim_low,xlim_up])
ylim([ylim_low,ylim_up])
legend('Bilocal Clifford','DEJMPS','F_{new}','Location','southwest')

% Save
if savefig
    if ~exist('figs', 'dir')
       mkdir('figs')
    end
    filename = sprintf('figs/FvsP_biCliff-Werner%.2f-%s%.2f.pdf', ...
                        F_good, bad_memory_state, F_new);
    set(fig,'Units','centimeters');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto',...
        'PaperUnits','centimeters','PaperSize',[pos(3)*1.05, pos(4)*1.05]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    print(fig,filename,'-dpdf')
end

