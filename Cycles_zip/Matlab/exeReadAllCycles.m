clear all;
close all;
clc;
% GPS projection parameters
Lambert93=InitLamber93;

% CSV Import paramters
Quotation='';
Separator=',';
ForceLocalDecimalSeparator=0;

% fonction de test
TestProvider=@(x) ~strcmpi(x,'gps')

% Directories to be importer
ListeRep={'..\Cycles'};

Matrice=[];
No=1;
Data=cell(100,1);
for NoRep=1:length(ListeRep)
    Rep=ListeRep{NoRep};
    ListeFich=dir([Rep '\*.csv']);
    for NoFich=1:length(ListeFich)
        fprintf('%s : %i/%i NoFich : %i\n',Rep,No,length(ListeFich),NoFich);
        FichName=ListeFich(NoFich).name;
        RawData=MyPrettyCsvRead([Rep '\' FichName],Quotation,Separator,ForceLocalDecimalSeparator);
        
        % Retrait des données obtenues via un autre moyen que le GPS
        ProviderStr=RawData(2:end,9);
        IsProviderOk=cellfun(@(x) strcmpi(x,'gps'),ProviderStr);
        ii=find(IsProviderOk)+1;
        RawData=RawData(ii,:);
        
        % Find and remove duplicate time stamp, if any
        if size(RawData,1)>5
            DateTimeStr=cell2mat(RawData(2:end,1));
            if size(DateTimeStr,2)==20
                Time=datetime(DateTimeStr(:,1:19),'InputFormat','uuuu-MM-dd''T''HH:mm:ss','TimeZone','UTC');
            else
                Time=datetime(DateTimeStr(:,1:23),'InputFormat','uuuu-MM-dd''T''HH:mm:ss.SSS','TimeZone','UTC');
            end
            ii=find(diff(Time)~=0)+1;
            RawData=RawData(ii,:);
            % Check for remaining (assumed valid) data
            DateTimeStr=cell2mat(RawData(2:end,1));
        else
            DateTimeStr=[];
        end
        if size(DateTimeStr,1)>5
            % Store file name
            Data{No}.Name=FichName;
            
            % Assez de données
            %             DateTimeStr(:,11)=' ';
            %             DateTimeStr=DateTimeStr(:,1:19);
            
            
            % Altitude
            Altitude=RawData(2:end,4);
            iii=cellfun('isempty', Altitude)';
            Altitude(iii)={0};
            Altitude=real(cell2mat(Altitude));
            
            % Vitesse
            %1021, 2631, 3413
            Vitesse=RawData(2:end,7);
            iii=cellfun('isempty', Vitesse)';
            Vitesse(iii)={0};
            Vitesse=real(cell2mat(Vitesse));
            
            Vitesse(iii)=NaN;
            
            Data{No}.Name=FichName;
            if size(DateTimeStr,2)==20
                Data{No}.Time=datetime(DateTimeStr(:,1:19),'InputFormat','uuuu-MM-dd''T''HH:mm:ss','TimeZone','UTC');
            else
                Data{No}.Time=datetime(DateTimeStr(:,1:23),'InputFormat','uuuu-MM-dd''T''HH:mm:ss.SSS','TimeZone','UTC');
            end
            
            Data{No}.Longitude=real(cell2mat(RawData(2:end,3)));
            Data{No}.Latitude=real(cell2mat(RawData(2:end,2)));
            
            % Nb of Satellite
            Data{No}.NbSatellites=real(cell2mat(RawData(2:end,8)));
            % Accuracy
            Data{No}.Accuracy=real(cell2mat(RawData(2:end,5)));
            
            
            % Fix speed errors
            iNaN=isnan(Vitesse);
            iOk=~isnan(Vitesse);
            Vitesse(iNaN)=interp1(Data{No}.Time(iOk),Vitesse(iOk),Data{No}.Time(iNaN),'linear','extrap');
            
            if any(isnan(Vitesse))
                error('nan');
            end
            % Projection
            [Data{No}.X,Data{No}.Y]=ProjLambert(Data{No}.Longitude*pi/180,Data{No}.Latitude*pi/180,Lambert93);
            
            
            Data{No}.Altitude=Altitude;
            Data{No}.Vitesse=Vitesse;
            
            % Data{NoFich}.geoidheight=cell2mat(RawData(2:end,13));
            
            Longitude=cell2mat(RawData(2:end,3));
            Latitude=cell2mat(RawData(2:end,2));
            
            % Calcul de la distance
            T=Data{No}.Time;
            DeltaT=etime(datevec(T(2:end)),datevec(T(1:end-1)));
            DeltaT(end+1)=DeltaT(end);
            Data{No}.Distance=cumsum(DeltaT.*Vitesse(1:end));
            
            % Calcul d'une distance bas? sur le GPS
            dX=diff(Data{No}.X);
            dY=diff(Data{No}.Y);
            DeltaS=sqrt(dX.^2+dY.^2);
            Data{No}.Distance2=[0; cumsum(DeltaS.*DeltaT(1:end-1))];
            oldData=Data{No};
            [Data{No},CycleError]=CleanDrivingCycle(Data{No});
            
     
            if (length(Data{No}.Time)>2)&~CycleError
                fprintf('Dist : %.2f\n',Data{No}.Distance(end));
                No=No+1;
                if No>size(Data,1)
                    Data{No+100}=[];
                end
            else
                fprintf('   => rejected\n');
                figure;
                plot(oldData.X,oldData.Y,'k');
                title(oldData.Name);
                grid on;
                drawnow;
            end
        end
    end
end
Data=Data(1:No-1);
save AllDataFile Data