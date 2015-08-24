function cn_whos(opt,varargin)
% Usages:
% 
% cn_whos()
% cn_whos(opt) 
% cn_whos(var1,var2,var3...)            [var1 cannot be of type char!]
% cn_whos(opt,var1,var2,var3...)
%   Prints info about the given variables in a readable format.
%   If a variable passed explicitly as an argument is a structure array, its
%   subfields will be printed.
% 
% opt
%   'minmax'        Show min/max values. (default)
%   'minmaxmed'     Show min/max/median values.
%   'minmaxmean'    Show min/max/mean values.
%   'mean'
%
% For numeric variables, informs user about NaN entries. 
%
% R.G.Cinbis Jan 2011. Migrated from cn_minmax() in Sep 2011.

if nargin==0 || isempty(opt)
    opt = 'minmax';
end

varnames = {};
for j = length(varargin):-1:1
    varnames{j} = inputname(j+1);
end

if ~ischar(opt)
    varargin = [{opt} varargin];
    varnames = [{inputname(1)} varnames];
    opt = 'minmax';
end

for j = 1:length(varnames)
    if isempty(varnames{j})
        varnames{j} = sprintf('<arg %d>',j);
    end
end

%table = {'NAME','SIZE','TYPE','INFO'};
table = {'NAME','SIZE','TYPE',upper(opt)};
%table{end+1,1} = [];

% we should check it here in case all variables are struct
if ~ismember(opt,{'minmax','minmaxmean','minmaxmed','mean'});
    error(['unknown opt=' opt]);
end

if length(varargin)>0
    for j = 1:length(varargin)
        x = varargin{j};
        n = varnames{j};
        table = addvar(opt,n,x,true,table);
    end
else 
    vars = evalin('caller','who');
    vars = setdiff(vars,'ans');
    for j = 1:length(vars)
        x = evalin('caller',vars{j});        
        n = vars{j}; 
        table = addvar(opt,n,x,false,table);
    end       
end

disp(cn_table2txt(table));


function table = addvar(opt,n,x,recurse,table)
% n: name
% x: variable

if isempty(n)
    n = '?';
end

if recurse && isstructscalar(x) 

    xfields = fieldnames(x);
    for z = 1:length(xfields)
        table = addvar(opt,[n '.' xfields{z}],x.(xfields{z}),false,table);
    end
    return

else
    ti = size(table,1) + 1;
    table{ti,1} = n;

    sztxt = sprintf('%dx',size(x));
    sztxt = sztxt(1:(end-1));
    table{ti,2} = sztxt;

    if issparse(x)
        table{ti,3} = ['sparse ' class(x)];
    else
        table{ti,3} = class(x);
    end

    if isnumeric(x) && ~isempty(x)
        switch(opt)
            case 'minmax'
                y = i_minmax(x);
            case 'minmaxmean'
                y = i_minmax(x);
                y = [y ' ' i_mean(x)];
            case 'minmaxmed'
                y = i_minmax(x);
                y = [y ' ' i_median(x)];
            case 'mean'
                y = i_mean(x);
            otherwise
                error('unrecognized opt');
        end

        if any(isnan(x(:)))
            y = [y ' -- HAS NaN!'];
        end

        table{ti,4} = y;

    end
end




function y = i_minmax(x)

mins = num2str(min(x(:)));
maxs = num2str(max(x(:)));
if numel(x)==1
    y = mins;
else
    y = sprintf('%s ~ %s',mins,maxs);
end


function y = i_mean(x)

y = ['mu=' num2str(mean(x(:)))];


function y = i_median(x)

y = ['med=' num2str(median(x(:)))];


