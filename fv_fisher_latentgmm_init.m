function genm = fv_fisher_latentgmm_init(p,fvbase,N,D,K)
% Initialize model.
%
% Gokberk Cinbis and Jakob Verbeek, 2012, revised 2015

%imw = reshape(i_norm(fvbase.counts,1),[N 1 K]); % (N 1 K) image weights based on p(c|x) 
imw = fvbase.counts;
imw( imw < p.method.init_cutoff ) = 0;
imw = reshape(i_norm(imw,1),[N 1 K]); % (N 1 K) image weights based on p(c|x) 

alpha = fv_varem_init_dirichlet(fvbase.counts);

if p.method.appdesc

    mu0 = i_wsum(fvbase.E_x,imw,1); % (1 D K) prior on mu

    empprec = 1./max(fvbase.E_x2 - fvbase.E_x.^2, eps); % (N D K)
    cn_whos('minmax',empprec); 
    fprintf('Applying init_minEmpVar option (%s,%s)',...
        p.method.init_minEmpVarMethod,num2str(p.method.init_minEmpVar));
    switch(p.method.init_minEmpVarMethod)
        case 'absolute' % previously this was the default behaviour
            if max(empprec(:)) > (1./p.method.init_minEmpVar)
                empprec = min( empprec, (1./p.method.init_minEmpVar) );
            end
        case 'relativeToGlobalVar'
            globalVar = sum(bsxfun(@times,imw,fvbase.E_x2),1) - sum(bsxfun(@times,imw,fvbase.E_x).^2,1);
            % var > k * globalVar => prec < (1/k) * globalPrec
            empprec = bsxfun(@min,empprec, 1 ./ (p.method.init_minEmpVar .* globalVar) );
        otherwise
            error('unknown');
    end
    cn_whos('minmax',empprec); 

    % Weighted average of empirical precision gives expected precision E[lambda]=a/b
    empprec_mean = i_wsum(empprec,imw,1); % (1 D K) 

    % variance of the empirical variance is the var(lambda)=
    % this is the variance of empirical variance = a/(b^2)
    empprec_var = i_wsum(bsxfun(@minus,empprec,empprec_mean).^2,imw,1); % (1 D K)
    b = empprec_mean./(eps+empprec_var); % (1 D K)
    a = empprec_mean.*b;

    % empirical variance 1/(beta*lambda) for the prior
    % mu0var is just a name I made up to refer to this variable. Technically it is not right.
    mu0var = i_wsum(bsxfun(@minus,fvbase.E_x,mu0).^2,imw,1); % (1 D K)

    % 1 / (lambda*(1/beta*lambda))=beta
    beta =  1 ./ (eps+empprec_mean.*mu0var); % (1 D K)

    genm = cn_vars2struct('mu0','a','b','beta','alpha');

else

    genm = cn_vars2struct('alpha');

end

cn_whos('minmax',genm);

end




function x = i_norm(x,d)

% change to cn_normsumone?
x = bsxfun(@times,x,1./(eps+sum(x,d)));

end




function x = i_wsum(x,w,d)

x = sum(bsxfun(@times,x,w),d);

end

