function v = rowvec(x,d)
% Returns reshape(x,1,[])=x(:).' 
% (But NOT x(:)', which differs for complex numbers)
%
% INPUT
% x
% [d]   Optional: Implicitly checks that numel(x)==d.
%
% SEE colvec
%
% R.Gokberk Cinbis, July 2011

if nargin<2
    v = x(:).';
else
    v = reshape(x,1,d);
end
   


