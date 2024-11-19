function filtered_table = filter_signal_table(meas_table, fpass)
% FILTER_SIGNAL_TABLE   Apply a lowpass filter to the meas_table 
%
% filtered_table = filter_signal_table(meas_table, fpass) Apply a lowpass filter with the
% cut-off frequency `fpass` to the meas column of the meas_table
    filtered_table=meas_table;

    for i=1:height(filtered_table)
        signal=filtered_table.meas{i}.signal;
        Time=filtered_table.meas{i}.Time;
        fs=length(Time)/seconds(Time(end));
        filteredSignal=lowpass(signal,fpass,fs);
        filtered_table.meas{i}=timetable(Time,filteredSignal);
        filtered_table.meas{i}.Properties.VariableNames={'signal'};
    end
end