function s = cn_setfielddefaults(s,overwriteifempty,varargin)
% s = cn_setfielddefaults(s,overwrite,fieldname,defval,fieldname,defval,...)
% 
% Sets default values to fields that does not currently exist.
% 
% overwriteifempty: If true, variables that exist but set to empty
%                   will be set to their default values. Important
%                   only when defval isnt empty.
%
% - If s is a struct array, every member of struct array is updated in the same
%   manner.  If s is empty, it is initialized to be a struct array of single
%   element.
%
% SEE cn_setvardefaults() cn_overwritestruct()
%
% todo: parse fieldnames if they contain '.'
% 
% R.G. Cinbis Nov 2009
%
% January 2010: CHANGED INTERFACE!

% $Id: cn_setfielddefaults.m,b 1.5 2011/09/18 15:36:45 cinbis Exp $

assert(nargout==1); % avoid mistakes.
assert(mod(length(varargin),2)==0);
nsi = max(numel(s),1);

%arg_flds = varargin(1:2:end);
%arg_vals = varargin(2:2:end);
%nfld = length(arg_flds);
%
%% find missing fields
%if isempty(s)
%    hasmask = false(1,nfld);
%else
%    hasmask = ismember(arg_flds,fieldnames(s));
%end
%
%% add new fields
%for j = reshape(find(~hasmask),1,[])
%    fn = arg_flds{j};
%    fv = arg_vals{j};
%    for si = 1:nsi
%        s(si).(fn) = fv;
%    end
%end
%
%if overwriteifempty
%    for j = reshape(find(hasmask),1,[])
%        fn = arg_flds{j};
%        fv = arg_vals{j};
%        for si = 1:nsi
%            if isempty(s(si).fn)
%                s(si).(fn) = fv;
%            end
%        end
%    end
%end


for j = 1:2:length(varargin)
    if ~isfield(s,varargin{j}) 
        
        % add field
        for si = 1:nsi
            s(si).(varargin{j}) = varargin{j+1};
        end

    elseif overwriteifempty

        % field exists, check empty entries
        for si = 1:nsi
            if isempty(s(si).(varargin{j})) 
                s(si).(varargin{j}) = varargin{j+1};
            end
        end

    end
end

