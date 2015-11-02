function types = getPlotTypes(type)

i=0;

i=i+1; types.MndF_FULL_RAW = i; % show fetal and maternal ECG with QRS positions
i=i+1; types.MndF_FULL_PreProc = i; % show fetal and maternal ECG with QRS positions
i=i+1; types.MndF_FULL = i; % show fetal and maternal ECG with QRS positions

i=i+1; types.MaternalECGWithQRS = i; % show maternal ECG with QRS positions

i=i+1; types.FetalECGWithQRS = i; % show Fetal ECG with QRS positions


i=i+1; types.FullECGICA = i; % show results of ICA analysis of full ECG data
i=i+1; types.FetalECGICA = i; % show results of ICA analysis of fECG data


i=i+1; types.MndF_FULL_RAW_withAnnfQRS = i;
i=i+1; types.MndF_FULL_Proc_withAnnfQRS = i;
i=i+1; types.FetalECGICA_withAnnfQRS = i;

i=i+1; types.MaternalECG_withRawECG = i; % show maternal ECG with QRS positions