function lb = fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,name)
% Compute variational lower-bound.
%
% Gokberk Cinbis and Jakob Verbeek, 2012

try

    lb = 0;

    % H[q_pi]
    x = -sum((eprm.alpha-1).*(eprm.alpha_ms-ls_gammaln(eprm.alpha+eps)),2) - ls_gammaln(sum(eprm.alpha,2)); % (N 1)
    lb = lb + mean(x);

    if p.method.appdesc
        % H[q_lambda] 
        x = ls_gammaln(eps+eprm.a)-(eprm.a-1).*digamma_mt(eps+eprm.a)-log(eprm.b+eps)+eprm.a;
        lb = lb + mean(sum(reshape(x,N,D*K),2));

        % E[ H[q_mu|lambda] ]
        % equal: y = mean(sum(reshape(  -0.5*log(eps+eprm.beta)-0.5.*eprm.ab_dml,   N,D*K),2));
        x = mean(sum(  -0.5*sum(log(eps+eprm.beta),2)-0.5.*eprm.ab_dml_sum2,  3));
        lb = lb + x;

    end

    % H[ q_zi ]
    lb = lb + (1/N)* sum(fvbase.counts,2)'* fvbase.E_Hk(:) ;

    % E[ log p(pi) ]
    x = ls_gammaln(sum(genm.alpha,2)) - sum( ls_gammaln(genm.alpha)) + (genm.alpha-1)*mean(eprm.alpha_ms,1)' ; 
    lb = lb + x;

    if p.method.appdesc

        inv_eprm_beta = 1./(eps+eprm.beta); % (N D K)
        mean_inv_beta = mean(inv_eprm_beta      ,1);
        mean_ab_xxx   = mean(eprm.ab_rat.*bminus(eprm.mu0,genm.mu0).^2,1);

        % E[ log p(lambda) ]
        x = -sum(ls_gammaln(genm.a(:))) + genm.a(:)'*log(eps+genm.b(:)) + (genm.a(:)'-1)*eprm.mean_ab_dml(:) - genm.b(:)'*eprm.mean_ab_rat(:);
        lb = lb + x;

        % E[ log p(mu|lambda) ]
        x = sum(log(eps+genm.beta(:))) + sum( eprm.mean_ab_dml(:) ) + genm.beta(:)' * mean_inv_beta(:) - genm.beta(:)'*mean_ab_xxx(:);
        lb = lb + x/2;

        % E[ sum_i log p(zi|pi) ]
        lb = lb + mean( sum( fvbase.counts .* eprm.alpha_ms, 2) ,1);

        % E[ sum_i log p(xi|zi,lambda,mu) ]
        % -- org --
        % y = eprm.ab_dml - inv_eprm_beta - eprm.ab_rat.*( fvbase.E_x2 + eprm.mu0.^2 - 2.*fvbase.E_x.*eprm.mu0 );
        % y = sum(y,2); % (N 1 K)
        % y = fvbase.counts(:)'*y(:);
        % -- the same but works with cntE_x and cntE_x2 --
        x = eprm.ab_dml_sum2 - sum( inv_eprm_beta + eprm.ab_rat.*eprm.mu0.^2, 2 ); % (N 1 K)
        x = fvbase.counts(:)'*x(:);
        x = x - sum(colvec( eprm.ab_rat.*( fvbase.cntE_x2 - 2.*fvbase.cntE_x.*eprm.mu0 ) ));

        lb = lb + x / (2*N);

    end

    if ~isempty(name)
        fv_varem_iterlb(p, name, lb);
    end

catch e
    fv_catch(e); keyboard;
end
