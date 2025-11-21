classdef AeroPolar
    %AEROPOLAR Class to estimate the drag coeefficent of a B777 like
    %aircraft during flight
    properties
        Beta
        e
        CD0
        CDmin
        CLmin % Cl at min drag
    end

    methods
        function obj = AeroPolar(ADP)
            %  CD0 estimate - 0.02
            % This is an extremely crude assumption, but CD0 of A320 and B777 
            % are similar and there is no clear trend across aircraft for 
            % CD0 with MTOM for example. You'll need to use flate  plate 
            % analogy + component method to deliver a class II/II.5 methodology 
            obj.CD0 = 0.019; 

            % calc AR
            AR = ADP.Span^2/ADP.WingArea;

            % calc induced factor (10.2514/1.C036529 Eq.4)
            Q = 1.05; P = 0.007;
            obj.e = 1/(Q+P*pi*AR); % estimate of oswald efficency factor
            obj.Beta = 1/(pi*AR*obj.e);            
        end

        function CD = CD(obj,CL)
            % calc CD for a given CL
            CD = obj.CD0 + obj.Beta*CL.^2;
        end
    end
end