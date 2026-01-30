%% An example script to show you the variation in atmospheric properties with altitude

% Choose altitude range
alts = 0:1000:50e3; %ft
alts = alts ./ SI.ft; % convert to SI

% extract properties
[rho,a,T,P] = cast.atmos(alts);

f = figure(1);
f.Units = "centimeters";
f.Position = [4,4,12,12];
clf;
tiledlayout(2,2);

data = {rho,a,T-273.15,P./1e3};
labels = ["Density [$kg/m^3$]","Speed of Sound [$m/s$]","Temperature [C]","Pressure [kPa]"];

for i = 1:4
    ax = nexttile(i);
    hold on
    ax.FontSize = 10;
    plot(data{i},alts.*SI.FL)
    xlabel(labels(i))
    ylabel('Flight Level')
    grid minor
end