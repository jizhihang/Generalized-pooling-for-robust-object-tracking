function wimgs = WarpImgColor(img, p, sz)

wimg1 = warpimg(img(:,:,1),p,sz);
wimg2 = warpimg(img(:,:,2),p,sz);
wimg3 = warpimg(img(:,:,3),p,sz);

wimgs = cat(4,wimg1,wimg2,wimg3);
wimgs = permute(wimgs,[1,2,4,3]);

end