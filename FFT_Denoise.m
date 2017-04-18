clear
close all
clc

%% Load Data
rawdata = load('0413PostNP12hr_pol_40xA_RAW.dat');
data = reshape(rawdata, 512, 512, 512);
clear rawdata

% Finding Maximum Reflection as peak value?
PIV = zeros(512, 512);
PWV = zeros(512, 512);
for i = 1:512
    [PIV(i, :), PWV(i, :)] = max(data(:,:,i)');
end

figure
imshow(PIV,[], 'border', 'tight', 'initialmagnification', 'fit')
set(gcf, 'Position', [0, 0, 512, 512])
axis normal
set(gcf, 'PaperPositionMode', 'auto')
print -f1 -r300 -djpeg 0413PostNP12hr_40xA_PIV_RAW

figure
imshow(PWV,[], 'border', 'tight', 'initialmagnification', 'fit')
set(gcf, 'Position', [0, 0, 512, 512])
axis normal
set(gcf, 'PaperPositionMode', 'auto')
print -f2 -r300 -djpeg 0413PostNP12hr_40xA_PWV_RAW



%% FFT Visualization
F_PIV = fftshift(fft2(PIV));
figure
imshow(abs(F_PIV), [0, 1000000], 'border', 'tight', 'initialmagnification', 'fit')
set(gcf, 'Position', [0, 0, 512, 512])
axis normal
set(gcf, 'PaperPositionMode', 'auto')
print -f3 -r300 -djpeg 0413PostNP12hr_40xA_Kspace

F_PWV = fftshift(fft2(PWV));
% figure
% imshow(abs(F_PWV), [0, 5000], 'border', 'tight', 'initialmagnification', 'fit')
% set(gcf, 'Position', [0, 0, 512, 512])
% axis normal
% set(gcf, 'PaperPositionMode', 'auto')

%% Mask Filtering In Kspace
% Mask in Kspace
mask = ones(512, 512);
mask([1:255, 258:end], 257) = 0;

% figure
% imshow(abs(mask.*F), [0, 1000000])

figure
imshow(abs((ifft2(mask.*F_PIV))),[], 'initialmagnification', 'fit')
set(gcf, 'Position', [0, 0, 600, 512])
colorbar
axis normal
set(gcf, 'PaperPositionMode', 'auto')
hold on
plot(370:470, 490, 'k.', 'MarkerSize', 5)
text(385, 470, '10 um', 'fontSize', 15)
print -f7 -r300 -djpeg 0413PostNP12hr_40xA_PIV_NP_1

figure
imshow(abs((ifft2(mask.*F_PWV))), [], 'border', 'tight', 'initialmagnification', 'fit')
% set(gcf, 'Position', [0, 0, 512, 512])
axis normal
set(gcf, 'PaperPositionMode', 'auto')
print -f5 -r300 -djpeg 0413PostNP12hr_40xA_PWV_NP


%% Background Extraction
b_mask = zeros(512, 512);
b_mask(:, 257) = 1;% Center of Kspace shall not be 0

figure
imshow(abs((ifft2(b_mask.*F_PIV))),[], 'border', 'tight', 'initialmagnification', 'fit')
set(gcf, 'Position', [0, 0, 512, 512])
axis normal
set(gcf, 'PaperPositionMode', 'auto')
print -f6 -r300 -djpeg 0413PostNP12hr_40xA_PIV_BG

%% Plot Transmission Spectrum at Certain Points
% Coordinates in the image
x1 = 185;
y1 = 272;
x2 = 161;
y2 = 267;

% FFT Filtering
mask = ones(1, 512);
mask(1, [1:230,270:512]) = 0;
F_1 = fftshift(fft(data(x1, :, y1)));
F_2 = fftshift(fft(data(x2, :, y2)));

figure
hold on
plot(abs(ifft(F_1.*mask)), 'r', 'LineWidth', 2)
plot(abs(ifft(F_2.*mask)), 'b', 'LineWidth', 2)
legend('Without Adhesion', 'Suspected Adhesion')
xlim([0 512])
xlabel('Wavelength/nm');
ylabel('Reflection Intensity')
set(gca, 'XTick', [53, 155, 258, 360, 462])
set(gca,'XTickLabel',{'600','610','620','630','640'})
set(gca,'FontName','Times New Roman','FontSize',10,'FontWeight','bold');
set(gcf, 'PaperPositionMode', 'auto')
print -f -r300 -djpeg 0413PostNP12hr_40xA_ReflSpect

close all