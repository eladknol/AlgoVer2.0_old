
%% Example for using MATLAB publisher
% This is the title section

%% Section 1: Text  
% This is a text section

%% Section 2: Static Image 
% This is an image section where the name of the image file is known.
% 
% <<FULL_PATH\dummyImage.png>>
% 

%% Section 3: Dynamic Image
% If the name of the image file is unknown, it can catch plots
plot(sin(0:0.01:20).*(1./exp(0:0.001:2)));
title('Decaying sine wave');
% You can hide the code if you wish...