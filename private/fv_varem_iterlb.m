function [iterlb2] = fv_varem_iterlb(p,name,lb)
%
% Use fv_varem_iterlb() to initialize it.
%
% INPUT
% p     Unused.     
% name  description of the step last made 
% lb    current lower bound
%
% OUTPUT
% iterlb2
%
% Gokberk Cinbis, 2011

persistent iterlb

if nargin==0
    iterlb = [];
    iterlb.vals = [];
    iterlb.names = {};
    return;
else
    iterlb.vals(end+1) = lb;
    iterlb.names{end+1} = name;
end

x = iterlb.vals;
if length(x)>1
    diff(x(max(1,end-3):end))
    %  plot(diff(x))
    %  rel_change = (LogL(iter)-LogL(iter-1)) / abs(mean(LogL(iter-1:iter)));
end

iterlb2 = iterlb;

