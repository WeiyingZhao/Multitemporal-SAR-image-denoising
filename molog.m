function [R x y] = molog(I, L, denoiser, varargin)
%% Implements MoLoG (Monochannel Logarithm with Gaussian denoiser
%
%    Monochannel version of MuLoG as described in
%
%    Deledalle, C.A., Denis, L., Tabti, S. and Tupin, F., 2017.
%    MuLoG, or How to apply Gaussian denoisers to multi-channel SAR
%    speckle reduction?
%
% Input/Output
%
%    I          a M x N array, OR
%               a M x N field of 1 x 1 covariance matrices
%               size 1 x 1 x M x N
%
%    Sigma      estimated array, OR field of 1 x 1 covariance matrices
%
%    x          estimated log-channels for output Sigma
%
%    y          extracted log-channels for input C
%
%    L          the number of looks: parameter of the Wishart
%               distribution linking C and Sigma
%               For SLC images: L = 1
%               For MLC images: L = ENL
%
%    DENOISER   handle on a function x = DENOISER(y, sig, ...)
%               removing noise for an image y damaged by Gaussian
%               noise with varaince sig^2
%
%               extra arguments of MULOG are passed to DENOISER
%
% Optional arguments
%
%    BETA       inner parameter of ADMM
%               default: 1 + 2 / L
%
%    LAMBDA     regularization parameter
%               default: 1
%
%    T          the number of iterations of ADMM
%               default: 6
%
%    K          the number of iterations for the Newton descent
%               default: 10
%
%
% License
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. You can use,
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info".
%
% As a counterpart to the access to the source code and rights to copy,
% modify and redistribute granted by the license, users are provided only
% with a limited warranty and the software's author, the holder of the
% economic rights, and the successive licensors have only limited
% liability.
%
% In this respect, the user's attention is drawn to the risks associated
% with loading, using, modifying and/or developing or reproducing the
% software by the user in light of its specific status of free software,
% that may mean that it is complicated to manipulate, and that also
% therefore means that it is reserved for developers and experienced
% professionals having in-depth computer knowledge. Users are therefore
% encouraged to load and test the software's suitability as regards their
% requirements in conditions enabling the security of their systems and/or
% data to be ensured and, more generally, to use and operate it in the
% same conditions as regards security.
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.
%
% Copyright 2017 Charles Deledalle
% Email charles-alban.deledalle@math.u-bordeaux.fr



options     = makeoptions(varargin{:});

%% Input data format conversion
reshaped = false;
if ndims(I) == 4
    reshaped = true;
    [D, D, M, N] = size(I);
    if D ~= 1
        error('Molog is for Monochannel images only');
    end
    I = squeeze(I);
elseif ndims(I) ~= 2
    error(['I must be a M x N array']);
end
I = double(I);

%% Remove negative and zero entries (safeguard)
I(abs(I) <= 0) = min(abs(I(abs(I) > 0)));

%% Initialization is debiased in intensity
%   - only the initialization (helps to converge faster)
%   - the original I will be given for the data fidelity term
I_init = I * L / exp(psi(L));

%% Log-channel decomposition:
y  = log(I_init);
sigma = estimate_sigma(y, 1, L);
y  = y ./ sigma;


%% Define fidelity term
proxllk = @(x, I, lambda, varargin) ...
          proxfishtipp(x, I, lambda, L, sigma, y, varargin{:});

%% Run Plug-and-play ADMM
x = admm(I, ...
         denoiser, ...
         'beta', 1 + 2/L, ...
         'sig', 1, ...
         'init', y, ...
         'proxllk', proxllk, ...
         varargin{:});

%% Return to the initial representation:
R = exp(x * sigma);

%% Output data format conversion
if reshaped
    R = reshape(R, [1, 1, M, N]);
end

end

%%% Prox of the Wishart Fisher-Tippet log likelihood

% Split the input onto the different cores
function z = proxfishtipp(x, I, lambda, L, sigma, y, varargin)

options   = makeoptions(varargin{:});
cbwaitbar = getoptions(options, 'waitbar', @(dummy) []);
K         = getoptions(options, 'K', 10);

[M, N, P] = size(x);
NC = feature('Numcores');
q = ceil(M / NC);
parfor c = 1:NC
    idx = floor((c-1)*q)+1:min(floor(c*q), M);
    zs{c} = subproxfishtipp(x(idx, :), I(idx, :), ...
                            lambda, L, sigma, ...
                            y(idx, :), K, ...
                            @(p) cbwaitbar((NC - c + p) / NC));
    cbwaitbar((NC-c+1) / NC);
end
z = zeros(M, N, P);
for c = 1:NC
    idx = floor((c-1)*q)+1:min(floor(c*q), M);
    z(idx, :, :) = zs{c};
end

end

% Main function
function z = subproxfishtipp(x, I, lambda, L, sigma, y, K, cbwaitbar)

z = (x + y ./ lambda) ./ (1 + 1 ./ lambda);
for k = 1:K
    ediff = I .* exp(-sigma * z);
    z = z - ...
        (z - x + sigma * lambda * L * (1 - ediff)) ./ ...
        abs(1 + sigma * lambda * L * ediff);

    cbwaitbar(k / K);
end

end

%%% Predict the noise standard deviation on each channel
function sigma = estimate_sigma(x, D, L)

var = psi(1, L);
sigma = sqrt(var);

end
