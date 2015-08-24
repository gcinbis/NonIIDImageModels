function str = cn_any2string(x,seps)
% A generic function that covers a lot of cases (cell arrays, cells of structs, structs, etc) 
% for conversion into a single-line/multi-line string, depending on "sep" options.
%
% INPUT
% x     An array/cell array/structure/etc.
% seps  See cn_stringseps (default='display1')
% 
% OUTPUT
% str   Output string.
%
% SEE cn_any2string cn_struct2string cn_strNameValPairs cn_stringseps
% 
% R.G.Cinbis July 2011

if nargin < 2
    seps = 'display1';
end

seps = cn_stringseps(seps);
cls = class(x);

if ischar(x)
    str = x;
elseif isempty(x)
    str = '';
elseif isnumeric(x) || islogical(x)
    % use sepfield to separate number as numbers cannot become field names.
    %     seppair can be empty, then, number will become indistinguishable.
    str = cn_numarray2str(x,seps.numarray); 
elseif iscell(x)
    % recursively handle the entries
    for i = 1:numel(x)
        xs = cn_any2string(x{i},seps);
        if i == 1
            str = [seps.cellstart xs];
        else
            str = [str seps.cellarray xs];
        end
        if i == numel(x)
            str = [str seps.cellend];
        end
    end
elseif isstruct(x) || isa(x,'StructLocked')
    if seps.structrecurselevel==0
        str = cn_struct2string(x,seps);
    else
        seps.fieldprefix = [seps.substructfields seps.fieldprefix];
        str = [seps.field cn_struct2string(x,seps)];
    end
elseif strcmp(cls,'function_handle')
    str = ['@' func2str(x)];
else 
    % todo: object's conversion itno string??
    error('unknown type to convert into string');
end




