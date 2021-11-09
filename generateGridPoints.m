function M_grid = generateGridPoints(gridArrangement, stepSize, method)
    % Build the grid of control points
    %
    % Input:
    %       - gridArrangement: rows, columns
    %       - stepSize: side of the square in mm
    %       - method: {April, Checker, Rig}
    % Output:
    %       - M_grid: grid points in 3D object-space (mm)
    
    n_cols = gridArrangement(2);  % # of columns
    n_rows = gridArrangement(1);  % # of rows
    
    switch method
        case 'April'
            [Y,X] = meshgrid( stepSize:2*stepSize:stepSize*n_cols, stepSize:2*stepSize:stepSize*n_rows);
            M_grid = [X(:)';Y(:)';zeros(1,length(X(:)))];
            % massage M_grid to meet the order of april tag detection
            Mcell = mat2cell(kron(M_grid, ones(1,4)),3,4*ones(1,n_cols*n_rows/4));
            % apply displacement to ghet the 4 corners
            Q = [ -stepSize/2     -stepSize/2    stepSize/2     stepSize/2
                -stepSize/2      stepSize/2    stepSize/2    -stepSize/2;
                0                  0              0           0  ];
            M_grid = cell2mat(cellfun(@(X) X+Q, Mcell, 'UniformOutput', false));
            
        case 'Checker'
            [Y,X] = meshgrid( stepSize:stepSize:stepSize*n_cols, stepSize:stepSize:stepSize*n_rows);
            M_grid = [X(:)';Y(:)';zeros(1,length(X(:)))];
            
        case 'Rig'
            [Y,X] = meshgrid( stepSize:stepSize:stepSize*n_cols, stepSize:stepSize:stepSize*n_rows);
            face1 = [X(:)';Y(:)'; zeros(1,size(X(:),1))];
            face2 = [zeros(1,size(X(:),1)); X(:)';Y(:)' ];
            M_grid = [face1, face2];
            
        otherwise
            error('unrecognised option\n');
            
    end
    
    %     figure(2)
    %     plot3(M_grid(1,:),M_grid(2,:),M_grid(3,:),'+k'), hold on
    %     a = [1:size(M_grid(3,:),2)]'; b = num2str(a); c = cellstr(b);
    %     dx = 0.1; dy = 0.1; dz = 0;
    %     % text(M_grid(1,:)+dx,M_grid(2,:)+dy,M_grid(3,:)+dz, c);
    %     xlabel('X'),  ylabel('Y') , zlabel('Z')
    %     view(90,90)
    %
    
end

