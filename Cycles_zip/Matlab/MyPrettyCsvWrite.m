function [Status,msg]=MyPrettyCsvWrite(FileName,RawData,Quotation,DoubleFormat,Separator)
Status=1;
msg.message='';
if length(Quotation)>1
    Status=-1;
    msg.message='Quotation must be empty or a single character';
end;
if ~isempty(Quotation) && ((length(Quotation)~=1) || ~ischar(Quotation))
   Status=-1;
    msg.message='Quotation must be empty or a single character';
    return;
end;
if (length(Separator)~=1) || ~ischar(Separator)
    Status=-1;
    msg.message='Separator must be a single character (comma, etc.)';
    return;
end;
% Check the double format
try
    Str=sprintf(DoubleFormat,3.2);
catch
    Status=-1;
    msg.message='The provided "DoubleFormat" string seems incorrect. Use a format specification as described in the sprintf function';
    return;
end;
% Check that Cells contains only single values (no array)
for i=1:size(RawData,1)
    for j=1:size(RawData,2)
        if ~isempty(RawData{i,j})
            % Non empty cell
            if ischar(RawData{i,j})
                if size(RawData{i,j},1)~=1
                    Status=-1;
                    msg.message=sprintf('Cell {%i,%i} contains an array of char, only strings are supported',i,j);
                    return;
                end
                
            else
                if ~isnumeric(RawData{i,j})
                    Status=-1;
                    msg.message=sprintf('Cell {%i,%i} does not contains a single numerical value or a string',i,j);
                    return;
                end
                if (size(RawData{i,j},1)~=1)||(size(RawData{i,j},2)~=1)
                    Status=-1;
                    msg.message=sprintf('Cell {%i,%i} contains an array. Only scalar values are supporsted',i,j);
                    return;
                end;
            end
        end;
    end
end
% Data can be writen into the file
try
    fich=fopen(FileName,'w');
catch
    Status=-1;
    msg.message='Error occured when trying to write the file. Check if the filename is correct and that the file is not locked by another application';
    return;
end
 NbrToStr=java.text.DecimalFormat;
 NbrToStr.setMaximumFractionDigits(12);
  NbrToStr.setGroupingUsed(0);
%NbrToStr.format=@(s) sprintf('%.9e',s);
for i=1:size(RawData,1)
    Line='';
    for j=1:size(RawData,2)
        Cell=RawData{i,j};
        % Construct string corresponding to the cell
        if isempty(Cell)
            CellString=[Quotation Quotation];
        else
            if isnumeric(Cell)
                if imag(Cell)==0
                    % Pure real number
                    % Try to decide the best format
                    if round(Cell)==Cell
                        % Integer
                        
                        CellString=sprintf('%s%i%s',Quotation,Cell,Quotation);
                    else
                        CellString=[Quotation char(NbrToStr.format(Cell)) Quotation];
                    end;
                else
                    % Imaginary number. Chose best format for real & imag
                    % part
                    if round(imag(Cell))==imag(Cell)
                        StrImag=sprintf('%i',imag(Cell));
                    else
                        StrImag= char(NbrToStr.format(imag(Cell)));
                    end;
                    if round(real(Cell))==real(Cell)
                        StrReal=sprintf('%i',real(Cell));
                    else
                        StrReal=char(NbrToStr.format(real(Cell)));
                    end;
                    CellString=[Quotation StrReal '+' StrImag 'i' Quotation]; 
                end;
            end
            if ischar(Cell)
                CellString=[Quotation Cell Quotation];
            end;
        end
        if j~=size(RawData,2)
            Line=[Line CellString Separator];
        else
            Line=[Line CellString];
        end
        
    end;
    fprintf(fich,'%s\n',Line);
end;
fclose(fich);