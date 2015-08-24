function s = cn_selections2struct(base,opts)
% Given a cell array of strings, return a struct s 
%   s.(f) = ismember(f,opts)
%
% INPUT
% base      Either a cell array of all possible values OR a scalar structure.
% opts      Cell array of field name strings. 
%           Required: For each j, assert(ismember(opts{j},base)).
%
% OUTPUT
% s         As defined above.
%
% EXAMPLE
% cn_selections2struct({'a','b','c'},{'b','c'})
%
% R.G.Cinbis, Sep 2011

if iscell(base)
    for i = 1:length(base)
        s.(base{i}) = false;
    end
else
    s = base;
    assert(isstructscalar(base),'base should be either a cell of strings or a scalar struct');
end

assert(iscell(opts));

for i = 1:numel(opts)
    x = opts{i};
    if ~isfield(s,x)
        error(['undefined option: ' x]);
    end
    s.(x) = true;
end








