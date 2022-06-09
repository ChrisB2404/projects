clc; clear;   %clear the Workspace

w1 = 2.7; h1 = 2.2; d1 = 3; %rover dimensions (meters)
w2 = 3; h2 = 2.5; d2 = 3;   %sky crane dimensions (meters)
M = 1025; m = 500;  %rover mass and sky crane mass, respectively (kg)
L = 25; l1 = m/(M+m)*L; l2 = L - l1;    %cable lengths; l1 = distance from rover to center of mass (meters)
g = 3.711;  %Martian gravitational acceleration (m/s^2)
x0 = zeros(12,1);   %initial states

%Moments of inertia for rover and sky crane relative to the center of mass
Izz1 = 1/12*M*(w1^2+d1^2); Izz2 = 1/12*m*(w2^2+d2^2);%along the axis of the cable
Iyy1 = 1/12*M*(w1^2+h1^2+12*l1^2); Iyy2 = 1/12*m*(w2^2+h2^2+12*l2^2);   %along the phi axis
Ixx1 = 1/12*M*(d1^2+h1^2+12*l1^2); Ixx2 = 1/12*m*(d2^2+h2^2+12*l2^2);   %along the theta axis

Izz = Izz1 + Izz2; Iyy = Iyy1 + Iyy2; Ixx = Ixx1 + Ixx2;    %moments of inertia for entire assembly
%A matrix from state-space equations
A = zeros(12); 
A(1:6,7:12) = eye(6,6);
A(7,5) = -g;
A(8,4) = g;
%B matrix from state-space equations
B = zeros(12,3);
B(9,1) = -1/(M+m);
B(10,2) = 1/Ixx1;
B(11,3) = 1/Iyy1;
%C matrix from state-space equations
C = zeros(6,12);    
C(1:6,1:6) = eye(6,6);
%D matrix from state-space equations
D = zeros(6,3); 

sys = tf(ss(A,B,C,D))   %compute matrix of transfer functions

Kd = 9000;  %derivative gain
Ki = 0.5;   %integral gain
Kp = 5000;  %proportional gain

Zeros = [-0.3126 -0.5807 -0.8273];  %controller zeros
Poles = [-0.0008+1.0000i -0.0008-1.0000i -10.23];   %controller poles
Gain = 93298;   %controller gain

simout = sim('linsim','StartTime','0','StopTime','300','FixedStep','0.01'); %call linear simulink model

figure
subplot(2,1,1)
plot(simout.t,simout.y(:,3))
xlabel('Time (sec)')
ylabel('Height Loss (m)')
hold on
plot(simout.r)
legend('Output','Reference')
subplot(2,1,2)
plot(simout.t,simout.u(:,1))
xlabel('Time (sec)')
ylabel('Thrust (N)')
figure
subplot(2,1,1)
plot(simout.t,simout.y(:,5))
xlabel('Time (sec)')
ylabel('Pitch Angle (Radians)')
hold on
plot(simout.t,zeros(1,length(simout.t)))
legend('Output','Reference')
subplot(2,1,2)
plot(simout.t,simout.u(:,3))
xlabel('Time (sec)')
ylabel('Moment around y-axis (N*m)')
print('-slinsim','-djpeg','model.jpeg')