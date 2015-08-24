function s = cn_selfields(s,fnames,skiponerr)
% s = cn_selfields(s,fnames,skiponerr)
%
% Removes all fields other than the ones provided.
%
% INTPUT
% s             Structure
% fnames        Field names
% [skiponerr]   'f' OR false: Fail if there is a missing field. (default)
%               'w' OR true:  Skip missing fields but print a small warning.
%               's':          Skip missing fields and be silent.
%
% SEE cn_copyfields
%
% R.G.Cinbis May 2010

if nargin < 3
    skiponerr = 'f';
else
    if ischar(skiponerr)
        assert(ismember(skiponerr,'fws'),'unrecognized skiponerr option');
    elseif skiponerr
        skiponerr = 'w';
    else 
        skiponerr = 'f';
    end
end

if skiponerr~='f'
    avlfields = fieldnames(s);
    errfields = setdiff(fnames,avlfields);
    fnames    = intersect(fnames,avlfields);

    if skiponerr~='s' && ~isempty(errfields)
        disp('cn_selfields::Following fields does not exist, skipped: ');
        for j = 1:length(errfields)
            disp(sprintf(' %s ',errfields{j}));
        end
        fprintf('\n');
    end
end

s = cn_copyfields(s,[],fnames);

