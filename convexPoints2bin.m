function contours = convexPoints2bin(contours, imgheaders)

%%
xfm = getAffineXfm(imgheaders);

d = xfm * [1 1 1 0]';

dimmin = [0 0 0 1]';
dimmax = double([imgheaders{1}.Columns-1 imgheaders{1}.Rows-1 length(imgheaders)-1 1])';

template = false([imgheaders{1}.Rows imgheaders{1}.Columns length(imgheaders)]);


%%
for i = 1:length(contours)
  if numel(contours(i).Points) > 0
    %% Make triangulation lattice
    % Find range of meshgrid as range of points expanded to nearest voxels
    % and constrained by image dimensions.
    gridpoints = xfm \ [contours(i).Points ones(length(contours(i).Points), 1)]';
    minvox = max(floor(min(gridpoints, [], 2)), dimmin);
    maxvox = min( ceil(max(gridpoints, [], 2)), dimmax);
    minwld = xfm * minvox;
    maxwld = xfm * maxvox;
    [x,y,z] = meshgrid(minwld(1):d(1):maxwld(1), minwld(2):d(2):maxwld(2), minwld(3):d(3):maxwld(3));
    
    %% Triangulate and make binary image
    DT = DelaunayTri(contours(i).Points);
    mask = ~isnan(pointLocation(DT, x(:), y(:), z(:)));
    mask = reshape(mask, size(x));
    
    %% Pad to image dimensions
    contours(i).ConvexSegmentation = template;
    contours(i).ConvexSegmentation((minvox(2):maxvox(2))+1, (minvox(1):maxvox(1))+1, (minvox(3):maxvox(3))+1) = mask;
    
  end
end
