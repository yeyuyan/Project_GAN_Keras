function [E,LambdaC,N,C,Xs,Ys]=ParametreLambertSecante(A,E,Lambda0,Phi0,Phi1,Phi2,X0,Y0)
LambdaC=Lambda0;
GN1=GrandeNormale(Phi1,A,E);
GN2=GrandeNormale(Phi2,A,E);
Lat1=LatitudeIsometrique(Phi1,E);
Lat2=LatitudeIsometrique(Phi2,E);

N=log((GN2*cos(Phi2))/(GN1*cos(Phi1)))/(Lat1-Lat2);
C=GN1*cos(Phi1)/N*exp(N*Lat1);
Xs=X0;
Ys=Y0;

if abs(Phi0-pi/2)<1e-9
    Xs=X0;
    Ys=Y0;
else

    Lat0=LatitudeIsometrique(Phi0,E);
    Xs=X0;
    Ys=Y0+C*exp(N*Lat0);
end;
