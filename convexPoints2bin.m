function contours = convexPoints2bin(contours, imgheaders)

%%
xfm = getAffineXfm(imgheaders);

dimmin = [0 0 0 1]';
dimmax = double([imgheaders{1}.Columns-1 imgheaders{1}.Rows-1 length(imgheaders)-1 1])';

template = false([imgheaders{1}.Rows imgheaders{1}.Columns length(imgheaders)]);


%%
for i = 1:length(contours)
  if numel(contours(i).Points) > 0
    %% Make triangulation lattice
    % Find range of meshgrid as range of points expanded to nearest voxels
    % and constrained by image dimensions.
    gridpoints = xfm \ [contours(i).Points ones(size(contours(i).Points,1), 1)]';
    minvox = max(floor(min(gridpoints, [], 2)), dimmin);
    maxvox = min( ceil(max(gridpoints, [], 2)), dimmax);
    [x,y,z] = meshgrid(minvox(1):maxvox(1), minvox(2):maxvox(2), minvox(3):maxvox(3));
    points = xfm * [x(:) y(:) z(:) ones(size(x(:)))]';
    
    %% Triangulate and make binary image
    DT = DelaunayTri(contours(i).Points);
    mask = ~isnan(pointLocation(DT, points(1,:)', points(2,:)', points(3,:)'));
    mask = reshape(mask, size(x));
    
    %% Pad to image dimensions
    contours(i).ConvexSegmentation = template;
    contours(i).ConvexSegmentation((minvox(2):maxvox(2))+1, (minvox(1):maxvox(1))+1, (minvox(3):maxvox(3))+1) = mask;
    
  end
end
