syms b1 b2 b3 g0

jump_functions = cell(7,1);

jump_functions{1} = -(b3*(g0 - 1) + 3*(b1 + b2 + b3 - 1)*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - 2*b1*(g0 - 1) - 2*b2*(g0 - 1) - b3*(g0 - 1) - 3*(b1 + b2 + b3 - 1)*g0 + 3*b3*g0);

jump_functions{2} = -((b1 + b2 + b3 - 1)*g0 - b3*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - b3*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b3*g0);

jump_functions{3} = -((b1 + b2 + b3 - 1)*g0 - b1*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - b1*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b1*g0);

jump_functions{4} = -(b1*(g0 - 1) + 3*(b1 + b2 + b3 - 1)*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - b1*(g0 - 1) - 2*b2*(g0 - 1) - 2*b3*(g0 - 1) - 3*(b1 + b2 + b3 - 1)*g0 + 3*b1*g0);

jump_functions{5} = -((b1 + b2 + b3 - 1)*g0 - b2*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - b2*(g0 - 1) - (b1 + b2 + b3 - 1)*g0 + b2*g0);

jump_functions{6} = -(b2*(g0 - 1) + 3*(b1 + b2 + b3 - 1)*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - 2*b1*(g0 - 1) - b2*(g0 - 1) - 2*b3*(g0 - 1) - 3*(b1 + b2 + b3 - 1)*g0 + 3*b2*g0);

jump_functions{7} = ((b1 + b2 + b3 - 1)*(g0 - 1) - 3*(b1 + b2 + b3 - 1)*g0)/((b1 + b2 + b3 - 1)*(g0 - 1) - b1*(g0 - 1) - b2*(g0 - 1) - b3*(g0 - 1) - 3*(b1 + b2 + b3 - 1)*g0 + 3*b1*g0 + 3*b2*g0 + 3*b3*g0);


for I = 1:length(jump_functions)
    jump_functions{I} = collect(jump_functions{I},g0);
    disp(jump_functions{I})
end