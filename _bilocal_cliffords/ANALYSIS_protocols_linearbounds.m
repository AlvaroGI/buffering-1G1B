% In this file we check that the jump function of any bilocal Clifford
% protocol can be upper bounded by a linear jump function.
%
% We only consider bilocal Clifford protocols and we use the
% enumeration methods from Jansen2022. For simplicity, we assume:
%       - Good memory = Werner state,
%       - Bad memory = Werner state or (twirled) R-state;
% although we can use any Bell diagonal state in both memories.
% For each combination of input fidelities, we use the methods from
% Jansen2022 (code in Python) to generate all possible combinations of
% output fidelity and probability of success. This data is contained
% in data_protocols_*.mat.

%% INPUTS
clear all

bad_memory_state = 'Werner'; % Werner or R

dF = 0.01; % Increments in fidelity for the numerical comparison

% Other
paper_formatting = true;
savefig = true;

%% CHECK
progress_bar = waitbar(0,'Checking linear bounds...');

for F_new = 0.5:dF:1

    % Read data
    if strcmp(bad_memory_state,'Werner')
        load('data_protocols_Werner.mat');
    elseif strcmp(bad_memory_state,'R')
        load('data_protocols_WernerR.mat');
    elseif strcmp(bad_memory_state,'example')
        load('data_protocols_example.mat');
    end

    for F_good = 0.25:dF:1

        % Read output fidelities for every bilocal Clifford protocol
        fbad = sprintf('%.3f', F_new/10);
        fgood = sprintf('%.3f', F_good/10);
        variable_name = sprintf('protocols_F%s_F%s',fbad(3:end),fgood(3:end));
        eval(strcat('succprob_vec = ',variable_name,'(1,:);'));
        eval(strcat('Fout_vec = ',variable_name,'(2,:);'));
    
        % Find best and worst
        max_Fout = max(Fout_vec);
        min_Fout = min(Fout_vec);

        % Compare with values of the linear bounds
        upper = 4*(F_good-0.25)*(1-F_new)/3 + F_new;
        lower = 4*(F_good-0.25)*(F_new-0.25)/3 + 0.25;
        if max_Fout > upper+(1e-15)
            error(sprintf(['Linear upper bound failed at F_new=%.2f, ' ...
                           'F_good=%.2f'], F_new, F_good))
        end
        if min_Fout < lower-(1e-15)
            error(sprintf(['Linear lower bound failed at F_new=%.2f, ' ...
                           'F_good=%.2f'], F_new, F_good))
        end
    end

    if round(F_new,2) == F_new
        waitbar((F_new-0.5)*2,progress_bar,'Checking linear bounds...');
    end

end

close(progress_bar)


%% PLOT EXAMPLE

F_new = 0.8; % Fidelity of newly generated links

% Read data
if strcmp(bad_memory_state,'Werner')
    load('data_protocols_Werner.mat');
elseif strcmp(bad_memory_state,'R')
    load('data_protocols_WernerR.mat');
elseif strcmp(bad_memory_state,'example')
    load('data_protocols_example.mat');
end
F_good_vec = [];
max_Fout_vec = [];
min_Fout_vec = [];
for F_good = 0.25:0.01:1
    % Read output fidelities for every bilocal Clifford protocol
    f1 = sprintf('%.3f', max(F_good,F_new)/10);
    f2 = sprintf('%.3f', min(F_good,F_new)/10);
    variable_name = sprintf('protocols_F%s_F%s',f2(3:end),f1(3:end));
    eval(strcat('succprob_vec = ',variable_name,'(1,:);'));
    eval(strcat('Fout_vec = ',variable_name,'(2,:);'));

    % Find best and worst
    F_good_vec = [F_good_vec, F_good];
    max_Fout_vec = [max_Fout_vec, max(Fout_vec)];
    min_Fout_vec = [min_Fout_vec, min(Fout_vec)];
end

% Delete other variables to avoid overheads
clear protocols*

% Plot specs
orange = [0.8500 0.3250 0.0980];
blue = [0 0.4470 0.7410];
black = [0 0 0];
cmap = copper(3);

% Figure
fig = figure('Name',sprintf(['Bilocal Clifford protocols,' ...
             ' Werner+%s, F_new = %.2f'], bad_memory_state, F_new));
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

% Plot
plot(F_good_vec, max_Fout_vec, ...
    'Color', blue, 'LineWidth', linewidth); hold on;
plot(F_good_vec, min_Fout_vec, ...
    'Color', blue, 'LineWidth', linewidth); hold on;

% Reference lines
plot([0,1], [0,1], '--', 'Color', black, 'LineWidth', linewidth)
plot([F_new,F_new],[0,1], '--', 'Color', black, 'LineWidth', linewidth)

% Fill area between bounds
fill([F_good_vec, fliplr(F_good_vec)], ...
     [max_Fout_vec, fliplr(min_Fout_vec)], ...
     blue, 'LineStyle','none', 'Facealph', 0.3);

% Linear bounds
upper = 4*(F_good_vec-0.25)*(1-F_new)/3 + F_new;
lower = 4*(F_good_vec-0.25)*(F_new-0.25)/3 + 0.25;
plot(F_good_vec, upper, 'Color', orange, 'LineWidth', linewidth); hold on;
plot(F_good_vec, lower, 'Color', orange, 'LineWidth', linewidth); hold on;

% Axes
set(gca, 'ycolor', black, 'FontSize', fontsize, 'TickDir', 'out', ...
    'TickLength', [0.015, 0.025], 'LineWidth', linewidth)
xlabel('Input fidelity (good memory)', 'FontSize', fontsize)
ylabel('Output fidelity', 'FontSize', fontsize)
xlim([0.25,1])
ylim([0.25,1])
legend('Upper/lower bounds', '', '', '', '', ...
       'Linear upper/lower bounds', 'Location','southeast')

% Save
if savefig
    if ~exist('figs', 'dir')
       mkdir('figs')
    end
    filename = sprintf('figs/linearboundsF_biCliff-%s%.2f.pdf', ...
                        bad_memory_state, F_new);
    set(fig,'Units','centimeters');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto',...
        'PaperUnits','centimeters','PaperSize',[pos(3)*1.05, pos(4)*1.05]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    print(fig,filename,'-dpdf')
end







