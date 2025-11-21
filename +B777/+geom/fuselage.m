function [GeomObj,massObj] = fuselage(obj)
% fuselage - this function build the fuselage for a B777 like aircraft


% estiamte fuselage length
L_f = obj.CockpitLength + obj.CabinLength + obj.CabinRadius * 1.48;

% cockpit plot points
theta = linspace(0,pi,101)';
Xs = [-sin(theta)*obj.CockpitLength,cos(theta)*obj.CabinRadius];

% tail plot points
theta = linspace(pi,0,101)';
Xs = [Xs;...
    sin(theta)*obj.CabinRadius*2*2.48+(obj.CabinLength-obj.CabinRadius*2),cos(theta)*obj.CabinRadius];

% tidy up geometry points
Xs(:,1) = Xs(:,1)+obj.CockpitLength; % ensure start from zero
GeomObj = cast.GeomObj(Name="Fuselage", Xs=Xs);

%% ---------------------------- Fuselage Mass -----------------------------
K_d  = 1.12;          % damage factor for transport
K_Lg = 1.12;          % landing gear factor (if mounted to fuselage bays)
M_dg = obj.MTOM * obj.Mf_TOC * SI.lb;     % design weight at TOC [lb]
n_z  = 2.5 * 1.5;     % ultimate maneuver load factor
D    = (2 * obj.CabinRadius) * SI.ft;     % max fuselage diameter [ft]
b_w  = obj.Span * SI.ft;                  % wing span [ft]

% Wing geometry influence (if using Raymer's K_ws)
SweepQtrChord = real(acosd(0.75 .* obj.Mstar ./ obj.TLAR.M_c)); % [deg]
tr = -0.0083 * SweepQtrChord + 0.4597;                          % outer wing taper
K_ws = 0.75 * ((1 + 2*tr) / (1 + tr)) * (b_w / L_f) * tand(SweepQtrChord);

% Fuselage wetted area (first-order)
S_f = pi*D*(obj.CabinLength.*SI.ft) + ...
    pi*(obj.CabinLength.*SI.ft)*(obj.CabinRadius.*SI.ft) + ...
    pi*(1.48*obj.CabinRadius.*SI.ft)*(obj.CabinRadius.*SI.ft);   % [ft^2]; add cone correction if you have precise geometry

% Raymer correlation (weight in lb)
W_fus_lb = 0.3280 * K_d * K_Lg * sqrt(M_dg * n_z) * (L_f^0.25) * (S_f^0.302) ...
           * ((1 + K_ws)^0.04) * ((L_f / D)^0.10);

% Convert to mass [kg]
m_fus_kg = W_fus_lb / SI.lb * 1.5; 

massObj = cast.MassObj(Name="Fuselage",m=m_fus_kg,X=[L_f/2;0]);

%% ----------------------------- Systems Mass -----------------------------
m_sys = (270*((2 * obj.CabinRadius))+150)*L_f/9.81 * 2;
massObj(end+1) = cast.MassObj(Name="Systems",m=m_sys,X=[L_f/2;0]);

%% --------------------------- Fuel System Mass ---------------------------
FuelMass = obj.MTOM * obj.Mf_Fuel;
N_fuelTank = 3; % number of tanks (one in each wing and a central tank)
V_t = FuelMass/cast.eng.Fuel.JA1.Density*SI.litre; % tank volume
N_eng = 2; % number of engines

m_fuelsys = (36.3*(N_eng+N_fuelTank-1)+4.366*N_fuelTank^0.5*V_t^(1/3)); % Torenbeek
massObj(end+1) = cast.MassObj(Name="Fuel Systems",m=m_fuelsys,X=[L_f/2;0]);
end