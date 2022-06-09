function [zvec, eps12, epsxy, sig12, sigxy] = stress_strain(N,M,eps0,curve,theta,prop)
% Generate the ABD matrix
n_ang = 1:length(theta);
h = length(n_ang)*prop(5);
z = zeros(1,(length(theta)+1));
z(1) = -h/2;

for i = 2:length(theta)+1
    z(i) = z(i-1)+prop(5);
end

zvec = [];
for j = 2:(length(z)-1)
    zvec = [zvec z(j) z(j)];
end
zvec = [z(1) zvec z(length(theta)+1)];

[A,B,D] = ABD(prop(1),prop(2),prop(4),prop(3),theta,n_ang,z);
ABDmat = [A B; B D];

% Calculate Structural Strains
epsxy = zeros(3,2*length(theta));
if N == zeros(3,1)
    for k = 1:2*length(theta)
        epsxy(1:3,k) = eps0+zvec(k)*curve;
    end
else
    eps0k = inv(ABDmat)*[N;M];
    for k = 1:2*length(theta)
        epsxy(1:3,k) = eps0k(1:3,1)+zvec(k)*eps0k(4:6,1);
    end
end
tvec = [];
for ii = 1:length(theta)
    tvec = [tvec theta(ii) theta(ii)];
end

%Calculate Principal Material Strains
eps12 = zeros(3,2*length(theta));
for jj = 1:(2*length(theta)-1)
    c = cosd(tvec(jj));
    s = sind(tvec(jj));
    Teps = [c^2 s^2 c*s; s^2 c^2 -c*s; -2*c*s 2*c*s c^2-s^2];
    eps12(1:3,jj) = Teps*epsxy(1:3,jj);
    eps12(1:3,jj+1) = Teps*epsxy(1:3,jj+1);
end

%Calculate Structural and Principal Material Stresses
sig12 = zeros(3,2*length(theta));
sigxy = zeros(3,2*length(theta));

for kk = 1:(2*length(theta)-1)
    [Qb,Q] = qbar(prop(1),prop(2),prop(4),prop(3),tvec(kk));
    sig12(1:3,kk) = Q*eps12(1:3,kk);
    sig12(1:3,kk+1) = Q*eps12(1:3,kk+1);
    sigxy(1:3,kk) = Qb*epsxy(1:3,kk);
    sigxy(1:3,kk+1) = Qb*epsxy(1:3,kk+1);
end
end