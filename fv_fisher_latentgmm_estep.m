function [eprm,fvbase] = fv_fisher_latentgmm_estep(fvbase,N,D,K,eprm_old,genm,p)
% Variational E-step. 
%
% INPUT
% fvbase    
% ...
% eprm_old  
% genm     (1 D K) or (1 K)
%
% OUTPUT
% eprm: (N D K) or (N K)
% fvbase:   Deletes E_x and E_x2 and introduces cntE_x, cntE_x2.
%
% Sep'11
% fvbase:
% E_x       (N D K) 
% E_x2      (N D K) 
% counts    (N K)
%
% Gokberk Cinbis and Jakob Verbeek, 2011

try

    if isfield(p.method,'debug')
        debug = p.method.debug;
    else
        debug = false;
    end
    if ~debug
        eprm = detach(eprm_old); else; eprm_old = []; % eprm_old consumes a lot of memory.
    end

    counts3 = reshape(fvbase.counts,N,1,K); % (N 1 K)

    % can save ~4 secs when K=512
    if ~isfield(fvbase,'cntE_x') && p.method.appdesc
        q_tic = tic;
        fvbase.cntE_x = btimes(counts3,fvbase.E_x);
        fvbase = rmfield(fvbase,'E_x');
        fvbase.cntE_x2 = btimes(counts3,fvbase.E_x2);
        fvbase = rmfield(fvbase,'E_x2');
        toc(q_tic);
    end

    if p.method.appdesc

        eprm.beta = bplus( genm.beta, counts3 ); % (N D K)

        if debug && ~isempty(eprm_old);
            fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'e_beta');
        end

        eprm.mu0 = bplus( fvbase.cntE_x, genm.beta .* genm.mu0 ) ./ eprm.beta ; % (N D K)

        if debug && ~isempty(eprm_old);
            fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'e_mu0');
        end

        eprm.a = bplus(genm.a, counts3 / 2); % (N D K)

        eprm.b = bplus(genm.b + 0.5 * genm.beta .* genm.mu0.^2, ...
            0.5 * ( fvbase.cntE_x2 - eprm.beta .* eprm.mu0.^2 ) );  % (N D K)
        eprm.b = max(eprm.b,p.method.estep_minb);

        % -- precalculations --

        % ab_dml: digamma_mt(eprm.a+eps) - log(eprm.b+eps); % (N D K), expected log-precision under posteriors
        eprm.ab_dml = digamma_mt(eprm.a+eps) - log(eprm.b+eps); 
        eprm.mean_ab_dml   = mean(eprm.ab_dml,1); % (1 D K)
        eprm.ab_dml_sum2 = sum(eprm.ab_dml,2); % (N 1 K)
        eprm = rmfield(eprm,'ab_dml'); % free memory

        eprm.ab_rat = eprm.a ./ (eps+eprm.b); % (N D K), expected precision under posteriors
        eprm.mean_ab_rat   = mean(eprm.ab_rat,1); % (1 D K)
        if ~all(isfinite(eprm.mean_ab_rat(:)))
            disp('[keyboard] error! mean_ab_rat contains non-finite values!');
            keyboard
        end

        if debug && ~isempty(eprm_old);
            fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'e_ab');
        end

    end

    eprm.alpha = bplus( genm.alpha, fvbase.counts );

    % precalculate
    eprm.alpha_ms = bsxfun(@minus,digamma_mt(eprm.alpha),digamma_mt(sum(eprm.alpha,2))); % (N K), expected log-mixingweights under posteriors

    if debug 
        fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'e_alpha');
    end

catch e
    fv_catch(e); keyboard;
end


