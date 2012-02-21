function contours = readRTstructures(rtssheader, imgheaders)

xfm = getAffineXfm(imgheaders);

ROIContourSequence = fieldnames(rtssheader.ROIContourSequence);
contours = struct('ROIName', {}, 'Points', {}, 'VoxPoints', {}, 'Segmentation', {});

template = false([imgheaders{1}.Rows imgheaders{1}.Columns length(imgheaders)]);


%% Loop through contours
for i = 1:length(ROIContourSequence)
  t = tic;
  
  contours(i).ROIName = rtssheader.StructureSetROISequence.(ROIContourSequence{i}).ROIName;
  contours(i).Segmentation = template;
  
  try
    ContourSequence = fieldnames(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence);
    
    %% Loop through segments (slices)
    segments = cell(1,length(ContourSequence));
    for j = 1:length(ContourSequence)
      segments{j} = reshape(rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).ContourData, ...
        3, rtssheader.ROIContourSequence.(ROIContourSequence{i}).ContourSequence.(ContourSequence{j}).NumberOfContourPoints)';
      
      start = xfm \ [segments{j}(1,:) 1]';
      [x,y,z] = meshgrid(0:size(contours(i).Segmentation,1)-1, 0:size(contours(i).Segmentation,2)-1, round(start(3)));
      points = xfm * [x(:) y(:) z(:) ones(size(x(:)))]';
      
      in = inpolygon(points(1,:), points(2,:), segments{j}(:,1), segments{j}(:,2));
      contours(i).Segmentation(:,:,round(start(3))+1) = reshape(in, size(x));
    end
    contours(i).Points = vertcat(segments{:});
    
    contours(i).VoxPoints = xfm \ [contours(i).Points ones(length(contours(i).Points), 1)]';
    contours(i).VoxPoints = contours(i).VoxPoints([2 1 3],:)' + 1;
    
  catch ME
    % Don't display errors about non-existent fields.
    if ~strcmp(ME.identifier, 'MATLAB:nonExistentField')
      warning(ME.identifier, ME.message);
    end
  end
  
  toc(t)
end
