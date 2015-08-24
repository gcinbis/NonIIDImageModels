function out = cn_table2txt(table,p)
% out = cn_table2txt(table)
%
% Given a table of entries, converts them into a well-spaced
% text format. If nargout==0, display on the console.
% 
% table       M x N cell array of contents
% [p]
%   .spacing    (def=auto)
%   .num2str    num2str function handle, eg: @(x) sprintf('%.1f',x)
%   .[automin]  (def=1) Minimum spacing for 'auto'.
%   .[automax]  (def=4) Maximum spacing for 'auto'.
%   .[autowidth] (def=100) Linewidth for 'auto'.
%
% SEE cn_table2latex cn_table2html cn_table2lyx cn_txt2table
%
% R.G.Cinbis March 2011

if nargin < 2
    p = [];
end
p = cn_setfielddefaults(p,true,'spacing','auto','automin',1,'automax',4,'autowidth',100);

M = size(table,1);
N = size(table,2);
assert(ndims(table)==2);

if isfield(p,'num2str')
    for i = 1:numel(table)
        if isnumeric(table{i})
            table{i} = p.num2str(table{i});
        end
    end
end

for i = 1:numel(table)
    x = table{i};
    x = cn_any2string(x,'display1');
    table{i} = x;
end

colmax = zeros(1,N);
for r = 1:M
    for c = 1:N
        colmax(c)=max(colmax(c),length(table{r,c}));
    end
end

if isequal(p.spacing,'auto')
    p.spacing = ceil(min(p.automax,max(p.automin,(p.autowidth- sum(colmax))/N)));
end
colmax(1:(end-1)) = colmax(1:(end-1)) + p.spacing;

fmt = cell(1,N);
for c = 1:N
    fmt{c} = ['%-' num2str(colmax(c)) 's'];
end
fmt = [fmt{:}];
fmt = ['%s' fmt '\n'];

txt = '';
for r = 1:M
    txt = sprintf(fmt,txt,table{r,:});
end

if nargout == 0
    disp(txt);
else
    out = txt;
end



