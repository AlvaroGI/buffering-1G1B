%% Inputs
clear all
close all
clc

% Newly generated state
% (Bell diagonal with elements F_new, B_new, C_new, D_new)
% (The basis elements are (phi+, psi+, psi-, phi-))
F_new = 0.8;
%B_new = (1-F_new)/3;
%C_new = (1-F_new)/3;
%D_new = (1-F_new)/3;
B_new = (1-F_new)/2;
C_new = (1-F_new)/2;
D_new = 1e-10;

% Gen/cons/purif rates
gen_rate = 1;
cons_rate = 0.1;
purif_prob_vec = linspace(0,1,50);

% Decoherence
Gamma = 0.0;

% Average
constraint = 'nonempty';

% Other
paper_formatting = true;
savefig = true;
legendlocation = 'southeast';
ylims = [0.6, 1];
xlims = [0.6, 1];

%% CALCULATE LINEAR BOUNDS

% Plot specs
orange = [0.8500 0.3250 0.0980];
blue = [0 0.4470 0.7410];
black = [0 0 0];
cmap_fill = cividis;
cmap = cividis(3);

% Figure
fig = figure('Name','Operation regimes');
if paper_formatting
    x0 = 0;
    y0 = 0;
    width = 8; % cm
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

% Compute upper bound
    % Jump function
    lambda_min = min([B_new,C_new,D_new]);
    Fstar = (2*F_new - 1 + sqrt( (2*F_new-1)^2 - ...
                2*lambda_min*(1-2*F_new-2*lambda_min) )) / ...
                (2 * (2*F_new-1+2*lambda_min) );
    a_upp = 4*(1-F_new)/3;
    b_upp = (4*F_new-1)/3;
    %a_upp = (Fstar-F_new)/(Fstar-1/4); % Does not apply to every F_new
    %b_upp = Fstar * (F_new-1/4)/(Fstar-1/4); % Does not apply to every F_new
    %a_upp = (F_new - Fstar * (lambda_min + F_new)) / ...
    %        ((1-Fstar) * (lambda_min + F_new)); % Only applies to nontrivial bilocal Cliffords
    %b_upp = Fstar * lambda_min / ((1-Fstar)*(lambda_min + F_new)); % Only applies to nontrivial bilocal Cliffords
    
    % Success probability
    p_success_upper = F_new + max([B_new, C_new, D_new]);
    %p_success_upper = 2*Fstar/3 + 1/3; % Does not apply to all protocols
avgfid_upp = zeros(1,length(purif_prob_vec));
availability_upp = zeros(1,length(purif_prob_vec));
for ii = 1:length(purif_prob_vec)
    purif_prob = purif_prob_vec(ii);
    avgfid_upp(ii) = THEORYavgfid_1G1B(constraint, "linear_mn", ...
                Gamma, F_new, gen_rate, cons_rate, purif_prob, ...
                p_success_upper, a_upp, b_upp);
    availability_upp(ii) = THEORYavailab_1G1B(gen_rate, cons_rate, ...
                            purif_prob, p_success_upper);
end

% Compute lower bound
    % Jump function
    %a_low = 4*(F_new-1/4)/3;
    %b_low = (1-F_new)/3;
    lambda_max = max([B_new, C_new, D_new]);
    lambda_23 = B_new + C_new + D_new - lambda_max;
    Jmaxstar = ((4*lambda_max + 3*lambda_23 - 3)*Fstar - lambda_max) / ...
               ((4*lambda_23 - 2)*Fstar - lambda_23 - 1);
    a_low = (Jmaxstar - (F_new + lambda_min)/2) / (Fstar - 0.25); % Only applies to nontrivial bilocal Cliffords
    b_low = (F_new + lambda_min)/2 - a_low/4; % Only applies to nontrivial bilocal Cliffords
    % Success probability
    p_success_lower = 0.5;
avgfid_low = zeros(1,length(purif_prob_vec));
availability_low = zeros(1,length(purif_prob_vec));
for ii = 1:length(purif_prob_vec)
    purif_prob = purif_prob_vec(ii);
    avgfid_low(ii) = THEORYavgfid_1G1B(constraint, "linear_mn", ...
                Gamma, F_new, gen_rate, cons_rate, purif_prob, ...
                p_success_lower, a_low, b_low);
    availability_low(ii) = THEORYavailab_1G1B(gen_rate, cons_rate, ...
                            purif_prob, p_success_lower);
end


%% FORBIDDEN - AVAILABILITY UPPER BOUND (any protocol, q=0, p=1)
max_availability = THEORYavailab_1G1B(gen_rate, cons_rate, 0, 1);

% Fill forbidden area
fill([max_availability,max_availability,1,1], [0,1,1,0], black, ...
     'LineStyle','none', 'Facealph', 0.4, 'HandleVisibility', 'off');

% Stripes
number_lines = 100;
[dotsX,dotsY] = ndgrid(linspace(max_availability, max_availability+1, ...
                                number_lines), ...
                       linspace(0, 1, number_lines));
for i = -size(dotsX,1):size(dotsX,1)
    plot(diag(dotsX,i), diag(dotsY,i), '-', 'color', [1,1,1,0.8], ...
         'LineWidth', 1, 'HandleVisibility', 'off');hold on
end

hold on;



%% PLOT LINEAR BOUNDS

% Upper bound
color = cmap(1,:);
plot(availability_upp, avgfid_upp, 'LineWidth', linewidth, 'Color', ...
        color, 'DisplayName', "Upper bound"); hold on;
scatter([availability_upp(end)], [avgfid_upp(end)], ...
         20, color, 'filled', 'HandleVisibility', 'off'); hold on;
textx = availability_upp(end)-0.035;%+0.012;
texty = 1.01*avgfid_upp(end)-0.03;%+0.01;
patch([textx-0.002, textx-0.002, textx+0.027, textx+0.027], ...
      [texty-0.016, texty+0.012, texty+0.012, texty-0.016], ...
      color, 'EdgeColor', 'none', 'HandleVisibility', 'off');
text(textx, texty,'q=1', ...
        'Color',[1,1,1],'FontSize',fontsize)

% Extend upper bound
plot([0,availability_upp(end)], ...
     [avgfid_upp(end),avgfid_upp(end)], ...
     '-.', 'LineWidth', linewidth, 'Color', color, ...
     'HandleVisibility', 'off')

% Lower bound
color = cmap(end,:);
plot(availability_low, avgfid_low, 'LineWidth', linewidth, 'Color', ...
        color, 'DisplayName', "Lower bound"); hold on;
scatter([availability_low(end)], [avgfid_low(end)], ...
         20, color, 'filled', 'HandleVisibility', 'off'); hold on;
textx = availability_low(end)+0.00;
texty = 1.01*avgfid_low(end)-0.03;
patch([textx-0.002, textx-0.002, textx+0.027, textx+0.027], ...
      [texty-0.016, texty+0.012, texty+0.012, texty-0.016], ...
      color, 'EdgeColor', 'none', 'HandleVisibility', 'off');
text(textx, texty,'q=1', 'Color', [0,0,0],'FontSize',fontsize)

% Extend lower bound
plot([0,availability_low(end)], ...
     [avgfid_low(end),avgfid_low(end)], ...
     '-.', 'LineWidth', linewidth, 'Color', color, ...
     'HandleVisibility', 'off')

% Fill area between bounds
colormap(cmap_fill)
if p_success_upper > p_success_lower
    x_aux_fill1 = linspace(0,availability_upp(end),20);
    x_aux_fill2 = linspace(availability_low(end),0,20);
    x_fill = [x_aux_fill1, fliplr(availability_upp), ...
              availability_low, x_aux_fill2];
    y_fill = [x_aux_fill1*0 + avgfid_upp(end), fliplr(avgfid_upp), ...
              avgfid_low, x_aux_fill2*0 + avgfid_low(end)];
    fill(x_fill, y_fill, ...
         [zeros(length(x_aux_fill1),1); ...
          zeros(length(availability_upp),1); ...
          1+ones(length(availability_low),1); ...
          1+ones(length(x_aux_fill2),1)], ...
         'LineStyle','none', 'Facealph', 0.5, 'HandleVisibility', 'off');
end
%if p_success_upper == p_success_lower
%    x_aux_fill = [];
%    y_aux_fill = [];
%    y_fill = [avgfid_upp, fliplr(avgfid_low)];
%    x_fill = [availability_upp, fliplr(availability_low)];
%else
%    x_aux_fill = linspace(availability_low(end),availability_upp(end),10);
%    y_aux_fill = 0*x_aux_fill + avgfid_upp(end);
%    x_fill = [x_aux_fill, fliplr(availability_upp), availability_low];
%    y_fill = [y_aux_fill, fliplr(avgfid_upp), avgfid_low];
%end
%fill(x_fill, y_fill, ...
%     [zeros(length(x_aux_fill),1); ...
%      zeros(length(availability_upp),1); ...
%      1+ones(length(availability_low),1)], ...
%     'LineStyle','none', 'Facealph', 0.5, 'HandleVisibility', 'off');

% Baseline fidelity
plot([0,1], [F_new,F_new], ':', 'LineWidth', linewidth, ...
     'Color', black, 'HandleVisibility', 'off'); hold on;


%% q=0 dot
scatter([availability_upp(1)], [avgfid_upp(1)], ...
        20, cmap(1,:), 'filled', 'HandleVisibility', 'off'); hold on;

textx = availability_upp(1)+0.005;
texty = 1.02*avgfid_upp(1)+0.01;
patch([textx-0.002, textx-0.002, textx+0.027, textx+0.027], ...
      [texty-0.016, texty+0.012, texty+0.012, texty-0.016], ...
      cmap(1,:), ...
      'EdgeColor', 'none', 'HandleVisibility', 'off');
text(textx, texty, ...
    'q=0', 'Color', [1,1,1], 'FontSize', fontsize)



%% FORBIDDEN - AVAILABILITY LOWER BOUND (any protocol, q=1, p=0)
min_availability = THEORYavailab_1G1B(gen_rate, cons_rate, 1, 0);

% Fill forbidden area
fill([0,0,min_availability,min_availability], [0,1,1,0], black, ...
     'LineStyle','none', 'Facealph', 0.2, 'HandleVisibility', 'off');
hold on;


%% FORBIDDEN - AVG FIDELITY UPPER BOUND (best protocol, q=1, p=1)
% Upper bound for ANY protocol:
p_max = 1;
q_max = 1;
max_avgfid = THEORYavgfid_1G1B(constraint, "linear_mn", ...
                            Gamma, F_new, gen_rate, cons_rate, q_max, ...
                            p_max, 0, 1);

% Fill forbidden area
fill([0,max_availability,max_availability,0], ...
     [max_avgfid,max_avgfid,1,1], black, ...
     'LineStyle','none', 'Facealph', 0.4, 'DisplayName', 'Unattainable');
hold on;

% Stripes
number_lines = 100;
[dotsX,dotsY] = ndgrid(linspace(0, max_availability, ...
                                number_lines), ...
                       linspace(max_avgfid, max_avgfid+max_availability, number_lines));
for i = -size(dotsX,1):size(dotsX,1)
plot(diag(dotsX,i), diag(dotsY,i), '-', 'color', [1,1,1,0.8], ...
     'LineWidth', 1, 'HandleVisibility', 'off');hold on
end


%% REPLACEMENT (probability of purification = 1; probability of success = 1)
% Calculations
avgfid_repl = THEORYavgfid_1G1B(constraint, "linear_mn", Gamma, F_new, ...
            gen_rate, cons_rate, 1, 1, 0, F_new);
availab_repl = THEORYavailab_1G1B(gen_rate, cons_rate, 1, 1);
scatter(availab_repl, avgfid_repl, 50, 'pentagram', ...
        'MarkerEdgeColor', orange, 'MarkerFaceColor', orange, ...
        'DisplayName', 'Replacement'); hold on;



%% UPPER BOUND (p=1)
if false
    avgfid = zeros(1,length(purif_prob_vec));
    availability = zeros(1,length(purif_prob_vec));
    for ii = 1:length(purif_prob_vec)
        purif_prob = purif_prob_vec(ii);
        avgfid(ii) = THEORYavgfid_1G1B(constraint, jumps(1), Gamma, ...
                            F_new, gen_rate, cons_rate, purif_prob, 1);
        availability(ii) = THEORYavailab_1G1B(gen_rate, cons_rate, ...
                                purif_prob, 1);
    end
    
    % Plot fidelity
    color = cmap(1,:);
    plot(availability, avgfid, ':', 'LineWidth', linewidth, 'Color', ...
         color, 'DisplayName', labels(1)); hold on;
    scatter([availability(1), [avgfid(1),avgfid(end)], ...
            availability(end)], ...
            20, color, 'filled', 'HandleVisibility', 'off'); hold on;
    text(availability(end)-0.01, avgfid(end)+0.01, 'q=1','Color', ...
        cmap(jj,:),'FontSize',fontsize)
end



%% PLOT SPECS

% Axes
set(gca, 'ycolor', black, 'FontSize', fontsize, 'TickDir', 'out', ...
    'TickLength', [0.015, 0.025], 'LineWidth', linewidth)
ylabel('Avg. consumed fidelity', 'FontSize', fontsize)
xlabel('Availability', 'FontSize', fontsize)
xlim(xlims)
ylim(ylims)
legend('Location',legendlocation)

% Save
if savefig
    if ~exist('figs', 'dir')
       mkdir('figs')
    end
    filename = 'figs/FvsA-linearbounds';
    filename = strcat(filename,sprintf(['-G%.6f-F%.3f_%.3f_%.3f_%.3f-'...
                        'g%.3f-c%.3f-successupp%.3f-successlow%.3f.pdf'], ...
                        Gamma, F_new, B_new, C_new, D_new, ...
                        gen_rate, cons_rate, ...
                        p_success_upper, p_success_lower));
    %saveas(fig,filename)
    %system(['pdfcrop ',filename,'.pdf ',filename,'.pdf']);
    set(fig,'Units','centimeters');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto',...
        'PaperUnits','centimeters','PaperSize',[pos(3)*1.05, pos(4)*1.05]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    print(fig,filename,'-dpdf')
end




