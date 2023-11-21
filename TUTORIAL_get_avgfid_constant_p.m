%% Inputs

% Gen/cons/purif rates
gen_rate = 1;
cons_rate = 0.2;
purif_prob = 0.5;
purif_success = 1;

% Fidelity
Gamma = 1/20;
F_new = 0.8;
jump_function = @linear_jump;
a0 = 1/3;
a1 = 1/3;
a2 = 1/3;
varargin_array = [a0, a1, a2];

% Average
constraint = 1;

% Numerical
sim_time = 10;
N_samples = 10;
randomseed = 2;
trans_method = 'natural';

%% SIMULATION
simCTMC_1G1B(gen_rate, cons_rate, purif_prob, purif_success, sim_time, ...
                N_samples, randomseed, trans_method)

%% FIDELITY CALCULATION
fidCTMC_1G1B(jump_function, Gamma, F_new, gen_rate, cons_rate, ...
              purif_prob, purif_success, sim_time, N_samples, ...
              randomseed, trans_method, a0, a1, a2)
          
%% AVG FIDELITY
avgfidCTMC_1G1B(constraint,jump_function, Gamma, F_new, gen_rate, ...
                cons_rate, purif_prob, purif_success, sim_time, ...
                N_samples, randomseed, trans_method, a0, a1, a2)
            
%% LOAD AVG FIDELITY IN STEADY STATE

% Check if average data exists
filename = sprintf('data_fid/avgfid-%s-%s', ...
                    num2str(constraint), func2str(jump_function));
for ii = 1:length(varargin_array)
    filename = strcat(filename,sprintf('-%.3f',varargin_array(ii)));
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

% Assume that steady state was reached:
F_avg_steadystate = F_avg(end);
F_2stderr_steadystate = F_2stderr(end);
steady_state = sprintf('%.3f (%.3f)',F_avg_steadystate,F_2stderr_steadystate);
disp(steady_state)



            
            
            
            
            
            
            