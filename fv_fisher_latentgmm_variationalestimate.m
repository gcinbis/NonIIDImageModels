function [genm,eprm] = fv_fisher_latentgmm_variationalestimate(p,fvbase,N,D,K,genm)
% Use variational inference to learn hyper parameters of the fisher vectors.
% Here, we assume that p(c|x) stays constant. This allow us to do all operations based on
% per-image zeroth/first/second moments.
%
% INPUT
% p
%   .method.appdesc              0=LatBoW 1=LatMoG
%   .method.maxemiter            Number of variational EM iterations.
%   .method.debug                Enable/disable debug mode (see code for exact effects).
%   .method.init_cutoff          Cut-off threshold to ignore initialization statistics based on too few visual words.
%   .method.init_minEmpVarMethod 'relativeToGlobalVar' Declares that init_minEmpVar is relative to global variance.
%                                'absolute' Declares that init_minEmpVar is not relative.
%   .method.init_minEmpVar       Minimum empirical variance. We cross-validate this parameter.
%   .method.estep_minb           minimum "b" value in E-step.
%   .method.mstep_mina           minimum "a" value in M-step.
% fvbase                         See README.md
% N                              Number of training images.
% D                              Local descriptor dimensionality.
% K                              Vocabulary size.
% genm                           Initial generative model. Provide [] if not available.
%
% Gokberk Cinbis and Jakob Verbeek, 2011

maxemiter = p.method.maxemiter;
clear functions

%%%% Initialization

% fvbase:
% E_x       (N D K) 
% E_x2      (N D K) 
% counts    (N K)

% we need E_x and E_x2 in initialization but not in later stages.

if maxemiter<0
    % test as a non-latent model via setting prior variances=0.
    error('maxiter<0:not implemented. use fv_gmm instead.');
elseif isempty(genm)
    try
        genm = fv_fisher_latentgmm_init(p,fvbase,N,D,K); % requires E_x, E_x2
    catch e
        fv_catch(e); keyboard;
    end
    fv_varem_iterlb();
end

eprm = [];

% iterate until convergence
iteri = 1;
while(true)    
    
    disp('e step');
    q=tic; [eprm,fvbase] = fv_fisher_latentgmm_estep(detach(fvbase),N,D,K,detach(eprm),genm,p); toc(q);
    
    % fv_fisher_latentgmm_lowerbound(fvbase,N,D,K,eprm,genm,p,'estep');
    
    cn_whos('minmax',genm,eprm);
    i_chkvals(genm);
    i_chkvals(eprm);
    fprintf('Variational EM iter %d max=%s \n',iteri,num2str(maxemiter));

    if iteri > maxemiter
        % be careful: eprm and genm should be in sync.
        break;
    end

    disp('m step');
    
    try
        q=tic; genm = fv_fisher_latentgmm_mstep(fvbase,N,D,K,eprm,genm,p); toc(q);        
    catch e
        fv_catch(e); keyboard;
    end
    
    iteri = iteri + 1;
end

% genm:
%   a,b,mu0,beta (1 D K) 
%   alpha: (1 K)
fn = fieldnames(genm);
for j = 1:length(fn)
    x = genm.(fn{j});
    assert( size(x,1)==1 & ...
        ( (size(x,2)==D & size(x,3)==K) | size(x,2)==K ) );
end

end




function i_chkvals(s)

fn = fieldnames(s);
for j = 1:length(fn)
    x = s.(fn{j});
    if ~all(isfinite(x))
        disp('keyboard--non finite value');
        keyboard
    end
end

end



function done = check_state(IterF,p)
% Check convergence based on lower bound.

done = false;
iteri = length(IterF);

if iteri>1
    rel_change = (IterF(iteri)-IterF(iteri-1)) / (1e-20+abs(mean(IterF(iteri-1:iteri))));
    cn_assert(isfinite(rel_change));
else 
    rel_change = inf;
end

if rel_change < 0;
    % can be due to loose lowerbound
    disp(sprintf('--> Lowerbound=%.4f decreased in iteration %d,  relative change %f\n',IterF(iteri),iteri,rel_change));
end

if (rel_change < p.method.emtol) && (iteri >= p.method.minemiter)
    done = true;
end

fprintf('iteration %3d   Logl %.4f  relative increment  %.6f\n',iteri, IterF(iteri),rel_change);

end



