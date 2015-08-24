function alpha = fv_varem_mfit_dirichlet(mean_eprm_alpha_ms,alpha_old)
% Variational EM's m step, fit dirichlet distribution 
% via maximizing E_q[ Dir(alpha) ] where q is variational dirichlet with 
% 
% INPUT
% mean_eprm_alpha_ms    (1 K) mean of per-image digamma_mt(alpha*)-digamma_mt(sum(alpha*)) variational params.
% alpha_old             (1 K) alpha params from the previous iteration.
%
% OUTPUT
% alpha                 (1 K) new alpha values
%
% 
% Gokberk Cinbis and Jakob Verbeek, Sep 2011

% sanity
assert(isvector(alpha_old));
assert(isvector(mean_eprm_alpha_ms));
K = length(alpha_old);
assert(length(mean_eprm_alpha_ms)==K);


% while we used a different lbfgsb implementation in our experiments, this seems to work fine:
[alpha,y] = fmincon(@i_obj_alpha,alpha_old,...
    [],[],[],[],repmat(eps,1,K),[],[],optimset('Hessian','lbfgs','Algorithm','interior-point'));
if ~(isfinite(y))
    disp('keyboard--nonfinite objective');
    keyboard
end

    function [obj,grad] = i_obj_alpha(xalpha)


        if any(xalpha < eps)
            disp('optimization doesnt respect lowerbound');
            xalpha = max(xalpha, eps);
        end

        xalpha = reshape(xalpha,1,K);

        obj = ls_gammaln(sum(xalpha)) + ...
            sum( -ls_gammaln(xalpha) ) + (xalpha-1)*mean_eprm_alpha_ms(:);

        grad = mean_eprm_alpha_ms - ( digamma_mt(xalpha) - digamma_mt(sum(xalpha)) );

        % maximization
        obj = -obj;
        grad = -grad;

    end


end


