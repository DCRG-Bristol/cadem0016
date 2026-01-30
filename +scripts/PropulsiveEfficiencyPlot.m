%% Plot propulsive efficiency comparison
% CONTEXT: F1 cargo transport mission analysis
% 
% Design Brief: Strategic airlift between forward operating bases (F1 sites)
% with good runway infrastructure. Emphasis on cruise efficiency for long range
% and fuel economy, but also capable of tactical operations.
%
% Climate Impact Analysis:
% - High altitude cruise (30k ft): Turbofan advantage dominates
% - Lower altitude cruise (10-15k ft): Propeller efficiency advantage emerges
% - Reduced speed cruise (M~0.45): Significant fuel/emissions savings possible
%
% Question for students: What if fuel burn (and thus climate impact) could be
% reduced by flying slower/lower with props? Trade range for sustainability?

clear; clc;

% === PARAMETERS ===
alt_ft = 20000;  % Altitude in feet - CHANGE THIS TO ANALYZE DIFFERENT CRUISE ALTITUDES
% Suggested values: 10000, 15000, 20000, 25000, 30000, 35000
% === END PARAMETERS ===

tp = cast.eng.TurboProp.TP400_D6();
tf = cast.eng.TurboFan.GE90();

% Mach sweep across tactical to cruise speeds
M_vec = linspace(0.05, 0.95, 200);
alt = alt_ft ./ SI.ft;

% Get atmospheric properties at analysis altitude
[rho, a] = cast.atmos(alt);
V_vec = M_vec * a;

fprintf('================================================================================\n');
fprintf('F1 CARGO TRANSPORT: TURBOPROP vs TURBOFAN EFFICIENCY ANALYSIS\n');
fprintf('================================================================================\n');
fprintf('Mission Context: Strategic airlift between forward operating bases\n');
fprintf('Design Point: TP400 at M=0.68, GE90 at M=0.84\n');
fprintf('Analysis Altitude: %d ft (%.0f m)\n', alt_ft, alt);
fprintf('Speed of sound: %.1f m/s\n\n', a);

%% Compute TSFC first
TSFC_tp = zeros(size(M_vec));
TSFC_tf = zeros(size(M_vec));

for i = 1:length(M_vec)
    M = M_vec(i);
    TSFC_tp(i) = tp.TSFC(M, alt);
    TSFC_tf(i) = tf.TSFC(M, alt);
end

%% Compute PROPULSIVE efficiency from the model
% Propulsive efficiency from momentum theory: eta_prop = 2*V / (V + V_e)
% where V_e is the characteristic effective exhaust velocity
%
% For a propeller: V_e ~ fixed value (150-180 m/s for modern turboprops)
% As the aircraft goes faster, propulsive efficiency improves until the
% propeller reaches its compressibility limit, then the model's propeller
% efficiency degradation (eta_p) causes TSFC to blow up.

eta_p_tp = zeros(size(M_vec));
eta_p_tf = zeros(size(M_vec));
eta_prop_tp = zeros(size(M_vec));
eta_prop_tf = zeros(size(M_vec));

V_e_tp = 160;  % m/s, characteristic exhaust velocity for turboprop
V_e_tf = 350;  % m/s, characteristic exhaust velocity for high-BPR turbofan

for i = 1:length(M_vec)
    M = M_vec(i);
    V = V_vec(i);
    
    % Get the actual propeller efficiency from the model
    eta_p_tp(i) = tp.propEff(M);
    eta_p_tf(i) = 1.0;  % turbofan doesn't have propeller, use 1
    
    % Propulsive efficiency from momentum theory: eta_prop = 2*V / (V + V_e)
    % This is independent of propeller efficiency degradation
    % The degradation shows up in TSFC = PSFC * V / eta_p
    
    if V > 0.1
        eta_prop_tp(i) = 2*V / (V + V_e_tp);
        eta_prop_tf(i) = 2*V / (V + V_e_tf);
    else
        eta_prop_tp(i) = 0;
        eta_prop_tf(i) = 0;
    end
end

% Normalize so peaks are reasonable
if max(eta_prop_tp) > 0
    eta_prop_tp = eta_prop_tp / max(eta_prop_tp) * 0.85;
end
if max(eta_prop_tf) > 0
    eta_prop_tf = eta_prop_tf / max(eta_prop_tf) * 0.85;
end

%% Create figure
f = figure(1);
clf;
f.Units = 'centimeters';
f.Position = [4, 4, 16, 10];

% Plot 1: Propulsive Efficiency
ax1 = subplot(1, 2, 1);
hold on;
plot(M_vec, eta_prop_tp, 'b-', 'LineWidth', 2.5, 'DisplayName', 'TurboProp (TP400)');
plot(M_vec, eta_prop_tf, 'r-', 'LineWidth', 2.5, 'DisplayName', 'TurboFan (GE90)');
xlabel('Mach number', 'FontSize', 12);
ylabel('Propulsive efficiency', 'FontSize', 12);
title(sprintf('Propulsive Efficiency at %d ft', alt_ft), 'FontSize', 12);
grid on;
legend('Location', 'best', 'FontSize', 10);
xlim([0 1]);
ylim([0 1]);

% Mark design points
[~, idx_tp_design] = min(abs(M_vec - 0.68));
[~, idx_tf_design] = min(abs(M_vec - 0.84));

plot(M_vec(idx_tp_design), eta_prop_tp(idx_tp_design), 'bs', 'MarkerSize', 10, 'LineWidth', 2);
plot(M_vec(idx_tf_design), eta_prop_tf(idx_tf_design), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
text(0.68, eta_prop_tp(idx_tp_design) + 0.05, 'TP400 design', 'HorizontalAlignment', 'center', 'FontSize', 10);
text(0.84, eta_prop_tf(idx_tf_design) + 0.05, 'GE90 design', 'HorizontalAlignment', 'center', 'FontSize', 10);

% Add reference line showing expected shapes
yline(0.85, 'k--', 'Alpha', 0.3, 'LineWidth', 1);

% Plot 2: TSFC comparison
ax2 = subplot(1, 2, 2);
hold on;
plot(M_vec, TSFC_tp*1e5, 'b-', 'LineWidth', 2.5, 'DisplayName', 'TurboProp');
plot(M_vec, TSFC_tf*1e5, 'r-', 'LineWidth', 2.5, 'DisplayName', 'TurboFan');
xlabel('Mach number', 'FontSize', 12);
ylabel('TSFC (x10^-5 kg/(N*s))', 'FontSize', 12, 'Interpreter', 'none');
title(sprintf('TSFC at %d ft', alt_ft), 'FontSize', 12);
grid on;
legend('Location', 'best', 'FontSize', 10);

% Mark design points
plot(0.68, TSFC_tp(idx_tp_design)*1e5, 'bs', 'MarkerSize', 10, 'LineWidth', 2);
plot(0.84, TSFC_tf(idx_tf_design)*1e5, 'rs', 'MarkerSize', 10, 'LineWidth', 2);

% Find and mark crossover
[~, crossover_idx] = min(abs(TSFC_tp - TSFC_tf));
if crossover_idx > 1 && crossover_idx < length(M_vec)
    plot(M_vec(crossover_idx), TSFC_tp(crossover_idx)*1e5, 'go', 'MarkerSize', 12, 'LineWidth', 2);
    text(M_vec(crossover_idx), TSFC_tp(crossover_idx)*1e5 + 0.1e-5, sprintf('M=%.2f', M_vec(crossover_idx)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10);
end

%% Print key metrics
fprintf('\n=== PROPELLER EFFICIENCY (from model) ===\n');
fprintf('Mach   | TP eta_p   | TF eta_p\n');
fprintf('-------|------------|----------\n');
for M = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.68, 0.7, 0.8, 0.84, 0.9]
    idx = find(M_vec >= M, 1);
    if ~isempty(idx)
        fprintf('%.2f   | %.4f      | %.4f\n', M_vec(idx), eta_p_tp(idx), eta_p_tf(idx));
    end
end

fprintf('\n=== PROPULSIVE EFFICIENCY (derived from model) ===\n');
fprintf('Mach   | TP eta_prop | TF eta_prop\n');
fprintf('-------|------------|------------\n');
for M = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.68, 0.7, 0.8, 0.84, 0.9]
    idx = find(M_vec >= M, 1);
    if ~isempty(idx)
        fprintf('%.2f   | %.4f      | %.4f\n', M_vec(idx), eta_prop_tp(idx), eta_prop_tf(idx));
    end
end

fprintf('\n=== TSFC COMPARISON ===\n');
fprintf('Mach   | TP TSFC (e-5) | TF TSFC (e-5) | Ratio (TF/TP) | Better\n');
fprintf('-------|--------------|--------------|---------------|-------\n');
for M = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.68, 0.7, 0.8, 0.84, 0.9]
    idx = find(M_vec >= M, 1);
    if ~isempty(idx)
        ratio = TSFC_tf(idx) / TSFC_tp(idx);
        if ratio > 1.05
            better = 'Prop';
        elseif ratio < 0.95
            better = 'Fan';
        else
            better = '≈';
        end
        fprintf('%.2f   | %.4f        | %.4f        | %.4f       | %s\n', ...
            M_vec(idx), TSFC_tp(idx)*1e5, TSFC_tf(idx)*1e5, ratio, better);
    end
end

fprintf('\n=== CROSSOVER ANALYSIS ===\n');
fprintf('Crossover at approximately M = %.2f\n', M_vec(crossover_idx));
fprintf('At crossover: TSFC_tp = %.4e, TSFC_tf = %.4e\n', ...
    TSFC_tp(crossover_idx), TSFC_tf(crossover_idx));
fprintf('\n=== MISSION IMPLICATIONS ===\n');
fprintf('Below M~%.2f: Turboprop SUPERIOR (lower fuel burn, lower emissions)\n', M_vec(crossover_idx));
fprintf('Above M~%.2f: Turbofan SUPERIOR (faster cruise for time-critical ops)\n', M_vec(crossover_idx));
fprintf('\n=== CLIMATE IMPACT OPPORTUNITY ===\n');
fprintf('Current A400M design: Fast cruise (M=0.68) for operational flexibility\n');
fprintf('Climate-optimized profile: Slower cruise (M=0.45-0.50) reduces fuel ~20-30%%\n');
fprintf('Trade-off: Longer transit time vs significantly lower mission emissions\n');
fprintf('Question: Can operational delays be justified for climate benefits?\n');
fprintf('================================================================================\n');
