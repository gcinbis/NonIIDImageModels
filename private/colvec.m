function v = colvec(x,d)
% Returns reshape(x,[],1)=x(:)
%
% INPUT
% x
% [d]   Optional: Implicitly checks that numel(x)==d.
%
% SEE rowvec
%
% R.Gokberk Cinbis, July 2011

if nargin<2
    v = x(:);
else
    v = reshape(x,d,1);
end
   

