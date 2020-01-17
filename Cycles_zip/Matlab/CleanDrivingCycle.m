function [Data,CycleError]=CleanDrivingCycle(Data2)
CycleError=false; % Assume no error

% Structure data
Liste={'Time','Vitesse','Longitude','Latitude','X','Y','Altitude','Distance','NbSatellites','Accuracy'};

% Check data and corrects some "errors"
Data=Data2;
T=seconds(Data.Time-Data.Time(1));

% Remove initial unacurate data
Condition=(Data.NbSatellites>4)&(Data.Accuracy<20);
iStart=find(Condition,1,'first');

% Remove overlength cycle
VitesseNulle=(Data.Vitesse==0)'&(1:length(T)>iStart);
iStop=find(diff(VitesseNulle)>.5,1,'last');
if isempty(iStop)||(Data.Vitesse(end)~=0)
    iStop=length(VitesseNulle);
else
    iStop=min(iStop+1,length(VitesseNulle));
end

% Check for duration between two samples
DeltaMax=4;
DeltaT=diff(T);
DeltaT(end+1)=DeltaT(end);
CycleError=CycleError||any(DeltaT(iStart:iStop)>DeltaMax);
if CycleError
    return;
end

Condition=(DeltaT>DeltaMax)'&((1:length(T))>iStart);
% Look for the first falling edge and last rising edge
i=find(diff(Condition)<-0.5,1,'first');
if ~isempty(i)
    iStart=max(iStart,min(i));
end
i=find(diff(Condition)>0.5,1,'last');

if ~isempty(i)
    iStop=min(iStop,min(i));
end
if 1==0
    figure;
    subplot(2,1,1);
    % plot(Data.Time(1:end-1),DeltaT,'r');
    hold on;
    plot(Data.Time(1:end-1),DeltaT>DeltaMax,'b');
    subplot(2,1,2);
    plot(Data.Time,Data.Vitesse);
    yy=ylim;
    figure(10);
    clf
    plot(Data.Time,Data.Vitesse,'r');
    hold on;
    plot(Data.Time,Data.Vitesse,'b+');
    
    plot(Data.Time(iStop)+[0 0],yy,'b');
    plot(Data.Time(iStart)+[0 0],yy,'g');
    grid on;
    drawnow;
end

% Remove unecessary start & end data
for ii=1:length(Liste)
    Data.(Liste{ii})=Data.(Liste{ii})(iStart:iStop);
end

% Add initial velocity slope
if Data.Vitesse(1)>0
    DeltaT=1;
    t0=Data.Time(1);
    
    Accel=1.5; % m/s²
    ti=-Data.Vitesse(1)/Accel;
    ti=floor(ti);

    % Create initial component
    SP=1; % Sampling period
    ArrTime=[ti:SP:-1];
    if isempty(ArrTime)
        error('No additionnal time');
    end
    ArrSpeed=interp1([ti 0],[0 Data.Vitesse(1)],ArrTime);
    DeltaD=fliplr(-cumsum(fliplr(ArrSpeed*SP))); % Distance covered every seconds
    
    
    
    Data2=Data;
    Data.Time=[Data.Time(1)+seconds(ArrTime)'; Data.Time];
    Data.Vitesse=[ArrSpeed';Data.Vitesse];
    Data.Distance=[Data.Distance(1)+DeltaD';Data.Distance];
    Data.Distance2=[Data.Distance(1)+DeltaD';Data.Distance2];
    
    
    for i=1:length(Liste)
        if ~strcmp(Liste{i},{'Vitesse','Time','Distance','Distance2'})
            % Add constant values
            Data.(Liste{i})=[Data.(Liste{i})(1)+ArrSpeed'*0 ;Data.(Liste{i})];
   
        end
    end
%     figure;
%     plot(Data2.Time(1:20),Data2.Vitesse(1:20),'r','linewidth',2);
%     hold on;
%     plot(Data.Time(1:20),Data.Vitesse(1:20),'b');
%     
%     figure;
%     plot(Data2.Distance(1:20),Data2.Vitesse(1:20),'r','linewidth',2);
%     hold on;
%     plot(Data.Distance(1:20),Data.Vitesse(1:20),'b');
%   
%     error('o')
end

if Data.Vitesse(end)>0
    % Add final slope
    Decel=0.5; % m/s²
    
    tf=ceil(Data.Vitesse(end)/Decel);
    
    % Create initial component
    SP=1; % Sampling period
    ArrTime=[1:SP:tf];
    if isempty(ArrTime)
        error('No additionnal time');
    end
    ArrSpeed=interp1([0 tf],[Data.Vitesse(end) 0],ArrTime);
    DeltaD=cumsum(ArrSpeed*SP); % Distance covered every seconds
    
    Data2=Data;
    Data.Time=[Data.Time; Data.Time(end)+seconds(ArrTime)' ];
    Data.Vitesse=[Data.Vitesse;ArrSpeed'];
    Data.Distance=[Data.Distance;Data.Distance(end)+DeltaD'];
    Data.Distance2=[Data.Distance2;Data.Distance(end)+DeltaD'];
    
    
    for i=1:length(Liste)
        if ~strcmp(Liste{i},{'Vitesse','Time','Distance','Distance2'})
            % Add constant values
            Data.(Liste{i})=[Data.(Liste{i});Data.(Liste{i})(end)+ArrSpeed'*0];
   
        end
    end
%     figure;
%     plot(Data.Time,Data.Vitesse,'k');
%     hold on;
%     plot(Data2.Time(end-20:end),Data2.Vitesse(end-20:end),'r','linewidth',2);
%     plot(Data.Time(end-20:end),Data.Vitesse(end-20:end),'b');
%     
%     figure;
%      plot(Data2.Distance,Data2.Vitesse,'k');
%    hold on;
%     plot(Data2.Distance(end-20:end),Data2.Vitesse(end-20:end),'r','linewidth',2);
%     plot(Data.Distance(end-20:end),Data.Vitesse(end-20:end),'b');
  
%     error('o')
end
    