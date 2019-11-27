function  ENL = enl_stdmad_sliding(x, W)
%% Estimate ENL based on logmoment statistics on sliding windows
%
%    RABASAR
%
% Input/Output
%
%    IM         an M x N array
%
%    W          window width
%
%    ENL        ENL estimation
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


x = log(x);
y = x(1:2:(end-1), 1:2:(end-1)) - x(2:2:end, 2:2:end);
y = y / sqrt(2);
s = 1.4826 * medfilt2(abs(y - medfilt2(y, [W W], 'symmetric')), [W W], 'symmetric');
k2 = s.^2 / 4;
ENLmap = ...
    (1.+3.5232*k2+1.57472*k2.^2+4.8288*10^(-2)*k2.^3) ./ ...
    (-1.705*10^(-5)+4.004*k2+5.9856*k2.^2+8.6208*10^(-1)*k2.^3);
ENLmap = ENLmap(1:W:end, 1:W:end);
ENL = quantile(ENLmap(:), .99);
