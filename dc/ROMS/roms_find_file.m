% finds files for type = ini / bry / grd / flt / his / avg
%   [fname] = roms_find_file(dir,type)
% can return a list for last two types. fname does NOT contain input
% directory

function [fname] = roms_find_file(dirin,type)

    if ~isdir(dirin)
        if strcmpi(type,'his') || strcmpi(type,'avg')
            fname = dirin;
            return;
        else
            index = strfind(dirin,'/');
            dirin = dirin(1:index(end));
        end
    end
    
    if isempty(strfind(dirin,'config')), fname = [dirin '/config/']; end
    % ls gives different results on windows and linux
    %in = ls([fname '/*.in']);
    in = dir([fname '/*.in']);
    
    if size(in,1) > 1
        ii = 1;
        while size(in,1) > 1
            if strcmpi(in(ii,:).name,'floats.in') || ...
                    strcmpi(in(ii,:).name,'stations.in') || ...
                    strfind(in(ii,:).name,'rst_')
               in(ii,:) = [];
               continue
            end
            ii = ii+1;
        end
    end
    
    in = in.name;
    
    % files from *.in 
    if strcmpi(type,'ini') || strcmpi(type,'bry') ||  strcmpi(type,'grd')
        fname = ['/config/' grep_in([fname in],type)];
    end
    
    % floats
    if strcmpi(type,'flt')
        fname = [grep_in([fname in],type)];
    end
    
    if strcmpi(type,'his')
        fnames = dir([dirin '/*_his*.nc*']);
        if isempty(fnames)
            fnames = dir([dirin '/*_avg*.nc*']); 
            disp('Using avg files instead.');
        end
        
        % convert from struct to names
        clear fname
        for kk=1:size(fnames)
            fname{kk}= fnames(kk,:).name;
        end
    end
    
    if strcmpi(type,'avg')
        fnames = dir([dirin '/*_avg*.nc*']);
        if isempty(fnames)
            fnames = dir([dirin '/*_his*.nc*']); 
            disp('Using his files instead.');
        end
        
        % convert from struct to names
        clear fname
        for kk=1:size(fnames)
            fname{kk}= fnames(kk,:).name;
        end
    end
    

% runs grep on input file
function [str] = grep_in(fname,type)
        [~,p] = grep('ININAME == ',fname); 
        % line in p.match must be processed to extract *.nc name
        str = sscanf(char(p.match),sprintf(' %sNAME == %%s',upper(type)));
        