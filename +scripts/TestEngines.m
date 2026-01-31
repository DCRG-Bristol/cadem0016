%% TSFC Surface Comparison: TurboProp vs TurboFan
clear; clc;

%% Instantiate engines
tp  = cast.eng.TurboProp.TP400_D6();   % A400M turboprop
tf  = cast.eng.TurboFan.GE90();        % GE90 turbofan

%% Mach and altitude grids
M_vec   = linspace(0.1, 0.95, 40);      % Mach sweep
alt_vec = linspace(0, 40e3 ./ SI.ft, 40); % altitude sweep (SI)

[M_grid, ALT_grid] = meshgrid(M_vec, alt_vec);

%% Preallocate TSFC arrays
TSFC_tp = zeros(size(M_grid));
TSFC_tf = zeros(size(M_grid));

%% Evaluate TSFC across grid
for i = 1:numel(M_grid)
    TSFC_tp(i) = tp.TSFC(M_grid(i), ALT_grid(i));
    TSFC_tf(i) = tf.TSFC(M_grid(i), ALT_grid(i));
end

%% Convert altitude back to ft for plotting
alt_ft = ALT_grid * SI.ft;

%% --- Plot TURBOPROP ---
f = figure(1);
clf;
f.Units = "centimeters";
f.Position = [4,4,35,8];
tiledlayout(1,3);

% --- TURBOPROP ---
ax1 = nexttile(1);
contourf(ax1, M_grid, alt_ft, TSFC_tp, 'EdgeColor','none');
xlabel('Mach number');
ylabel('Altitude [ft]');
title('TurboProp TSFC Surface (TP400-D6)');
colorbar(ax1);
clim(ax1, [0 3e-5]);
colormap(ax1, parula);   % <--- set colormap for tile 1

% --- TURBOFAN ---
ax2 = nexttile(2);
contourf(ax2, M_grid, alt_ft, TSFC_tf, 'EdgeColor','none');
xlabel('Mach number');
ylabel('Altitude [ft]');
title('TurboFan TSFC Surface (GE90)');
colorbar(ax2);
clim(ax2, [0 3e-5]);
colormap(ax2, parula);    % <--- set colormap for tile 2

% --- DELTA ---
ax3 = nexttile(3);
contourf(ax3, M_grid, alt_ft, TSFC_tf - TSFC_tp, 'EdgeColor','none');
xlabel('Mach number');
ylabel('Altitude [ft]');
title('TSFC Difference (Fan - Prop)');
colorbar(ax3);
clim(ax3, [-1e-5 1e-5]);
colormap(ax3, redbluecmap);     % <--- set colormap for tile 3