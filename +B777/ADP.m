classdef ADP < handle
    %ADP Aircraft Design Parameters for a B777F


    % Top level Design Parameters

    % Masses
    properties
        TLAR
        Engine
        AeroPolar
    end

    properties
        MTOM    % Maximum take-off mass
        OEM     % Operational Empty Mass
        Mf_Ldg  % maximum landing mass fraction (e.g. MLDG = MTOM*Mf_Ldg)
        Mf_Fuel % fuel mass fraction 
        Mf_TOC  % "top of climb" mass fraction
        Mf_res  % "Resevre Fuel" mass fraction
    end
    % constraint Paramters
    properties
        ThrustToWeightRatio  % 
        WingLoading          % 
    end
    % Aerodynamic
    properties
        % ------------------------- geometry -------------------------
        V_HT = 0.9; % Horizontal Tail Volume
        V_VT = 0.07; % Vertical tail volume

        % --------------------- aero properties ----------------------
        Cl_max = 1.5;   % airfoil amx Cl for wing
        
        Delta_Cl_ld = 1; % Extra CL during landing
        Delta_Cl_to = 0.8; % Extra CL at take-off

        CD_TO = 0.03;     % CD in ground run
        CL_TO = 0.8;      % CL during ground run        
        CD_LDG = 0.03;    % CD in ground run on landing
        CL_LDG = 0.8;     % CL during ground run on landing
        CL_cruise = 0.5;  % CL during cruise

        LD_c = 16;        % Lift to drag ratio in cruise
        LD_app = 10;      % Lift to drag ratio during landing
        CD0 = 0.02;       % Zero-lift drag coefficent
        e = 0.8;          % Oswald Efficency Factor
    end

    % Sizing Flags (whether to Adjust certain values during sizing process)
    properties
        isSizeEng = true; % whether to change engine maximum Thrust Value
        isSizeWing = true; % whether to size the wing
    end

    % Concrete properties
    properties
        Thrust;

        % planfrom specific
        Span;
        WingArea;
        KinkPos;    % y position of wing kink 
        WingPos;    % Wing position along fuselage
        HtpPos;     % HTP pos along fuselage
        VtpPos;     % VTP pos along fuselage

        Mstar = 0.935; % wing technology factor

        % Empenage Specific
        HtpArea;
        VtpArea
    end

    % useful properties
    properties
        c_ac % mean geometric chord of main wing
        x_ac % x location of mean geometeric chord
        c_ach % mean geometric chord of HTP
        c_acv % mean geometric chord of VTP
    end

    % fuselage properties
    properties
        CockpitLength = 6;
        CabinRadius = 3.1;
        CabinLength = 63.7 - 4 - 3.1*2*1.48;
    end

    methods
        function out = AR(obj)
            out = obj.Span^2/obj.WingArea;
        end
    end
end