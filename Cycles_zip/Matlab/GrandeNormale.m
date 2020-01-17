function N=GrandeNormale(Phi,A,E)
% Algorithme de calcul de la grande normale
% ALG0021 de l'ign
N=A/(sqrt(1-E^2*sin(Phi)^2));
