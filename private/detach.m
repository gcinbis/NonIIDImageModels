function x = detach(x)
% USAGE
% function_name( detach(variable) )
%
% Remove variable from the workspace before passing to the function
% function_name().
%
% DESCRIPTION
% In matlab, when a variable passed into a function is modified within the
% function, a copy of the variable is created on the fly, unless the variable
% is completely a temporary variable or unless the same variable is retrieved
% as an output argument.
%
% detach() is a very simple function to clear the variable from the caller 
% workspace and convert it into a temporary variable that is not accessible
% anymore upon return from the function call. If variable doesn't exist in
% another workspace, this avoids copy-on-write. detach() can also be handy for
% code clarity.
%
% NOTES
% A use like detach(x+1) has no effect since x+1 is already a temporary
% variable created based on a copy of x. In this example, 'x' would remain in 
% the caller workspace. Displays a warning message in such cases. 
% (Instead, detach(x)+1 should be used.)
%
% evalin() may not work properly when used in debug mode with dbup/dbdown.
%
% SEE detachfield() 
%
% Gokberk Cinbis Nov 2011

n = inputname(1);
if isempty(n)
    disp('detach(): cant detach, argument is already a temporary variable');
else
    evalin('caller',['clear ' n]);
end

