function [dimg, si, Lsi, dsi, Ldsi] = function_RABASAR_AM(stack,k,L)
%% parameters that can be modified
% ENL estimator and corresponding window size
% k is the denoised image
% L is the ENL of original image 

%% (1)RABASAR-AM

addpath('mulog');addpathrec('.');

% Choose ENL estimator
enl_estimate = @(x) enl_logmoment_sliding(x, 30);

% Rabasar callibration (offline)
if nargin<3
    L  = enl_estimate(stack(:,:,1));
end

% Rabasar (online)
%h = robustwaitbar(0);
tic
[dimg, si, Lsi, dsi, Ldsi] = ...
    rabasarOriginal(stack, L, k, ...
            'enl_estimate', enl_estimate);
toc
%close(h);


%% Visualization
% fancyfigure;
% subplot(2,2,1);h = plotimagesar((si), 'alpha', 2/3);        title(sprintf('Arithmetic mean: L=%.2f', Lsi));
% subplot(2,2,2);plotimagesar((dsi), 'rangeof', h);           title(sprintf('Super image: L=%.2f', Ldsi));
% subplot(2,2,3);plotimagesar((stack(:,:,k)), 'rangeof', h);  title(sprintf('Input date: t=%d', k));
% subplot(2,2,4);plotimagesar((dimg), 'rangeof', h);          title('Rabasar result');
% linkaxes;


end