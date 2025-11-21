function [GeomObj,massObj] = empenage(obj)
% empenage - This function builds the empenage for a B777 like aircraft

%% cruise condition
M_c = obj.TLAR.M_c;
[rho,a] = cast.atmos(obj.TLAR.Alt_cruise);
q_c = 0.5*rho*(M_c*a)^2;

%% ---------------------------- HTP planform -----------------------------
% calc HTP moment arm from 
L_h = obj.HtpPos - obj.WingPos;

% calc HTP Area
obj.HtpArea = obj.V_HT * obj.WingArea * obj.c_ac / L_h;

AR = 5; % aspect ratio of the HTP
SweepQtrChord = real(acosd(0.75.*obj.Mstar./obj.TLAR.M_c)); % quarter chord sweep angle
tr =  -0.0083*SweepQtrChord + 0.4597; % taper ratio of outer portion of the wing
b = sqrt(AR*obj.HtpArea); % calc HTP span
c_rh = obj.HtpArea/((1+tr)/2*b); % calc HTP root chord

% calc aero centre
y_ac = fzero(@(y)trapz([0,y],interp1([0,b/2],[c_rh c_rh*tr],[0,y]))-(obj.HtpArea/4),b/4);
obj.c_ach = interp1([0,b/2],[c_rh c_rh*tr],y_ac);

% calc coords
ys = [-b/2 0 b/2]';
cs = [tr,1,tr]'*c_rh;
 
sweepLE = atand((1-tr)*c_rh/(4*b/2)+tand(SweepQtrChord));
x_le = [tand(sweepLE)*(b/2) 0 tand(sweepLE)*(b/2)]';
x_le = -c_rh.*0.25 + x_le;
x_te = cs + x_le;

Xs = [x_le,ys;flipud(x_te),flipud(ys)];
Xs(:,1) = Xs(:,1) + obj.HtpPos;
GeomObj = cast.GeomObj(Name="HTP", Xs=Xs);

%% ------------------------------ HTP mass -------------------------------
M_dg = obj.MTOM*obj.Mf_TOC*SI.lb; % design mass (taken at Top of Climb)

tcr = 0.15; % thickness to chord at the root
tct = 0.12; % thickness to chord at teh tip

% Gudmunson (6-49)
m_HT = 0.016*(1.5*2.5*M_dg)^0.414*(SI.lb/SI.ft^2*q_c)^0.168*...
        (obj.HtpArea*SI.ft^2)^0.896*...
        (100*(tcr+tct)/2/cosd(SweepQtrChord))^-0.12*...
        (AR/cosd(SweepQtrChord)^2)^0.043*tr^-0.02;
m_HT = m_HT./SI.lb;
massObj = cast.MassObj(Name="HTP",m=m_HT,X=[obj.HtpPos+c_rh*0.25;0]);

%% ---------------------------- VTP planform -----------------------------
obj.VtpArea =  obj.WingArea*obj.Span*obj.V_VT/(obj.VtpPos-obj.WingPos);

AR = 3.1; % aspect ratio of the VTP
b_VT = sqrt(AR*obj.VtpArea*2)/2;
c_rv = obj.VtpArea/(b_VT*(1+tr)/2);

% calc aero centre
y_ac = fzero(@(y)trapz([0,y],interp1([0,b_VT],[c_rv c_rv*tr],[0,y]))-(obj.VtpArea/2),b_VT/2);
obj.c_acv = interp1([0,b_VT],[c_rv c_rv*tr],y_ac);

% calc coords
ys = [0 0]';
cs = [1,tr]'*c_rv;


x_qtr = [0 tand(SweepQtrChord)*b_VT]';
x_le = -cs.*0.25 + x_qtr;
x_te = cs.*0.75 + x_qtr;

Xs = [x_le,ys;flipud(x_te),flipud(ys)];
Xs(:,1) = Xs(:,1) + obj.VtpPos;
GeomObj(end+1) = cast.GeomObj(Name="VTP", Xs=Xs);
%% ------------------------------ VTP mass -------------------------------
m_VT = 0.073*(1+0.2*0)*(1.5*2.5*M_dg)^0.376*(SI.lb/SI.ft^2*q_c)^0.122*...
    (obj.VtpArea*SI.ft^2)^0.873*...
    (100*(tcr+tct)/2/cosd(SweepQtrChord))^-0.49*...
    (AR/cosd(SweepQtrChord)^2)^0.357*tr^0.039;
m_VT = m_VT./SI.lb;
massObj(end+1) = cast.MassObj(Name="VTP",m=m_VT,X=[obj.VtpPos+c_rv*0.25;0]);

end