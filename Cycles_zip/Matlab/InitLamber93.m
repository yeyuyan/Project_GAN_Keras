function Lambert93=InitLamber93
Lambert93.N=0.725607765;
Lambert93.C=11754255.426;
Lambert93.Lambda0=3*pi/180;
Lambert93.E=0.08248325676;
Lambert93.A = 6378137;
Lambert93.Phi0=(46+30/60)*pi/180;
Lambert93.Phi1=44*pi/180;
Lambert93.Phi2=49*pi/180;
Lambert93.X0=700000;
Lambert93.Y0=6600000;
[Lambert93.E,Lambert93.LambdaC,Lambert93.N,Lambert93.C,Lambert93.Xs,Lambert93.Ys]=ParametreLambertSecante(Lambert93.A,Lambert93.E,Lambert93.Lambda0,Lambert93.Phi0,Lambert93.Phi1,Lambert93.Phi2,Lambert93.X0,Lambert93.Y0);

