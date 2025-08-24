function [sigma, kappa] = fit_two_regime(prefix)
    data = load('alastframe_Ahq2_q.txt');
    q = data(:,1);
    A_hq2 = data(:,2);
    log_q = log(q);
    log_A = log(A_hq2);
    
    if nargin >= 1 && ~isempty(prefix)
        output_prefix = prefix;
    else
        output_prefix = getenv('MATLAB_PARAM');
    end
    
    % 从环境变量读取参数
    transition_idx_str = getenv('MATLAB_TRANSITION_IDX');
    end_id_str = getenv('MATLAB_END_ID');
    
    if ~isempty(transition_idx_str) && ~isempty(end_id_str)
        transition_idx = str2double(transition_idx_str);
        end_id = str2double(end_id_str);
        fprintf('读取到参数: transition_idx=%d, end_id=%d\n', transition_idx, end_id);
    else
        % 如果没有环境变量，使用默认值
        transition_idx = 1;
        end_id = 1;
        fprintf('警告: 未找到环境变量，使用默认参数: transition_idx=%d, end_id=%d\n', transition_idx, end_id);
    end
    
    % 显示数据信息
    fprintf('数据长度: %d, q范围: %.6f 到 %.6f\n', length(q), min(q), max(q));
    
    % 参数验证和调整
    if transition_idx < 1
        fprintf('警告: transition_idx < 1,调整为 1\n');
        transition_idx = 1;
    end
    if transition_idx > length(q)
        fprintf('警告: transition_idx > 数据长度，调整为 %d\n', length(q));
        transition_idx = length(q);
    end
    if end_id < 0
        fprintf('警告: end_id < 0,调整为 0\n');
        end_id = 0;
    end
    if end_id >= length(q)
        fprintf('警告: end_id >= 数据长度，调整为 %d\n', length(q) - 1);
        end_id = length(q) - 1;
    end
    
    small_q_idx = 1:transition_idx;
    large_q_idx = transition_idx:(length(q)-end_id);
    
    % 检查拟合区间的有效性
    if length(small_q_idx) < 2
        fprintf('错误: small_q区间点数不足 (需要>=2点，当前%d点)\n', length(small_q_idx));
        sigma = NaN;
        kappa = NaN;
        return;
    end
    
    if length(large_q_idx) < 2
        fprintf('错误: large_q区间点数不足 (需要>=2点,当前%d点)\n', length(large_q_idx));
        fprintf('检查参数: transition_idx=%d, end_id=%d, 数据长度=%d\n', transition_idx, end_id, length(q));
        sigma = NaN;
        kappa = NaN;
        return;
    end
    
    fprintf('small_q区间: %d-%d (%d点), large_q区间: %d-%d (%d点)\n', ...
            1, transition_idx, length(small_q_idx), ...
            transition_idx, length(q)-end_id, length(large_q_idx));
    
    % 执行拟合
    p1 = polyfit(log_q(small_q_idx), log_A(small_q_idx), 1);
    p2 = polyfit(log_q(large_q_idx), log_A(large_q_idx), 1);
    
    kBT_sigma = exp(p1(2));  % kBT/σ
    kBT_kappa = exp(p2(2));  % kBT/κ
    
    kBT = 0.23;
    sigma = kBT / kBT_sigma;
    kappa = kBT / kBT_kappa;
    
    % 绘图
    fig = figure('Visible', 'off');
    loglog(q, A_hq2, 'bo', 'MarkerSize', 4);
    hold on;
    loglog(q(small_q_idx), exp(polyval(p1, log_q(small_q_idx))), 'r-', 'LineWidth', 2);
    loglog(q(large_q_idx), exp(polyval(p2, log_q(large_q_idx))), 'g-', 'LineWidth', 2);
    
    % 标记转折点
    if transition_idx <= length(q)
        loglog(q(transition_idx), A_hq2(transition_idx), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'yellow', 'LineWidth', 2);
    end
    
    xlabel('$q, 'Interpreter', 'latex', 'FontSize', 12);  
    ylabel('$A \langle |h_q|^2 \rangle, 'Interpreter', 'latex', 'FontSize', 12);  
    title(sprintf('Two-regime fitting (t\\_idx=%d, end\\_id=%d)', transition_idx, end_id), 'FontSize', 14);
    legend('Data', sprintf('q^{%.1f} (tension)', p1(1)), sprintf('q^{%.1f} (bending)', p2(1)), 'Transition', 'Interpreter', 'latex', 'FontSize', 10);  
    grid on;
    
    % 保存图片
    plot_filename = [output_prefix '.png'];
    print(fig, plot_filename, '-dpng', '-r300');
    close(fig);
    
    % 输出结果（供bash脚本解析）
    fprintf('拟合斜率: small_q=%.3f, large_q=%.3f\n', p1(1), p2(1));
    fprintf('TENSION=%.6f\n', sigma);
    fprintf('BENDING=%.6f\n', kappa);
    fprintf('PLOT_SAVED=%s\n', plot_filename);
end


行: 96 列: 18
无效表达式。请检查缺失的乘法运算符、缺失或不对称的分隔符或者其他语法错误。要构造矩阵，请使用方括
号而不是圆括号。
 

=== 准备分析参数 2.0 的数据 ===
请为当前数据输入拟合参数：
请输入 transition_idx (过渡点索引): ^C

