function isIorF = isIVPorFVP(guifile, allVarNames)
%ISIVPORFVP    Detect whether a GUI ODE is an IVP or FVP
%
% ISIORF = ISIVPORFVP(GUIFILE, BCINPUT, ALLVARNAMES), where
%   GUIFILE:     A CHEBGUI object
%   ALLVARNAMES: A cell-string with the names of all variables that appear in
%                the problem.
% returns
%   0: If the problem is detected to be a boundary-value problem.
%   1: If the problem is detected to be an initial-value problem.
%   2: If the problem is detected to be an a final value problem.

% The domain of the problem
dom = guifile.domain;

% The BC input
bcInput = guifile.BC;
% Ensure that the BC input is a cell-string:
if (~iscell(bcInput))
    bcInput = {bcInput};
end

% Find out what the variables that appear in the problem are if they didn't get
% passed:
if ( nargin < 2 ) 
    allVarNames = getVarNames(guifile);
end


% Find what the left end right endpoint of the interval is. We look to the left
% of the first whitespace, and to the right of the last whitespace.
spaceLoc = strfind(dom, ' ');
firstSpace = min(spaceLoc);
lastSpace = max(spaceLoc);

% LEFTDOMSTR and RIGHTDOMSTR are strings that contain information about the
% endpoint of the domain. E.g., if dom = '[0 10]', we'll have LEFTDOMSTR = '0'
% and RIGHTDOMSTR = '10'.
leftDomStr = dom(2:firstSpace-1);
rightDomStr = dom(lastSpace+1:end-1);

% NUMSTR is a regular expression for representing general numbers.
numStr = '[+-]?[0-9]*\.?[0-9]*(e[0-9]+)*';

% Initialize cells for storing evaluation information.
% For storing information about left boundary conditions.
leftConditionLocs = cell(size(bcInput));
% For storing information about right boundary conditions.
rightConditionLocs = leftConditionLocs;
% For any parts of the strings where condition of the form u(0) are imposed.
pointEvalConditionLocs = leftConditionLocs;
% For storing information about where variables appear at places other than
% where point evaluation takes place. This happens e.g. in conditions such as
% 'sum(u) = 1':
globalConditionLocs = leftConditionLocs;

% Anonymous function for combinging information about where conditions are
% evaluated for different variable names.
unionFun = @(c1, c2) cellfun(@union, c1, c2, 'uniformOutput', false);

% Find parts of the boundary conditions input where condition are imposed on the
% left or right ends of the interval. In case of systems, ALLVARNAMES will be a
% cell-array that contains the variable names that appear in the problem. So
% need to loop through the ALLVARNAMES cell.
for varCounter = 1:size(allVarNames,1)
    % The current dependent variable name we're looking at.
    varName = allVarNames{varCounter};
    tempLeft = regexp(bcInput,[varName, '''*\(', leftDomStr, '\)']);
    tempRight = regexp(bcInput,[varName, '''*\(', rightDomStr, '\)']);
    tempPoint = regexp(bcInput,[varName, '''*\(', numStr, '\)']);
    tempGlobal =  regexp(bcInput, [varName, '[^''*\(', numStr, '\)]']);
    
    % Combine with previously obtained information.
    leftConditionLocs = unionFun(leftConditionLocs, tempLeft);
    rightConditionLocs = unionFun(rightConditionLocs, tempRight);
    pointEvalConditionLocs = unionFun(pointEvalConditionLocs, tempPoint);
    globalConditionLocs = unionFun(globalConditionLocs, tempGlobal);
end

% Below, we like to work with cells which arise in the case where more than one
% condition is imposed. So ensure LEFTCONDITIONLOCS, RIGHTCONDITIONLOCS and
% POINTEVALCONDITIONLOCS are all cells:
leftConditionLocs = vec2cell(leftConditionLocs);
rightConditionLocs = vec2cell(rightConditionLocs);
pointEvalConditionLocs = vec2cell(pointEvalConditionLocs);
globalConditionLocs = vec2cell(globalConditionLocs);

% Find locations in the inputs where either left or right conditions are
% imposed:
leftRigthConditionLocs = ...
    cellfun(@union, leftConditionLocs, rightConditionLocs, ...
    'uniformOutput', false);
interiorConditionLocs = ...
    cellfun(@setdiff, pointEvalConditionLocs, leftRigthConditionLocs, ...
    'uniformOutput', false);
leftConditionsImposed = any(cellfun(@any, leftConditionLocs));
rightConditionsImposed = any(cellfun(@any, rightConditionLocs));
interiorConditionsImposed = ~all(cellfun(@isempty,interiorConditionLocs));
globalConditionsImposed = ~all(cellfun(@isempty, globalConditionLocs));

% If any conditions are imposed at points other than the endpoints, we certainly
% don't have an IVP/FVP. Also, if both left and right endpoint conditions are
% imposed, we're dealing with a BVP, not an IVP/FVP.
if ( interiorConditionsImposed || globalConditionsImposed || ...
        (leftConditionsImposed && rightConditionsImposed) )
    isIorF = 0;
elseif ( leftConditionsImposed )
    % We only have left condition(s) imposed, so we're working with an IVP:
    isIorF = 1;
else
    % We only have right condition(s) imposed, so we're working with an FVP:
    isIorF = 2;
end
%%
end

function out = vec2cell(vec)
% Convert potential vectors to cells.
if ( ~iscell(vec) )
    out = {vec};
else
    out = vec;
end
end