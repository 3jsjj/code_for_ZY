
function safe_line = safe_fgetl(fid)
	temp_line = fgetl(fid);
	if ~ischar(temp_line)
		if temp_line == -1
			temp_line='';
		else
			error('not end');
		end
	end
	safe_line = strtrim(temp_line);
end

