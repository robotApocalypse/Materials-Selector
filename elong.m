function [el] = elong(S,E,Sy,n)

% This is the Ramberg-Osgood Equation, which
% models strain as a function of stress. 

% S  = Stress 
% E  = Young's Modulus 
% Sy = Yield strength
% n  = Ramberg-Osgood strain-hardening constant 

el=S./E+0.002*(S./Sy).^n;

end