% eeg_eegrej() - reject porition of continuous data in an EEGLAB 
%                dataset
%
% Usage:
%   >> EEGOUT = eeg_eegrej( EEGIN, regions );
%
% Inputs:
%   INEEG      - input dataset
%   regions    - array of regions to suppress. number x [beg end]  of 
%                regions. 'beg' and 'end' are expressed in term of points
%                in the input dataset. Size of the array is
%                number x 2 of regions.
%
% Outputs:
%   INEEG      - output dataset with updated data, events latencies and 
%                additional boundary events.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 8 August 2002
%
% See also: eeglab(), eegplot(), pop_rejepoch()

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG, com] = eeg_eegrej( EEG, regions);

com = '';
if nargin < 2
	help eeg_eegrej;
	return;
end;
if nargin<3
    probadded = [];
end
if isempty(regions)
	return;
end;

% regions = sortrows(regions,3); % Arno and Ramon on 5/13/2014 for bug 1605

% Ramon on 5/29/2014 for bug 1619
if size(regions,2) > 2
    regions = sortrows(regions,3);
else
    regions = sortrows(regions,1);
end;

try
    % For AMICA probabilities...Temporarily add model probabilities as channels
    %-----------------------------------------------------
    if isfield(EEG.etc, 'amica') && ~isempty(EEG.etc.amica) && isfield(EEG.etc.amica, 'v_smooth') && ~isempty(EEG.etc.amica.v_smooth) && ~isfield(EEG.etc.amica,'prob_added')
        if isfield(EEG.etc.amica, 'num_models') && ~isempty(EEG.etc.amica.num_models)
            if size(EEG.data,2) == size(EEG.etc.amica.v_smooth,2) && size(EEG.data,3) == size(EEG.etc.amica.v_smooth,3) && size(EEG.etc.amica.v_smooth,1) == EEG.etc.amica.num_models

                EEG = eeg_formatamica(EEG);
                %-------------------------------------------

                [EEG com] = eeg_eegrej(EEG,regions);

                %-------------------------------------------

                EEG = eeg_reformatamica(EEG);
                EEG = eeg_checkamica(EEG);
                return;
            else
                disp('AMICA probabilities not compatible with size of data, probabilities cannot be epoched')
                disp('Load AMICA components before extracting epochs')
                disp('Resuming rejection...')
            end
        end

    end
    % ------------------------------------------------------
catch
    warnmsg = strcat('your dataset contains amica information, but the amica plugin is not installed.  Continuing and ignoring amica information.');
    warning(warnmsg)
end


if isfield(EEG.event, 'latency'),
   	 tmpevent = EEG.event;
     tmpalllatencies = [ tmpevent.latency ];
else tmpalllatencies = []; 
end;

% handle regions from eegplot
% ---------------------------
if size(regions,2) > 2, regions = regions(:, 3:4); end;
regions = combineregions(regions);

[EEG.data EEG.xmax tmpalllatencies boundevents] = eegrej( EEG.data, ...
												  regions, EEG.xmax-EEG.xmin, tmpalllatencies);
oldEEGpnts = EEG.pnts;
EEG.pnts   = size(EEG.data,2);
EEG.xmax   = EEG.xmax+EEG.xmin;

% add boundary events
% -------------------
if ~isempty(boundevents) % boundevent latencies will be recomputed in the function below
    [ EEG.event ] = eeg_insertbound(EEG.event, oldEEGpnts, regions);
    EEG = eeg_checkset(EEG, 'eventconsistency');
end;

com = sprintf('%s = eeg_eegrej( %s, %s);', inputname(1), inputname(1), vararg2str({ regions })); 
end

% combine regions if necessary
% it should not be necessary but a 
% bug in eegplot makes that it sometimes is
% ----------------------------
function newregions = combineregions(regions)
newregions = combine(combine(regions));
    function newregions=combine(regions)
        [regions(:,1),ii]=sort(regions(:,1));
        regions(:,2) = regions(ii,2);
        newindex = 0;
        regions = [regions(1,:); regions];
        index = size(regions,1);
        while index >= 2
            if regions(index-1,2) >= regions(index,1)
                indexEnd = index;
                while regions(index-1,2) >= regions(index,1) && index > 2 %find nested regions
                    index = index - 1;
                end
                index =  index - 1;
                
                disp('Warning: overlapping regions detected and fixed in eeg_eegrej');
                newindex = newindex + 1;
                RegionEnd = max(regions(index+1:indexEnd,2));
                newregions(newindex,:) = [regions(index+1,1) RegionEnd(1)];
            else
                newindex = newindex + 1;
                newregions(newindex,:) = regions(index,:);
                index = index - 1;
            end
        end
        
        [newregions(:,1),ii]=sort(newregions(:,1));
        newregions(:,2) = newregions(ii,2);
    end
end


