label = niftiread('Task06_Lung\labelsTr\lung_095.nii.gz');
depth = Helpers.search_max_region_in_label(label);

mri = niftiread('Task06_Lung\imagesTr\lung_095.nii.gz');
img = Helpers.extractyimage(mri, depth);
 
imshow(img);
imshow(imageFromMRI, [], 'InitialMagnification', 'fit');