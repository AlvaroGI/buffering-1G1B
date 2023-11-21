%% Inputs

% Gen/cons/purif rates
gen_rate = 1;
cons_rate = 0.2;
purif_prob = 1;
purif_success = 1;

% Jump
Gamma = 1/20;

F_new = 0.8;
jump_function = @linear_jump;
a0 = 1/3;
a1 = 1/3;
a2 = 1/3;

% Average
constraint = 1;

% Numerical
sim_time = 10;
N_samples = 50;
randomseed = 2;
trans_method = 'natural';

%% SIMULATION
simCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, ...
                N_samples, randomseed, trans_method)

%% FIDELITY CALCULATION
fidCTMC_1G1B(jump_function, Gamma, F_new, gen_rate, cons_rate, ...
              purif_prob, purif_success, sim_time, N_samples, ...
              randomseed, trans_method, a0, a1, a2)
          
avgfidCTMC_1G1B(constraint,jump_function, Gamma, F_new, gen_rate, ...
                cons_rate, purif_prob, purif_success, sim_time, ...
                N_samples, randomseed, trans_method, a0, a1, a2)

%% PLOT FIDELITY TRACES
plotfidCTMC_1G1B(constraint, jump_function, Gamma, F_new, gen_rate, ...
                    cons_rate, purif_prob, purif_success, sim_time, ...
                    N_samples, randomseed, trans_method, a0, a1, a2)
disp(['PLEASE visually check if the steady state has been reached,' ...
        ' we have no steady state detection algorithm yet.'])

%% PLOT STATE TRACES
plotCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, ...
                N_samples, randomseed, trans_method)
disp(['PLEASE visually check if the steady state has been reached,' ...
        ' we have no steady state detection algorithm yet.'])

%% LEGACY CODE FOR DEBUGGING
% Load
filename = sprintf('data_fid/avgfid-%s-%s', ...
                    num2str(constraint), func2str(jump_function));
varargin_array = [a0, a1, a2];
for ii = 1:length(varargin_array)
    filename = strcat(filename,sprintf('-%.3f',varargin_array(ii)));
end
filename = strcat(filename,sprintf(['-G%.3f-F%.3f-g%.3f-c%.3f' ...
                    '-p%.3f-ps%.3f-t%.0f-N%.0f-rs%.0f-%s.mat'], ...
                    Gamma, F_new, gen_rate, cons_rate, purif_prob, ...
                    purif_success, sim_time, N_samples, ...
                    randomseed, trans_method));
load(filename, 'F_avg', 'F_2stderr', 'data_time');
delete(filename)






