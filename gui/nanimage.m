function h = nanimage( img_data )
% a wrapper for imagesc, with some formatting going on for nans

% plotting data. Removing and scaling axes (this is for image plotting)
h = image(img_data);
% axis image off % JOHN: Removed this because it made it empty. 

% setting alpha values
if ndims( img_data ) == 2
  set(h, 'AlphaData', ~isnan(img_data))
elseif ndims( img_data ) == 3
  set(h, 'AlphaData', ~isnan(img_data(:, :, 1)))
end

if nargout < 1
  clear h
end
