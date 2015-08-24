% Example script to train a LatMoG model and compute its Fisher vectors.

%% Collect image statistics based on random local descriptors

% parameters for random data generation
N = 10; % number of training images.
D = 3;  % local descriptor dimensionality.
K = 2;  % vocabulary size
NumLocalDescRange = [100 200] % [min max]
seed = 100; % random seed

% generate data and collect statistics
RandStream.setGlobalStream( RandStream.create('mt19937ar','seed',seed) );
fvbase.E_x    = zeros(N,D,K);
fvbase.E_x2   = zeros(N,D,K);
fvbase.counts = zeros(N,K);
for imi = 1:N
    n  = ceil(rand * (NumLocalDescRange(2)-NumLocalDescRange(1)) + NumLocalDescRange(1));
    % generate local descriptors
    X  = rand(D,n); 
    X2 = X.^2; 
    % component posteriors
    Q = rand(n,K); 
    Q = bsxfun(@rdivide,Q,sum(Q,2)+eps);
    % collect statistics
    counts = sum(Q,1); % (1 K)
    W = bsxfun(@times, Q, 1 ./ ( eps + counts ) ); % (N K)
    fvbase.counts(imi,:) = counts;
    fvbase.E_x(imi,:,:)  = shiftdim( X * W, -1);  % (1 D K)
    fvbase.E_x2(imi,:,:) = shiftdim( X2 * W, -1 ); % (1 D K)
end

%% train generative model and extract Fisher vectors

% important parameters.
p.method.appdesc              = 1; % 0=LatBoW 1=LatMoG
p.method.init_minEmpVar       = 0.1; % Minimum empirical variance. We cross-validate this parameter.

% other params
p.method.maxemiter            = 50; % Number of variational EM iterations.
p.method.debug                = 0;  % Enable/disable debug mode (see code for exact effects).
p.method.init_cutoff          = 10; % Cut-off threshold to ignore initialization statistics based on too few visual words.
p.method.init_minEmpVarMethod = 'relativeToGlobalVar';  % Declares that init_minEmpVar is relative to global variance.
p.method.estep_minb           = eps; % minimum "b" value in E-step.
p.method.mstep_mina           = eps; % minimum "a" value in M-step.

% train
[genm,eprm] = fv_fisher_latentgmm_variationalestimate(p,fvbase,N,D,K,[]);

% compute gradients on training images
[desc,dinfo] = fv_fisher_latentgmm_grads(N,D,K,'all',genm,eprm);

