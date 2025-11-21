function draw(GeomObj,massObj)
arguments
    GeomObj 
    massObj = cast.MassObj.empty
end
%DRAW Summary of this function goes here
%   Detailed explanation goes here
hold on;
for i = 1:length(GeomObj)
    p = GeomObj(i).draw;
end
for i = 1:length(massObj)
    p = massObj(i).draw;
end

% estimate COM
CoM = sum([massObj.X].*[massObj.m],2)./sum([massObj.m]);
p = plot(CoM(1),CoM(2),'wo',MarkerEdgeColor='k');
p.Annotation.LegendInformation.IconDisplayStyle = "off";
p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("Name","CoM");
p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("Mass",string(sprintf('%.2f t',sum([massObj.m])/1e3)));
end