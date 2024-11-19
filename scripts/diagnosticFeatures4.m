function featureTable = diagnosticFeatures4(inputData)
%DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
%
% Input:
%  inputData: A timetable.
%
% Output:
%  featureTable: A table containing all features.
%
% This function computes signals:
%  meas_interp/signal
%  meas_tsproc/signal
%
% This function computes spectra:
%  meas_ps/SpectrumData
%
% This function computes features:
%  meas_sigstats/ClearanceFactor
%  meas_sigstats/CrestFactor
%  meas_sigstats/ImpulseFactor
%  meas_sigstats/Kurtosis
%  meas_sigstats/Mean
%  meas_sigstats/PeakValue
%  meas_sigstats/RMS
%  meas_sigstats/SINAD
%  meas_sigstats/SNR
%  meas_sigstats/ShapeFactor
%  meas_sigstats/Skewness
%  meas_sigstats/Std
%  meas_sigstats/THD
%  meas_tsfeat/Minimum
%  meas_tsfeat/Median
%  meas_tsfeat/Maximum
%  meas_tsfeat/Q1
%  meas_tsfeat/Q3
%  meas_tsfeat/IQR
%  meas_tsmodel/Coef1
%  meas_tsmodel/Freq1
%  meas_tsmodel/Damp1
%  meas_tsmodel/MSE
%  meas_tsmodel/MAE
%  meas_tsmodel/AIC
%  meas_tsmodel/Mean
%  meas_tsmodel/Variance
%  meas_tsmodel/RMS
%  meas_tsmodel/Kurtosis
%  meas_ps_spec/PeakAmp1
%  meas_ps_spec/PeakFreq1
%  meas_ps_spec/BandPower
%  meas_tsproc_sigstats/ClearanceFactor
%  meas_tsproc_sigstats/CrestFactor
%  meas_tsproc_sigstats/ImpulseFactor
%  meas_tsproc_sigstats/Kurtosis
%  meas_tsproc_sigstats/Mean
%  meas_tsproc_sigstats/PeakValue
%  meas_tsproc_sigstats/RMS
%  meas_tsproc_sigstats/SINAD
%  meas_tsproc_sigstats/SNR
%  meas_tsproc_sigstats/ShapeFactor
%  meas_tsproc_sigstats/Skewness
%  meas_tsproc_sigstats/Std
%  meas_tsproc_sigstats/THD
%  meas_tsproc_tsfeat/Minimum
%  meas_tsproc_tsfeat/Median
%  meas_tsproc_tsfeat/Maximum
%  meas_tsproc_tsfeat/Q1
%  meas_tsproc_tsfeat/Q3
%  meas_tsproc_tsfeat/IQR
%  meas_tsproc_tsmodel/Coef1
%  meas_tsproc_tsmodel/Freq1
%  meas_tsproc_tsmodel/Damp1
%  meas_tsproc_tsmodel/MSE
%  meas_tsproc_tsmodel/MAE
%  meas_tsproc_tsmodel/AIC
%  meas_tsproc_tsmodel/Mean
%  meas_tsproc_tsmodel/Variance
%  meas_tsproc_tsmodel/RMS
%  meas_tsproc_tsmodel/Kurtosis
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 14-Nov-2024 14:41:50

% Initialize feature table.
featureTable = table;

% Get all input variables.
temp = detrend(inputData.signal, 1, 'omitnan', 'SamplePoints', inputData.Time);
meas = table(inputData.Time,temp,'VariableNames',{'Time','signal'});

%% Interpolation
% Compute interpolation
time = meas.Time;

% Get sampling period
meas_interp_Fs = effectivefs(time);
samplePeriod_numeric = 1/meas_interp_Fs;
if isduration(time) || isdatetime(time)
    samplePeriod = seconds(samplePeriod_numeric);
else
    samplePeriod = samplePeriod_numeric;
end

timeOrigin = datetime(0,1,1,0,0,0);
if isdatetime(time)
    ivStart = min(time) - timeOrigin;
    ivEnd = max(time) - timeOrigin;
else
    ivStart = min(time);
    ivEnd = max(time);
end

if rem(ivStart, samplePeriod) ~= 0
    gridStartIdx = ceil((ivStart+eps)/samplePeriod);
else
    gridStartIdx = ivStart/samplePeriod;
end

if rem(ivEnd, samplePeriod) ~= 0
    gridEndIdx = floor((ivEnd-eps)/samplePeriod);
else
    gridEndIdx = ivEnd/samplePeriod;
end

ivGrid = (gridStartIdx:gridEndIdx)'*samplePeriod;
if isdatetime(time)
    ivGrid = ivGrid + timeOrigin;
end

% Interpolation
val = interp1(time,meas.signal,ivGrid,'linear',NaN);
meas_interp = table(ivGrid,val,'VariableNames',{'Time','signal'});

%% TimeSeriesProcessing
% Apply time series processing steps.
x = meas.signal;
t = meas.Time;
% Detrend the signal.
order = 1;
x = detrend(x, order, 'omitnan', 'SamplePoints', t);

% Store computed signal in a table.
meas_tsproc = table(t,x,'VariableNames',{'Time','signal'});

%% PowerSpectrum
% Get units to use in computed spectrum.
tuReal = "seconds";

% Compute effective sampling rate.
tNumeric = time2num(meas.Time,tuReal);
[Fs,irregular] = effectivefs(tNumeric);
Ts = 1/Fs;

% Resample non-uniform signals.
x_raw = meas.signal;
if irregular
    x = resample(x_raw,tNumeric,Fs,'linear');
else
    x = x_raw;
end

% Set Welch spectrum parameters.
L = fix(length(x)/4.5);
noverlap = fix(L*50/100);
win = hamming(L);

% Compute the power spectrum.
[ps,f] = pwelch(x,win,noverlap,[],Fs);
w = 2*pi*f;

% Convert frequency unit.
factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
w = factor*w;
Fs = 2*pi*factor*Fs;

% Remove frequencies above Nyquist frequency.
I = w<=(Fs/2+1e4*eps);
w = w(I);
ps = ps(I);

% Configure the computed spectrum.
ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
ps.Properties.VariableUnits = {'Hz', ''};
meas_ps = ps;
meas_ps_SampleFrequency = Fs;

%% SignalFeatures
% Compute signal features.
inputSignal = meas.signal;
ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
CrestFactor = peak2rms(inputSignal);
ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
Kurtosis = kurtosis(inputSignal);
Mean = mean(inputSignal,'omitnan');
PeakValue = max(abs(inputSignal));
RMS = rms(inputSignal,'omitnan');
SINAD = sinad(inputSignal);
SNR = snr(inputSignal);
ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
Skewness = skewness(inputSignal);
Std = std(inputSignal,'omitnan');
THD = thd(inputSignal);

% Concatenate signal features.
featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

% Store computed features in a table.
featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
meas_sigstats = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_sigstats/' featureNames{ct}];
end
meas_sigstats = renamevars(meas_sigstats, featureNames, newFeatureNames);
featureTable = [featureTable, meas_sigstats];

%% TimeSeriesFeatures
% Compute time series features.
inputSignal = meas.signal;
quartiles = quantile(inputSignal, [0.25 0.5 0.75]);

% Extract individual feature values.
Minimum = min(inputSignal);
Median = median(inputSignal, 'omitnan');
Maximum = max(inputSignal);
Q1 = quartiles(1);
Q3 = quartiles(3);
IQR = quartiles(3)-quartiles(1);

% Concatenate signal features.
featureValues = [Minimum,Median,Maximum,Q1,Q3,IQR];

% Store computed features in a table.
featureNames = {'Minimum','Median','Maximum','Q1','Q3','IQR'};
meas_tsfeat = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_tsfeat/' featureNames{ct}];
end
meas_tsfeat = renamevars(meas_tsfeat, featureNames, newFeatureNames);
featureTable = [featureTable, meas_tsfeat];

%% TimeSeriesModelFeatures
% Compute model-based time series features.
x = meas.signal;
t = meas.Time;
y = x - mean(x,'omitnan');
N = numel(x);

% Estimate autoregressive model.
p = 10;
R = xcorr(y,p,'biased');
R(1:p) = [];
a = zeros(1, p+1);
[tmp_a,Ep] = levinson(R,p);
a(1:end) = tmp_a(1:numel(a));

% Compute effective sampling rate.
tNumeric = time2num(t,"seconds");
Fs = effectivefs(tNumeric);

% Compute model poles.
r = sort(roots(a),'descend');
s = Fs*log(r);
Fn = abs(s)/2/pi;
Zn = -real(s)./abs(s);

% Estimate process noise.
w = filter(a,1,y);

% Estimate model residuals.
e = filter(a,1,x);

% Extract individual feature values.
Coef1 = a(2);
Freq1 = Fn(1);
Damp1 = Zn(1);
MSE = var(w,'omitnan');
MAE = mean(abs(w),'omitnan');
AIC = log(Ep) + 2*p/N;
Mean = mean(e,'omitnan');
Variance = var(e,'omitnan');
RMS = rms(e,'omitnan');
Kurtosis = kurtosis(e);

% Concatenate signal features.
featureValues = [Coef1,Freq1,Damp1,MSE,MAE,AIC,Mean,Variance,RMS,Kurtosis];

% Store computed features in a table.
featureNames = {'Coef1','Freq1','Damp1','MSE','MAE','AIC','Mean','Variance','RMS','Kurtosis'};
meas_tsmodel = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_tsmodel/' featureNames{ct}];
end
meas_tsmodel = renamevars(meas_tsmodel, featureNames, newFeatureNames);
featureTable = [featureTable, meas_tsmodel];

%% SpectrumFeatures
% Compute spectral features.
% Get frequency unit conversion factor.
factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
ps = meas_ps.SpectrumData;
w = meas_ps.Frequency;
w = factor*w;
mask_1 = (w>=factor*0) & (w<=factor*500.000000011823);
ps = ps(mask_1);
w = w(mask_1);

% Compute spectral peaks.
[peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
    'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

% Extract individual feature values.
PeakAmp1 = peakAmp(1);
PeakFreq1 = peakFreq(1);
BandPower = trapz(w/factor,ps);

% Concatenate signal features.
featureValues = [PeakAmp1,PeakFreq1,BandPower];

% Store computed features in a table.
featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
meas_ps_spec = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_ps_spec/' featureNames{ct}];
end
meas_ps_spec = renamevars(meas_ps_spec, featureNames, newFeatureNames);
featureTable = [featureTable, meas_ps_spec];

%% SignalFeatures
% Compute signal features.
inputSignal = meas_tsproc.signal;
ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
CrestFactor = peak2rms(inputSignal);
ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
Kurtosis = kurtosis(inputSignal);
Mean = mean(inputSignal,'omitnan');
PeakValue = max(abs(inputSignal));
RMS = rms(inputSignal,'omitnan');
SINAD = sinad(inputSignal);
SNR = snr(inputSignal);
ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
Skewness = skewness(inputSignal);
Std = std(inputSignal,'omitnan');
THD = thd(inputSignal);

% Concatenate signal features.
featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

% Store computed features in a table.
featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
meas_tsproc_sigstats = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_tsproc_sigstats/' featureNames{ct}];
end
meas_tsproc_sigstats = renamevars(meas_tsproc_sigstats, featureNames, newFeatureNames);
featureTable = [featureTable, meas_tsproc_sigstats];

%% TimeSeriesFeatures
% Compute time series features.
inputSignal = meas_tsproc.signal;
quartiles = quantile(inputSignal, [0.25 0.5 0.75]);

% Extract individual feature values.
Minimum = min(inputSignal);
Median = median(inputSignal, 'omitnan');
Maximum = max(inputSignal);
Q1 = quartiles(1);
Q3 = quartiles(3);
IQR = quartiles(3)-quartiles(1);

% Concatenate signal features.
featureValues = [Minimum,Median,Maximum,Q1,Q3,IQR];

% Store computed features in a table.
featureNames = {'Minimum','Median','Maximum','Q1','Q3','IQR'};
meas_tsproc_tsfeat = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_tsproc_tsfeat/' featureNames{ct}];
end
meas_tsproc_tsfeat = renamevars(meas_tsproc_tsfeat, featureNames, newFeatureNames);
featureTable = [featureTable, meas_tsproc_tsfeat];

%% TimeSeriesModelFeatures
% Compute model-based time series features.
x = meas_tsproc.signal;
t = meas_tsproc.Time;
y = x - mean(x,'omitnan');
N = numel(x);

% Estimate autoregressive model.
p = 10;
R = xcorr(y,p,'biased');
R(1:p) = [];
a = zeros(1, p+1);
[tmp_a,Ep] = levinson(R,p);
a(1:end) = tmp_a(1:numel(a));

% Compute effective sampling rate.
tNumeric = time2num(t,"seconds");
Fs = effectivefs(tNumeric);

% Compute model poles.
r = sort(roots(a),'descend');
s = Fs*log(r);
Fn = abs(s)/2/pi;
Zn = -real(s)./abs(s);

% Estimate process noise.
w = filter(a,1,y);

% Estimate model residuals.
e = filter(a,1,x);

% Extract individual feature values.
Coef1 = a(2);
Freq1 = Fn(1);
Damp1 = Zn(1);
MSE = var(w,'omitnan');
MAE = mean(abs(w),'omitnan');
AIC = log(Ep) + 2*p/N;
Mean = mean(e,'omitnan');
Variance = var(e,'omitnan');
RMS = rms(e,'omitnan');
Kurtosis = kurtosis(e);

% Concatenate signal features.
featureValues = [Coef1,Freq1,Damp1,MSE,MAE,AIC,Mean,Variance,RMS,Kurtosis];

% Store computed features in a table.
featureNames = {'Coef1','Freq1','Damp1','MSE','MAE','AIC','Mean','Variance','RMS','Kurtosis'};
meas_tsproc_tsmodel = array2table(featureValues,'VariableNames',featureNames);

% Append computed features to featureTable.
newFeatureNames = cell(1, numel(featureNames));
for ct = 1:numel(featureNames)
    newFeatureNames{ct} = ['meas_tsproc_tsmodel/' featureNames{ct}];
end
meas_tsproc_tsmodel = renamevars(meas_tsproc_tsmodel, featureNames, newFeatureNames);
featureTable = [featureTable, meas_tsproc_tsmodel];

end
