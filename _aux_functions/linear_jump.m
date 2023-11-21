function output_fidelity = linear_jump(input_F1,input_F2,varargin)
%
%   This function calculates fidelity after purification when the output
%   fidelity is a linear function of the input fidelities:
%   output_fidelity = a_0 + a_1 * input_F1 + a_2 * input_F2.
%   The value of the constants must be provided in an array as varargin.
%   If no constants are provided, they are set by default to 1/3, which
%   corresponds to a linear approximation of the DEJMPS protocol in a
%   high-fidelity regime.
%
%   --- Inputs ---
%   input_F1:   (float) input fidelity 1.
%   input_F2:  (float) input fidelity 2.
%   a_0:    (float) independent constant.
%   a_1:    (float) constant 1.
%   a_2:    (int) constant 2.
%
%   --- Outputs ---
%   output_fidelity: (float) output fidelity
%

%% INITIAL CHECKS
    % Check inputs
    mustBeGreaterThanOrEqual(input_F1,0)
    mustBeLessThanOrEqual(input_F1,1)
    mustBeGreaterThanOrEqual(input_F2,0)
    mustBeLessThanOrEqual(input_F2,1)

    % Check if the constants were provided
    if nargin < 3
        a_0 = 1/3;
        a_1 = 1/3;
        a_2 = 1/3;
    elseif nargin > 5
        error('Too many inputs')
    else
        a_0 = varargin{1}(1);
        a_1 = varargin{1}(2);
        a_2 = varargin{1}(3);
    end

%% CALCULATE
    output_fidelity = a_0 + a_1 * input_F1 + a_2 * input_F2;
    % Check output
    mustBeGreaterThanOrEqual(output_fidelity,0)
    mustBeLessThanOrEqual(output_fidelity,1)

end

