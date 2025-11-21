classdef SI
    %SI a class with many static properties represent changing from SI
    %units to differnt units. For example a*SI.ff turn a metres into feet, 
    % and b./SI.lb turns pounds into kg.
    
    properties(Constant)
        ft = 3.28084;
        FL = 3.28084e-2; % Flight Level (hundreds of feet)
        inch = 39.3701;
        Nmile = 0.000539957;
        mile = 0.000621371;
        km = 1e-3;
    end
    %pressure
    properties(Constant)
        lbft = 0.0208854342;
        psi = 0.0001450377;
        bar = 1e-5;
    end
    %force
    properties(Constant)
        lbf = 0.224809;
    end
    %mass
    properties(Constant)
        lb = 2.20462;
        Tonne = 1/1e3;
    end
    %volume
    properties(Constant)
        gal = 219.969;
        litre = 1000;
    end
    %velocity
    properties(Constant)
        knt = 1/0.514444;
    end
    %time
    properties(Constant)
        hr = 1/(60*60);
        min = 1/60;
    end
    %other
    properties(Constant)
        DragCount = 1e4;
        g = 9.81
    end
end

