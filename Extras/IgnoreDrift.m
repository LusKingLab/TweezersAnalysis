
function adjustPos = IgnoreDrift(piezoPos2,qpdVolts2)

numData = length(piezoPos2);

% offset = 50;

% adjust drift
adjustPos = cell(numData,1); 
for i = 1:numData

    pos = piezoPos2{i};
    qpd = qpdVolts2{i};
    
    %adjustPos{i} = pos - pos(1);
%     adjustPos{i} = pos - mean(pos);
    adjustPos{i} = pos;
        
end

end