% function bending_rigidity
% 
% for i=2:5
%   prefix = ['rc2.6t0.22m4a' num2str(i) '.0c'];
%   spectra(1,prefix,1,10);
% end


% function bending_rigidity %(flag1,prefix,pb,pe)
function bending_rigidity(prefix)
flag1 =1;
pb=1;pe=15;

if nargin >= 1 && ~isempty(input_filename)
    output_prefix = prefix;
else
    output_prefix = getenv('MATLAB_PARAM');
end


set(0, 'DefaultFigureVisible', 'off');

Lx = 44;
Ly = 42;
n = 100;
begini = 1;
endi = 1;

natoms=1929;

for i=2:2
prefix='alastframe';
filename = [prefix '.lammpstrj'];


m=round(n/2)-1;

if flag1 ==1

xi=linspace(-0,Lx, n+1); xi = xi(1:n)+Lx/n/2;
yi=linspace(-Ly/2,Ly/2,n+1); yi = yi(1:n)+Ly/n/2;
[XI,YI] = meshgrid(xi,yi);

hq2 = zeros(n,n);

fid_input = fopen(filename, 'r');


for i=1:(9+natoms)*(begini-1)
chartemp=safe_fgetl(fid_input);
end

hq2v_sum = zeros(1,m);

for datai = begini:endi

for i=1:5
chartemp=safe_fgetl(fid_input);
end    
boxsize = fscanf(fid_input, '%g %g', [2 3]) ; boxsize=boxsize';
chartemp=safe_fgetl(fid_input);
chartemp=safe_fgetl(fid_input);

xyz = fscanf(fid_input, '%g %g %g %g %g  %g  %g  %g', [8 natoms]) ;
chartemp=safe_fgetl(fid_input);

xyz = xyz(3:5,:)';

xyz(:,1) = xyz(:,1)*(boxsize(1,2)-boxsize(1,1))+boxsize(1,1);
xyz(:,2) = xyz(:,2)*(boxsize(2,2)-boxsize(2,1))+boxsize(2,1);
xyz(:,3) = xyz(:,3)*(boxsize(3,2)-boxsize(3,1))+boxsize(3,1);

fprintf('Starting griddata interpolation...\n');
tic;


%try
    %ZI = griddata(xyz(:,1), xyz(:,2), xyz(:,3), XI, YI, 'v4');
%catch
    %fprintf('Linear interpolation failed, trying nearest...\n');
    ZI = griddata(xyz(:,1), xyz(:,2), xyz(:,3), XI, YI, 'nearest');
%end

interpolation_time = toc;
fprintf('Griddata completed in %.2f seconds\n', interpolation_time);


fig = figure('Visible','off');
surf(XI,YI,ZI);
shading interp;
% pause

surf_filename = sprintf('%d_surface_frame.png', output_prefix);
print(fig, surf_filename,'-dpng','-r300');
fprintf('Surface plot saved as :%s\n', surf_filename);
close(fig);

hq2_t =  fft2(ZI)/n/n;  
hq2 = hq2 + abs(hq2_t).^2;

end % datai
fclose(fid_input);

hq2 = hq2/(endi-begini+1);



hq2v = zeros(1,m);
qn_k = zeros(1,m);
for i=1:m
    for j=1:m
%         q = 2*pi*sqrt((i-1)^2+(j-1)^2)/L;
        qn=floor(sqrt((i-1)^2+(j-1)^2));
        if qn <= m-1
          hq2v(qn+1) = hq2v(qn+1) + hq2(i,j);
          qn_k(qn+1) = qn_k(qn+1) +1; 
        end
    end    
end
hq2 =  hq2v./qn_k;
hq2 =  hq2(2:m);% remove zero-frequency
q = 2*pi*[1:m-1]/Lx; % remove zero-frequency

A = Lx*Ly;
fid = fopen([prefix '_Ahq2_q.txt'],'w+');
fprintf(fid,'%26.14f %26.14f \n',[q;A*hq2]);
fclose(fid);

end


if flag1 == 2 % find bending rigidity and plot
    
data = load([prefix '_Ahq2_q.txt']);
data = log10(data);

hold on
plot(data(:,1),data(:,2),'.');


b1 = (2*sum(data(pb:pe,1))+sum(data(pb:pe,2))) / (pe-pb+1);
b2 = (4*sum(data(pb:pe,1))+sum(data(pb:pe,2))) / (pe-pb+1);
tension = exp(-b1)
bend_k = exp(-b2)

f1= polyval([-2 b1],data(pb:pe,1));
f2= polyval([-4 b2],data(pb:pe,1));


plot(data(pb:pe,1),f1,'b')
plot(data(pb:pe,1),f2,'r')

end

end


