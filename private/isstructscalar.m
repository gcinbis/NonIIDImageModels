function x = isstructscalar(p)

if isstruct(p) && (length(p)==1)
    x = true;
else
    x = false;
end

