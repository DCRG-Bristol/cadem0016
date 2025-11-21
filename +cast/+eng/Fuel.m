classdef Fuel
    %FUEL class for storing info about fuel    
    properties
        Name
        SpecificEnergy
        CostPerKilo
        Density
    end
    methods
        function obj = Fuel(Name,SpecificEnergy,CostPerKilo,Density)
            obj.Name = Name;
            obj.SpecificEnergy = SpecificEnergy; % 
            obj.CostPerKilo = CostPerKilo;
            obj.Density = Density;
        end
    end
    
    methods(Static)  
        function obj = LH2() % Liquid Hydrogen
            obj = cast.eng.Fuel("LH2",120,4.016,70.85); % 120 MJ/kg, 4.016 $/kg, 0.071 kg/m^3
        end
        function obj = JA1() % Jet A1
            obj = cast.eng.Fuel("JA1",43.2,1.009,785); % 43.2 MJ/kg, 1.009 $/kg, 0.785 kg/m^3
        end
    end
end

