function idx = get_last_idx(arr, mode)
% GET_LAST_IDX   get last index of a 2D ARRAY
    last_idx = find(arr(:, mode), 1, 'last');
    if isempty(last_idx)
        idx = 1;
    else
        idx = last_idx+1;
    end
end