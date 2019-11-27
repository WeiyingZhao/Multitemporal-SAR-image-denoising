clear all
close all

if ~exist('mulog', 'file')
    system('git clone https://bitbucket.org/charles_deledalle/mulog.git');
end
addpath('mulog');
addpathrec('.');

% Load/generate data
mode = 'simu';
switch mode
    case 'real'
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
    case 'simu'
        im0 = double(imread('cameraman.png'));
        [M, N] = size(im0);
        T = 69;
        L = 1;
        stack = im0.^2 .* mean((randn(M, N, T, L).^2 + randn(M, N, T, L).^2) / 2, 4);

        view = @(x) x;
end
[M, N, T] = size(stack);

% Choose ENL estimator
enl_estimate = @(x) enl_logmoment_sliding(x, 30);

% Rabasar callibration (offline)
L    = enl_estimate(stack(:,:,1));
thrs = bw_thresholds(M, N, round(L), 7, .92);

% Rabasar (online)
k = 11;
h = robustwaitbar(0);
tic
[dimg, si, Lsi, dsi, Ldsi] = ...
    rabasar(stack, L, k, ...
            'thrs', thrs, ...
            'enl_estimate', enl_estimate, ...
            'waitbar', @(p) robustwaitbar(p, h));
toc
close(h);

% Visualization
fancyfigure;
subplot(2,2,1);
h = plotimagesar(view(si), 'alpha', 2/3);
title(sprintf('Arithmetic mean: L=%.2f', Lsi));
subplot(2,2,2);
plotimagesar(view(dsi), 'rangeof', h);
title(sprintf('Super image: L=%.2f', Ldsi));
subplot(2,2,3);
plotimagesar(view(stack(:,:,k)), 'rangeof', h);
title(sprintf('Input date: t=%d', k));
subplot(2,2,4);
plotimagesar(view(dimg), 'rangeof', h);
title('Rabasar result');
linkaxes;

return

savesubfig(gcf, 'results/bw_stdmad/');