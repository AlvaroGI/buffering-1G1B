%% Inputs
close all
clc

% Gen/cons/purif rates
gen_rate_vec = [1, 1, 1, 1, 1, 1, 1.7];
cons_rate_vec = [0, 0.5, 0.5, 0.5, 1, 1, 0.8];
purif_prob_vec = [0, 0, 0.5, 1, 0.5, 1, 0.35];
purif_success_vec = [0, 0, 1, 1, 1, 0.5, 0.75];
Gamma_vec = [1/2, 1/2, 1/5, 1/2, 1/3, 1/10, 1/6];

% Newly generated state
% (Bell diagonal with elements F_new, B_new, C_new, D_new)
% (The basis elements are (phi+, psi+, psi-, phi-))
F_new_vec = [0.5, 0.6, 0.7, 0.8, 0.9, 0.85, 0.97];
B_new_vec = [0.5, 0.2, 0.1, 0.1, 0.0, 0.05, 0.01];
C_new_vec = [0  , 0.2, 0.1, 0.0, 0.0, 0.05, 0.01];
D_new_vec = [0  , 0.0, 0.1, 0.1, 0.1, 0.05, 0.01];

% Jump (aF + b)
jump_parameters = 'upper_bound'; % 'lower_bound' or 'upper_bound' are 
                                 % the linear bounds for bilocal Cliffords

% Average
constraint = 'nonempty';

% Numerical
sim_time = 10;
N_samples = 100;
randomseed = 2;
trans_method = 'natural';

% Plot
paper_formatting = false;

%% CALCULATIONS

% Analytical jump

F_avg_vec = zeros(1,length(gen_rate_vec));
F_2stderr_vec = zeros(1,length(gen_rate_vec));
F_avg_theory_vec = zeros(1,length(gen_rate_vec));

for ii = 1:length(gen_rate_vec)
    disp([num2str(ii),'/',num2str(length(gen_rate_vec))])
    gen_rate = gen_rate_vec(ii);
    cons_rate = cons_rate_vec(ii);
    purif_prob = purif_prob_vec(ii);
    purif_success = purif_success_vec(ii);
    Gamma = Gamma_vec(ii);
    F_new = F_new_vec(ii);
    B_new = B_new_vec(ii);
    C_new = C_new_vec(ii);
    D_new = D_new_vec(ii);
    % Theory jump parameters
    if ~strcmp(jump_parameters,'lower_bound')
        % Theory
        a = 4*F_new/3 - 1/3;
        b = (1-F_new)/3;
    elseif ~strcmp(jump_parameters,'upper_bound')
        lambda_min = min([B_new,C_new,D_new]);
        Fstar = (2*F_new - 1 + sqrt( (2*F_new-1)^2 - ...
                    2*lambda_min*(1-2*F_new-2*lambda_min) )) / ...
                    (2 * (2*F_new-1+2*lambda_min) );
        a = (Fstar-F_new)/(Fstar-1/4);
        b = Fstar * (F_new-1/4)/(Fstar-1/4);
    end
    % Simulation jump parameters
    a0 = b;
    a1 = a;
    a2 = 0;

    % SIMULATION
    simCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, ...
                    N_samples, randomseed, trans_method)
    
    % FIDELITY CALCULATION
    fidCTMC_1G1B(@linear_jump, Gamma, F_new, gen_rate, cons_rate, ...
                  purif_prob, purif_success, sim_time, N_samples, ...
                  randomseed, trans_method, a0, a1, a2)
              
    avgfidCTMC_1G1B(constraint,@linear_jump, Gamma, F_new, gen_rate, ...
                    cons_rate, purif_prob, purif_success, sim_time, ...
                    N_samples, randomseed, trans_method, a0, a1, a2)
    
    % LOAD DATA
    if ~strcmp(constraint,'none')
        filename = sprintf('data_fid/avgfid-%s-%s', ...
                            num2str(constraint), func2str(@linear_jump));
        varargin_array = [a0, a1, a2];
        for jj = 1:length(varargin_array)
            filename = strcat(filename,sprintf('-%.3f',varargin_array(jj)));
        end
        filename = strcat(filename,sprintf(['-G%.3f-F%.3f-g%.3f-c%.3f' ...
                            '-p%.3f-ps%.3f-t%.0f-N%.0f-rs%.0f-%s.mat'], ...
                            Gamma, F_new, gen_rate, cons_rate, purif_prob, ...
                            purif_success, sim_time, N_samples, ...
                            randomseed, trans_method));
       load(filename, 'F_avg', 'F_2stderr', 'data_time');
    end

    F_avg_vec(ii) = F_avg(end);
    F_2stderr_vec(ii) = F_2stderr(end);
    F_avg_theory_vec(ii) = THEORYavgfid_1G1B(constraint, "linear_mn", Gamma, ...
                F_new, gen_rate, cons_rate, purif_prob, purif_success, ...
                a, b);
end
disp(['PLEASE visually check if the steady state has been reached,' ...
        ' we have no steady state detection algorithm yet.'])

%% PLOT
% Plot specs
    % Colors
    orange = [0.8500 0.3250 0.0980];
    blue = [0 0.4470 0.7410];
    black = [0 0 0];

    % Figure
    fig = figure('Name','Avg. nonempty fidelity (theory vs simulation)');
    if paper_formatting
        x0 = 0;
        y0 = 0;
        width = 9; % cm
        height = 6; % cm
        set(gcf,'units','centimeters','position',[x0,y0,width,height])
    end

    % Labels
    if paper_formatting
        fontsize = 8;
    else
        fontsize = 14;
    end

    xlabel('Case', 'FontSize', fontsize)
    ylabel('Average nonempty fidelity', 'FontSize', fontsize)
    set(gca, 'FontSize', fontsize)

% Plot
hold on; plot(F_avg_theory_vec, 'LineWidth', 2, 'Color', black);
hold on; errorbar(F_avg_vec, F_2stderr_vec, 'LineWidth', 2, 'Color', orange);
legend('Theory (linear jump)', ...
        ['Simulation (after ',num2str(sim_time),' time steps)'], ...
        'Location', 'northwest')

















