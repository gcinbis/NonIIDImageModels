function alpha = fv_varem_init_dirichlet(counts)
% alpha = fv_varem_init_dirichlet(counts)
% 
% INPUT
% counts:   (N K) word/sample histograms (or sum of posteriors)
%           (ex: fvbase .counts)
%
% OUTPUT
% alpha     (1 K)
%
% Gokberk Cinbis and Jakbo Verbeek, 2011

% old: alpha = mean( counts, 1 ); % (1 K) dirichlet prior
alpha_m = mean( i_norm(counts,2), 1 ); % (1 K)
alpha_v = var( i_norm(counts,2), 1, 1 ); % (1 K)
sc = mean( alpha_v ./  (eps + alpha_m - alpha_m.^2 - alpha_v), 2 );
alpha = alpha_m * (sc+eps) + eps;




function x = i_norm(x,d)

% change to cn_normsumone?
x = bsxfun(@times,x,1./(eps+sum(x,d)));



