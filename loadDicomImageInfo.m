function imgheaders = loadDicomImageInfo(imagedir, studyInstanceUID)

imagefiles = dir([imagedir filesep '*']);
imagefiles = imagefiles(~[imagefiles.isdir]);

imgheaders = cell(1, length(imagefiles));

sliceno = NaN(1,length(imagefiles));
for i  = 1:length(imagefiles)
  try
    info = dicominfo(fullfile(imagedir, imagefiles(i).name));
    
    % Skip files from other studies and DICOM-RT files.
    if strcmp(info.StudyInstanceUID, studyInstanceUID ) ...
        && isempty(regexpi(info.Modality, '^RT.*'))
      sliceno(i) = info.InstanceNumber;
      imgheaders{info.InstanceNumber} = info;
    end
    
  catch ME
    % Don't display errors about files not in DICOM format.
    if ~strcmpi(ME.identifier, 'Images:dicominfo:notDICOM')
      warning(ME.identifier, ME.message);
    end
  end
end

imgheaders = imgheaders(min(sliceno):max(sliceno));
