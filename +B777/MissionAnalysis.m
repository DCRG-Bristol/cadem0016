function [BlockFuel,TripFuel,ResFuel,Mf_TOC,MissionTime,cruise_FL] = MissionAnalysis(ADP,tripRange,M_TO)
%MISSIONANALYSIS conduct mission analysis to estimate fuel burn
arguments
    ADP % geometry object
    tripRange % mission range in m
    M_TO = ADP.MTOM; % take off mass
end

EWF = 1;   % empty weight fraction
fs = double.empty;
ts = double.empty;

%% cruise analysis (assume constant C_L)

% pick optimal altitude for cruise
alts = linspace(15e3./SI.ft,44e3./SI.ft,61);
[rho,a,~,~] = cast.atmos(alts);
% [rho_s,a_s,~,P_s] = dcrg.aero.atmos(0);
M_cruise = ADP.TLAR.M_c;
CL_c = EWF*M_TO*9.81./(1/2.*rho.*(a.*M_cruise).^2.*ADP.WingArea); % cruise C_L
CD_c = ADP.AeroPolar.CD(CL_c);
LD_c = CL_c./CD_c;
[~,idx] = max(LD_c);

alt = alts(idx);
CL_c = CL_c(idx);
CD_c = CD_c(idx);
LD_c = CL_c/CD_c;
[~,a,~,~] = cast.atmos(alt);
cruise_FL = round(alt.*SI.ft/1e2,0);
disp(cruise_FL)

Cls = 0.4:0.01:0.8;
LDs = Cls*0;
for i = 1:length(Cls)
   LDs(i) =  Cls(i)/ADP.AeroPolar.CD(Cls(i));
end
f = figure(11);clf;plot(Cls,LDs)

% account for fact I don't model climb with an "effective" trip range
tripRange = tripRange * 1;
fs(1) = exp(-tripRange*9.81*ADP.Engine.TSFC(M_cruise,alt)/(M_cruise*a*LD_c)); % Rearranged Brequet
ts(1) = tripRange/(M_cruise*a); % time taken
EWF = EWF*fs(1);


%% alternate mission analysis
[rho,a,~,P] = cast.atmos(ADP.TLAR.Alt_alternate);
% [rho_s,a_s,~,P_s] = dcrg.aero.atmos(0);
M_cruise = ADP.TLAR.M_c;

CL_c = EWF*M_TO*9.81/(1/2*rho*(a*M_cruise)^2*ADP.WingArea); % cruise C_L
CD_c = ADP.AeroPolar.CD(CL_c);
LD_c = CL_c/CD_c;

% account for fact I don't model climb with an "effective" trip range
altRange = ADP.TLAR.Range_alternate * 1;

fs(2) = exp(-altRange*9.81*ADP.Engine.TSFC(M_cruise,altRange)/(M_cruise*a*LD_c)); % Rearranged Brequet
ts(2) = altRange/(M_cruise*a); % time taken
EWF = EWF*fs(2);

%% loiter
[rho,a,~,P] = cast.atmos(0);
Mach = 150/a;
CL = EWF*M_TO*9.81/(1/2*rho*(a*Mach)^2*ADP.WingArea);
CD = ADP.AeroPolar.CD(CL);
LD = CL/CD;

fs(3) = exp(-ADP.TLAR.Loiter*9.81*ADP.Engine.TSFC(Mach,0)/LD); % Snorri
ts(3) = ADP.TLAR.Loiter; % time taken
EWF = EWF*fs(3);

%% Contingency
df = (1-EWF)*0.03;
fs(4) = 1-df/EWF;
ts(4) = 5*60; % 5 minutes...
EWF = EWF*fs(4);


%% update model
BlockFuel = (1-EWF) * M_TO;
TripFuel = (1-fs(1))*M_TO;
ResFuel = (1-prod(fs(2:end)))*M_TO;
Mf_TOC = 1;

MissionTime = ts(1);
end