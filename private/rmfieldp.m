function x = rmfieldp(x,fields)
% Same with rmfield but doesn't generate an error if field(s) dont exist.

if ischar(fields)
    fields = {fields};
end

for i = 1:length(fields)
    f = fields{i};
    if isfield(x,f)
        x =rmfield(x,f);
    end
end

