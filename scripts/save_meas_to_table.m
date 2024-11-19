function new_table = save_meas_to_table(meas_table, acc_Sensor, mode, aufbau, options)
% SAVE_MEAS_TO_TABLE Save the new measurements from Simulink into table
%
% new_table = save_meas_to_table(meas_table, acc_Sensor, mode, aufbau)
% Saves the measurements from `acc_Sensor` into `meas_table` with the
% current `date`, `mode`, `aufbau`. The condition by default is 'healthy'.
% fs is calculted from the time array in the `acc_Sensor`.
%
% __ = save_meas_to_table(__, __, 'Condition', condition) Optionally
% indicate the condition of the demonstrator. Can be 'healthy' (default) or
% 'unhealthy'
%
% __ = save_meas_to_table(__, __, 'Date', date) Optionally include the
% date as a datetime object
%
% __ = save_meas_to_table(__, __, 'T', T) Indicate the length of a signal
% in seconds

    arguments
        meas_table table
        acc_Sensor struct
        mode {mustBeNumeric}
        aufbau {mustBeNumeric}
        options.Condition string = 'healthy'
        options.Date datetime = datetime("today")
        options.T {mustBeNumeric} = 10;
    end

    if ~(strcmp(options.Condition, 'healthy') | strcmp(options.Condition, 'unhealthy'))
        error("ValueError.\n'Condition' argument can have to values 'healthy' or 'unhealthy', but %s was given", str(options.Condition))
    end
    
    new_table = meas_table;
    signal = acc_Sensor.signals.values;
    time = acc_Sensor.time;
    fs = 1/mean(diff(time));

    num_of_meas = length(time)/fs/options.T;
    for i=1:num_of_meas
        idx = (i-1)*options.T <= time & time <= i*options.T;
        t = time(idx) - min(time(idx));
        s = signal(idx);
        s = detrend(s, 1, 'omitnan', 'SamplePoints', t);
        ttable = timetable(seconds(t), s, 'VariableNames', {'signal'});

        rows = height(new_table);
        new_table{rows+1, "date"} = options.Date;
        new_table{rows+1, "meas"} = {ttable};
        new_table{rows+1, "mode"} = mode;
        new_table{rows+1, "aufbau"} = aufbau;
        new_table{rows+1, "fs"} = fs;
        new_table{rows+1, 'condition'} = options.Condition;
    end

end