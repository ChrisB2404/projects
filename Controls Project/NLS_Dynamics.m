function [sys,x0] = NLS_Dynamics(t,x,u,flag,p)
%%NLS_Dynamics is a MATLAB S-function that simulates a nonlinear system in
 %Simulink
%%Outputs: sys - generic output, depends on flag
 %         x0 - initial states
%%Inputs: t - current time
 %        x - current state
 %        u - current input
 %        flag - flag used by MATLAB internally
 %        p - additional parameters (see below)
%%Author: Jonathan Brooks, University of Florida
 %Based on work by Prof. Oscar Crisalle, University of Florida
%%Additional parameters are of the following form:
 %p = [M, m, Ix, Iy, Iz, g, x1_initial, x2_initial, ..., x12_initial]

    if flag == 0    %return size of state variable and initial conditions
        %Define state space vector sizes
        size_continuous_states = 12;
        size_discrete_states = 0;
        size_outputs = 6;
        size_inputs = 3;
        size_discrete_roots = 0;
        size_feedthrough = 0;
        %Output vector of sizes
        sys = [size_continuous_states,size_discrete_states,size_outputs,size_inputs,size_discrete_roots,size_feedthrough];

        %Initial conditions
        if length(p)>=19    %if user gave initial states
            p = p(:);   %make sure p is a column vector
            x0 = p(7:19);
        else    %if user did not give initial states
            x0 = zeros(12,1);   %assume initial states are all zero
        end
    elseif flag == 1    %return state variable derivative values
        %Physical parameters
        M = p(1);
        m = p(2);
        Ix = p(3);
        Iy = p(4);
        Iz = p(5);
        g = p(6);

        %State equations
        xdot(1:6) = x(7:12);    %first six state derivatives are the last six states
        %Formulas:
        xdot(7) = -1/(M+m)*(sin(x(4))*sin(x(6))+cos(x(4))*sin(x(5))*cos(x(6)))*u(1);
        xdot(8) = -1/(M+m)*(cos(x(4))*sin(x(5))*sin(x(6))-sin(x(4))*cos(x(6)))*u(1);
        xdot(9) = g - cos(x(4))*cos(x(5))/(M+m)*u(1);
        xdot(10) = ((Iy-Iz)*x(5)*x(6) + u(2))/Ix;
        xdot(11) = ((Iz-Ix)*x(4)*x(6) + u(3))/Iy;
        xdot(12) = (Ix-Iy)/Iz*x(4)*x(5);
        sys = xdot(:);  %output state derivatives
    elseif flag == 3    %return output variable
        y = x(1:6); %output is first six states
        sys = y(:); %output outputs
    else %return nothing
        sys = [];
    end
end