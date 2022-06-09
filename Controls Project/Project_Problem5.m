clc; clear;
Kd = 9000;
Kp = 5000;
Ki = 1;
sys = tf([Kd Kp Ki],[1 Kd Kp Ki]);
step(10*sys);
a = 0.1*step(10*sys);
b = 0.9*step(10*sys);
disp(b(end)-a(end));