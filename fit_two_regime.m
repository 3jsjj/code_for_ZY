function [sigma, kappa] = fit_two_regime()
    data = load('alastframe_Ahq2_q.txt');
    q = data(:,1);
    A_hq2 = data(:,2);
    log_q = log(q);
    log_A = log(A_hq2);
    
    transition_idx =1;  
    small_q_idx = 1:transition_idx;
    p1 = polyfit(log_q(small_q_idx), log_A(small_q_idx), 1);

    large_q_idx = transition_idx:length(q)-260;
    p2 = polyfit(log_q(large_q_idx), log_A(large_q_idx), 1);
    
    kBT_sigma = exp(p1(2));  % kBT/考
    kBT_kappa = exp(p2(2));  % kBT/百
    
    kBT = .23;
    sigma = kBT / kBT_sigma;
    kappa = kBT / kBT_kappa;
    

    figure;
    loglog(q, A_hq2, 'bo');
    hold on;
    loglog(q(small_q_idx), exp(polyval(p1, log_q(small_q_idx))), 'r-');
    loglog(q(large_q_idx), exp(polyval(p2, log_q(large_q_idx))), 'g-');
    
    xlabel('$q$', 'Interpreter', 'latex');  
    ylabel('$A \langle |h_q|^2 \rangle$', 'Interpreter', 'latex');  
    title('Two-regime fitting');
    legend('Data', 'q^{-2} (tension)', 'q^{-4} (bending)', 'Interpreter', 'latex');  
    grid on;
    
    fprintf('Surface tension 考 = %.4f\n', sigma);
    fprintf('Bending rigidity 百 = %.4f\n', kappa);
end
