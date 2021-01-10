basedir = "D:\Users\Kyle\IRSS contest\ChangeDetectionToolbox-master\validation\";
fileID = fopen(basedir+"validation_tile_index.txt",'r');

alg_cd = "MAD";
alg_thre = "KMeans";

algCD = Algorithms.(alg_cd)();
algThre = ThreAlgs.(alg_thre)();
fcnNorm = @Utilities.normMeanStd;

%read tile ids;

tiles = {};
while ~feof(fileID)
tile = sscanf(fgetl(fileID),'%s');
tile = string(tile)

path_t1 = basedir+tile+"_naip-2013.tif";
path_t2 = basedir+tile+"_naip-2017.tif";
path_l1 = basedir+tile+"_nlcd-2013.tif";
path_l2 = basedir+tile+"_nlcd-2016.tif";

imT1 = imread(path_t1, 'tiff');
imT2 = imread(path_t2, 'tiff');
[imT1, imT2] = deal(fcnNorm(double(imT1)), fcnNorm(double(imT2)));
iml1 = imread(path_l1, 'tiff');
iml2 = imread(path_l2, 'tiff');

iml1 = simplifyLabel(iml1,"soft");
iml2 = simplifyLabel(iml2,"soft");
DI = algCD.detectChange(imT1, imT2);
CM = algThre.segment(DI);

CM = changeMap(CM,iml1,iml2);

predfn = convertStringsToChars(basedir+"\predictions\"+tile+'_predictions.tiff')
imwrite(CM,predfn,'tiff');

%tiles = [tiles,tile];
end
%tiles=string(tiles);






function [landcover] = simplifyLabel(landcover,hardness)
%landccover a nlcd landcover map
%hardness if "soft" then use soft target map, otherwise use
%hard targetmap
    landcover(landcover==11) = 0;
    if strcmp(hardness,"soft")
    landcover(landcover==21)=-1;
    landcover(landcover==22)=-1;
    landcover(landcover==31)=-1;
    else
    landcover(landcover==21) = 2;
    landcover(landcover==22) = 3;
    landcover(landcover==31) = 2; 
    end
    landcover(landcover==23) = 3;
    landcover(landcover==24) = 3;
    landcover(landcover==41) = 1;
    landcover(landcover==42) = 1;
    landcover(landcover==43) = 1;
    landcover(landcover==52) = 1;
    landcover(landcover==71) = 2;
    landcover(landcover==81) = 2;
    landcover(landcover==82) = 2;
    landcover(landcover==90) = 1;
    landcover(landcover==95) = 1;    
end

function [changemap] = changeMap(CM,L1,L2)
changemap = L1*4 + L2; 
changemap (CM==0) = 0;
changemap (changemap==5) = 0;
changemap (changemap==10) = 0;
changemap (changemap==15) = 0;
end