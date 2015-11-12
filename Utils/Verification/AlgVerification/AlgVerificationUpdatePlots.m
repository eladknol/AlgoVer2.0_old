function AlgVerificationUpdatePlots( res ,i_Interval, handles)
% AlgVerificationUpdatePlots plots deb ugging results per interval
%   Input - handles - handle to AlgVerificationGUI
%           res - struct containing alg results for entire session (output of
%                 DecisionFusionLogic.m)
%           - i_interval - interval number in session

% Get results for desired interval
resData=res.OutStruct.resData(i_Interval);
ECGData=res.ECG{i_Interval};
AudioData=res.Audio{i_Interval};
[~,rawData,~]=ReadNGF(handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'NGF Path'))},'Reshape');
crosscorr=1;

Score_TH=0.2;
N_Samples=resData.EndSample-resData.StartSample+1;%length(ECGData.FetSig);
Fs=res.OutStruct.Fs;

% Run ScoreGraph on ECG results here (not good!!!), until NGO file will be updated
try
    ECGData.Fetal.ScoreGrph=ScoreGraph(resData.ECG_fQRSPos,'GlobScore',resData.Fetal_ECG_Score,'GlobHR',resData.ECG_avgBestFHR,'Fs',Fs);
    % patch for cases where length of HR vector is not 6
    if length(ECGData.Fetal.ScoreGrph.HRvec)<6
        ECGData.Fetal.ScoreGrph.HRvec=vertcat(ECGData.Fetal.ScoreGrph.HRvec,repmat(ECGData.Fetal.ScoreGrph.HRvec(end),[6-length(ECGData.Fetal.ScoreGrph.HRvec) 1]));
    end
catch
end

%calculate instantaneous and median HR
med_win_size=handles.med_win_size;

%ECG
try
[ resData.ECG_f_HR_INST , resData.ECG_f_HR_MED ]=AlgVerificationCalcHR(resData.ECG_fQRSPos,med_win_size,Fs);
catch
end

%Audio
try
[ resData.Audio_f_HR_INST , resData.Audio_f_HR_MED ]=AlgVerificationCalcHR(resData.Audio_fSPos,med_win_size,Fs);
catch
end

cc=[255,127,80]/255;

% Set title colors according to detection results
tit_ECG_Score=[];tit_Audio_Score=[];tit_ECG_HR=[];tit_Audio_HR=[];
[m,I]=min([resData.Fetal_ECG_Score resData.Fetal_Audio_Score]);
    
if m<Score_TH;
    switch I
        case 1
            tit_ECG_Score=strcat(tit_ECG_Score,'\color{green}',num2str(resData.Fetal_ECG_Score,2));
            tit_Audio_Score=strcat(tit_Audio_Score,'\color{red}',num2str(resData.Fetal_Audio_Score,2));
            tit_ECG_HR=strcat(tit_ECG_HR,'\color{green}',num2str(uint16(resData.ECG_avgFHR)));
            tit_Audio_HR=strcat(tit_Audio_HR,'\color{red}',num2str(uint16(resData.Audio_avgFHR)));

        case 2
            tit_ECG_Score=strcat(tit_ECG_Score,'\color{red}',num2str(resData.Fetal_ECG_Score,2));
            tit_Audio_Score=strcat(tit_Audio_Score,'\color{green}',num2str(resData.Fetal_Audio_Score,2));
            tit_ECG_HR=strcat(tit_ECG_HR,'\color{red}',num2str(uint16(resData.ECG_avgFHR)));
            tit_Audio_HR=strcat(tit_Audio_HR,'\color{green}',num2str(uint16(resData.Audio_avgFHR)));

    end
else % none of the score is below threshold, all scores will be painted red
    tit_ECG_Score=strcat(tit_ECG_Score,'\color{red}',num2str(resData.Fetal_ECG_Score,2));
    tit_Audio_Score=strcat(tit_Audio_Score,'\color{red}',num2str(resData.Fetal_Audio_Score,2));
    tit_ECG_HR=strcat(tit_ECG_HR,'\color{red}',num2str(uint16(resData.ECG_avgFHR)));
    tit_Audio_HR=strcat(tit_Audio_HR,'\color{red}',num2str(uint16(resData.Audio_avgFHR)));
end

% Get Algo ECG and Audio results
% Define time tag vector
Ttag=(1:N_Samples)/Fs;

% clear axes
try
	cla(handles.axes1,'reset');	cla(handles.axes2,'reset');	cla(handles.axes3,'reset');	cla(handles.axes4,'reset');	cla(handles.axes5,'reset');	cla(handles.axes6,'reset'); cla(handles.axes7,'reset');	cla(handles.axes8,'reset');
end
    
%Fetal
Start_smp=res.OutStruct.resData(i_Interval).StartSample;
End_smp=res.OutStruct.resData(i_Interval).EndSample;

% raw signals
plot(handles.axes7,Ttag,rawData(Start_smp:End_smp,1:6));grid(handles.axes7,'on');
plot(handles.axes8,Ttag,rawData(Start_smp:End_smp,7:10));grid(handles.axes8,'on');

% best fetal ECG channel and QRS detections
try
plot(handles.axes1,Ttag,ECGData.FetSig);title(handles.axes1,'ECG Signal','FontSize',7);hold(handles.axes1,'on');
scatter(handles.axes1,resData.ECG_fQRSPos/Fs,ECGData.FetSig(resData.ECG_fQRSPos),14,cc,'LineWidth',1);grid(handles.axes1,'on');
catch
end

% Calculate score per peak - test
% pkwdth=30; % parameter for width of detected peak[msec];
% RR_Score=zeros(1,length(resData.ECG_fQRSPos));
% for i=1:length(resData.ECG_fQRSPos);
%     if i==1;
%         Pre_RR_idx=1:max(resData.ECG_fQRSPos(i)-pkwdth,1);
%         Post_RR_idx=min(resData.ECG_fQRSPos(i)+pkwdth,N_Samples):max(resData.ECG_fQRSPos(i+1)-pkwdth,1);
%         
%     else if i==length(resData.ECG_fQRSPos)
%             Pre_RR_idx=min(resData.ECG_fQRSPos(i-1)+pkwdth,N_Samples):max(resData.ECG_fQRSPos(i)-pkwdth,1);
%             Post_RR_idx=min(resData.ECG_fQRSPos(i)+pkwdth,N_Samples):N_Samples;
%         else
%             Pre_RR_idx=min(resData.ECG_fQRSPos(i-1)+pkwdth,N_Samples):max(resData.ECG_fQRSPos(i)-pkwdth,1);
%             Post_RR_idx=min(resData.ECG_fQRSPos(i)+pkwdth,N_Samples):max(resData.ECG_fQRSPos(i+1)-pkwdth,1);
%         end
%     end
%     srnd=horzcat(ECGData.FetSig(Pre_RR_idx),ECGData.FetSig(Post_RR_idx));
%     max_srnd=max(srnd);
%     RR_Score(i)=max_srnd/ECGData.FetSig(resData.ECG_fQRSPos(i));
% end

% alternative QRS detection
if 0
ECG_wo_DC=ECGData.FetSig-mean(ECGData.FetSig);
[R_pks_1,R_locs_1]=findpeaks(ECG_wo_DC,'MinPeakDistance',330,'MinPeakProminence',0.04);
[R_pks_2,R_locs_2]=findpeaks(-1*ECG_wo_DC,'MinPeakDistance',330,'MinPeakProminence',0.04);

if mean(R_pks_1)>mean(R_pks_2);
    R_pks=R_pks_1;
    R_locs=R_locs_1;
else
    R_pks=R_pks_2;
    R_locs=R_locs_2;
end

[R_pks,R_locs]=findpeaks(ECGData.FetSig,'MinPeakDistance',350);
end
% scatter(handles.axes1,R_locs/Fs,ECGData.FetSig(R_locs),14,'k','LineWidth',1);
% xlabel(handles.axes1,'Time [sec]','FontSize',7); ylabel(handles.axes1,'Amplitude [V]','FontSize',7);
% legend(handles.axes1,'Filtered Signal','S','Location','best','FontSize',3);

% best fetal audio channel and S1 detections
plot(handles.axes2,Ttag,AudioData.Fetal.Res.Signal);title(handles.axes2,'Audio Signal','FontSize',7);hold(handles.axes2,'on');
scatter(handles.axes2,resData.Audio_fSPos/Fs,AudioData.Fetal.Res.Pks,14,cc,'LineWidth',1);grid(handles.axes2,'on');

% Overlay of ECG detections over audio
scatter(handles.axes2,resData.ECG_fQRSPos/Fs,zeros(1,length(resData.ECG_fQRSPos)),14,'g','LineWidth',1);

% alternative S detection
[S_pks,S_locs]=findpeaks(AudioData.Fetal.Res.Signal,'MinPeakDistance',350);
% scatter(handles.axes2,S_locs/Fs,S_pks,14,'k','LineWidth',1);
% xlabel(handles.axes2,'Time [sec]','FontSize',7); ylabel(handles.axes2,'Amplitude [V]','FontSize',7);
% legend(handles.axes2,'Filtered Signal','S','Location','best','FontSize',3);


% best fetal ECG HR
try
plot(handles.axes3,resData.ECG_fQRSPos(2:end)/Fs,resData.ECG_f_HR_INST);hold(handles.axes3,'on');grid(handles.axes3,'on');
plot(handles.axes3,resData.ECG_fQRSPos(2:end)/Fs,resData.ECG_f_HR_MED); axis tight
scatter(handles.axes3,[10 20 30 40 50 60],ECGData.Fetal.ScoreGrph.HRvec',30,'m','filled');
catch
end
ylabel(handles.axes3,'HR [bpm]','FontSize',7);
ylim(handles.axes3,[50 300]);
% legend(handles.axes3,'INST','MED','Location','best','FontSize',3);
title(handles.axes3,['ECG HR= ' tit_ECG_HR],'FontSize',7);

% best fetal AUDIO HR
try
plot(handles.axes4,resData.Audio_fSPos(2:end)/Fs,resData.Audio_f_HR_INST);hold(handles.axes4,'on');grid(handles.axes4,'on');
plot(handles.axes4,resData.Audio_fSPos(2:end)/Fs,resData.Audio_f_HR_MED); axis tight;hold(handles.axes4,'on');
scatter(handles.axes4,[10 20 30 40 50 60],AudioData.Fetal.ScoreGrph.HRvec',30,'m','filled');
catch
end
ylabel(handles.axes4,'HR [bpm]','FontSize',7);
ylim(handles.axes4,[50 300]);
% legend(handles.axes3,'INST','MED','Location','best','FontSize',3);
title(handles.axes4,['Audio HR= ' tit_Audio_HR],'FontSize',7);


% fetal ECG scores

% [handles.axes5,H5_bars,H5_peak]=plotyy(handles.axes5,[ECGData.Fetal.ScoreGrph.StartFrame' ECGData.Fetal.ScoreGrph.EndFrame']'/Fs,...
%     repmat(ECGData.Fetal.ScoreGrph.Score',[1 2])',resData.ECG_fQRSPos/Fs,RR_Score);hold(handles.axes5(1),'on');
try
plot(handles.axes5(1),[ECGData.Fetal.ScoreGrph.StartFrame' ECGData.Fetal.ScoreGrph.EndFrame']'/Fs,...
    repmat(ECGData.Fetal.ScoreGrph.Score',[1 2])');xlabel(handles.axes5(1),'Time [sec]','FontSize',7);axis tight ;hold(handles.axes5(1),'on');

plot(handles.axes5(1),get(handles.axes5(1),'XLim'),[Score_TH Score_TH],'-r');axis tight ; xlim(handles.axes5(1),[0 60]); hold(handles.axes5(1),'on');

if crosscorr
    FetMatXcorr=CalcFetMatXCorr(resData,Fs,0);
    plot(handles.axes5(1),linspace(0,60,length(FetMatXcorr.f_E_m_E_xcorr)),FetMatXcorr.f_E_m_E_xcorr,'k');hold on;
    plot(handles.axes5(1),linspace(0,60,length(FetMatXcorr.f_E_m_A_xcorr)),FetMatXcorr.f_E_m_A_xcorr,'b');hold on;
end
catch
end

title(handles.axes5(1),['ECG Score= ' tit_ECG_Score],'FontSize',7);
% fetal audio scores
plot(handles.axes6,[AudioData.Fetal.ScoreGrph.StartFrame' AudioData.Fetal.ScoreGrph.EndFrame']'/Fs,...
    repmat(AudioData.Fetal.ScoreGrph.Score',[1 2])');xlabel(handles.axes6,'Time [sec]','FontSize',7);axis tight ;hold(handles.axes6,'on');
plot(handles.axes6,get(handles.axes6,'XLim'),[Score_TH Score_TH],'-r');hold(handles.axes6,'on');
try
if crosscorr
    plot(handles.axes6,linspace(0,60,length(FetMatXcorr.f_A_m_E_xcorr)),FetMatXcorr.f_A_m_E_xcorr,'k');hold on;
    plot(handles.axes6,linspace(0,60,length(FetMatXcorr.f_A_m_A_xcorr)),FetMatXcorr.f_A_m_A_xcorr,'b');hold on;
end
catch
end

title(handles.axes6,['Audio Score= ' tit_Audio_Score],'FontSize',7);

% link axes
linkaxes([handles.axes1 handles.axes2 handles.axes7 handles.axes8],'x');

% finding limits for score plots
% Audio
Audio_Score_Lim_x_Fet=get(handles.axes6,'XLim');
Audio_Score_Lim_y_Fet=get(handles.axes6,'YLim');

Audio_HR_Lim_x_Fet=get(handles.axes4,'XLim');
Audio_HR_Lim_y_Fet=get(handles.axes4,'YLim');

% ECG
ECG_Score_Lim_x_Fet=get(handles.axes5(1),'XLim');
ECG_Score_Lim_y_Fet=get(handles.axes5(1),'YLim');

ECG_HR_Lim_x_Fet=get(handles.axes3,'XLim');
ECG_HR_Lim_y_Fet=get(handles.axes3,'YLim');


% plot initial ROI of signal in score plot
% Audio
plot(handles.axes6,Audio_Score_Lim_x_Fet(1)*[1 1],Audio_Score_Lim_y_Fet,'--r'); hold(handles.axes6,'on');
plot(handles.axes6,Audio_Score_Lim_x_Fet(2)*[1 1],Audio_Score_Lim_y_Fet,'--r');
%ECG
plot(handles.axes5(1),ECG_Score_Lim_x_Fet(1)*[1 1],ECG_Score_Lim_y_Fet,'--r'); hold(handles.axes5(1),'on');
plot(handles.axes5(1),ECG_Score_Lim_x_Fet(2)*[1 1],ECG_Score_Lim_y_Fet,'--r');


% plot initial ROI of signal in HR plot
% Audio
plot(handles.axes4,Audio_HR_Lim_x_Fet(1)*[1 1],Audio_HR_Lim_y_Fet,'--r'); hold(handles.axes4,'on');
plot(handles.axes4,Audio_HR_Lim_x_Fet(2)*[1 1],Audio_HR_Lim_y_Fet,'--r');
% ECG
plot(handles.axes3,ECG_HR_Lim_x_Fet(1)*[1 1], ECG_HR_Lim_y_Fet,'--r'); hold(handles.axes3,'on');
plot(handles.axes3,ECG_HR_Lim_x_Fet(2)*[1 1], ECG_HR_Lim_y_Fet,'--r'); 


% update ROI according to pan motion
hpan=pan;hpan.Motion = 'horizontal';
newLim=[];

ax=[handles.axes4 handles.axes6 handles.axes3 handles.axes5(1)];
lims=[Audio_HR_Lim_y_Fet; Audio_Score_Lim_y_Fet; ECG_HR_Lim_y_Fet; ECG_Score_Lim_y_Fet];
hpan.ActionPostCallback={@PanSessioncallback newLim ax lims};

% update ROI according to pan motion
hzoom=zoom;hzoom.Motion = 'horizontal';
newLim=[];
hzoom.ActionPostCallback={@ZoomSessioncallback newLim ax lims };

%% Display Verification comments
% from NGO file
NGO_file_path=strcat(fullfile(handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Subject Path'))},handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'File Name'))}),'.ngo');
[read_status,NGO_Data]=readNGO(NGO_file_path);
if read_status
    % ECG verification status
    if isfield(NGO_Data.resData(i_Interval),'ECG_VV_Status')
        ECG_VV_Status=NGO_Data.resData(i_Interval).ECG_VV_Status;
        if ~isempty(ECG_VV_Status)
            switch ECG_VV_Status
                case '' % No value
                    set(handles.popupmenu5,'Value',4)
                case -1 % No value
                    set(handles.popupmenu5,'Value',4)
                case 0 % Fail
                    set(handles.popupmenu5,'Value',3)
                case 1 % Pass
                    set(handles.popupmenu5,'Value',2)
                case 2 % Pending
                    set(handles.popupmenu5,'Value',1)
            end
        else
            set(handles.popupmenu5,'Value',4)
        end;
    else
        set(handles.popupmenu5,'Value',4)
    end
    
    % Audio verification status
    if isfield(NGO_Data.resData(i_Interval),'Audio_VV_Status')
        Audio_VV_Status=NGO_Data.resData(i_Interval).Audio_VV_Status;
        if ~isempty(Audio_VV_Status)
            switch Audio_VV_Status
                case '' % No value
                    set(handles.popupmenu6,'Value',4)
                case -1 % No value
                    set(handles.popupmenu6,'Value',4)
                case 0 % Fail
                    set(handles.popupmenu6,'Value',3)
                case 1 % Pass
                    set(handles.popupmenu6,'Value',2)
                case 2 % Pending
                    set(handles.popupmenu6,'Value',1)
            end
        else
            set(handles.popupmenu6,'Value',4)
        end;
    else
        set(handles.popupmenu6,'Value',4)
    end
    
    % ECG verification comments
    if isfield(NGO_Data.resData(i_Interval),'ECG_VV_Comments')
        set(handles.edit18,'String',NGO_Data.resData(i_Interval).ECG_VV_Comments);
    else
        set(handles.edit18,'String','');
    end
    
    % Audio verification comments
    if isfield(NGO_Data.resData(i_Interval),'Audio_VV_Comments')
        set(handles.edit19,'String',NGO_Data.resData(i_Interval).Audio_VV_Comments);
    else
        set(handles.edit19,'String','');
    end
end

