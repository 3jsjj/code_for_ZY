function getq()
    value = 0.23;
    value1 = 0.98;
    Lx = 280 * value1;
    Ly = 140 * value1 *1.73 ;
    n = round(Lx);
    % n = 50;

    natoms=78400;

    %读入一个dump文件
    prefix=['dump_' num2str(value1) '_' num2str(value) '_228_onlymembrane'];
    filename = [prefix '.lammpstrj'];

    %建立盒子大小的网格
    yi=linspace(-Ly/2,Ly/2,n+1);% use short side to form a square % 生成以0为中心的，关于0对称的含0元素的向量
    L = Ly;
    yi = yi(1:n)+Ly/n/2;%移动元素，就是给所有的元素加了一个Ly/n/2
    [XI,YI] = meshgrid(yi,yi);%确定插值的范围
    hq2 = zeros(n,n);%建一个hq2的n阶空矩阵

    begini = 4000;
    endi = 8000;
    interval = 1;

    for i= begini:interval: endi %中间隔2
        %储存每帧数据，为每帧数据命名prefix1
        prefix1 = ['rc2.6t0.22m4a' num2str(i) '.0c'];
        getaframe(filename,begini,i,prefix1,interval,natoms);
        %读取刚刚写的那一帧数据
        xyz=getxyz1(natoms,prefix1);
        %插值
        ZI = griddata(xyz(:,1),xyz(:,2),xyz(:,3),XI,YI);
        for k=1:n
            for j=1:n
                if abs(ZI(k,j)) <= 3 % remove bad points and flying out points

                else
                    ZI(k,j)=0;
                end
            end
        end
        %%傅里叶变换
        hq_t = fft2(ZI)/n/n;%2维平面的傅里叶变换，/n/n是为归一化
        hq_t = abs(hq_t).^2;%只关注数值大小的功率谱密度，忽略方向

        hq2 = hq2 + hq_t;%积累数据
%         surf(XI,YI,ZI);
%         shading interp
%         pause
    end

    hq2 = hq2./((begini-begini)/interval +1);%求平均
    m=round(n/2)-1;
    hq2v = zeros(1,m);
    qn_k = zeros(1,m);
    for i=1:m
        for j=1:m
            qn=floor(sqrt((i-1)^2+(j-1)^2));
            if qn <= m-1
                hq2v(qn+1) = hq2v(qn+1) + hq2(i,j);
                qn_k(qn+1) = qn_k(qn+1) +1;
            end
        end
    end
    hq2 =  hq2v./qn_k;
    hq2 =  hq2(2:m);% remove zero-frequency
    q = 2*pi*[1:m-1]/L; % remove zero-frequency

    A = L^2 ;

    fid = fopen([prefix '_Ahq2_q.txt'],'w+');
    fprintf(fid,'%26.14f %26.14f \n',[q;A*hq2]);
    fclose(fid);

    fid = fopen([prefix 'log_Ahq2_q.txt'],'w+');
    fprintf(fid,'%26.14f %26.14f \n',[log(q);log(A*hq2)]);
    fclose(fid);

    %% 拟合
    
    data = load('dump_0.98_0.23_228_onlymembrane_Ahq2_q.txt');
    q = data(:,1);
    A_hq2 = data(:,2);
    log_q = log(q);
    log_A = log(A_hq2);
    
    %设置一个中间点
    transition_idx=2;
    %设置一个结束点
    end_id=20;
    
    small_q_idx = 1:transition_idx;
    large_q_idx = transition_idx:(length(q)-end_id);
    
    
    p1 = polyfit(log_q(small_q_idx), log_A(small_q_idx), 1);
    p2 = polyfit(log_q(large_q_idx), log_A(large_q_idx), 1);
    
    fprintf('TENSION:%.6f\n', p1(1));
    fprintf('BENDING:%.6f\n', p2(1));

    sigma = exp(-p1(2));  
    kappa = exp(-p2(2));  
    
    loglog(q, A_hq2, 'bo', 'MarkerSize', 4);
    hold on;
    loglog(q(small_q_idx), exp(polyval(p1, log_q(small_q_idx))), 'r-', 'LineWidth', 2);
    loglog(q(large_q_idx), exp(polyval(p2, log_q(large_q_idx))), 'g-', 'LineWidth', 2);
    
    
    fprintf('TENSION=%.6f\n', sigma);
    fprintf('BENDING=%.6f\n', kappa);

end



