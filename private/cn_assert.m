function cn_assert(condition,errmsg,option)
% cn_assert(condition,errmsg,option)
% 
% This is similar to assert() however it is better behaved, 
% it generates a matlab error which is more suitable in some cases
% (if assert is used within a function passed to a mex file, matlab
%  behaves weirdly.) Also provides conveniently more options.
%
% Suggestion: For real bug-checks, use 'assert'
%             For user input checks, use 'cn_assert'  
%
% condition: 
%       boolean condition. if true, no error generated.
% [errmsg]: error message
% [option]: 'error'     error is generated.
%           'keyboard'  keyboard is called rather than error function. allows
%                       continuation of the code, so can be good in large scale xps.
%           'warning'   warning is generated rather than an error.
%
% SEE cn_assertprefs to set defaults.
%
% todo: condition can be a string to be evaluated
%
% RGC Nov 09

if condition
    return;
end

% function call overhead is fine. we arrive here only on an error:
cn_setvardefaults(true,'errmsg','');
cn_setvardefaults(true,'option',cn_assertprefs());

errmsg = ['cn_assert::failed ' errmsg];
fprintf('%s \n',errmsg); % print in any case before calling error()

evalin('caller','disp('' ----- whos info: ----- '')');
%evalin('caller','whos');
evalin('caller','cn_whos');
evalin('caller','disp('' DBSTACK:: '')');
evalin('caller','dbstack');

switch(option)
    case 'error'
        evalin('caller',['error(''' errmsg ''')']);

    case {'keyboard','keyb'}
        disp('cn_assert:calling keyboard(). can continue execution.');
        evalin('caller','keyboard');

    case 'warning'
        warning(errmsg);

    otherwise
        error('unknown option');
end


