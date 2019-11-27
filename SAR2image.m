function img=SAR2image(mod)   
Iradar=single(mod);
SARGRDImg(:,:,1)=Iradar;
SARGRDImg(:,:,2)=Iradar;
SARGRDImg(:,:,3)=Iradar;
img=uint8(SARGRDImg);

end