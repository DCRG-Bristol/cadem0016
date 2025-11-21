function T = atmosT(h, tOffset)
%  ATMOST  Find temperature in the 1976 Standard Atmosphere (optimized).
%   T = ATMOST(h, tOffset)
%
%   ATMOST returns only the temperature from the 1976 Standard Atmosphere at
%   geopotential altitude h. This is a highly optimized version of ATMOS that
%   only calculates temperature, making it much faster for temperature-only queries.
%
%   Inputs:
%     h        - Altitude or height (m), scalar, vector, matrix, or ND array
%     tOffset  - Temperature offset (°C/°K), optional. Default is 0.
%                Must be same size as h or scalar.
%
%   Output:
%     T        - Temperature (°K), same size as h
%
%   This function uses the same atmospheric model as ATMOS but skips all
%   pressure, density, viscosity, and other calculations for maximum speed.
%
%   Example:
%       h = [0, 5000, 11000, 20000];
%       T = dcrg.aero.atmosT(h);  % Standard atmosphere temperatures
%       T_hot = dcrg.aero.atmosT(h, 15);  % +15°C offset
%
%   See also ATMOS
%
%   Copyright 2015 Sky Sartorius (original ATMOS)
%   Optimized temperature-only version

arguments
    h
    tOffset = 0
end

%% Quick return for sea level standard conditions
if length(h)==1 && h==0 && tOffset==0
    T = 288.15;  % Sea level temperature
    return
end

%% Atmospheric layer data (temperature calculation only):
% Pre-computed data for fast lookup
K_D = [-0.0065; 0; 0.001; 0.0028; 0; -0.0028; -0.002; 0]; % Lapse rates °K/m
T_D = [288.15; 216.65; 216.65; 228.65; 270.65; 270.65; 214.65; 186.94590831019]; % Base temps °K
H = [0; 11000; 20000; 32000; 47000; 51000; 71000; 84852.04584490575]; % Altitudes m

%% Optimized logic: separate handling for single calls vs arrays
if isscalar(h)
    %% SINGLE CALL OPTIMIZATION - Direct calculation without loops
    % Find the atmospheric layer using simple conditional logic
    if h <= 11000          % Layer 1: Troposphere
        T = T_D(1) + K_D(1) * (h - H(1));
    elseif h <= 20000      % Layer 2: Tropopause (isothermal)
        T = T_D(2);
    elseif h <= 32000      % Layer 3: Stratosphere 1
        T = T_D(3) + K_D(3) * (h - H(3));
    elseif h <= 47000      % Layer 4: Stratosphere 2
        T = T_D(4) + K_D(4) * (h - H(4));
    elseif h <= 51000      % Layer 5: Stratopause (isothermal)
        T = T_D(5);
    elseif h <= 71000      % Layer 6: Mesosphere 1
        T = T_D(6) + K_D(6) * (h - H(6));
    elseif h <= 84852.04584490575  % Layer 7: Mesosphere 2
        T = T_D(7) + K_D(7) * (h - H(7));
    else                   % Layer 8: Mesopause (isothermal, extrapolation)
        T = T_D(8);
    end
    
    % Apply temperature offset
    T = T + tOffset;
    
else
    %% ARRAY OPTIMIZATION - Use interp1 for vectorized efficiency
    % Pre-computed temperature profile as piecewise linear segments
    H_breaks = [0; 11000; 20000; 32000; 47000; 51000; 71000; 84852.04584490575; 100000];
    T_breaks = [288.15; 216.65; 216.65; 228.65; 270.65; 270.65; 214.65; 186.94590831019; 186.94590831019];
    
    % Use interp1 for arrays (better vectorization)
    T = interp1(H_breaks, T_breaks, h, 'linear', 'extrap');
    
    % Apply temperature offset
    T = T + tOffset;
end

end
