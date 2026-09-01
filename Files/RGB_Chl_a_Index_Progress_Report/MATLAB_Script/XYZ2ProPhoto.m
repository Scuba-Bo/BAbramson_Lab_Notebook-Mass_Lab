function ppRGB = XYZ2ProPhoto(inImg)
%
% PPRGB = XYZ2PROPHOTO(INIMG)
% 
% INIMG     : input RGB image of size NxMx3, linear RGB.
% PPRGB     : output RGB image of size NxMx3, in ProPhoto RGB space.
% Transformation taken from http://brucelindbloom.com. To get to the relevant page, click Math, click
% RGB/XYZ matrices.
%
% ************************************************************************
% If you use this code, please cite the following paper:
%
%
% <paper>
%
% ************************************************************************
% For questions, comments and bug reports, please use the interface at
% Matlab Central/ File Exchange. See paper above for details.
% ************************************************************************


s = size(inImg);

M = [1.3459 -0.2556 -0.0511;...
    -0.5446 1.5082 0.0205;...;
    0 0 1.2118];

RGB = M*reshape(xyz2double(inImg),[s(1)*s(2) 3])';
RGB(RGB<=0)=0;
RGB(RGB>1)=1;


ppRGB = reshape(RGB',[s(1) s(2) 3]);

