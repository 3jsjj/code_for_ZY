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
        transition_idx = 1;
        end_id = 1;
        fprintf('警告: 未找到环境变量，使用默认参数: transition_idx=%d, end_id=%d\n', transition_idx, end_id);
    end
    
    small_q_idx = 1:transition_idx;
    large_q_idx = transition_idx:(length(q)-end_id);
    
    % 执行拟合找斜率p1(1),截距p1(2)
    p1 = polyfit(log_q(small_q_idx), log_A(small_q_idx), 1);
    p2 = polyfit(log_q(large_q_idx), log_A(large_q_idx), 1);
    
    fprintf('TENSION:%.6f\n', p1(1));
    fprintf('BENDING:%.6f\n', p2(1));

    sigma = exp(-p1(2));  % σ/kBT
    kappa = exp(-p2(2));  % κ/kBT
    
    
    % 绘图
    fig = figure('Visible', 'off');
    loglog(q, A_hq2, 'bo', 'MarkerSize', 4);
    hold on;
    loglog(q(small_q_idx), exp(polyval(p1, log_q(small_q_idx))), 'r-', 'LineWidth', 2);
    loglog(q(large_q_idx), exp(polyval(p2, log_q(large_q_idx))), 'g-', 'LineWidth', 2);
    
    plot_filename = [output_prefix '.png'];
    print(fig, plot_filename, '-dpng', '-r300');
    close(fig);
    
    % 输出结果（供bash脚本解析）
    fprintf('TENSION=%.6f\n', sigma);
    fprintf('BENDING=%.6f\n', kappa);
    fprintf('PLOT_SAVED=%s\n', plot_filename);
end

