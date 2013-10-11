function out = ggrnd(n,p,g, varargin)
% GG - random numbers from generalized Gaussian distribution (requires
% Statistics toolbox)
%   R = GGRND(N,P,G) returns a vector of N random numbers having a
%   generalized gaussian distribution with shape parameter P, and scale
%   parameter G, i.e. p(x) \propto exp(-G*|x|^P).
%
%   If P=2 it GGRND returns normally distributed random numbers
%
%   Reference: Johnson, M. E., Computer generation of the exponential power
%   distributions", Journal of Statistical Computation and Simulation, 9,
%   pp. 239--240, 1979
%
%   See also: RANDN, GAMRND

%   Author: G. Gomez-Herrero, german.gomezherrero@ieee.org
%   $Revision: 1.0 $Date: 21/06/2007

import misc.process_arguments;

% User has provided a random number generator state
keySet = {'streamstate'};
streamstate = [];
eval(process_arguments(keySet, varargin));

if ~isempty(streamstate),
    defStream = RandStream.getDefaultStream;
    defStream.State = streamstate;
end

if nargin < 3 || isempty(g), g=1; end
if nargin < 2 || isempty(p), p=2; end

if abs(p-2)<1e-3,
    x = randn(1,n);
else
    y = gamrnd(1/p,1,1,n);
    x = abs(g.*y).^(1/p);
    pos = find(rand(1,n)<0.5);
    x(pos) = -x(pos);
end
% normalize variance and return
out = x'./sqrt(var(x));




end
