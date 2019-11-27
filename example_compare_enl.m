clear all
close all

addpath('mulog');
addpathrec('.');

% Load/generate data
mode = 'cameraman';
switch 'saclay'
    case 'saclay'
        T = 69;
        if exist('saclay.mat', 'file')
            load('saclay.mat');
        else
            stack = zeros(1024, 1536, T);
            for k = 1:T
                stack(:,:,k) = ...
                    sarread(sprintf('/home/cdeledal/Data/multitemp_saclay/Pilesaclaycoord_1536x1024RECALZ4_%d.rat', k));
            end
            stack = abs(stack(1:2:end, 1:2:end, :)).^2;
            stack(stack <= 0) = min(stack(stack > 0));
        end
        view = @(x) x(floor(2*end/3):end, floor(2*end/3):end);
    case 'cameraman'
        im0 = double(imread('cameraman.png'));
        [M, N] = size(im0);
        T = 69;
        L = 100;
        stack = im0.^2 .* mean((randn(M, N, T, L).^2 + randn(M, N, T, L).^2) / 2, 4);

        view = @(x) x;
    case 'constant'
        im0 = ones(256, 256);
        [M, N] = size(im0);
        T = 69;
        L = 100;
        stack = im0.^2 .* mean((randn(M, N, T, L).^2 + randn(M, N, T, L).^2) / 2, 4);

        view = @(x) x;
end
[M, N, T] = size(stack);

% Single image
enl_estimate = @(x) enl_logmoment_sliding(x, 30);
L    = enl_estimate(stack(:,:,11))

enl_estimate = @(x) enl_stdmad(x);
L    = enl_estimate(stack(:,:,11))

% Mean image
enl_estimate = @(x) enl_logmoment_sliding(x, 30);
L    = enl_estimate(mean(stack, 3))

enl_estimate = @(x) enl_stdmad(x);
L    = enl_estimate(mean(stack, 3))

% Weighted mean image
thrs = bw_thresholds(M, N, 1, 7, .92);
si   = bwsi(stack, 1, 7, thrs);

enl_estimate = @(x) enl_logmoment_sliding(x, 30);
L    = enl_estimate(si)

enl_estimate = @(x) enl_stdmad(x);
L    = enl_estimate(si)
