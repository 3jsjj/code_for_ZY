function  getaframe(input_filenames)
%   MATLAB_INPUT_FILE, MATLAB_OUTPUT_FILE, MATLAB_BEGINI, MATLAB_NATOMS

begini = 201;
natoms = 1920;

if nargin >= 1 && ~isempty(input_filename)
    filename = input_filename;
else
    filename = getenv('MATLAB_INPUT_FILE');
end

fid_input = fopen(filename,'r');
output_file = 'alastframe.lammpstrj'
fid_output = fopen(output_file, 'w+');
if fid_output == -1
    fclose(fid_input);
    error('Cannot create output file: %s', output_file);s
end

try
    skip_lines = (9 + natoms) * (begini - 1);
    fprintf('Skipping %d lines...\n', skip_lines);
    
    for i = 1:skip_lines
        chartemp = fgetl(fid_input);
        if ~ischar(chartemp)
            error('End of file reached while skipping lines. Check begini and natoms parameters.');
        end
    end
    line_count = 0;
    while 1
        chartemp = fgetl(fid_input);   
        if ~ischar(chartemp)
            break
        end
        fprintf(fid_output, '%s\n', chartemp);
        line_count = line_count + 1;
    end
    
    fprintf('Successfully extracted %d lines to %s\n', line_count, output_file);
catch ME
	fclose(fid_input);
	fclose(fid_output);
	rethrow(ME);
    
end
fclose(fid_input);
fclose(fid_output);

fprintf('Process completed successfully.\n');
end
