function [X,Y]=ProjLambert(LongitudeGPS,LatitudeGPS,Lambert93)
% ALG0003 de l'IGN
L=LatitudeIsometrique(LatitudeGPS,Lambert93.E);
X=Lambert93.Xs+Lambert93.C*exp(-Lambert93.N*L).*sin(Lambert93.N*(LongitudeGPS-Lambert93.LambdaC));
Y=Lambert93.Ys-Lambert93.C*exp(-Lambert93.N*L).*cos(Lambert93.N*(LongitudeGPS-Lambert93.LambdaC));