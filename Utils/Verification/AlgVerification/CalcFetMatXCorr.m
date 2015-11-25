function [resOut]=CalcFetMatXCorr(resData,Fs,debug)
%CalcFetMatXcorr calculates the cross-coreelation between fetal and
%maternal S or QRS detections
% Inputs: resData - Algorithm output results for one minute
%         Fs - sampling frequency
%         debug - flag for plotting debug data
% Outputs: resOut - structure containing cross correlation data

win_size=50;% [msec]
win_size=(Fs/1000)*win_size; % [samples]
a=1;b=ones(1,win_size);

max_lag=350; % [msec]
max_lag=(Fs/1000)*max_lag; %[samples]

N_Samples=resData.EndSample-resData.StartSample+1;

% Create combs for detection position vectors
if ~isfield(resData,'ECG_fQRSPos')||(isempty(resData.ECG_fQRSPos))
    f_E_comb_rect=[];
else
    f_E_comb=zeros(1,N_Samples);f_E_comb(resData.ECG_fQRSPos)=1; f_E_comb_rect=filter(b,a,f_E_comb);
end

if ~isfield(resData,'ECG_mQRSPos')||(isempty(resData.ECG_mQRSPos))
    m_E_comb_rect=[];
else
    m_E_comb=zeros(1,N_Samples);m_E_comb(resData.ECG_mQRSPos)=1; m_E_comb_rect=filter(b,a,m_E_comb);
end


if ~isfield(resData,'Audio_fSPos')|| isempty(resData.Audio_fSPos)
    f_A_comb_rect=[];
else
    f_A_comb=zeros(1,N_Samples);f_A_comb(resData.Audio_fSPos)=1; f_A_comb_rect=filter(b,a,f_A_comb);
end


if ~isfield(resData,'Audio_mSPos')|| isempty(resData.Audio_mSPos)
    m_A_comb_rect=[];
else
    m_A_comb=zeros(1,N_Samples);m_A_comb(resData.Audio_mSPos)=1; m_A_comb_rect=filter(b,a,m_A_comb);
end


% Calculate xcorrelation max scores between vectors
[resOut.f_E_m_E_max,resOut.f_E_m_E_xcorr,resOut.f_E_m_E_lag]=CalcDetectionXcorr(f_E_comb_rect,m_E_comb_rect,max_lag,debug);
[resOut.f_E_m_A_max,resOut.f_E_m_A_xcorr,resOut.f_E_m_A_lag]=CalcDetectionXcorr(f_E_comb_rect,m_A_comb_rect,max_lag,debug);

[resOut.f_A_m_E_max,resOut.f_A_m_E_xcorr,resOut.f_A_m_E_lag]=CalcDetectionXcorr(f_A_comb_rect,m_E_comb_rect,max_lag,debug);
[resOut.f_A_m_A_max,resOut.f_A_m_A_xcorr,resOut.f_A_m_A_lag]=CalcDetectionXcorr(f_A_comb_rect,m_A_comb_rect,max_lag,debug);

[resOut.m_E_m_A_max,resOut.m_E_m_A_xcorr,resOut.m_E_m_A_lag]=CalcDetectionXcorr(m_E_comb_rect,m_A_comb_rect,max_lag,debug);
[resOut.f_E_f_A_max,resOut.f_E_f_A_xcorr,resOut.f_E_f_A_lag]=CalcDetectionXcorr(f_E_comb_rect,f_A_comb_rect,max_lag,debug);

if debug
    figure;h1=subplot(2,2,1);plot((1:N_Samples)/Fs,f_E_comb);ylim([0 2]);
    title('Fetal detection comb');
    h2=subplot(2,2,3);plot((1:N_Samples)/Fs,m_E_comb,'r');ylim([0 2]);
    title('Maternal detection comb');xlabel('Time [sec]');
    h3=subplot(2,2,2);plot((1:N_Samples)/Fs,f_E_comb_rect);
    title(['Fetal detection comb after dilation to rectangle of witdh=' num2str(win_size) '[samples]']);
    h4=subplot(2,2,4);plot((1:N_Samples)/Fs,m_E_comb_rect);xlabel('Time [sec]');
    title(['Maternal detection comb after dilation to rectangle of witdh=' num2str(win_size) '[samples]']);
    linkaxes([h1 h2 h3 h4]);
end

