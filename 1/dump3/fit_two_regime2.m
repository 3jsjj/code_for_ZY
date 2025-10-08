function [sigma, kappa] = fit_two_regime2(value)
    % flag = 1: 仅拟合斜率-4 (只考虑弯曲刚度)
    % flag = 2: 拟合斜率-2和-4 (考虑表面张力和弯曲刚度)
    
    if nargin < 2
        flag =2; % 默认值
    end
    prefix = sprintf('dump_0.92_%s_228_onlymembrane', num2str(value));
    data = load( sprintf('%s_Ahq2_q.txt',prefix));
    q = data(:,1);
    A_hq2 = data(:,2);
    log_q = log(q);
    log_A = log(A_hq2);
    %初始设定
    transition_idx = 3;
    sigma = NaN;
    kappa = NaN;
    
    if flag == 1
        large_q_idx = transition_idx:length(q)-20;
        
        % 固定斜率拟合: log(A) = log(kBT/κ) - 4*log(q)
        % 重写为: log(A) + 4*log(q) = log(kBT/κ)
        fixed_slope = -4;
        intercept = mean(log_A(large_q_idx) - fixed_slope * log_q(large_q_idx));
        
        % 提取弯曲刚度参数
        kappa = exp(-intercept);  % κ = kBT * exp(intercept)
        
        % 计算拟合优度
        fitted_log_A = intercept + fixed_slope * log_q(large_q_idx);
        r_squared = 1 - sum((log_A(large_q_idx) - fitted_log_A).^2) / ...
                       sum((log_A(large_q_idx) - mean(log_A(large_q_idx))).^2);
        
        fprintf('弯曲刚度 κ = %.4f (kBT)\n', kappa);
        fprintf('拟合优度 R? = %.4f\n', r_squared);
        fprintf('实际斜率: %.4f\n', fixed_slope);
        
        % 绘图
        figure;
        loglog(q, A_hq2, 'bo', 'MarkerSize', 6);
        hold on;
        
        % 绘制拟合线
        fitted_A = exp(intercept) .* q(large_q_idx).^fixed_slope;
        loglog(q(large_q_idx), fitted_A, 'g-', 'LineWidth', 2);
        
        xlabel('$q$ (nm$^{-1}$)', 'Interpreter', 'latex', 'FontSize', 12); 
        ylabel('$A \langle |h_q|^2 \rangle$ (nm$^2$)', 'Interpreter', 'latex', 'FontSize', 12);  
        title('单一机制拟合 (弯曲刚度主导)', 'FontSize', 14);
        legend('实验数据', 'q^{-4} (弯曲)', 'Location', 'best'); 
        grid on;
        
    elseif flag == 2
        %% 情况2：双机制拟合，斜率-2和-4
        fprintf('Mode 2: 双机制拟合 (表面张力 + 弯曲刚度)\n');
        
        % 小q区域：强制斜率为-2 (表面张力主导)
        small_q_idx = 1:transition_idx;
        fixed_slope1 = -2;
        intercept1 = mean(log_A(small_q_idx) - fixed_slope1 * log_q(small_q_idx));
        
        % 大q区域：强制斜率为-4 (弯曲刚度主导)
        large_q_idx = transition_idx:length(q)-28;
        fixed_slope2 = -4;
        intercept2 = mean(log_A(large_q_idx) - fixed_slope2 * log_q(large_q_idx));
        
        % 提取参数
        sigma = exp(-intercept1);  % σ = kBT * exp(intercept1)
        kappa = exp(-intercept2)  % κ = kBT * exp(intercept2)
        
        % 计算各区域拟合优度
        fitted_log_A1 = intercept1 + fixed_slope1 * log_q(small_q_idx);
        r_squared1 = 1 - sum((log_A(small_q_idx) - fitted_log_A1).^2) / ...
                        sum((log_A(small_q_idx) - mean(log_A(small_q_idx))).^2);
        
        fitted_log_A2 = intercept2 + fixed_slope2 * log_q(large_q_idx);
        r_squared2 = 1 - sum((log_A(large_q_idx) - fitted_log_A2).^2) / ...
                        sum((log_A(large_q_idx) - mean(log_A(large_q_idx))).^2);
        
        fprintf('表面张力 σ = %.4f (kBT/nm?)\n', sigma);
        fprintf('弯曲刚度 κ = %.4f (kBT)\n', kappa);
        fprintf('小q区域拟合优度 R? = %.4f\n', r_squared1);
        fprintf('大q区域拟合优度 R? = %.4f\n', r_squared2);
        fprintf('小q区域实际斜率: %.4f\n', fixed_slope1);
        fprintf('大q区域实际斜率: %.4f\n', fixed_slope2);
        
        % 绘图
        figure;
        loglog(q, A_hq2, 'bo', 'MarkerSize', 6);
        hold on;
        
        % 绘制拟合线
        fitted_A1 = exp(intercept1) .* q(small_q_idx).^fixed_slope1;
        fitted_A2 = exp(intercept2) .* q(large_q_idx).^fixed_slope2;
        
        loglog(q(small_q_idx), fitted_A1, 'r-', 'LineWidth', 2);
        loglog(q(large_q_idx), fitted_A2, 'g-', 'LineWidth', 2);
        
        % 标记分界点
        line([q(transition_idx) q(transition_idx)], ylim, 'Color', 'k', ...
             'LineStyle', '--', 'LineWidth', 1);
        
        xlabel('$q$ (nm$^{-1}$)', 'Interpreter', 'latex', 'FontSize', 12); 
        ylabel('$A \langle |h_q|^2 \rangle$ (nm$^2$)', 'Interpreter', 'latex', 'FontSize', 12);  
        title('双机制拟合 (表面张力 + 弯曲刚度)', 'FontSize', 14);
        legend('实验数据', 'q^{-2} (表面张力)', 'q^{-4} (弯曲)', '分界点', ...
               'Location', 'best'); 
        grid on;
        
    else
        error('flag必须为1或2');
    end
    
    % 添加图形美化
    set(gca, 'FontSize', 11);
    box on;
    
    % 显示最终结果
    fprintf('\n=== 拟合结果总结 ===\n');
    if flag == 1
        fprintf('模式: 单一机制 (弯曲刚度)\n');
        fprintf('κ = %.4f kBT\n', kappa);
    else
        fprintf('模式: 双机制\n');
        fprintf('σ = %.4f kBT/nm?\n', sigma);
        fprintf('κ = %.4f kBT\n', kappa);
        fprintf('转换点索引: %d (q = %.4f nm^-1)\n', transition_idx, q(transition_idx));
    end
end