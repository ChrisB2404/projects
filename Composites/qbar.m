function [qb, q] = qbar(E1, E2, v12, G12, th)
% sine and cosine
c = cosd(th);
s = sind(th);

% compliance matrix
s11 = 1/E1;
s22 = 1/E2;
s12 = -v12/E1;
s66 = 1/G12;

% reduced lamina stiffness matrix
q11 = s22/((s11*s22) - (s12^2));
q12 = -s12/((s11*s22) - (s12^2));
q22 = s11/((s11*s22) - (s12^2));
q66 = 1/s66;
q = [q11 q12 0; q12 q22 0; 0 0 q66]; 

% trasnformed reduced stiffness matrix
qb11 = q11*c^4 + q22*s^4 + 2*(q12+2*q66)*s^2*c^2;
qb12 = (q11+q22-4*q66)*s^2*c^2 + q12*(c^4+s^4);
qb22 = q11*s^4 + q22*c^4 + 2*(q12+2*q66)*s^2*c^2;
qb16 = (q11-q12-2*q66)*c^3*s - (q22-q12-2*q66)*c*s^3;
qb26 = (q11-q12-2*q66)*c*s^3 - (q22-q12-2*q66)*c^3*s;
qb66 = (q11+q22-2*q12-2*q66)*s^2*c^2 + q66*(s^4+c^4);

% generate matrix
qb = [qb11 qb12 qb16; qb12 qb22 qb26; qb16 qb26 qb66];
end