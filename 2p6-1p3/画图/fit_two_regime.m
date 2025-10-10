function [sigma1, kappa1,sigma2, kappa2] = fit_two_regime(value1,value2)
    prefix1 = sprintf('dump_%s_0.2_228_onlymembrane', num2str(value1));
    data1 = load( sprintf('%s_Ahq2_q.txt',prefix1));
    q1 = data1(:,1);
    A_hq21 = data1(:,2);
    log_q1 = log(q1);
    log_A1 = log(A_hq21);
    %初始设定
    sigma1 = NaN;
    kappa1 = 0;
    
    %% 对于低张力部分
    transition_idx1=1;
    large_q_idx1 = transition_idx1:length(q1)-158;  
    % 固定斜率拟合: log(A) = log(kBT/κ) - 4*log(q)
    % 重写为: log(A) + 4*log(q) = log(kBT/κ)
    fixed_slope1 = -4;
    intercept1 = mean(log_A1(large_q_idx1) - fixed_slope1 * log_q1(large_q_idx1));
        
    % 提取弯曲刚度参数
    kappa1 = exp(-intercept1);  % κ = kBT * exp(intercept)
        
    % 计算拟合优度
    fitted_log_A1 = intercept1 + fixed_slope1* log_q1(large_q_idx1);
    r_squared1 = 1 - sum((log_A1(large_q_idx1) - fitted_log_A1).^2) / ...
                   sum((log_A1(large_q_idx1) - mean(log_A1(large_q_idx1))).^2);
        
    fprintf('弯曲刚度 κ = %.4f (kBT)\n', kappa1);
    fprintf('拟合优度 R? = %.4f\n', r_squared1);
    fprintf('实际斜率: %.4f\n', fixed_slope1);
        
    % 绘图
    figure;
    loglog(q1, A_hq21, 'bo', 'MarkerSize', 6);
    hold on;
        
    % 绘制拟合线
    fitted_A = exp(intercept1) .* q1(large_q_idx1).^fixed_slope1;
    loglog(q1(large_q_idx1), fitted_A, 'r-', 'LineWidth', .5);
        
    xlabel('$q$ (nm$^{-1}$)', 'Interpreter', 'latex', 'FontSize', 12); 
    ylabel('$A \langle |h_q|^2 \rangle$ (nm$^2$)', 'Interpreter', 'latex', 'FontSize', 12);  
    title('单一机制拟合 (弯曲刚度主导)', 'FontSize', 14);
    legend('实验数据', 'q^{-4} (弯曲)', 'Location', 'best'); 
    grid on;

    %% 高张力部分
    prefix2 = sprintf('dump_%s_0.2_228_onlymembrane', num2str(value2));
    data2 = load( sprintf('%s_Ahq2_q.txt',prefix2));
    q2 = data2(:,1);
    A_hq22 = data2(:,2);
    log_q2 = log(q2);
    log_A2 = log(A_hq22);
    %初始设定
    sigma2 = NaN;
    kappa2 = NaN;
    
    transition_idx2=3;
    % 小q区域：强制斜率为-2 (表面张力主导)
    small_q_idx2 = 1:transition_idx2;
    fixed_slope2 = -2;
    intercept2 = mean(log_A2(small_q_idx2) - fixed_slope2 * log_q2(small_q_idx2));
        
    % 大q区域：强制斜率为-4 (弯曲刚度主导)
    large_q_idx2 = transition_idx2:length(q2)-28;
    fixed_slope3 = -4;
    intercept3 = mean(log_A2(large_q_idx2) - fixed_slope3 * log_q2(large_q_idx2));
        
    % 提取参数
    sigma2 = exp(-intercept2)  % σ = kBT * exp(intercept1)
    kappa2 = exp(-intercept3);  % κ = kBT * exp(intercept2)
        
    % 计算各区域拟合优度
    fitted_log_A2 = intercept2 + fixed_slope2 * log_q2(small_q_idx2);
    r_squared1 = 1 - sum((log_A2(small_q_idx2) - fitted_log_A2).^2) / ...
                    sum((log_A2(small_q_idx2) - mean(log_A2(small_q_idx2))).^2);
        
    fitted_log_A3 = intercept2 + fixed_slope3 * log_q2(large_q_idx2);
    r_squared2 = 1 - sum((log_A2(large_q_idx2) - fitted_log_A3).^2) / ...
                    sum((log_A2(large_q_idx2) - mean(log_A2(large_q_idx2))).^2);
        
    fprintf('表面张力 σ = %.4f (kBT/nm?)\n', sigma2);
    fprintf('弯曲刚度 κ = %.4f (kBT)\n', kappa2);
    fprintf('小q区域拟合优度 R? = %.4f\n', r_squared1);
    fprintf('大q区域拟合优度 R? = %.4f\n', r_squared2);
    fprintf('小q区域实际斜率: %.4f\n', fixed_slope2);
    fprintf('大q区域实际斜率: %.4f\n', fixed_slope3);
        
    % 绘图
    %figure;
    loglog(q2, A_hq22, 'b^', 'MarkerSize', 6);
    hold on;
        
    % 绘制拟合线
        fitted_A1 = exp(intercept2) .* q2(small_q_idx2).^fixed_slope2;
        fitted_A2 = exp(intercept3) .* q2(large_q_idx2).^fixed_slope3;
        
        loglog(q2(small_q_idx2), fitted_A1, 'r-', 'LineWidth', 0.5);
        loglog(q2(large_q_idx2), fitted_A2, 'g-', 'LineWidth', 0.5);
        
        % 标记分界点
        line([q2(transition_idx2) q2(transition_idx2)], ylim, 'Color', 'k', ...
             'LineStyle', '--', 'LineWidth', 1);
        
        xlabel('$q$ (nm$^{-1}$)', 'Interpreter', 'latex', 'FontSize', 12); 
        ylabel('$A \langle |h_q|^2 \rangle$ (nm$^2$)', 'Interpreter', 'latex', 'FontSize', 12);  
        title('双机制拟合 (表面张力 + 弯曲刚度)', 'FontSize', 14);
        legend('实验数据', 'q^{-2} (表面张力)', 'q^{-4} (弯曲)', '分界点', ...
               'Location', 'best'); 
        grid on;
        % 设置x轴范围
        xlim([.05, 1.]);

        % 设置y轴范围
        ylim([.01, 10000]);


end