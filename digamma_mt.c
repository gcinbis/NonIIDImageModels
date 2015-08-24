/* Written by Tom Minka
 * (c) Microsoft Corporation. All rights reserved.
 *
 * multi-threaded by Gokberk Cinbis and Jakob Verbeek.
 */

/* mex digamma_mt.c CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" 
 * x = rand(1,1e6);
 * tic;q=digamma(x);toc;tic;w=digamma_mt(x);toc;assert(isequal(q,w));
 */

#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <float.h>
#include <omp.h>
#include <sched.h>
#include <time.h>
#include <string.h>

#ifdef _MSC_VER
#define finite _finite
#define isnan _isnan
#endif

#ifdef	 __USE_ISOC99
/* INFINITY and NAN are defined by the ISO C99 standard */
#else
double my_infinity(void) {
  double zero = 0;
  return 1.0/zero;
}
double my_nan(void) {
  double zero = 0;
  return zero/zero;
}
#define INFINITY my_infinity()
#define NAN my_nan()
#endif


/* The digamma function is the derivative of gammaln.

   Reference:
    J Bernardo,
    Psi ( Digamma ) Function,
    Algorithm AS 103,
    Applied Statistics,
    Volume 25, Number 3, pages 315-317, 1976.

    From http://www.psc.edu/~burkardt/src/dirichlet/dirichlet.f
    (with modifications for negative numbers and extra precision)
*/
double digamma(double x)
{
  double neginf = -INFINITY;
  static const double c = 12,
    digamma1 = -0.57721566490153286,
    trigamma1 = 1.6449340668482264365, /* pi^2/6 */
    s = 1e-6,
    s3 = 1./12,
    s4 = 1./120,
    s5 = 1./252,
    s6 = 1./240,
    s7 = 1./132,
    s8 = 691./32760,
    s9 = 1./12,
    s10 = 3617./8160;
  double result;
  /* Illegal arguments */
  if((x == neginf) || isnan(x)) {
    return NAN;
  }
  /* Singularities */
  if((x <= 0) && (floor(x) == x)) {
    return neginf;
  }
  /* Negative values */
  /* Use the reflection formula (Jeffrey 11.1.6):
   * digamma(-x) = digamma(x+1) + pi*cot(pi*x)
   *
   * This is related to the identity
   * digamma(-x) = digamma(x+1) - digamma(z) + digamma(1-z)
   * where z is the fractional part of x
   * For example:
   * digamma(-3.1) = 1/3.1 + 1/2.1 + 1/1.1 + 1/0.1 + digamma(1-0.1)
   *               = digamma(4.1) - digamma(0.1) + digamma(1-0.1)
   * Then we use
   * digamma(1-z) - digamma(z) = pi*cot(pi*z)
   */
  if(x < 0) {
    return digamma(1-x) + M_PI/tan(-M_PI*x);
  }
  /* Use Taylor series if argument <= S */
  if(x <= s) return digamma1 - 1/x + trigamma1*x;
  /* Reduce to digamma(X + N) where (X + N) >= C */
  result = 0;
  while(x < c) {
    result -= 1/x;
    x++;
  }
  /* Use de Moivre's expansion if argument >= C */
  /* This expansion can be computed in Maple via asympt(Psi(x),x) */
  if(x >= c) {
    double r = 1/x, t;
    result += log(x) - 0.5*r;
    r *= r;
#if 0
    result -= r * (s3 - r * (s4 - r * (s5 - r * (s6 - r * s7))));
#else
    /* this version for lame compilers */
    t = (s5 - r * (s6 - r * s7));
    result -= r * (s3 - r * (s4 - r * t));
#endif
  }
  return result;
}

#ifndef __WIN32__
int count_cpu() {
    cpu_set_t set;
    sched_getaffinity(0, sizeof(cpu_set_t), &set);
    int i, count=0;
    for(i=0;i<CPU_SETSIZE;i++)
        if(CPU_ISSET(i, &set)) count++;
    if (count>1) count--;

    return count;
}
#endif

#define LOAD 1e3 /* ~ per core load */
#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))
#define MAXNCORE 15 /* ~15, dont set too high */

void helper(mwSize len, double *indata,double *outdata)
{
    mwSize i, ncore;

    if (len <= LOAD) { 
        for(i=0;i<len;i++)
            outdata[i] = digamma(indata[i]);
        return;
    }

#ifndef __WIN32__
    ncore = MIN(len/LOAD,MAXNCORE);
    ncore = MIN(count_cpu(),ncore);
    omp_set_num_threads( ncore );
#endif

#pragma omp parallel for
    for(i=0;i<len;i++)
        outdata[i] = digamma(indata[i]);

}


void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    mwSize ndims, len, i, nnz;
    mwSize * dims;
    double *indata, *outdata;

    if((nlhs > 1) || (nrhs != 1))    
        mexErrMsgTxt("Usage: x = digamma(n)");

    /* prhs[0] is first argument.
     * mxGetPr returns double*  (data, col-major)
     */
    ndims = mxGetNumberOfDimensions(prhs[0]);
    dims = (mwSize*)mxGetDimensions(prhs[0]);
    indata = mxGetPr(prhs[0]);
    len = mxGetNumberOfElements(prhs[0]);

    if(mxIsSparse(prhs[0])) {
        plhs[0] = mxDuplicateArray(prhs[0]);
        /* number of nonzero entries */
        nnz = mxGetJc(prhs[0])[mxGetN(prhs[0])];
        if(nnz != mxGetNumberOfElements(prhs[0])) {
            mexErrMsgTxt("Cannot handle sparse n.");
        }
    } else {
        /* plhs[0] is first output */
        plhs[0] = mxCreateNumericArray(ndims, dims, mxDOUBLE_CLASS, mxREAL);
    }
    outdata = mxGetPr(plhs[0]);
    helper(len, indata,outdata);
}








