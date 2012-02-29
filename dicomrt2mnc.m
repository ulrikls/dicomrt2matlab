function files_out = dicomrt2mnc(rtssfile, mncfile, imagedir, segdir)

%% Parse input
if nargin < 3
  imagedir = '';
end
if nargin < 4
  segdir = '';
end

if isempty(imagedir)
  imagedir = fileparts(rtssfile);
end
if isempty(segdir)
  segdir = imagedir;
end

files_out = {};


%% Load DICOM headers
rtssheader = dicominfo(rtssfile);
imageheaders = loadDicomImageInfo(imagedir, rtssheader.StudyInstanceUID);


%% Read contour sequences
contours = readRTstructures(rtssheader, imageheaders);


%% Save segmentations
mnchdr = niak_read_hdr_minc(mncfile);
[~, name, ~] = fileparts(mncfile);

for i = 1:length(contours)
  files_out = {files_out [segdir filesep name filesep contours(i).ROIName '.mnc']};
  niak_write_minc(mnchdr, contours(i).Segmentation);
end


