function [GeomObj,massObj] = landingGear(obj)
% empenage - This function builds the landing gear for a B777 like aircraft

% ------------------------------ Parameters ------------------------------
M_ldg = obj.MTOM*obj.Mf_Ldg*SI.lb;
L_ldg = obj.Engine.Diameter * 1.2; % length of landing gear


% -------------------------- Nose Landing Gear ---------------------------
m_ldg = 0.125*(1*1.5*M_ldg)^0.566*(L_ldg*SI.ft)^0.845; % Raymer 15.51
m_ldg = m_ldg ./ SI.lb; % convert to kg

Xwheel = [-0.5,0.25;0.5,0.25;0.5,-0.25;-0.5,-0.25];
offset = [obj.CockpitLength,0];

GeomObj = cast.GeomObj(Name="Nose Landing Gear",Xs=Xwheel+offset);
massObj = cast.MassObj(Name="Nose Landing Gear",m=m_ldg,X=offset);

% -------------------------- Main Landing Gear ---------------------------

m_ldg = 0.095*(1*1.5*M_ldg)^0.768*(L_ldg*SI.ft)^0.409;
m_ldg = m_ldg ./ SI.lb; % convert to kg
offset = [obj.x_ac + obj.c_ac*0.5,obj.CabinRadius + 0.5*obj.Engine.Diameter]; % gear sit just inside of engine...

GeomObj(end+1) = cast.GeomObj(Name="Main Right Landing Gear",Xs=Xwheel+offset);
massObj(end+1) = cast.MassObj(Name="Main Right Landing Gear",m=m_ldg,X=offset);
GeomObj(end+1) = cast.GeomObj(Name="Main Left Landing Gear",Xs=Xwheel+offset.*[1 -1]);
massObj(end+1) = cast.MassObj(Name="Main Left Landing Gear",m=m_ldg,X=offset.*[1 -1]);
end