function [xh] = lin_scale( xh, mPatch, mMean )
%mPatch is 5*5 im_l_y
%mMean is mPatch's avg    (m)
%xh is Dh*a
%add it before x+m

mPatch = mPatch(:) - mMean;
mNorm = sqrt(sum(mPatch.^2));
hNorm = sqrt(sum(xh.^2));

if hNorm
    s = mNorm*1.2/hNorm;
    xh = xh.*s;
end