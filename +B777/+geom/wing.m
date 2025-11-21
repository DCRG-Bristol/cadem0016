function [GeomObj,massObj] = wing(obj)
% empenage - This function builds the wing for a B777 like aircraft


%% Calculate wing planform parameters
SweepQtrChord = real(acosd(0.75.*obj.Mstar./obj.TLAR.M_c)); % quarter chord sweep angle
tr =  -0.0083*SweepQtrChord + 0.4597; % taper ratio of outer portion of the wing

b = obj.Span;
S = (obj.MTOM*9.81)/obj.WingLoading;

R_f = obj.CabinRadius;        % radius of fuselage
L2 = obj.KinkPos-R_f;   % length from fuselage to kink
L3 =  obj.Span/2-obj.KinkPos;  % length from kink to wingtip

% estimate chord at kink
c_r_star  = (S/b)/(1 + tr); % root chord if constant taper
c = (1-(1-tr)*obj.KinkPos/(b/2))*c_r_star; % estimate chord at kink pos

% find chord at the kink which gives the correct wing area
% Note - look at "get_areas" function at the bottum of script which
% parameterises the planform 
c = fminsearch(@(x)(get_areas(x,L2,L3,R_f,tr,SweepQtrChord)-S).^2,c);
[~,c_t,c_r,A1,A2,A3] = get_areas(c,L2,L3,R_f,tr,SweepQtrChord);

%% create wing planfrom
% Create straight leading edge based on quarter chord sweep
ys = [-b/2 -obj.KinkPos -R_f 0 R_f obj.KinkPos b/2]';
cs = [c_t,c,c_r,c_r,c_r,c,c_t]';
 
sweepLE = atand((tand(SweepQtrChord)*L3+c/4-c_t/4)/L3);
sweepHalf = atand((tand(SweepQtrChord)*L3-c/4+c_t/4)/L3);
x_le = [tand(sweepLE)*(L2+L3) tand(sweepLE)*L2 0 0 0 tand(sweepLE)*L2 tand(sweepLE)*(L2+L3)]';
x_le = -c_r.*0.25 + x_le;
x_qtr = x_le + cs*0.25;
x_te = cs + x_le;

Xs = [x_le,ys;flipud(x_te),flipud(ys)];

% calc mean aero chord  (this is a crude approximation) you can do better!
As = [A3,A2,A1,A1,A2,A3];
As_sum = [0,cumsum(As)];
idx = find(As_sum>=S/4,1,'first')-1;
y_ac = fminsearch(@(y)(trapz([ys(idx),y],interp1(ys(idx:idx+1),cs(idx:idx+1),[ys(idx),y]))-(S/4-As_sum(idx))).^2,mean(ys(idx:idx+1)));
obj.c_ac = interp1(ys,cs,y_ac);
obj.x_ac = interp1(ys,x_qtr,y_ac);

% place aerodynamic centre at WingPos
Xs(:,1) = Xs(:,1) + (obj.WingPos-obj.x_ac);
obj.x_ac = obj.WingPos;

GeomObj = cast.GeomObj(Name="Wing", Xs=Xs);
%% calcualte mass
b_w  = obj.Span * SI.ft;           % [ft]
S_w  = obj.WingArea * (SI.ft)^2;   % [ft^2]

t_w = 0.15*c_r*SI.ft; % max thickness at root
cosLambda     = cosd(sweepHalf);

% Design gross weight in pounds-force (no 9.81 anywhere)
Wdg_lb = obj.MTOM * obj.Mf_TOC * SI.lb;  % choose design mass fraction Mf_TOC appropriately
n_z    = 2.5 * 1.5;                      % ultimate

% Pressurization factor (transport default)
Wpc = 1.0;

% Raymer wing weight [lb]
w_wing = 0.00125 * Wdg_lb * (b_w/cosLambda)^0.75 * ...
    (1 + sqrt(6.3*cosLambda/b_w))*n_z^0.55 * ...
    (b_w*S_w/(t_w*Wdg_lb*cosLambda))^0.3;

% Convert to mass [kg]
m_wing = (w_wing / SI.lb);

massObj = cast.MassObj(Name="Wing",m=m_wing,X=[obj.x_ac;0]);
end


function [S,c_t,c_r,A1,A2,A3] = get_areas(c,L2,L3,R_f,tr,SweepQtrChord)
    c_t = tr*c;

    sweepLE = atand((tand(SweepQtrChord)*L3+c/4-c_t/4)/L3);
    c_r = c + tand(sweepLE)*L2;
    % c_r = (c-c_t)/L3*L2+c;  % if you want no kink

    % calc area of each area
    A1 = c_r*R_f;
    A2 = (c_r+c)/2*L2;
    A3 = (c+c_t)/2*L3;
    %calc total area
    S = 2*(A1+A2+A3);
end