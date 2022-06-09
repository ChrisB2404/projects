clc; clear;
syskd = tf([1 0 0],[1 0 1 1]);
syskp = tf([1 0],[1 1 0 1]);
syski = tf(1,[1 1 1 0]);
rlocus(syskd);
figure
rlocus(syskp);
figure
rlocus(syski);