function L=LatitudeIsometrique(Phi,E)
% Algorithme alg 0001 de l'ign

L=(log(tan(pi./4+Phi./2).*(((1-E.*sin(Phi))./(1+E.*sin(Phi))).^(E./2)))).* (abs(Phi-pi./2)>1e-9);

