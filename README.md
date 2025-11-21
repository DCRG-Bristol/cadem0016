# CADEM0016 Reference Code

Welcome to the example code issued for the University of Bristol unit CADEM0016 (MSc Groupd Design Project) 2026.

In its initial form, this codebase can perform ~class-I conceptual sizing for a B777F-like freighter aircraft.

The script "+scripts/ExampleSizing.m", which can be called in MATLAB as ```scripts.ExampleSizing;```, demonstrates the sizing of a B777F-like aircraft and gives an example of a simple trade study comparing the variation in maximum take-off mass (MTOM) and block fuel mass as a function of wingspan.

## The +B777 namespace

The folder "+B777/" contains a set of classes and functions for conceptual sizing of a B777-like aircraft.

The class ```B777.ADP``` in the primary class and stores all the metadata for a particular instance of the sizing process.

The class ```B777.AeroPolar``` is used to estimate the coefficient of drag at different points in the flight envelope. In its initial form, it uses a constant estimate for CD0 and then uses an empirically corrected version of Prandtl's lifting‑line theory with an Oswald efficiency factor.


The function ```B777.ConstraintAnalysis``` takes an instance of ```B777.ADP``` as input and performs constraint analysis to estimate the aircraft's thrust-to-weight ratio (the ratio of engine thrust to the total weight of the aircraft) and wing loading (the weight of the aircraft divided by the area of the wings). (Note: In the initial version, these values are held constant; it is up to the student to complete the full constraint analysis.)


The function ```B777.MissionAnalysis``` takes an instance of ```B777.ADP``` as an input and conducts Mission Analysis for a mission of a given range and Take-off mass to estimate fuel burn.


The function ```B77.BuildGeometry``` takes an instance of ```B777.ADP``` and returns an array of geometry and mass objects. The namespace ```B777.geom``` contains additional functions which build the geometry objects of sub-components, such as the main wing, fuselage, landing gear, and empenage. The function BuildGeometry calls each of these functions and assembles them into two arrays.  


## The +cast namespace

The "+cast/" namespace contains a series of helper functions and classes to aid in the development of conceptual models.

The class ```cast.eng.Fuel``` standardises quantities of aviation fuel.

The class ```cast.eng.TurboFan``` builds a simplified model of a turbofan engine.

The function ```cast.atmos``` can be used to estimate altitude-dependent properties of the "standard atmospheric model".

The function ```cast.atmosT``` is a simplified version of ```cast.atmos```, and only returns the temperature as a function of altitude.

The class ```cast.GeomObj``` is a standardised way to represent each geometry object in a conceptual model.

The class ```cast.MassObj``` is a standardised way to represent each mass object in a conceptual model.

The function ```cast.draw``` can take an array of ```cast.GeomObj``` and ```cast.MassObj``` objects and can plot them in 2D.

The class ```SI```, ( which is not strictly in the +cast namespace...) is a static class containing constants for conversion between SI and non-SI units.


footnote - the name ```cast``` may seem esoteric. CAST stands for "Conceptual Aeroelastic Sizing Tool" which, admittedly, has little to do with your design task; however, these tools are a simplified version of the tools I have used in my own [research](https://www.researchgate.net/publication/389855530), so some "Easter eggs" may remain from this evolution!


## Notes For Development

As described in the project specification, you are required to develop two conceptual models for quantitative comparison. You can develop the +B777 namespace for your tube-and-wing style model (one that can replicate the B777F), and you can then also develop a new namespace for your second model. If you find there are features that are common between the two models, you might consider adding new functions to the +cast namespace to save on repetition.

Not all of the required disciplines have dedicated locations in the current version of the code (e.g., economic and climate analysis). For the missing disciplines, you should consider the best place to put these models within the code, particularly considering whether the same functions should be common between the two conceptual models.