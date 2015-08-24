function [desc,dinfo] = fv_fisher_latentgmm_grads(N,D,K,gradopt,genm,eprm)
% Extract gradients wrt model parameters. Useful in 1) fisher vector extraction 2) hyperparameter
% learning via variational inference (for M step).
%
% INPUT
% N,D,K
% gradopt   'all' (LatMoG) | 'alpha' (LatBoW, use if appdesc=false) | ... 
% genm      Output of fv_fisher_latentgmm_variationalestimate.
%           (1 D K) or (1 K)
% eprm      Params containing found in the E step of variational approximation.
%           (corresponding to a*,b*,etc in the paper). (N D K) or (N K). Provide with detach().
%
% OUTPUT
% desc      (N dlen)
% dinfo     Information about the ordering of descriptors in "desc"
%       .k  (1 ddesc) index denoting which component creates a particular the descriptor dimension.
%
% Gokberk Cinbis and Jakob Verbeek, Sep'11

try

    % keep only potentially necessary data
    eprm = cn_selfields(eprm,{'ab_dml','a','b','ab_rat','beta','alpha_ms','mu0'},true);

    % ordering is not important here
    switch(gradopt)
        case 'all'
            g = {'a','b','mu0','beta','alpha'};
        case 'alpha'
            g = {'alpha'};
        case 'gaussonly' % all - alpha (useful!)
            g = {'a','b','mu0','beta'};
        case 'mu0'
            g = {'mu0'};
        otherwise
            error unknown
    end
    g = cn_selections2struct({'b','a','mu0','beta','alpha'},g);

    % find descriptor length
    % all => dlen = D*K*4+K -- for D=80;K=1024;N=10000; we need 27GB.
    dlen = 0;
    if g.a;     dlen = dlen + D*K;  end
    if g.b;     dlen = dlen + D*K;  end
    if g.mu0;   dlen = dlen + D*K;  end
    if g.beta;  dlen = dlen + D*K;  end
    if g.alpha; dlen = dlen + K;    end

    % -- sufficient stats --

    if g.a && ~isfield(eprm,'ab_dml')
        % normally this is the case.
        fprintf('calculating ab_dml... (usual)');
        q_tic = tic;
        eprm.ab_dml = digamma_mt(eprm.a+eps) - log(eprm.b+eps); 
        toc(q_tic);
    end
    eprm = rmfieldp(eprm,'a');
    eprm = rmfieldp(eprm,'b');

    % -- allocs --

    desc = zeros(N,dlen);
    dinfo.k = zeros(1,dlen);

    % be careful about the ordering!
    i0 = 0;

    info_1xDxK = repmat( reshape(1:K,[1 1 K]), [1 D 1]);
    info_1xK   = 1:K; 

    % -- grads --
    
    if g.a
        iadd( bsxfun(@plus, - digamma_mt(genm.a) + log(genm.b), eprm.ab_dml), info_1xDxK );
    end
    eprm = rmfieldp(eprm,'ab_dml');
    
    if g.b
        iadd( bsxfun(@minus, genm.a ./ (eps+genm.b), eprm.ab_rat ), info_1xDxK );
    end
    
    if g.mu0 || g.beta
        x = bsxfun(@minus,eprm.mu0,genm.mu0); % mu0_e_g (N D*K)
        eprm = rmfieldp(eprm,'mu0');

        if g.mu0
            iadd( bsxfun( @times, genm.beta,  eprm.ab_rat .* x ), info_1xDxK ); % (N D*K)
        end

        x = eprm.ab_rat .* x.^2; % eprm.ab_rat .* mu0_e_g.^2 
        eprm = rmfieldp(eprm,'ab_rat');

        if g.beta
            iadd( 0.5.*( bsxfun(@minus, 1./(eps+genm.beta), detach(x) ) - 1./(eps+eprm.beta) ), info_1xDxK );
        end
    end
    eprm = rmfieldp(eprm,'ab_rat');
    eprm = rmfieldp(eprm,'beta');
    eprm = rmfieldp(eprm,'mu0');

    if g.alpha
        iadd( bsxfun(@minus,eprm.alpha_ms,digamma_mt(genm.alpha)) + digamma_mt(sum(genm.alpha)), info_1xK );
    end

catch e
    fv_catch(e); keyboard;
end



    function iadd(newdata,newinfok)
        % add descriptor data

        assert(size(newdata,2)==size(newinfok,2));
        assert(size(newdata,3)==size(newinfok,3));
        i2 = i0+size(newdata,2)*size(newdata,3);
        assert(i2<=size(desc,2));
        desc(:,(i0+1):i2) = reshape(newdata,N,[]);
        dinfo.k(1,(i0+1):i2) = rowvec(newinfok);
        i0 = i2;

    end

end

