function RawData=MyPrettyCsvRead(FileName,Quotation,Separator,ForceLocalDecimalSeparator)
% Replace decimal separator with a dot if necessary
Raw={};

% Check separator and quotation mark
if length(Quotation)>1
    error('Quotation must be empty or a single character');
end
if ~isempty(Quotation) && ((length(Quotation)~=1) || ~ischar(Quotation))
    error('Quotation must be empty or a single character');
end
if (length(Separator)~=1) || ~ischar(Separator)
    error('Separator must be a single character (comma, etc.)');
end
% Data can be read from the file
try
    fich=fopen(FileName,'r');
catch
    error('Error occured when trying to write the file. Check if the filename is correct and that the file is not locked by another application');
end


% Read File to measure the number of cells
% On large file, this is probably better than modifying the cell size
% dynamicaly
n=0;
m=0;
while ~feof(fich)
    Line=fgetl(fich);
    
    [mline]=LineAnalysis(Line,Quotation,Separator);
    if mline>m
        m=mline;
    end
    n=n+1;
end
frewind(fich);
% Read data
RawData=cell(n,m);
for iLine=1:n
    Line=fgetl(fich);
    
    [LineData,mLine]=DecodeLine(Line,Quotation,Separator,m,ForceLocalDecimalSeparator);
    RawData(iLine,1:mLine)=LineData(1,1:mLine);
end
fclose(fich);
    function [LineData,mLine]=DecodeLine(Line,Quotation,Separator,m,ForceLocalDecimalSeparator)
        LineData=cell(1,m);
        i=1;
        if isempty(Quotation)
            % If necessary add a final separator
            if Line(end)~=Separator
                Line(end+1)=Separator;
            end
            % Uses separator mark
            iSep=find(Line==Separator);
            deb=1;
            LineData=cell(1,length(iSep));
            for i=1:length(iSep)
                fin=iSep(i);
                if fin-1>=deb
                    LineData{1,i}=ConvertData(Line(deb:fin-1),ForceLocalDecimalSeparator);
                else
                    LineData{1,i}='';
                end
                deb=fin+1;
            end
            mLine=length(iSep);
        else
            % Use quotation mark
            iQuote=find(Line==Quotation);
            i=1;
            mLine=length(iQuote)/2;
            for i=1:mLine
                iStart=iQuote((i-1)*2+1)+1;
                iEnd=iQuote(i*2)-1;
                if iStart<=iEnd
                    LineData{1,i}=ConvertData(Line(iStart:iEnd));
                end
            end
        end
    end
    function Data=ConvertData(CellString,ForceLocalDecimalSeparator)
        if ForceLocalDecimalSeparator
            NbrToStr=java.text.DecimalFormat;
            try
                Data=double(NbrToStr.parse(CellString));
                if isnan(Data)
                    Data=CellString;
                end
            catch
                Data=CellString;
            end
        else
            %             NbrToStr.parse=@(s) str2doubleq(s);
            if any( ((CellString>'9')|(CellString<'0')) & ...
                      ~((CellString=='.')|(CellString=='-')|(CellString=='e')|(CellString=='E')|(CellString=='-')))
                
                Data=CellString;
            else
                Data=str2doubleq(CellString);
            end
        end
        
    end
    function [mline]=LineAnalysis(Line,Quotation,Separator)
        % Check the number of cells in the line
        if ~isempty(Quotation)
            % Number of items is given by the numbe of quote divided by two
            % Nb : some separator mark may be in between the quote so it cannot be
            % used to count the number of cells
            NbQuotation=(Line==Quotation);
            if mod(NbQuotation,2)~=0
                error(sprintf('In the following line the number of quotation mark is incorrect:\n"%s"',Line));
            end
            mline=sum(Line==Quotation)/2;
        else
            % Number of items only depends on the number of separator mark
            if Line(end)~=Separator
                mline=sum(Line==Separator)+1;
            else
                mline=sum(Line==Separator);
            end
        end
        
    end
end