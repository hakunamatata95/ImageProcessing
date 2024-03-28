clear all;
close all;

label = niftiread('Task06_Lung\labelsTr\lung_095.nii.gz');
depth = Helpers.search_max_region_in_label(label);

mri = niftiread('Task06_Lung\imagesTr\lung_095.nii.gz');

img = Helpers.extractyimage(mri, depth);
 
imshow(imrotate(img, 90),[]);

%volshow(mri);

%normalizzazione min max
%Vmax= max(mri, [], 'all');
%Vmin= min(mri, [], 'all');
%model = (mri-Vmin)./(Vmax-Vmin);

%imshow(imageFromMRI, [], 'InitialMagnification', 'fit');
