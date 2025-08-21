function [sigma, kappa] = fit_two_regime(prefix)
    data = load('alastframe_Ahq2_q.txt');
    q = data(:,1);
    A_hq2 = data(:,2);
    log_q = log(q);
    log_A = log(A_hq2);
    
    if nargin >= 1 && ~isempty(input_filename)
    output_prefix = prefix;
else
    output_prefix = getenv('MATLAB_PARAM');
end
    
    transition_idx =1;  
    small_q_idx = 1:transition_idx;
    p1 = polyfit(log_q(small_q_idx), log_A(small_q_idx), 1);

    large_q_idx = transition_idx:length(q)-260;
    p2 = polyfit(log_q(large_q_idx), log_A(large_q_idx), 1);
    
    kBT_sigma = exp(p1(2));  % kBT/σ
    kBT_kappa = exp(p2(2));  % kBT/κ
    
    kBT = 0.23;
    sigma = kBT / kBT_sigma;
    kappa = kBT / kBT_kappa;
    

    fig = figure('Visible', 'off');
    loglog(q, A_hq2, 'bo');
    hold on;
    loglog(q(small_q_idx), exp(polyval(p1, log_q(small_q_idx))), 'r-', 'LineWidth', 2);
    loglog(q(large_q_idx), exp(polyval(p2, log_q(large_q_idx))), 'g-', 'LineWidth', 2);
    
    xlabel('$q$', 'Interpreter', 'latex', 'FontSize', 12);  
    ylabel('$A \langle |h_q|^2 \rangle$', 'Interpreter', 'latex', 'FontSize', 12);  
    title('Two-regime fitting', 'FontSize', 14);
    legend('Data', 'q^{-2} (tension)', 'q^{-4} (bending)', 'Interpreter', 'latex', 'FontSize', 10);  
    grid on;
    
    % 保存图片
    plot_filename = [output_prefix '.png'];
    print(fig, plot_filename, '-dpng', '-r300');
    close(fig);
    
    fprintf('TENSION=%.6f\n', sigma);
    fprintf('BENDING=%.6f\n', kappa);
    fprintf('PLOT_SAVED=%s\n', plot_filename);


end
