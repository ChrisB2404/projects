function [zvec, eps12, epsxy, sig12, sigxy, NT, MT, eps0k, kvals] = stress_strain_temp(N,M,eps0,curve,theta,prop,thprop)
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

avals = zeros(3,length(theta));
for k = 1:length(theta)
    c = cosd(theta(k));
    s = sind(theta(k));
    avals(1,k) = thprop(1)*c^2 + thprop(2)*s^2;
    avals(2,k) = thprop(1)*s^2 + thprop(2)*c^2;
    avals(3,k) = 2*(thprop(1)-thprop(2))*c*s;
end

tvec = [];
for ii = 1:length(theta)
    tvec = [tvec theta(ii) theta(ii)];
end

% Calculate Structural Strains
epsxy = zeros(3,2*length(theta));
if eps0 == zeros(3,1)
    Nx = N(1);
    Ny = N(2);
    Nxy = N(3);
    Mx = M(1);
    My = M(2);
    Mxy = M(3);
    for k = 1:length(theta)
        [Qb,~] = qbar(prop(1),prop(2),prop(4),prop(3),theta(k));
        NxT = thprop(3)*(Qb(1,1)*avals(1,k)+Qb(1,2)*avals(2,k)+Qb(1,3)*avals(3,k))*(z(k+1)-z(k));
        Nx = Nx+NxT;
        NyT = thprop(3)*(Qb(2,1)*avals(1,k)+Qb(2,2)*avals(2,k)+Qb(2,3)*avals(3,k))*(z(k+1)-z(k));
        Ny = Ny+NyT;
        NxyT = thprop(3)*(Qb(3,1)*avals(1,k)+Qb(3,2)*avals(2,k)+Qb(3,3)*avals(3,k))*(z(k+1)-z(k));
        Nxy = Nxy+NxyT;
    end
    NT = [Nx; Ny; Nxy];
    for k = 1:length(theta)
        [Qb] = qbar(prop(1),prop(2),prop(4),prop(3),theta(k));
        MxT = thprop(3)/2*(Qb(1,1)*avals(1,k)+Qb(1,2)*avals(2,k)+Qb(1,3)*avals(3,k))*(z(k+1)^2-z(k)^2);
        Mx = Mx + MxT;
        MyT = thprop(3)/2*(Qb(2,1)*avals(1,k)+Qb(2,2)*avals(2,k)+Qb(2,3)*avals(3,k))*(z(k+1)^2-z(k)^2);
        My = My + MyT;
        MxyT = thprop(3)/2*(Qb(3,1)*avals(1,k)+Qb(3,2)*avals(2,k)+Qb(3,3)*avals(3,k))*(z(k+1)^2-z(k)^2);
        Mxy = Mxy + MxyT;
    end
    MT = [Mx; My; Mxy];
    eps0k = inv(ABDmat)*[NT; MT];
    kvals = eps0k(4:6,1);
    for k = 1:2*length(theta)
        epsxy(1:3,k) = eps0k(1:3,1)+zvec(k)*kvals;
    end
else
    for k = 1:2*length(theta)
        epsxy(1:3,k) = eps0+zvec(k)*curve;
    end
    kvals = curve;
end

%Calculate Principal Material Strains
eps12 = zeros(3,2*length(theta));
for jj = 1:2*length(theta)
    c = cosd(tvec(jj));
    s = sind(tvec(jj));
    Teps = [c^2 s^2 c*s; s^2 c^2 -c*s; -2*c*s 2*c*s c^2-s^2];
    eps12(1:3,jj) = Teps*epsxy(1:3,jj);
end

%Calculate Structural and Principal Material Stresses
sigxy = zeros(3,2*length(theta));
sig12 = zeros(3,2*length(theta));

for kk = 1:length(theta)
    [Qb,~] = qbar(prop(1),prop(2),prop(4),prop(3),theta(kk));
    sigxy(1:3,kk*2-1) = Qb*(epsxy(1:3,kk*2-1)-avals(1:3,kk)*thprop(3));
    sigxy(1:3,kk*2) = Qb*(epsxy(1:3,kk*2)-avals(1:3,kk)*thprop(3));
    c = cosd(theta(kk));
    s = sind(theta(kk));
    Tsig = [c^2 s^2 2*c*s; s^2 c^2 -2*c*s; -c*s c*s c^2-s^2];
    sig12(1:3,kk*2-1) = Tsig*sigxy(1:3,kk*2-1);
    sig12(1:3,kk*2) = Tsig*sigxy(1:3,kk*2);
end
end