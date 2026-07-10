function skewdoc()
fp = fileparts(mfilename('fullpath'));
file = fullfile( fp , '..', 'doc', 'index.html');
open(file);
end