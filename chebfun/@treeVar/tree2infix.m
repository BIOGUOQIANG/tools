function [out, varCounter, varArray] = tree2infix(tree, eqno, indexStart)
varCounter = 1;
varArray = [];

if isempty(tree)
    out = '';
    return
end

[out, varCounter, varArray] = ...
    toInfix(tree, eqno, indexStart, varCounter, varArray);

end

function [out, varCounter, varArray] = toInfix(tree, eqno, indexStart, varCounter, varArray)

% Check whether we're converting a syntax tree to infix form, or whether we're
% working directly with a scalar or a CHEBFUN
if ( isstruct(tree) )
    numArgs = tree.numArgs;
else
    numArgs = -1;
end

switch numArgs
    case -1
        disp('Chebfun/scalar')
        [out, varArray, varCounter] = ...
                scalarChebfunInfix(eqno, varCounter, tree, varArray);
    case 0
        out = sprintf('u(%i)', indexStart(tree.ID));
    case 1
        [tempOut, varCounter, varArray] = ...
            toInfix(tree.center, eqno, indexStart, varCounter, varArray);
        out = sprintf('%s(%s)', tree.method, tempOut);
    case 2
        if ( strcmp(tree.method, 'diff') )
            out = sprintf('u(%i)', tree.right + indexStart(tree.ID));
            return
        end
        
        if ( isstruct(tree.left) )
            [leftInfix, varCounter, varArray] = ...
                toInfix(tree.left, eqno, indexStart, varCounter, varArray);
        else
            [leftInfix, varArray, varCounter] = ...
                scalarChebfunInfix(eqno, varCounter, tree.left, varArray);
        end
        
        if ( isstruct(tree.right) )
            [rightInfix, varCounter, varArray] = ...
                toInfix(tree.right, eqno, indexStart, varCounter, varArray);
        else
            [rightInfix, varArray, varCounter] = ...
                scalarChebfunInfix(eqno, varCounter, tree.right, varArray);
        end
        
        out = sprintf('%s(%s, %s)', tree.method, ...
            leftInfix, rightInfix);
end

end

function [infixOut, varArray, varCounter] = scalarChebfunInfix(eqno, varCounter, tree, varArray)
% Convert a scalar/CHEBFUN expression (i.e. a syntax tree that only contains a
% scalar/CHEBFUN) to infix form:
varName = sprintf('eq%i_var%i', eqno, varCounter);
if ( isnumeric(tree) )
    % The left tree is a scalar.
    infixOut = varName;
else
    % The left tree must be a chebfun -- need to be able to evaluate
    % it on gridpoints
    infixOut = [varName, '(t)'];
end
varArray = [varArray; {varName, tree}];
varCounter = varCounter + 1;
end
