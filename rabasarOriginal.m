function [dimg, si, Lsi, dsi, Ldsi] = rabasarOriginal(stack, L, k, varargin)
%% Implements Rabasar as described in
%
%    Rabasar paper
%
% Input/Output
%
%    STACK      a M x N x T array
%
%    L          the number of looks: parameter of the Gamma
%               distribution linking stack and dimg
%               For SLC images: L = 1
%               For MLC images: L = ENL
%
%    k          the index of the image to filter in the stack
%
% Optional arguments
%
%    THRS       a M x N array of thresholds for patch similarity
%               to build the binary weighted super-image
%               default: inf
%
%    ENL_ESTIMATE handle on a function ENL_ESTIMATE(x) estimating
%               the equivalent number of looks on the image x
%               default: @(x) enl_logmoment_sliding(x, 30)
%
%    DENOISER   handle on a function DENOISER(y, lambda, ...)
%               default: bm3d
%
%    CBWAITBAR  handle on a function CBWAITBAR(percentage) showing
%               a progress bar. Percentage lies in [0, 1].
%               default: @(p) []
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

options      = makeoptions(varargin{:});
thrs         = getoptions(options, 'thrs', inf * ones(size(stack(:,:,1))));
cbwaitbar    = getoptions(options, 'waitbar', @(dummy) []);
enl_estimate = getoptions(options, 'enl_estimate', @(x) enl_logmoment_sliding(x, 30));
denoiser     = getoptions(options, 'denoiser', @bm3d);

si   = bwsi(stack, k, 7, thrs);

Ldsi = enl_estimate(si); %size(stack,3);%
Lsi  = Ldsi; dsi=si;
ra   = stack(:,:,k) ./ si;
dra  = rulog(ra, L, Ldsi, denoiser, ...
             'waitbar', @(p) cbwaitbar(.5 + p/2));
dimg = si .* dra;
