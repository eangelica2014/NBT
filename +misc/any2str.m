function str = any2str(val, maxLength)
% any2str - Convert MATLAB variable to string
%
% ````matlab
% str = any2str(val, maxLength)
% ````
%
% Where
%
% `val` is a MATLAB variable of any built-in class.
%
% `maxLength` is a natural scalar, the maximum length of the generated
% string.
%
% `str` is the generated string (of maximum length equal to `maxLength`
%
% See also: misc
 


import misc.cell2str;
import misc.matrix2str;

if nargin < 2 || isempty(maxLength), maxLength = 200; end

if isnumeric(val),
    
    str = matrix2str(val, false);
    
    if numel(str) > maxLength,
        
        str = [str(1:maxLength-4) ' ...'];
        
    end

elseif isa(val, 'function_handle') && numel(char(val)) < maxLength,
    
    str = char(val);
    
elseif iscell(val),
    
    str = cell2str(val);
    
    if numel(str) > maxLength,
        
        str = [str(1:maxLength-4) ' ...'];
        
    end
    
elseif islogical(val) && numel(val) == 1,
    
    if val,
        str = 'true';
    else
        str = 'false';
    end
    
elseif ischar(val) && numel(val) < maxLength,
    
    str = val;
    
else
    
    str = num2str(size(val));
    str = ['[' regexprep(str, '\s+', 'x') ' ' class(val) ']'];
    
end


end