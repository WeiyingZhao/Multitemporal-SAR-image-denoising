clear all
close all

addpath('mulog');
addpathrec('.');
deterministic('on');

%% Setting
Lnum = 2;
Lden = 5;
denoiser = @bm3d;

%% Gaussian noise simulation setting
x = loadimage('data/cameraman.png').^2;
[m, n] = size(x);
y = x .* mean((randn(m, n, Lnum).^2 + randn(m, n, Lnum).^2) / 2, 3);
z = mean((randn(m, n, Lden).^2 + randn(m, n, Lden).^2) / 2, 3);


%% Run RuLoG with embedded BM3D Gaussian denoiser
disp('Run RuLoG with embedded BM3D Gaussian denoiser');
tic;
h = robustwaitbar(0);
xhat = rulog(y ./ z, Lnum, Lden, denoiser, ...
              'waitbar', @(p) robustwaitbar(p, h));
close(h);
disp(sprintf('  Elapsed time %.2f s', toc));

%% Run RuLoG with embedded BM3D Gaussian denoiser
disp('Run MuLoG with embedded BM3D Gaussian denoiser');
tic;
h = robustwaitbar(0);
xhat2 = molog(y ./ z, Lnum, denoiser, ...
              'waitbar', @(p) robustwaitbar(p, h));
close(h);
disp(sprintf('  Elapsed time %.2f s', toc));

%% Display results
f = fancyfigure;
subplot(1, 3, 1);
h = plotimagesar(y ./ z, 'range', [0, 255]);
title(sprintf('Ratio Lnum=%d Lden=%d', Lnum, Lden));
subplot(1, 3, 2);
plotimagesar(xhat, 'rangeof', h);
title(sprintf('RuLoG+BM3D (psnr %.2f)', perfs(xhat, x, Lnum, 'psnr')));
subplot(1, 3, 3);
plotimagesar(xhat2, 'rangeof', h);
title(sprintf('MuLoG+BM3D (psnr %.2f)', perfs(xhat2, x, Lnum, 'psnr')));
linkaxes
