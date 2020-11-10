load('..\sofitool\GUI\image_sequence.mat');
numOfFrames = size(stacks_discrete,3);
n = 5;
itp_factor = 2;
addation_itp_factor = 1;
framesPerPhase = numOfFrames/n/n;
framesSIM = zeros(size(stacks_discrete,1),size(stacks_discrete,1),n^2);
framesSOFI = zeros(size(stacks_discrete,1)*itp_factor,size(stacks_discrete,1)*itp_factor,n^2);
frameSIM_FT = zeros(size(stacks_discrete,1)*itp_factor,size(stacks_discrete,1)*itp_factor,n^2);
for j = 1 : n
   for k = 1 : n
       for i = 1 : framesPerPhase
            framesSIM(:,:,k+(j-1)*n) = framesSIM(:,:,k+(j-1)*n)+...
           double(stacks_discrete(:,:,(k-1+(j-1)*n)*framesPerPhase+i));
       end
       framesSIM(:,:,k+(j-1)*n) = framesSIM(:,:,k+(j-1)*n)/framesPerPhase;
       [a,~] = FSOFI_Analysis(stacks_discrete(:,:,...
           (k+(j-1)*n-1)*framesPerPhase+1:(k+(j-1)*n)*framesPerPhase),2,100,0,itp_factor,'lateral'); 
       framesSOFI(:,:,k+(j-1)*n) = a;
   end
end
for i = 1:n^2
    a = fourierInterpolation(framesSIM(:,:,i),itp_factor,'lateral');
    frameSIM_FT(:,:,i) = a;
end

SIM = zeros(size(frameSIM_FT,1),size(frameSIM_FT,1));
for i = 1:n^2
   SIM = SIM+frameSIM_FT(:,:,i); 
end

minSIM = min(min(min(frameSIM_FT)));
maxSIM = max(max(max(frameSIM_FT)));
figure;
for i = 1 : n^2
    subplot(n,n,i);
    imshow(frameSIM_FT(:,:,i),[minSIM maxSIM]);
end

SOFI = zeros(size(framesSOFI,1),size(framesSOFI,1));
for i = 1:n^2
   SOFI = SOFI+framesSOFI(:,:,i); 
end
minSOFI = min(min(min(framesSOFI)));
maxSOFI = max(max(max(framesSOFI)));
figure;
for i = 1 : n^2
    subplot(n,n,i);
    imshow(framesSOFI(:,:,i),[minSOFI maxSOFI]);
end
figure;
subplot(1,2,1);
imshow(SIM,[]);
title("Original Image")
subplot(1,2,2);
imshow(SOFI,[]);
title("2nd order SOFI")
framesSOFI_FI = zeros(size(framesSOFI,1)*addation_itp_factor,size(framesSOFI,1)*addation_itp_factor,n^2);
framesSIM_FIFI = zeros(size(framesSOFI,1)*addation_itp_factor,size(framesSOFI,1)*addation_itp_factor,n^2);
for i = 1:n^2
    framesSOFI_FI(:,:,i) = fourierInterpolation(framesSOFI(:,:,i),addation_itp_factor,'lateral');
    framesSIM_FIFI(:,:,i) = fourierInterpolation(frameSIM_FT(:,:,i),addation_itp_factor,'lateral');
end
save('result.mat','framesSIM_FIFI','framesSOFI_FI')