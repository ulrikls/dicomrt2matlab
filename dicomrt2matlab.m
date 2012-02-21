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
imgheaders = loadDicomImageInfo(imagedir, rtssheader.StudyInstanceUID);


%% Read contour sequences
contours = readRTstructures(rtssheader, imgheaders);
%contours = convexPoints2bin(contours, imgheaders);


%% Save segmentations
[~, name, ~] = fileparts(rtssfile);
save([name '.mat'], 'contours', 'rtssheader', 'imageheaders', '-v7.3');


