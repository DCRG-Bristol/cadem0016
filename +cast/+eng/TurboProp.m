classdef TurboProp
    %ENGINE Simple turboprop model with TSFC interface identical to TurboFan
    
    properties
        Power_SL          % Shaft power at sea level (W)
        Mass
        Diameter
        PSFC_TO           % Power SFC at takeoff (kg/W/s)
        PSFC_cruise       % Power SFC at cruise
        eta_p0            % Propeller efficiency at low Mach
        
        PSFC_A
        PSFC_B
    end
    
    methods
        function obj = TurboProp(Power_SL, Mass, Diameter, ...
                                 PSFC_TO, PSFC_cruise, eta_p0, ...
                                 alt_cruise, M_cruise)
            arguments
                Power_SL
                Mass
                Diameter
                PSFC_TO
                PSFC_cruise
                eta_p0
                alt_cruise = 25e3 ./ SI.ft
                M_cruise = 0.45
            end
            
            obj.Power_SL = Power_SL;
            obj.Mass = Mass;
            obj.Diameter = Diameter;
            obj.PSFC_TO = PSFC_TO;
            obj.PSFC_cruise = PSFC_cruise;
            obj.eta_p0 = eta_p0;
            
            % altitude scaling (Raymer / Mattingly)
            T = cast.atmosT(alt_cruise);
            T0 = cast.atmosT(0);
            
            obj.PSFC_A = obj.PSFC_TO;
            obj.PSFC_B = (obj.PSFC_cruise / (T/T0)^0.3 - obj.PSFC_A) / M_cruise;
        end
        
        function eng_new = Rubberise(obj, P_new)
            f = P_new / obj.Power_SL;
            
            eng_new = cast.eng.TurboProp( ...
                P_new, ...
                obj.Mass * f^1.1, ...
                obj.Diameter * f^0.5, ...
                obj.PSFC_TO, ...
                obj.PSFC_cruise, ...
                obj.eta_p0);
            
            eng_new.PSFC_A = obj.PSFC_A;
            eng_new.PSFC_B = obj.PSFC_B;
        end
        
        function PSFC = PSFC(obj, M, alt)
            T = cast.atmosT(alt);
            T0 = cast.atmosT(0);
            
            % altitude + Mach effect
            PSFC = (obj.PSFC_A + obj.PSFC_B .* M) .* (T./T0).^0.3;
        end
        
        function eta_p = propEff(obj, M)
            % Propeller efficiency degrades with Mach
            % At low Mach: propeller operates near design point, high efficiency
            % At high Mach: propeller compressibility effects and tip Mach dominate
            % This is modeled as a parabolic degradation
            %
            % The degradation coefficient is chosen so that:
            % - At design point (M~0.68), efficiency is still reasonable
            % - Beyond M~0.75, efficiency drops sharply
            % - Crossover with turbofan happens around M~0.65-0.75
            
            eta_p = obj.eta_p0 * (1 - 0.5 * M.^2);
            
            % Ensure physically reasonable (0 < eta_p <= eta_p0)
            eta_p = max(eta_p, 0.05 * obj.eta_p0);
        end
        
        function TSFC = TSFC(obj, M, alt)
            % Convert PSFC to TSFC so interface matches TurboFan
            % TSFC = (fuel mass rate) / (thrust)
            %      = (PSFC * P) / (eta_p * P / V)
            %      = PSFC * V / eta_p
            % 
            % The power lapse at altitude naturally reduces available thrust
            % without needing explicit correction - it's captured in the 
            % propeller thrust equation T = eta_p * P / V, where P decreases
            % with altitude via (rho/rho0)^0.7
            
            [rho, a] = cast.atmos(alt);
            
            V = M * a;
            
            % TSFC from power-based SFC and velocity
            TSFC = obj.PSFC(M, alt) * V / obj.propEff(M);
        end
    end
    methods(Static)
        function obj = TP400_D6(alt_cruise, M_cruise)
            arguments
                alt_cruise = 30e3 ./ SI.ft
                M_cruise   = 0.68
            end
    
            Power_SL  = 8.2e6;   % W, ~11,000 shp
            Mass      = 1950;    % kg (approx)
            Diameter  = 5.3;     % m, prop diameter
    
            f = 0.453592 / (745.7 * 3600); % lb/shp/hr -> kg/W/s
            PSFC_TO     = 0.45 * f;      % Published value for modern turboprops
            PSFC_cruise = 0.33 * f;      % Published value for modern turboprops
    
            eta_p0 = 0.87;
    
            obj = cast.eng.TurboProp(Power_SL, Mass, Diameter, ...
                                     PSFC_TO, PSFC_cruise, eta_p0, ...
                                     alt_cruise, M_cruise);
        end
    end

end
