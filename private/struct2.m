function x = struct2(varargin)
% Very similar to struct()
%
% This is equivalent to 
%   x.(name1) = (val1)
%   ... etc
% whereas 
%   struct() handles cell arrays differently.
%
% Assignments are done from left to done. Latter assignments can overwrite previous ones.
%
% SEE structR
%
% R.G.Cinbis Jan 2011

assert(mod(length(varargin),2)==0,'Invalid (odd) number of input arguments.');

np = length(varargin) / 2;
for j = 1:np
    i2 = j*2;
    varargin{i2} = {varargin{i2}};
end
x = struct(varargin{:});

%x = struct;
%np = length(varargin) / 2;
%for j = 1:np
%    i1 = (j-1)*2+1;
%    i2 = i1+1;
%    f = varargin{i1};
%    v = varargin{i2};
%    x.(f) = v;
%end


