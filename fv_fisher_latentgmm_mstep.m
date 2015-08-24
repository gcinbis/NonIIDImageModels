function genm = fv_fisher_latentgmm_mstep(fvbase,N,D,K,eprm,genm_old,p)
% eprm: (N D K) or (N K)
%
% genm:
%   a,b,mu0,beta (1 D K) 
%   alpha: (1 K)

tmp1=[];tmp2=[]; % keep for debugging
debug = p.method.debug;
if debug
    genm = genm_old;
end

if p.method.appdesc

    genm.mu0 = i_wsum( eprm.mu0, i_norm( eprm.ab_rat, 1), 1); % (1 D K)

    if debug
        fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'m_mu0');
    end

    genm.beta = 1 ./ (eps+mean(  ...
        eprm.ab_rat.*(bsxfun(@minus,eprm.mu0,genm.mu0).^2) + 1./(eprm.beta)  ...
        ,1)); % (1 D K)

    if debug 
        fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'m_beta');
    end

    mean_ab_dml = eprm.mean_ab_dml; % (1 D K)
    mean_ab_rat = eprm.mean_ab_rat; % (1 D K)
    log_mean_ab_rat = log( eps + mean_ab_rat ); % (1 D K)
    for d = D:-1:1
        for k = K:-1:1
            if cn_timepassth
                fprintf('fitting a,b d=%d/%d k=%d/%d \n',d,D,k,K);
            end

            tryi = 1;
            while(true)

                % while we used a different lbfgsb implementation in our experiments, this seems to work fine:
                % fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
                [genm.a(1,d,k),y] = fmincon(@i_obj_a,[genm_old.a(1,d,k)],[],[],[],[],[p.method.mstep_mina],[],[],optimset('Hessian','lbfgs','Algorithm','interior-point'));
                if ~(isfinite(y))
                    y
                    disp('nonfinite objective');
                    tryi

                    if tryi > 50
                        disp('keyboard--#try limit has been reached');
                        keyboard
                    end

                    pause(0.1);

                    tryi = tryi + 1;
                else
                    break;
                end

            end % end of while loop

            genm.b(1,d,k) = genm.a(1,d,k) / mean_ab_rat(1,d,k);

        end
    end

    if ~all(isfinite(genm.a(:))) || ~all(isfinite(genm.b(:)))
        disp('keyboard--nonfinite');
        keyboard
    end

    if debug 
        fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'m_ab');
    end

end

% all terms in F somewhat related to alpha: H(q_pi) + E[ log p(pi) + log(z|pi) ]
% H(q_pi) is constant in M step. log(z|pi) doesn't depend on alpha values.
% so, objective = E[ log p(pi) ] = 
mean_eprm_alpha_ms = mean(eprm.alpha_ms,1); % (1 K)
genm.alpha = fv_varem_mfit_dirichlet(mean_eprm_alpha_ms,genm_old.alpha);

if debug 
    fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'m_alpha');
end



    function [obj,grad] = i_obj_a(xa)

        if any(xa < eps)
            disp('optimization doesnt respect lowerbound');
            xa = max(xa, eps);
        end

        obj = -ls_gammaln(xa) + xa.*( log(xa) - log_mean_ab_rat(1,d,k) ) + (xa-1)*mean_ab_dml(1,d,k) - xa;     
        grad = -digamma_mt(xa)+log(xa) - log_mean_ab_rat(1,d,k) + mean_ab_dml(1,d,k);

        % maximization
        obj = -obj;
        grad = -grad;

    end


end

function x = i_norm(x,d)

% change to cn_normsumone?
x = bsxfun(@times,x,1./(eps+sum(x,d)));

end




function x = i_wsum(x,w,d)

x = sum(bsxfun(@times,x,w),d);

end





function val = getfieldorempty(s,f)

if isfield(s,f)
    val = s.(f);
else
    val = [];
end

end







