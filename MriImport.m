clear;
close all;


%label = niftiread('Task06_Lung\labelsTr\lung_095.nii.gz');
%depth = Helpers.search_max_region_in_label(label);

%mri = niftiread('Task06_Lung\imagesTr\lung_095.nii.gz');
%info = niftiinfo('Task06_Lung\imagesTr\lung_095.nii.gz');
%img = Helpers.extractyimage(mri, depth);

  
%imshow(imrotate(img, 90),[]);
%B = imresize(A,scale)
 

imag = Helpers.datasetimport('Task06_Lung\labelsTr\lung_095.nii.gz', ...
    'Task06_Lung\imagesTr\lung_095.nii.gz');


imshow(imag); 
%imshow(imag, []);
%normalizzazione min max
%Vmax= max(mri, [], 'all');
%Vmin= min(mri, [], 'all');
%model = (mri-Vmin)./(Vmax-Vmin);

%imshow(imageFromMRI, [], 'InitialMagnification', 'fit');


%Rappresentazione 3D MRI
%volshow(mri);
