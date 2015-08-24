function seps = cn_stringseps(seps)
% Definition of rules and separatures used by cn_any2string(), cn_struct2string(), cn_strNameValPairs().
% 
% INPUT
% seps
% Either a struct
%       .field
%       .pair
%       .cellarray
%       .numarray
%       .substructfields
%       .[structarray]      If input is a structure array, how to separate the entries. (def='_')
%                           Options:  (These are constants that are handled specially)
%                           '_' 
%                           '(%d)' 
%       .[isfilename]       Replaces all spaces and '/' with '_'.
%       .[MaxNameLen]       Gets up to N characters from each field name. 
%       .[fieldprefix]      A prefix to every fieldname.
% OR predefined options:
%       'readible1'     Good for creating a readible, single-line string.
%       'display1'      Good for creating a readible, multi-line string.
%       'filename1'     Filename with separators. 
%       'filenameE'     Filename without separators.
%       'space'         Each separator is a space.
%       'none'          Without any separators.
% And any prefined with '<predefname>MaxNameN' (ex:'filename1MaxName5')
%
% OUTPUT
% seps  Converted into a structure.
%
% SEE cn_any2string cn_struct2string cn_strNameValPairs cn_stringseps
% 
% R.G.Cinbis July 2011

if ~isstruct(seps) && ~isempty(seps)

    seps_org = seps;
    seps     = [];
    
    j = strfind(seps_org,'MaxName');
    if ~isempty(j)
        j= j(1);
        assert(j>1);
        k               = length('MaxName');
        seps.MaxNameLen = str2num(seps_org((j+k):end));
        assert(isscalar(seps.MaxNameLen),'MaxName is not properly defined');
        seps_org        = seps_org(1:(j-1));
    end

    switch(seps_org)
        case 'readible1'
            seps.field     = ' |  ';
            seps.pair      = ': ';
            seps.cellarray = ' ; ';
            seps.numarray  = ',';
        case 'filename1'
            seps.isfilename = true;
            seps.field     = '_';
            seps.pair      = '';
            seps.cellarray = '-';
            seps.numarray  = '_';
        case 'filenameE'
            seps.isfilename = true;
            seps.field     = '';
            seps.pair      = '';
            seps.cellarray = '';
            seps.numarray  = '';
        case 'space'
            seps.field     = ' ';
            seps.pair      = ' ';
            seps.cellarray = ' ';
            seps.numarray  = ' ';
        case 'display1'
            seps.field     = sprintf('\n');
            seps.pair      = ': ';
            seps.cellarray = ', ';
            seps.cellstart = '{';
            seps.cellend = '}';
            seps.numarray  = ' ';
            seps.substructfields = ' .';
            seps.structarray = '(%d)';
        case 'none'
            seps.field     = '';
            seps.pair      = '';
            seps.cellarray = '';
            seps.numarray  = '';
        otherwise
            error('unknown seps');
    end
end

% important: dont overwrite empty fields!
seps = cn_setfielddefaults(seps,false,'field','_','pair','',...
    'cellarray','-','numarray','_','fieldprefix','',...
    'substructfields',seps.pair,'structarray','_',...
    'structrecurselevel',0,'cellstart','','cellend','');

% overwrite the following if empty
seps = cn_setfielddefaults(seps,true,'MaxNameLen',inf,'isfilename',false);


