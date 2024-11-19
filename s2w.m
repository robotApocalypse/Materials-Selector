function s = s2w(Su,rho)

% Calculates specific strength of a given material.
% Desired output is usually in kN-m/kg, which allows 
% for variables to be in MPa and g/m^3, respectively
% without the need for conversion.

% Su = Yield strength
% rho = density

s=Su/rho;

end