function thrs = bw_thresholds(M, N, L, W, alpha)
%% Compute thresholds for Binary Weight Super Images
%
%    RABASAR
%
% Input/Output
%
%    M, N       image size
%
%    L          number of looks
%
%    W          window size
%
%    ALPHA      quantile
%
%    THRS       estimated M x N array of thresholds
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

Ms = 64;
Ns = 64;
Ts = 256;
stack = mean((randn(Ms, Ns, Ts, L).^2 + randn(Ms, Ns, Ts, L).^2) / 2, 4);

ratio = sqrt(stack(:,:,1) ./ stack);
w     = log(ratio + 1 ./ ratio) - log(2);

k = 1;
for Wx = 1:W
    for Wy = Wx:W
        wn     = convn(w, ones(Wx, Wy, 1) / Wx / Wy, 'valid');
        sigs(k) = quantile(wn(:), alpha);
        areas(k) = Wx * Wy;
        k = k + 1;
    end
end
K = k - 1;

Wmap = convn(ones(M, N), ones(W, W), 'same');
thrs = zeros(M, N);
for k = 1:K
    thrs(Wmap == areas(k)) = sigs(k);
end
