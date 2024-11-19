function [predicted_modes, confusion_matrix, accuracy] = predict_mode_from_table(test_table, feature_extractor_func, classifier_file_name)
    % PREDICT_MODE_FROM_TABLE   Predict operation mode
    %
    % predicted_modes = predict_mode_from_table(test_table, @feature_extractor_func,
    % classifier_file_name) Returns an array of modes for each row in
    % the test_table predicted with a classifier stored in the
    % `classifier_file_name` from features extracted with the
    % `diafnosticFeatures` function
    %
    % [predicted_modes, confusion_matrix] = predict_mode_from_table(__, __)
    % Also returns the confusion matrix
    %
    % [predicted_modes, confusion_matrix, accuracy] =
    % predict_mode_from_table(__, __) Also returns the accuracy of the
    % predictions
    %
    % predict_mode_from_table(__, __) Makes the predictions but only shows the
    % confusion matrix without returning anything
    classifier = loadLearnerForCoder(classifier_file_name);
    modes=zeros(height(test_table),1);
    for jj=1:height(test_table)
        ratio = floor(jj/height(test_table)*100);
        loading_string = repmat('=', 1, ratio);
        spaces = repmat(' ', 1, 100-ratio);
        clc
        disp(strcat([sprintf('%d/%d %.2f', jj, height(test_table), jj/height(test_table)*100) '%' '    [' loading_string spaces ']']))
        meas = test_table.meas{jj};
        Predict_FeatureTable=feature_extractor_func(meas);
        mode = predict(classifier,Predict_FeatureTable);
        modes(jj)=mode;    
    end

    if nargout == 0
        confusionchart(test_table.mode, modes)
    elseif nargout == 1
        predicted_modes = modes;
    elseif nargout == 2
        predicted_modes = modes;
        confusion_matrix = confusionmat(test_table.mode, modes);
    elseif nargout == 3
        predicted_modes = modes;
        confusion_matrix = confusionmat(test_table.mode, modes);
        accuracy = sum(test_table.mode == modes)/length(modes)*100;
    end
end