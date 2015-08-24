function s = cn_vars2struct(varargin)
% USAGE
%
% s = cn_vars2struct(varname1,varname2,...)
%
% Creates the structure s from the variables in the caller
% workspace with the same names.
%
% s = cn_vars2struct('*')
%
% Copy all variables in the caller workspace into s.
%
% EXAMPLE
% x = 12; y = 3; s = cn_vars2struct('x','y');
%
% SEE
% cn_struct2vars
%
% R.G.Cinbis June 2010

% todo: who,load,etc like pattern matching support to generalize '*' option.

if nargin==1 && isequal(varargin{1},'*')
    names = evalin('caller','who');
else
    names = varargin;
end

for j = 1:length(names)
    n = names{j};
    s.(n) = evalin('caller',n);
end


