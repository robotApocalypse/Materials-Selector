function n = ROexp(ef,Su,Sy)

% Finds the Ramberg Osgood exponent n

% ef = Fracture elongation
% Su = Ultimate tensile strength
% Sy = Yield strength

n=log(ef/0.002)/log(Su/Sy);

end