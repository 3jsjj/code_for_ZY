function getaframe(input_filename,begini,current,prefix1,interval,natoms)
%   MATLAB_INPUT_FILE, MATLAB_OUTPUT_FILE, MATLAB_BEGINI, MATLAB_NATOMS


    if nargin >= 1 && ~isempty(input_filename)
        filename = input_filename;
    else
        filename = getenv('MATLAB_INPUT_FILE');
    end

    fid_input = fopen(filename,'r');
    output_file = [prefix1 '.lammpstrj'];
    fid_output = fopen(output_file, 'w+');

    if fid_output == -1
        fclose(fid_input);
        error('Cannot create output file: %s', output_file); 
    end

    try
        %跳过关键帧前面的数据
        skip_lines = (9 + natoms) *  ( current - begini) / interval;
        fprintf('Skipping %d lines...\n', skip_lines);

        for i = 1:skip_lines
            chartemp = fgetl(fid_input);
            if ~ischar(chartemp)
                error('End of file reached while skipping lines. Check begini and natoms parameters.');
            end
        end
        %读取关键帧数据，跳过关键帧后面的数据
        line_count = 0;
        while 1
            chartemp = fgetl(fid_input);   
            if ~ischar(chartemp)
                break
            end
            fprintf(fid_output, '%s\n', chartemp);
            line_count = line_count + 1;
            if line_count >= natoms+9
            break
            end
        end

        fprintf('Successfully extracted %d lines to %s\n', line_count, output_file);

    catch ME
        if fid_input > 0
            fclose(fid_input);
        end
        if fid_output > 0
            fclose(fid_output);
        end
        rethrow(ME);  
    end

    fclose(fid_input);
    fclose(fid_output);

    fprintf('Process completed successfully.\n');
end
