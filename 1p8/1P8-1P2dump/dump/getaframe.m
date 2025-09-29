function bending_rigidity

clc;
clear;

begini=401;

natoms=5600;


filename = 'dump_0.951_0.2_228_onlymembrane.lammpstrj';


fid_input = fopen(filename, 'r');
fid_output = fopen('alastfram.lammpstrj', 'w+');

for i=1:(9+natoms)*(begini-1)
%chartemp=fgetl(fid_input);
end

while 1
    chartemp=fgetl(fid_input);   
    if ~ischar(chartemp),   break,   end
    fprintf(fid_output, [chartemp '\n']);
    %disp(tline)
end

fclose(fid_input)
fclose(fid_output)