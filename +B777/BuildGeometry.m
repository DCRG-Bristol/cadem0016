function [GeomObj,massObj] = BuildGeometry(obj,opts)
arguments
    obj
    opts.FuelFraction = 1;
    opts.PayloadFraction = 1;
end

% Wing
GeomObj = struct.empty;
massObj = struct.empty;

FuncNames = ["wing","empenage","fuselage","engine","landingGear"];

for i = 1:length(FuncNames)
    [gTmp,mTmp] = B777.geom.(FuncNames(i))(obj); 
    GeomObj = [GeomObj,gTmp]; % Accumulate geom objects
    massObj = [massObj, mTmp]; % Accumulate mass objects
end

% add fuel mass
massObj(end+1) = cast.MassObj(Name="Fuel",m=obj.MTOM*obj.Mf_Fuel*opts.FuelFraction,...
                    X=[obj.WingPos+obj.c_ac*0.15,0]);
% add payload mass
massObj(end+1) = cast.MassObj(Name="Payload",m=obj.TLAR.Payload*opts.PayloadFraction,...
                    X=[obj.CockpitLength+obj.CabinLength/2,0]);
end