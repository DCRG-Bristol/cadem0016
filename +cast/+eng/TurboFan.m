classdef TurboFan
    %ENGINE Turbo Fan engine model 
    
    properties
        Length
        Diameter
        Mass
        SFC_TO
        SFC_cruise
        T_Static
        BPR;

        SFC_A = 0.45;
        SFC_B = 0.54;
    end
    methods
        function obj = TurboFan(T_Static,L,D,M,SFC_TO,SFC_cruise,BPR,alt_cruise,M_cruise)
            arguments
                T_Static
                L
                D
                M
                SFC_TO
                SFC_cruise
                BPR
                alt_cruise = 32e3 ./ SI.ft
                M_cruise = 0.78
            end
            obj.T_Static = T_Static;
            obj.Length = L;
            obj.Diameter = D;
            obj.Mass = M;
            obj.SFC_TO = SFC_TO;
            obj.SFC_cruise = SFC_cruise;
            obj.BPR = BPR;

            obj.SFC_A = obj.SFC_TO;
            T = cast.atmosT(alt_cruise);
            T0 = cast.atmosT(0);
            obj.SFC_B = (obj.SFC_cruise / sqrt(T/T0) - obj.SFC_A)/M_cruise;
        end
        function eng_new = Rubberise(obj,T_new)
            f = T_new/obj.T_Static;
            % rubberise a new engine using scaling laws from Raymer (10.1 - 10.3)
            eng_new = cast.eng.TurboFan(T_new,obj.Length*f^0.4,obj.Diameter*f^0.5,obj.Mass*f^1.1,...
                obj.SFC_TO,obj.SFC_cruise,obj.BPR);
            eng_new.SFC_A = obj.SFC_A;
            eng_new.SFC_B = obj.SFC_B;
        end
        function TSFC = TSFC(obj,M,alt)
            T = cast.atmosT(alt);
            T0 = cast.atmosT(0);
            TSFC = (obj.SFC_A + obj.SFC_B.*M).*sqrt(T./T0);
        end
    end
    
    methods(Static)
        
        function obj = CFM_LEAP_1A(sfc_scaling,alt_cruise,M_cruise)
            arguments
                sfc_scaling = 1;
                alt_cruise = 32e3 ./ SI.ft
                M_cruise = 0.78
            end
            %CFM_LEAP_1A SData for CFM LEAP-1A
            %   https://www.easa.europa.eu/en/downloads/20086/en
            f = 1./(SI.lb/(SI.lbf*SI.hr)) * sfc_scaling; % to convert SFC from imperial to SI.
            BPR = 11;
            SFC_T0 = 19*exp(-0.12*BPR)*1e-6 * sfc_scaling; % from Aircraft Design: A Conceptual Approach, Raymer, 5th Ed. eq.10.7
            SFC_cruise = 25*exp(-0.05*BPR)*1e-6 * sfc_scaling; % from Aircraft Design: A Conceptual Approach, Raymer, 5th Ed. eq.10.9 (very close to value on wikipedia)
            obj = cast.eng.TurboFan(143050,3.328,2.4,3008,SFC_T0,SFC_cruise,BPR,alt_cruise,M_cruise);
        end
        function obj = GE90(sfc_scaling,alt_cruise,M_cruise)
            arguments
                sfc_scaling = 1;
                alt_cruise = 32e3 ./ SI.ft
                M_cruise = 0.84
            end
            %CFM_LEAP_1A SData for CFM LEAP-1A
            %   https://www.easa.europa.eu/en/downloads/20086/en
            f = 1./(SI.lb/(SI.lbf*SI.hr)) * sfc_scaling; % to convert SFC from imperial to SI.
            BPR = 8.5;
            SFC_T0 = 19*exp(-0.12*BPR)*1e-6 * sfc_scaling; % from Aircraft Design: A Conceptual Approach, Raymer, 5th Ed. eq.10.7
            SFC_cruise = 25*exp(-0.05*BPR)*1e-6 * sfc_scaling; % from Aircraft Design: A Conceptual Approach, Raymer, 5th Ed. eq.10.9 (very close to value on wikipedia)
            obj = cast.eng.TurboFan(513e3,7.28,3.85,8762,SFC_T0,SFC_cruise,BPR,alt_cruise,M_cruise);
        end
        function obj = CFM56_5()
            %CFM56_5 Data for CFM56-5 as on a318/a319
            %   https://en.wikipedia.org/wiki/CFM_International_CFM56
            f = 1./(SI.lb/(SI.lbf*SI.hr)); % to convert SFC from imperial to SI.
            obj = cast.eng.TurboFan(107e3,2.422,2.00,2331,0.3316*f,0.596*f,6);
        end
    end
end

