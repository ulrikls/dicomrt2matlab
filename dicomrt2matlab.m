function files_out = dicomrt2matlab(rtssfile, imagedir)

%% Parse input
if nargin < 2
  imagedir = '';
end

if isempty(imagedir)
  imagedir = fileparts(rtssfile);
end

files_out = {};


%% Load DICOM headers
rtssheader = dicominfo(rtssfile);
imageheaders = loadDicomImageInfo(imagedir, rtssheader.StudyInstanceUID);


%% Read contour sequences
contours = readRTstructures(rtssheader, imageheaders);
%contours = convexPoints2bin(contours, imageheaders);


%% Save segmentations
[~, name, ~] = fileparts(rtssfile);
files_out = [imagedir filesep name '.mat'];
save(files_out, 'contours', 'rtssheader', 'imageheaders', '-v7.3');


