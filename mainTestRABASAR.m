
clear
%% Saclay
%% Sentinel-1 images
load PileI1.mat %intensity
[M,N,Num]=size(PileI1);
stack=PileI1(1:2:M,1:2:N,1:69);

%% multitemporal decorrelated TerraSAR-X complex data
% addpath C:\Bmaterials\01Experiments\01TemporalSARChangeDetection\08Denoisingmthods\RemyData
% load speckle_plus_target_decomposition_domancy.mat
% u0=u0_mov(501:756,351:606,:);
% w0=w0_mov(501:756,351:606,:);
% d0=d0_mov(501:756,351:606,:);
% Img_Set=abs(w0)+abs(d0);
% stack=Img_Set(:,:,1:16).*Img_Set(:,:,1:16);

L=1;k=1;thr=0.92;
[dimg4, si4, Lsi, dsi4, Ldsi4] = function_RABASAR_DBWAM(stack,k,L,thr);
[dimg3, si3, Lsi, dsi3, Ldsi3] = function_RABASAR_BWAM(stack,k,L,thr);
[dimg2, si2, Lsi, dsi2, Ldsi2] = function_RABASAR_DAM(stack,k,L);
[dimg1, si1, Lsi, dsi1, Ldsi1] = function_RABASAR_AM(stack,k,L);

%%
figure;
subplot(1,4,1);imagesc(SAR2image(sqrt(dimg1)));title('RABASAR-AM')
subplot(1,4,2);imagesc(SAR2image(sqrt(dimg2)));title('RABASAR-DAM')
subplot(1,4,3);imagesc(SAR2image(sqrt(dimg3)));title('RABASAR-BWAM')
subplot(1,4,4);imagesc(SAR2image(sqrt(dimg4)));title('RABASAR-DBWAM')