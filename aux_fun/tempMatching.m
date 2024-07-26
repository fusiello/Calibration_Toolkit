function cumCorrScore = tempMatching(frameImg, templateImg, rots)
    % -------------------------------------------------------------------------
    % Function corrMatching: Template Matching using Correlation Coefficients
    % Inputs:
    %           frameImg = gray or color frame image
    %           templateImg = gray or color template image
    %           
    % Output:
    %           corrScore = 2D matrix of correlation coefficients
    %
    % -------------------------------------------------------------------------
    % By Yue Wu (Rex)
    % Department of Electrical and Computer Engineering
    % Tufts University
    % Medford, MA
    % 08/30/2010
    % -------------------------------------------------------------------------
    % Mofified by A. Fusiello, 2019
    % rots contains additional rotations to be applied. eg. [] , [1 2 3] or [2]
   

    %% 1. initialization
    if size(frameImg,3) ~=1
        grayFrame = rgb2gray(frameImg);
    else
        grayFrame = frameImg;
    end
    grayFrame = double(grayFrame);
    
    if size(templateImg,3) ~=1
        grayTemplate = rgb2gray(templateImg);
    else
        grayTemplate = templateImg;
    end
    grayTemplate = double(grayTemplate);
    avgTemplate = mean(grayTemplate(:));
    stdTemplate = std(grayTemplate(:));

    %flipped by 180 becuase it is a covolution
    grayTemplate = rot90(grayTemplate-avgTemplate,2);


    %% 2. correlation calculation
    avgFrame = conv2(grayFrame,ones(size(grayTemplate))./numel(grayTemplate),'same');
    stdFrame = sqrt(conv2(grayFrame.^2,ones(size(grayTemplate))./numel(grayTemplate),'same')-avgFrame.^2);
    corrPartII = avgFrame.*sum(grayTemplate(:));
   
    corrPartI = conv2(grayFrame,grayTemplate,'same')./numel(grayTemplate);
    cumCorrScore =  (corrPartI-corrPartII)./(stdFrame*stdTemplate);
    
    % rotate the same template n times by 90 deg
   for t=rots
        corrPartI = conv2(grayFrame,rot90(grayTemplate,t),'same')./numel(grayTemplate);
        corrScore =  (corrPartI-corrPartII)./(stdFrame*stdTemplate);
        cumCorrScore =  max(cumCorrScore,corrScore);
    end
    
    
