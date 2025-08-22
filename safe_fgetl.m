function safe_line = safe_fgetl(fid) 
    temp_line = fgetl(fid); 
    if ~ischar(temp_line) 
        if temp_line == -1 
            safe_line = -1;  % 保持原来的 -1，不要转换成空字符串
            return;
        else 
            error('not end'); 
        end 
    end 
    safe_line = strtrim(temp_line); 
end
