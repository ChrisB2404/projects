function [A,B,D,Qb,Q,Sb,S] = ABD_2matl(E1,E2,v12,G12,theta,n_angle,z)
A = zeros(3,3);
B = zeros(3,3);
D = zeros(3,3);
Ak = zeros(3,3);
Bk = zeros(3,3);
Dk = zeros(3,3);

for ii = 2:(length(n_angle)+1)
    [Qb,Q] = qbar(E1(ii-1),E2(ii-1),v12(ii-1),G12(ii-1),theta(ii-1));
    for i = 1:length(Ak(1:3,1))
        for j = 1:length(Ak(1,1:3))
            Ak(i,j) = Qb(i,j)*(z(ii)-z(ii-1));
            Bk(i,j) = (1/2)*Qb(i,j)*(z(ii)^2-z(ii-1)^2);
            Dk(i,j) = (1/3)*Qb(i,j)*(z(ii)^3-z(ii-1)^3);
        end
    end
    A = A+Ak;
    B = B+Bk;
    D = D+Dk;
end

S = inv(Q);
Sb = inv(Qb);
end