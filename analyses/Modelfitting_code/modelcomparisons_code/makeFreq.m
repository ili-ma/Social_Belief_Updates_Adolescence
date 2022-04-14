function total_counts = makeFreq(policy)
    T = size(policy,3) + 1;
    total_counts = zeros(T, T);
    probs = [0 0.2 0.4 0.6 0.8 1];
    % n will keep track of how many parameter configurations there are
    n = 0;
    for subject = 1:size(policy, 1)
		for p_green = probs
			counts = zeros(T, T);
			counts(1, 1) = 1;
			for t = 1:T-1
				current_p_sample = squeeze(policy(subject, 1:t, t));
				current_counts = counts(1:t, t);
				next_counts = current_counts .* current_p_sample';
				
				next_green = [0; next_counts * p_green];
				next_red = [next_counts * (1 - p_green); 0];
				counts(1:t + 1, t + 1) = next_red + next_green;
			end
			total_counts = total_counts + counts;
			n = n + 1;
        end
    end
    total_counts = total_counts / n;
    % Put NaN's in the unreachable states
    for t = 1:(T - 1)
        total_counts((t + 1):end, t) = NaN;
    end
end
