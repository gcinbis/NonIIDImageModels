function res = cn_timepassth(name,threshold)
% res = cn_timepassth(name,threshold)
%
% A shortcut to print out information with a certain period.
%
% Use as 
% while ...
%       if cn_timepassed('somedescriptor',threshold)
%               print info
%       end
%
% INPUT
% [name]        (def=[]). If provided, should be a valid variable name.
% [threshold]   threshold=3 (secs)
%
% Notes
%   Use cn_timepassed('somedescriptor',0) to clear corresponding counter.
%
% R.G.Cinbis, May 2010

persistent db default

mlock % needed to avoid clear functions at various functions

if (nargin < 2) || isempty(threshold)
    threshold = 3;
end

if (nargin < 1) || isempty(name) % just to make default case a little bit faster, use a separate variable for default case.

    if isempty(default)
        default = tic;
        res = false;
        return;
    end

    if toc(default) >= threshold
        res = true;
        default = tic;
        return;
    end

else

    if ~isfield(db,name)
        db.(name) = tic;
        res = false;
        return;
    end

    % dont use > since if threshold=0, we should return 0 always.
    if toc(db.(name)) >= threshold
        res = true;
        db.(name) = tic;
        return;
    end

end

res = false;




