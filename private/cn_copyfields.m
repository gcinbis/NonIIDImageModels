function sto = cn_copyfields(sfrom,sto,fnames,newnames)
% sto = cn_copyfields(sfrom,sto,fnames)
%
% Copies fields from sfrom structure to sto.
% If structure arrays, then sfrom and sto has to be of same length.
%
% INPUT
% sfrom         Structure from.
% sto           Structure to. Should have the same length or can be empty.
% [fnames]      If provided, copies only the specified fields. By default, fieldnames(sfrom).
% [newnames]    New names of the fields. By default, fnames.
%
% OUTPUT 
% sto:      Updated version of sto structure.
%
% * Note that setdiff() also works on cell array of strings.
%   This might help in building fnames input.
% * Similarly, intersect() can be used with cell array of strings.
% 
% R.Gokberk Cinbis, Jan 2010

% 2013-05-31: Bug-fix: Previously, when sfrom had no fields, sto was an empty struct.

% no need to check here, matlab will do itself.
% nitem = length(sfrom);
% cn_assert(length(sto)==nitem,'sfrom and sto has to be of same length');

cn_assert(nargin <= 4,'invalid # input');

if isempty(sfrom)
    return;
end

if nargin < 3
    fnames = fieldnames(sfrom);
elseif ~iscell(fnames)
    fnames = {fnames};
end

if nargin < 4
    newnames = fnames;
elseif ~iscell(newnames)
    newnames = {newnames};
end

n = numel(fnames);
assert(length(newnames)==n,'inconsistent length of fnames and newnames arrays');

if ~isempty(sto)
    assert( isequal( size(sfrom), size(sto) ), 'sto should be either empty or of same size with sfrom' );
end

if n > 0 
    % there is at least a field.
    for j = 1:n
        if isempty(sto)
            sto(numel(sfrom)).(newnames{j}) = [];
        end
        [sto.(newnames{j})] = sfrom.(fnames{j});
    end
    sto = reshape(sto,size(sfrom));
end

