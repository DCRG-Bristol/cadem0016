classdef TLAR
    %TLAR Top-Level Aircraft (Design) Requirements
    
    properties
        Crew
        Range       % Harmonic Range
        Payload     % Max. Payload
        V_ld        % Landing Speed
        V_app       % approach speed
        V_climb     % climb speed (CAS)
        GroundRun
        GroundRunLanding
        M_c         % cruise Mach number
        Alt_max     % max altitude in m
        Alt_cruise  % Cruise Altitude
        CrewMass    % Mass of the Crew
    end

    properties
        M_alt % Mach number at each alititude to be limited by either M_c or V_climb
    end

    % alternate airport diversion properties
    properties
        Alt_alternate = 22e3./SI.ft;
        Range_alternate = 200./SI.Nmile;
        Loiter = 30./SI.min; % 30 minutes in seconds
    end
    methods(Static)
        function obj = B777F
            obj = cast.TLAR();
            obj.Range = 4800./SI.Nmile;% m (from nautical miles)
            obj.GroundRun = 2830; %m
            obj.GroundRunLanding = 1500; %m
            obj.M_c = 0.82;
            obj.Alt_max = 39e3./SI.ft; %m (39,000ft)
            obj.Alt_cruise = 31e3./SI.ft;
            obj.Crew = 4;
            obj.Payload = 103700;
            obj.CrewMass = (80+10)*obj.Crew;
            obj.V_app = 200./SI.knt;
            obj.V_ld = 150./SI.knt;
            obj.V_climb = 250/SI.knt;
        end
    end
end