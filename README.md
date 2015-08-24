# Source Code for Non-i.i.d. Image Models

This package provides the Matlab source code for training and extracting Fisher vectors of Latent Bag-of-Words (LatBoW) and Latent Mixture-of-Gaussians (LatMoG) models, as explained in 
* Ramazan Gokberk Cinbis, Jakob Verbeek, Cordelia Schmid, “Image categorization using Fisher kernels of non-iid image models”, in IEEE Conference on Computer Vision & Pattern Recognition (CVPR), Providence, USA, June 2012

Call 
``` 
[genm,eprm] = fv_fisher_latentgmm_variationalestimate(p,fvbase,N,D,K,[])
```
to train a generative model `genm` using variational expectation-maximization (EM) procedure. This function also returns the posteriors `eprm` for the training examples. 

Call
```
    [eprm] = fv_fisher_latentgmm_estep(fvbase,N,D,K,[],genm,p)
```
to estimate posteriors on test images.


Call
```
    [desc] = fv_fisher_latentgmm_grads(N,D,K,gradopt,genm,eprm)
```
to extract LatMoG Fisher vectors. Use `grapopt=alpha` for the LatBoW model and `grapopt=all` for the LatMoG model to get all Fisher vector components. In our experiments, we then apply per-dimension whitening and L2 normalization to the resulting descriptors, as explained in the paper.

In order to utilize the aforementioned functions, the following per-image statistics over local descriptors should to be provided in the `fvbase` struct:
field         | Size          | Contents  
------------- |:-------------:|:---------:
  E_x         |   (N D K)     | E_x(j,:,k)=sum_i( p(k\|x_i) * x_i ) / sum_i( p(k\|x_i) ), over x_i \in image_j |
  E_x2        | (N D K)       | E_x2(j,:,k)=sum_i( p(k\|x_i) * x_i^2 ) / sum_i( p(k\|x_i) )
  counts      | (N K)         | counts(j,k)=sum_i( p(k\|x_i) ), over x_i \in image_j
where 
* `x_i` i-th local descriptor in an image.
* `N`:  number of training images
* `D`:  local descriptor dimensionality
* `K`:  vocabulary size
* `E_x` and `E_x2` fields are not needed when training LatBoW models.

A couple of other options should be provided in the `p` struct. See `example.m` for default values and their explanations.
 
A final note: When using spatial grids, we train per-cell models independently.

