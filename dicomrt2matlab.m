function files_out = dicomrt2matlab(rtssfile, imagedir, segdir)

%% Parse input
if nargin < 2
  imagedir = '';
end
if nargin < 3
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
contours = readRTstructures(rtssheader, imageheaders); %#ok<NASGU>
%contours = convexPoints2bin(contours, imageheaders); %#ok<NASGU>


%% Save segmentations
[~, name, ~] = fileparts(rtssfile);
files_out{1} = [segdir filesep name '.mat'];
save(files_out{1}, 'contours', 'rtssheader', 'imageheaders', '-v7.3');


