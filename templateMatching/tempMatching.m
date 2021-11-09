function cumCorrScore = tempMatching(frameImg, templateImg, method)
    % -------------------------------------------------------------------------
    % Function corrMatching: Template Matching using Correlation Coefficients
    % Inputs:
    %           frameImg = gray or color frame image
    %           templateImg = gray or color template image
    %           method = if set to 'rot' rotate the template
    %                    4 times by 90 deg
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
    
    %% 1. initialization
    if size(frameImg,3) ~=1
        frameGray = rgb2gray(frameImg);
    else
        frameGray = frameImg;
    end
    frameGray = double(frameGray);
    
    if size(templateImg,3) ~=1
        templateGray = rgb2gray(templateImg);
    else
        templateGray = templateImg;
    end
    templateGray = double(templateGray);
    
    
    %% 2. correlation calculation
    frameMean = conv2(frameGray,ones(size(templateGray))./numel(templateGray),'same');
    templateMean = mean(templateGray(:));
    stdTemplate = std(templateGray(:));
    stdFrame = sqrt(conv2(frameGray.^2,ones(size(templateGray))./numel(templateGray),'same')-frameMean.^2);
    corrPartII = frameMean.*sum(templateGray(:)-templateMean);
    
    corrPartI = conv2(frameGray,templateGray-templateMean,'same')./numel(templateGray);
    cumCorrScore =  (corrPartI-corrPartII)./(stdFrame.*stdTemplate);
    
    % rotate the same template 3 times by 90 deg
    if strcmp(method, 'rot')
        
        corrPartI = conv2(frameGray,rot90(templateGray-templateMean,1),'same')./numel(templateGray);
        corrScore =  (corrPartI-corrPartII)./(stdFrame.*stdTemplate);
        cumCorrScore =  max(cumCorrScore,corrScore);
        
        corrPartI = conv2(frameGray,rot90(templateGray-templateMean,2),'same')./numel(templateGray);
        corrScore =  (corrPartI-corrPartII)./(stdFrame.*stdTemplate);
        cumCorrScore =  max(cumCorrScore,corrScore);
        
        corrPartI = conv2(frameGray,rot90(templateGray-templateMean,3),'same')./numel(templateGray);
        corrScore =  (corrPartI-corrPartII)./(stdFrame.*stdTemplate);
        cumCorrScore =  max(cumCorrScore,corrScore);
    end
    
    
