function contours = readRTstructures(rtssheader, imgheaders)

%%
xfm = getAffineXfm(imgheaders);

dimmin = [0 0 0 1]';
dimmax = double([imgheaders{1}.Columns-1 imgheaders{1}.Rows-1 length(imgheaders)-1 1])';

template = false([imgheaders{1}.Columns imgheaders{1}.Rows length(imgheaders)]);

ROIContourSequence = fieldnames(rtssheader.ROIContourSequence);
contours = struct('ROIName', {}, 'Points', {}, 'VoxPoints', {}, 'Segmentation', {});


%% Loop through contours
for i = 1:length(ROIContourSequence)
  contours(i).ROIName = rtssheader.StructureSetROISequence.(ROIContourSequence{i}).ROIName;
  contours(i).Segmentation = template;
  
  try
    ContourSequence = fieldnames(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence);
    
    %% Loop through segments (slices)
    segments = cell(1,length(ContourSequence));
    for j = 1:length(ContourSequence)
      
      if strcmp(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourGeometricType, 'CLOSED_PLANAR')
        %% Read points
        segments{j} = reshape(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourData, ...
          3, rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).NumberOfContourPoints)';
        
        %% Make lattice
        points = xfm \ [segments{j} ones(size(segments{j},1), 1)]';
        start = xfm \ [segments{j}(1,:) 1]';
        minvox = max(floor(min(points, [], 2)), dimmin);
        maxvox = min( ceil(max(points, [], 2)), dimmax);
        minvox(3) = round(start(3));
        maxvox(3) = round(start(3));
        [x,y,z] = meshgrid(minvox(1):maxvox(1), minvox(2):maxvox(2), minvox(3):maxvox(3));
        points = xfm * [x(:) y(:) z(:) ones(size(x(:)))]';
        
        %% Make binary image
        in = inpolygon(points(1,:), points(2,:), segments{j}(:,1), segments{j}(:,2));
        contours(i).Segmentation((minvox(1):maxvox(1))+1, (minvox(2):maxvox(2))+1, (minvox(3):maxvox(3))+1) = permute(reshape(in, size(x)), [2 1]);
        
      end
    end
    contours(i).Points = vertcat(segments{:});
    
    %% Save contour points in voxel coordinates
    contours(i).VoxPoints = xfm \ [contours(i).Points ones(size(contours(i).Points,1), 1)]';
    contours(i).VoxPoints = contours(i).VoxPoints(1:3,:)';
    
  catch ME
    % Don't display errors about non-existent fields.
    if ~strcmp(ME.identifier, 'MATLAB:nonExistentField')
      warning(ME.identifier, ME.message);
    end
  end
  
end
