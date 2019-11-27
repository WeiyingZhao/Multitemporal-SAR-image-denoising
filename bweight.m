function bw = bweight(stack, k, W, thrs)
%% Performs a Binary Weight Super Image as detailed in
%
%    RABASAR
%
% Input/Output
%
%    STACK      a M x N x T array
%
%    K          index for the reference image
%
%    W          patch width
%
%    THRS       a M x N array of thresholds for patch comaprison
%               (can be generated with bw_thresholds)
%
%    SI         the super-image
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


ratio = sqrt(stack(:,:,k) ./ stack);
w     = log(ratio + 1 ./ ratio) - log(2);
w     = convn(w, ones(W, W, 1) / W^2, 'same');
bw    = w <= thrs;
%si    = sum(bw .* stack, 3) ./ sum(bw, 3);
