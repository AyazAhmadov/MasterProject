function feature_table = extractFeaturesByHand(inputData)
    feature_table = table;
    signal = inputData.signal;
    time = inputData.Time;
    fs = 1/seconds(mean(diff(time)));

    %% Power Spectrum
    [P, f] = power_spectrum(signal, time, 'dBScale', true);
    [maxP, maxidx] = max(P);
    maxf = f(maxidx);
    tab = array2table([maxP, maxf], 'VariableNames', {'PeakAmp1', 'PeakFreq1'});
    feature_table = [feature_table, tab];

    %% Total Harmonic Distortion
    [thd_db,harmpow,harmfreq] = thd(signal, fs);
    harmpow = paddata(harmpow, 5, "FillValue", NaN);
    harmpow = harmpow(1:5);
    harmfreq = paddata(harmfreq, 5, "FillValue", NaN);
    harmfreq = harmfreq(1:5);

    varNames = cellstr(['THD', strcat('HarmPower', string([1, 2, 3, 4, 5])), strcat('HarmFreq', string([1, 2, 3, 4, 5]))]);
    tab = array2table([thd_db; harmpow; harmfreq]', 'VariableNames',varNames);
    feature_table = [feature_table, tab];

    %% Signal Statistics
    Mean = mean(signal, 'omitnan');
    RMS = rms(signal, 'omitnan');
    PeakValue = max(abs(signal));
    ClearanceFactor = max(abs(signal))/(mean(sqrt(abs(signal)))^2);
    CrestFactor = peak2rms(signal);
    ImpulseFactor = max(abs(signal))/mean(abs(signal));
    Kurtosis = kurtosis(signal);
    Skewness = skewness(signal);
    SNR = snr(signal);
    STD = std(signal);
    [Sinad, TotDistPow] = sinad(signal, fs);

    quartiles = quantile(signal, [0.25 0.5 0.75]);
    Minimum = min(signal);
    Median = median(signal, 'omitnan');
    Maximum = max(signal);
    Q1 = quartiles(1);
    Q3 = quartiles(3);
    IQR = quartiles(3)-quartiles(1);

    varNames = {'Mean', 'RMS', 'PeakValue', 'ClearanceFactor', 'CrestFactor', 'ImpulseFactor', 'Kurtosis', 'Skewness', 'SNR', 'STD', 'SINAD', 'TotDistPow', 'Minimum', 'Median', 'Maximum', 'Q1', 'Q3', 'IQR'};
    tab = array2table([Mean, RMS, PeakValue, ClearanceFactor, CrestFactor, ImpulseFactor, Kurtosis, Skewness, SNR, STD, Sinad, TotDistPow, Minimum, Median, Maximum, Q1, Q3, IQR], 'VariableNames',varNames);
    feature_table = [feature_table, tab];
end