function bw2 = bwcustfilt(bw, p, lambda)
%filter by Solidity + lambda * Area

conn = ones(3,3);
direction = 'largest';

CC = bwconncomp(bw,conn);
props = regionprops(CC, 'Solidity');

if isempty(props)
    bw2 = bw;
    return;
end

props2 = regionprops(CC,'Area');
area = vertcat(props2.Area)';
val = area/max(area);

allValues = [props.('Solidity')] + lambda*val;

 switch numel(p)
    case 1
        % Find the top "p" regions.
        p = min(p, numel(props));
        
        switch direction
            case {'smallest'}
                [~, idx] = sort(allValues, 'ascend');
            otherwise
                [~, idx] = sort(allValues, 'descend');
        end
        
        % Take care of ties.
        minSelected = allValues(idx(p));
        switch direction
            case {'smallest'}
                regionsToKeep = allValues <= minSelected;
            otherwise
                regionsToKeep = allValues >= minSelected;
        end
        
        if (numel(find(regionsToKeep)) > p)
            warning(message('images:bwfilt:tie'))
        end
        
        % Keep the first p regions. (linear indices)
        regionsToKeep = idx(1:p);
        
    case 2
        % Find regions within the range. (logical indices)
        regionsToKeep = (allValues >= p(1)) & (allValues <= p(2));
end

pixelsToKeep = CC.PixelIdxList(regionsToKeep);
pixelsToKeep = vertcat(pixelsToKeep{:});

bw2 = false(size(bw));
bw2(pixelsToKeep) = true;