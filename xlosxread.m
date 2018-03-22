function xlsData = xlosxread(xlfile,xlsheet)

xlFile = py.pandas.read_excel(fullfile(xlfile), pyargs('sheet_name', xlsheet));

xlFileDict = xlFile.to_dict();

xlKeys = cellfun(@string, cell(py.list(xlFileDict.keys())));

clear reshaped
for k = 1:length(xlKeys)
    strcfld = regexprep(xlKeys{k}(~isspace(xlKeys{k})),'\[(.*?)\]','');
    strcfld = regexprep(strcfld, ':.*','');
    if isnumeric(cell(py.list(xlFileDict{xlKeys{k}}.values())))
        xlStruct.(strcfld) =...
            cellfun(@double,cell(py.list(xlFileDict{xlKeys{k}}.values())));
    else
        xlStruct.(strcfld) =...
            cell(py.list(xlFileDict{xlKeys{k}}.values()));
    end
    
    classType = cell(1, length(xlStruct.(strcfld)));
    
    for j = 1:length(xlStruct.(strcfld))
        classType{j} = class(xlStruct.(strcfld){j});
    end
    
    classKeys = unique(classType,'stable');
    classVals = cellfun(@(x) sum(ismember(classType,x)),...
        classKeys,'un',0);
    
    classCmp = containers.Map(classKeys,classVals);
    

    if any(strcmp(classCmp.keys,'py.str'))
        for j = 1:length(xlStruct.(strcfld))
            if isa(xlStruct.(strcfld){j},'py.str')
                xlStruct.(strcfld){j} = string(xlStruct.(strcfld){j});
            else
                try 
                    if isnan(xlStruct.(strcfld){j})
                        xlStruct.(strcfld){j} = string.empty(0);
                    end
                catch
                    break
                end
            end
        end
        xlStruct.(strcfld) = reshape(xlStruct.(strcfld),length(xlStruct.(strcfld)),1);
    end
    
    if any(strcmp(classCmp.keys,'py.int'))
        for j = 1:length(xlStruct.(strcfld))
            if isa(xlStruct.(strcfld){j},'py.int')
                xlStruct.(strcfld){j} = double(xlStruct.(strcfld){j});
            else
                try
                    if isnan(xlStruct.(strcfld){j})
                        xlStruct.(strcfld){j} = double.empty(0);
                    end
                catch
                    break
                end
            end
        end
        xlStruct.(strcfld) = reshape(xlStruct.(strcfld),length(xlStruct.(strcfld)),1);
    end
    
    if classCmp.Count == 1
        if strcmp(classCmp.keys, 'double')
            for j = 1:length(xlStruct.(strcfld))
                if isnan(xlStruct.(strcfld){j})
                    xlStruct.(strcfld){j} = double.empty(0);
                end
            end
        end
        xlStruct.(strcfld) = reshape(xlStruct.(strcfld),length(xlStruct.(strcfld)),1);
    end
end

xlsData = xlStruct;

end