function img=SAR2RGBimage(mod,mod_ref)   
    if nargin < 2
        mod_ref = mod;
    end
    if nargin < 3
        nsigma = 3;
    end
    th = mean(mean(mod_ref)) + nsigma * std(reshape(mod_ref,size(mod_ref,1)*size(mod_ref,2),1));
    mod(mod > th) = th;
    nmod = 255 * mod / th;
    
    img(:, :, 1) = nmod;
    img(:, :, 2) = nmod;
    img(:, :, 3) = nmod;  
    img=uint8(img);
end