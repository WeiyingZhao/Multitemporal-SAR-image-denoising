function noise = speckle_noise(sz, L)
    % make sure that 'sz' is a 3-length vector
    if length(sz) == 2, sz(3) = 1; end
    % noise generation
    s = randn([sz 2*L]);
    s = mean(s.^2, 4);
noise = (s);