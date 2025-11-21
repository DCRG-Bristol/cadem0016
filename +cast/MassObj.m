classdef MassObj
    %MASSOBJ Simple class object to store information about point masses

    properties
        X (2,1) double = [nan nan] % Planform Location
        m (1,1) double = nan % mass (kg)
        Name string = "" % Name
    end

    methods
        function obj = MassObj(opts)
            arguments
                opts.?cast.MassObj
            end
            for prop = string(fieldnames(opts))'
                obj.(prop) = opts.(prop);
            end
        end

        function p = draw(obj)
            p = plot(obj.X(1),obj.X(2),'^w',MarkerEdgeColor='k');
            p.Annotation.LegendInformation.IconDisplayStyle = "off";
            p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("Name",obj.Name);
            p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("Mass",obj.m);
        end

        function val = GetData(obj)
            val = [[[obj.Name],"Total"]',[[obj.m],sum([obj.m])]'.*1e-3];
        end
        function Print(obj)
            clipboard('copy',obj.GetData.join(char(9)).join(char(10)));
        end
    end
end