syms b1 b2 b3 g0

functions = cell(7,1);

functions{1} = 1/3*(b1 + b2 + b3 - 1)*(g0 - 1) - 2/3*b1*(g0 - 1) - 2/3*b2*(g0 - 1) - 1/3*b3*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b3*g0;
 
functions{2} = (b1 + b2 + b3 - 1)*(g0 - 1) - b3*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b3*g0;

functions{3} = (b1 + b2 + b3 - 1)*(g0 - 1) - b1*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b1*g0;

functions{4} = 1/3*(b1 + b2 + b3 - 1)*(g0 - 1) - 1/3*b1*(g0 - 1) - 2/3*b2*(g0 - 1) - 2/3*b3*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b1*g0;

functions{5} = (b1 + b2 + b3 - 1)*(g0 - 1) - b2*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b2*g0;

functions{6} = 1/3*(b1 + b2 + b3 - 1)*(g0 - 1) - 2/3*b1*(g0 - 1) - 1/3*b2*(g0 - 1) - 2/3*b3*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b2*g0;

functions{7} = 1/3*(b1 + b2 + b3 - 1)*(g0 - 1) - 1/3*b1*(g0 - 1) - 1/3*b2*(g0 - 1) - 1/3*b3*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b1*g0 + b2*g0 + b3*g0;

for I = 1:length(functions)
    functions{I} = collect(functions{I},g0);
    disp(functions{I})
end