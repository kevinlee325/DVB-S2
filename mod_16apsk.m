function y = mod_16apsk(bits,gamma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mdulates the stream of input bits according to the 16apsk mapping
% defined for a certain gamma value. 
% Inputs : 
%     symb : The stream of input bits 
%     gamma : The 16 apsk radii ratio 
% Outputs : 
%     y : The stream of 16apsk modulated symbols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constellation and 16APSK bitMapping  
[constellation, bitMapping] = DVBS2Constellation('16APSK',gamma); 

% Converting bits into decimal values for mapping 
matx = reshape(bits,4,length(bits)/4)'; 
mapp =  bi2de(fliplr(matx),2)';  
symb= zeros(1,length(mapp)); 

% Mappinf the values onto the correspondant constellation points 
for i=1:length(mapp)
    [idx2,idx]= find(bitMapping == mapp(i)); 
    symb(i)= constellation(idx); 
end 

% The stream of 16apsk constellation symbols 
y = symb; 




    
 