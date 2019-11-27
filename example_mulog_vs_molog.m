clear all
close all

addpath('mulog');
addpathrec('.');
deterministic('on');

%% Setting
L = 2;
denoiser = @bm3d;

%% Gaussian noise simulation setting
x = loadimage('data/cameraman.png').^2;
[m, n] = size(x);
y = x .* mean((randn(m, n, L).^2 + randn(m, n, L).^2) / 2, 3);

%% Run MuLoG with embedded BM3D Gaussian denoiser
disp('Run MuLoG with embedded BM3D Gaussian denoiser');
tic;
h = robustwaitbar(0);
xhat = mulog(y, L, denoiser, ...
            'waitbar', @(p) robustwaitbar(p, h));
close(h);
disp(sprintf('  Elapsed time %.2f s', toc));

%% Run MoLoG with embedded BM3D Gaussian denoiser
disp('Run MoLoG with embedded BM3D Gaussian denoiser');
tic;
h = robustwaitbar(0);
xhat2 = molog(y, L, denoiser, ...
              'waitbar', @(p) robustwaitbar(p, h));
close(h);
disp(sprintf('  Elapsed time %.2f s', toc));

%% Display results
f = fancyfigure;
subplot(1, 3, 1);
h = plotimagesar(y, 'range', [0 255]);
title(sprintf('Noisy image (psnr %.2f)', perfs(y, x, L, 'psnr')));
subplot(1, 3, 2);
plotimagesar(xhat, 'rangeof', h);
title(sprintf('MuLoG+BM3D (psnr %.2f)', perfs(xhat, x, L, 'psnr')));
subplot(1, 3, 3);
plotimagesar(xhat2, 'rangeof', h);
title(sprintf('MoLoG-BM3D (psnr %.2f)', perfs(xhat2, x, L, 'psnr')));
linkaxes
