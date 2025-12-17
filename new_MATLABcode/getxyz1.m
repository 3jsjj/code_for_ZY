function [xyz] =getxyz1(natoms,prefix)
    filename = [prefix '.lammpstrj'];
    fid_input = fopen(filename, 'r');
%     %跳过一帧
%     for i=1:(9+natoms)
%         chartemp=fgetl(fid_input);
%     end

    for i=1:5
        chartemp=fgetl(fid_input);
    end
    boxsize = fscanf(fid_input, '%g %g', [2 3]) ; boxsize=boxsize';
    chartemp=fgetl(fid_input);
    chartemp=fgetl(fid_input);
    
    xyz = fscanf(fid_input, '%g %g %g %g %g ', [5 natoms]) ;
    chartemp=fgetl(fid_input);
    %%
    xyz = xyz(3:5,:)';%%%这里是否有问题，要明确xyz = xyz(:,3:5);和xyz = xyz(3:5,:)';的区别
    %这里归一化坐标，原本实在（0，1）范围，乘以盒子长度之后应加上盒子左边界，完全没问题
    xyz(:,1) = xyz(:,1)*(boxsize(1,2)-boxsize(1,1))+boxsize(1,1);
    xyz(:,2) = xyz(:,2)*(boxsize(2,2)-boxsize(2,1))+boxsize(2,1);
    xyz(:,3) = xyz(:,3)*(boxsize(3,2)-boxsize(3,1))+boxsize(3,1);
end