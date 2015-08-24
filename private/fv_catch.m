function fv_catch(e)

ERROR = 1;

disp(e.getReport());

if ERROR
    rethrow(e);
end

disp('--- error has been catched [keyboard] First rerun manually and then dbcont(). ---');

