function [ECG_decomp, ECG_vec_orig, ECG_mat_SVD] = SVD_filter(ECG, beatLen)

nNumOfMatPeaks = size(ECG, 2);

k = sum(svd(ECG)>sqrt(10));
disp(k);
[u,s,v] = svds(ECG, 6);
ECG_mat_SVD = (u*s*v');

ECG_vec_orig = [];
ECG_decomp = [];
for i=1:nNumOfMatPeaks % TBC 2->1
    ECG_vec_orig = [ECG_vec_orig ECG(1:beatLen(i), i)'];
    ECG_decomp = [ECG_decomp ECG_mat_SVD(1:beatLen(i), i)'];
end