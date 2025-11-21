classdef GeomObj
    %GEOMOBJ Simple class to store info for planform geometery

    properties
        Xs (:,2) double = [nan nan] % nodes of the planform box
        Name string = ""
    end

    methods
        function obj = GeomObj(opts)
            arguments
                opts.?cast.GeomObj
            end
            for prop = string(fieldnames(opts))'
                obj.(prop) = opts.(prop);
            end
        end

        function p = draw(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            p = patch(obj.Xs(:,1),obj.Xs(:,2),'b',DisplayName=obj.Name,FaceAlpha=0.6);
        end
    end
end