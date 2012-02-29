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
fprintf('Reading image headers...\n');
rtssheader = dicominfo(rtssfile);
imageheaders = loadDicomImageInfo(imagedir, rtssheader.StudyInstanceUID);


%% Read contour sequences
fprintf('Converting RT structures...\n');
contours = readRTstructures(rtssheader, imageheaders);


%% Save segmentations
mnchdr = niak_read_hdr_minc(mncfile);
mnchdr.type = 'minc2';
[~, dirname, ~] = fileparts(mncfile);

for i = 1:length(contours)
  name = [regexprep(contours(i).ROIName, '[^a-z0-9]', '_', 'ignorecase') '.mnc'];
  mnchdr.file_name = [segdir filesep dirname filesep name];
  mnchdr.info.history = sprintf('Generated from RT structure "%s", ROI "%s".\n', rtssfile, contours(i).ROIName);
  fprintf('Writing "%s"...\n', mnchdr.file_name);
  
  if ~exist([segdir filesep dirname], 'file')
    mkdir(segdir, dirname);
  end
  
  niak_write_minc(mnchdr, contours(i).Segmentation);
  files_out = [files_out mnchdr.file_name];
end


