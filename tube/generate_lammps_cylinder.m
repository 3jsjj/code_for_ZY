function generate_lammps_cylinder(N_target, R)
    % --- 1. 参数设定 ---
    mu = 3.0; P = -1.0e-01; Pdamp = 500.0; seed = 123;
    target_d = 1.0; % 目标间距

    % 几何计算
    n_per_ring = round(2 * pi * R / target_d); 
    d_phi = 2 * pi / n_per_ring;
    h = target_d * (sqrt(3)/2); % 六方步长

    % --- 2. 严格命名 (N补齐6位，R补齐2位) ---
    fileName = sprintf('lmpdat_cyl_mu%.1f_P%.1e_N%06d_R%02d_Pdamp%.1f_seed%d.in', ...
                       mu, P, N_target, round(R), Pdamp, seed);

    % --- 3. 生成坐标 ---
    coords = zeros(N_target, 3);
    phi_list = zeros(N_target, 1);
    count = 1;
    ring_idx = 0;
    while count <= N_target
        curr_x = ring_idx * h;
        phi_offset = mod(ring_idx, 2) * (d_phi / 2);
        for j = 0:n_per_ring-1
            if count > N_target, break; end
            phi = j * d_phi + phi_offset;
            coords(count, :) = [curr_x, R * sin(phi), R * cos(phi)];
            phi_list(count) = phi;
            count = count + 1;
        end
        ring_idx = ring_idx + 1;
    end
    coords(:,1) = coords(:,1) - mean(coords(:,1)); % 居中

    % --- 4. 写入文件 ---
    fid = fopen(fileName, 'w');
    fprintf(fid, 'LAMMPS data file: Exact N=%d, 8-column hybrid format\n\n', N_target);
    fprintf(fid, '%d atoms\n1 atom types\n%d ellipsoids\n\n', N_target, N_target);

    % 边界设定
    fprintf(fid, '%+12.6f %+12.6f xlo xhi\n', min(coords(:,1))-5, max(coords(:,1))+5);
    fprintf(fid, '%+12.6f %+12.6f ylo yhi\n', -100.0, 100.0);
    fprintf(fid, '%+12.6f %+12.6f zlo zhi\n\n', -100.0, 100.0);

    % 必须有 Masses 部分
    fprintf(fid, 'Masses\n\n1 1.0\n\n');

    % --- 5. Atoms 部分: 修正为 8 列 ---
    % 格式：ID type x y z ellipsoidflag density molecule-ID
    fprintf(fid, 'Atoms # hybrid ellipsoid molecular\n\n');
    for i = 1:N_target
        % 最后一列设为 0，满足你看到的案例习惯
        fprintf(fid, '%7d %2d %+14.6f %+14.6f %+14.6f %2d %d %d\n', ...
            i, 1, coords(i,1), coords(i,2), coords(i,3), 1, 1.0, 0);
    end

    % --- 6. Ellipsoids 部分 ---
    fprintf(fid, '\nEllipsoids\n\n');
    theta_half = pi / 4; 
    for i = 1:N_target
        p = phi_list(i);
        qw = cos(theta_half);
        qi = 0;
        qj = -cos(p) * sin(theta_half);
        qk = sin(p) * sin(theta_half);
        fprintf(fid, '%7d %+12.6f %+12.6f %+12.6f %+10.4f %+10.4f %+10.4f %+10.4f\n', ...
            i, 1.0, 0.9999, 0.9999, qw, qi, qj, qk);
    end

    fclose(fid);
    fprintf('成功生成！文件名: %s\n', fileName);
    fprintf('列数检查：Atoms 段现在为 8 列，最后一列(molecule-ID)为 0\n');
end