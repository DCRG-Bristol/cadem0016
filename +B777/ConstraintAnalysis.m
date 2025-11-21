function [ThrustToWeightRatio,WingLoading] = ConstraintAnalysis(obj)

%% estimate T/W and W/S from constraint analysis
% for now just setting to those of B777
% ---------------------- TODO -----------------------
% --------- update with constraint analysis ---------
obj.ThrustToWeightRatio = (513e3*2)/(347815*9.81);
obj.WingLoading = (347815*9.81)/(473.3*cosd(31.6));
% obj.WingLoading = (347815*9.81)/436.8;

% set Wing Area and Thrust
SweepQtrChord = real(acosd(0.75.*obj.Mstar./obj.TLAR.M_c)); % quarter chord sweep angle
obj.WingArea = obj.MTOM*9.81/obj.WingLoading/cosd(SweepQtrChord);
obj.Thrust = obj.ThrustToWeightRatio * obj.MTOM * 9.81;
end