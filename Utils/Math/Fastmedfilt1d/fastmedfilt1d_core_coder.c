/*
Core MEX routine implementing a fast version of the classical 1D running
median filter of size W, where W is odd.

Usage:
m = fastmedfilt1d_core(x, xic, xfc, W2)

Input arguments:
- x          Input signal
- xic        Initial boundary condition
- xfc        End boundary condition
- W2         Half window size (so that window size is W=2*W2+1)

Output arguments:
- m          Median filtered signal

(c) Max Little, 2010. If you use this code, please cite:
Little, M.A. and Jones, N.S. (2010),
"Sparse Bayesian Step-Filtering for High-Throughput Analysis of Molecular
Machine Dynamics"
in Proceedings of ICASSP 2010, IEEE Publishers: Dallas, USA.
*/

#include "fastmedfilt1d_core_coder.h"

#ifdef MEX
#include "mex.h"
#include "matrix.h"


/* Input parameters */
#define  X_IN        prhs[0]
#define  XIC_IN      prhs[1]
#define  XFC_IN      prhs[2]
#define  W2_IN       prhs[3]

/* Output parameters */
#define  M_OUT       plhs[0]

/* Function definition */
#define  SYNTAX   "m = fastmedfilt1d_core(x, xic, xfc, W2)"
#endif

#ifdef CODER
/* Entry point function*/
void medianFilter_wrapper(double *inSig, int sigLen, int winLen, double *medianOutput)
{
	int windowSize, windowSizeHalf;
	double *xInputIC;          /* Input initial condition vector */
	double *xInputFC;          /* Input final condition vector */

	windowSizeHalf = winLen;
	windowSize = 2 * windowSizeHalf + 1;

	xInputIC = (double *)malloc(winLen * sizeof(double));
	xInputFC = (double *)malloc(winLen * sizeof(double));

	for (size_t i = 0; i < winLen; i++)
	{
		xInputIC[i] = 0;
		xInputFC[i] = 0;
	}
	/* Compute running median */
	//medianOutput = (double *)malloc(sigLen*sizeof(double));
	medianFilter(inSig, medianOutput, xInputIC, xInputFC, sigLen, windowSize, windowSizeHalf);

	return;
}
#endif

double quickSelect(double arr[], int n)
{
	long low, high;
	long median;
	long middle, ll, hh;

	low = 0;
	high = n - 1;
	median = (low + high) / 2;
	for (;;)
	{
		/* One element only */
		if (high <= low)
			return arr[median];

		/* Two elements only */
		if (high == low + 1)
		{
			if (arr[low] > arr[high])
				SWAP(arr[low], arr[high]);
			return arr[median];
		}

		/* Find median of low, middle and high items; swap to low position */
		middle = (low + high) / 2;
		if (arr[middle] > arr[high])
			SWAP(arr[middle], arr[high]);
		if (arr[low] > arr[high])
			SWAP(arr[low], arr[high]);
		if (arr[middle] > arr[low])
			SWAP(arr[middle], arr[low]);

		/* Swap low item (now in position middle) into position (low+1) */
		SWAP(arr[middle], arr[low + 1]);

		/* Work from each end towards middle, swapping items when stuck */
		ll = low + 1;
		hh = high;
		for (;;)
		{
			do
				ll++;
			while (arr[low] > arr[ll]);
			do
				hh--;
			while (arr[hh] > arr[low]);

			if (hh < ll)
				break;

			SWAP(arr[ll], arr[hh]);
		}

		/* Swap middle item (in position low) back into correct position */
		SWAP(arr[low], arr[hh]);

		/* Reset active partition */
		if (hh <= median)
			low = ll;
		if (hh >= median)
			high = hh - 1;
	}
}


/* Perform running median filtering */
static void medianFilter(double    *x,     /* Input signal */
	double    *m,     /* Output signal buffer */
	double    *xic,   /* Initial condition */
	double    *xfc,   /* Final condition */
	long      N,      /* Size of input signal */
	long      W,      /* Size of sliding window (odd) W = 2*W2+1*/
	long      W2      /* W2 in above */)
{
	long i, k, idx;

	double *w = (double *)malloc(W*sizeof(double));   /* Allocate sliding window */

	for (i = 0; i < N; i++)
	{
		/* Fill up the sliding window */
		for (k = 0; k < W; k++)
		{
			idx = i - W2 + k;

			if (idx < 0)
			{
				/* Need to get values from the initial condition vector */
				w[k] = xic[W2 + idx];
			}
			else if (idx >= N)
			{
				/* Need to get values from the final condition vector */
				w[k] = xfc[idx - N];
			}
			else
			{
				w[k] = x[idx];
			}
		}

		/* Select the median of the sliding window */
		m[i] = quickSelect(w, W);
	}

	/* Clean up */
	free(w);
}



#ifdef MEX
/* Main entry point */
/* lhs - output parameters */
/* rhs - input parameters */
void mexFunction(
	int           nlhs,           /* number of expected outputs */
	mxArray       *plhs[],        /* array of pointers to output arguments */
	int           nrhs,           /* number of inputs */
#if !defined(V4_COMPAT)
	const mxArray *prhs[]         /* array of pointers to input arguments */
#else
	mxArray *prhs[]         /* array of pointers to input arguments */
#endif
	)
{
	long samples, dimensions, elements, windowSize, windowSizeHalf, i;
	double            *scalar;            /* Reused pointer to get access to scalar input parameters */
	double            *medianOutput;      /* MEX buffer for median filter output vector */
	double            *xInput;            /* Input signal vector */
	double            *mOutput;           /* Median filtered output signal vector */
	double            *xInputIC;          /* Input initial condition vector */
	double            *xInputFC;          /* Input final condition vector */

	/* Check for proper number of arguments */
	if ((nrhs != 4) || (nlhs != 1))
	{
		mexErrMsgTxt("Incorrect number of parameters.\nSyntax: "SYNTAX);
	}

	samples = mxGetM(X_IN);
	dimensions = mxGetN(X_IN);
	elements = samples * dimensions;

	xInput = mxGetPr(X_IN);
	xInputIC = mxGetPr(XIC_IN);
	xInputFC = mxGetPr(XFC_IN);

	scalar = mxGetPr(W2_IN);
	windowSizeHalf = (long)scalar[0];
	windowSize = 2 * windowSizeHalf + 1;

	/* Compute running median */
	medianOutput = (double *)mxCalloc(elements, sizeof(double));
	medianFilter(xInput, medianOutput, xInputIC, xInputFC, elements, windowSize, windowSizeHalf);

	/* Create output signal, get pointer access */
	M_OUT = mxCreateDoubleMatrix(elements, 1, mxdouble);
	mOutput = mxGetPr(M_OUT);
	for (i = 0; i < elements; i++)
	{
		mOutput[i] = medianOutput[i];
	}

	/* Release allocated memory */
	mxFree(medianOutput);

	return;
}
#endif