#include <math.h>
#include <memory.h>
#include <opencv\cv.h>
#include <opencv\cxcore.h>
#ifndef HAS_OPENCV 
#define HAS_OPENCV 
#endif
#include "mex.h"

using namespace cv;

// matlab entry point
// [smpRank, splitCandi] = LODseq(K, selectNum, splitCandi)
// image should be color with double values
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 
  if (nrhs != 3)
    mexErrMsgTxt("Wrong number of inputs"); 
  if (nlhs != 2)
    mexErrMsgTxt("Wrong number of outputs");
  
  double *K = (double *)mxGetPr(prhs[0]);
  const int *dims = mxGetDimensions(prhs[0]);
  const int ndim  = mxGetNumberOfDimensions(prhs[0]);
  if(ndim != 2 || mxGetClassID(prhs[0]) != mxDOUBLE_CLASS || dims[0] != dims[1])
      mexErrMsgTxt("Invalid input: kernel matrix");
  int n = dims[0];
  
  if (!mxIsDouble(prhs[1]) || mxGetN(prhs[1])*mxGetM(prhs[1]) != 1)
      mexErrMsgTxt("Invalid input: select number must be scalar");
  int m = mxGetScalar(prhs[1]);
  
  bool *splitCandi = (bool *)mxGetPr(prhs[2]);
  if (!mxIsLogical(prhs[2]) || mxGetN(prhs[2]) != 1 || mxGetM(prhs[2]) != n)
      mexErrMsgTxt("Invalid input: split label");
  
  int out[2];
  out[0] = m;
  out[1] = 1;
  plhs[0] = mxCreateNumericArray(2, out, mxDOUBLE_CLASS, mxREAL);
  double *smpRank = (double *)mxGetPr(plhs[0]);
  out[0] = n;
  out[1] = 1;
  plhs[1] = mxCreateLogicalArray(2, out);
  bool *selectCandi = (bool *)mxGetPr(plhs[1]);

  Mat Kernel(n, n, CV_64FC1, K);
  Mat z = Mat::ones(1, n, CV_64FC1);
  
  for(int k = 0; k < m; k++)
  {
	  Mat sum = z*(Kernel.mul(Kernel));
	  Mat val = sum.t()/(Kernel.diag()+1);
	  double maxv = -1;
	  int sel;
	  for(int i = 0; i < val.rows; i++)
	  {
		  double* r = val.ptr<double>(i);
		  if(splitCandi[i] && r[0] > maxv)
		  {
			  maxv = r[0];
			  sel = i;
		  }
	  }
	  double* d = Kernel.ptr<double>(sel);
	  Mat K1 = (Kernel.col(sel)*Kernel.row(sel));
	  Kernel = Kernel - K1/(1+d[sel]);
	  splitCandi[sel] = false;
	  smpRank[k] = (sel + 1);
  }
  
  for(int i = 0; i < n; i++)
  {
	  selectCandi[i] = !splitCandi[i];
  }
}

