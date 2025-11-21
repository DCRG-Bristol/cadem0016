classdef DragMeta
    %DragMeta Simple class to store zero-lift-drag coefficent data
properties (SetAccess = immutable)
    Name
    CD0
end
methods
    function obj = DragMeta(name,cd0)
        obj.Name = name;
        obj.CD0 = cd0;
    end

    function val = GetData(obj)
        val = [[[obj.Name],"Total"]',[[obj.CD0],sum([obj.CD0])]'*1e4];
    end
    function Print(obj)
        clipboard('copy',obj.GetData.join(char(9)).join(char(10)));
    end
end
end