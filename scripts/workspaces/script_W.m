% Load configs
clc; clear; warning off; %close all;
%% Temporarily add libraries to the current path
path_string = fileparts(mfilename('fullpath'));
path_string = path_string(1:strfind(path_string, 'scripts')-2);
addpath(genpath(path_string));

%% Initialise objects
model_config = ModelConfig(ModelConfigType.M_2R_PLANAR_XZ);
% model_config = ModelConfig(ModelConfigType.M_SIMPLE_SPATIAL);
cable_set_id = 'basic_4_cables';
% cable_set_id = 'basic_7_cables';
bodies_xmlobj = model_config.getBodiesProperiesXmlObj();
cableset_xmlobj = model_config.getCableSetXmlObj(cable_set_id);

%% Initialisation
dynObj = SystemKinematicsDynamics.LoadXmlObj(bodies_xmlobj, cableset_xmlobj);
% Define the workspace condition
% Workspace conditions
% wcondition = WorkspaceStub();
% wcondition  =   WrenchClosure('quad_prog');
% wcondition  =   WorkspaceStatic('quad_prog');
wcondition  =   WorkspaceStatic('capability_measure');
% wcondition  =   WorkspaceStatic('capacity_margin');
% wcondition = Example2Workspace()
%% Define the metric
% metric = NullMetric();
metric = SEACM();
% metric = CapacityMarginMetric();

%% Start the simulation
disp('Start Setup Simulation');
start_tic       =   tic;
wsim            =   WorkspaceSimulator(dynObj,wcondition,metric);
q_step          =   pi/180;
n_dim           =   2;
uGrid           =   UniformGrid(-pi*ones(n_dim,1),(pi-q_step)*ones(n_dim,1),q_step*ones(n_dim,1));
% q_step = 0.01;
% uGrid           =   UniformGrid([0;0;0.1;1;0;0;0],[1;1;0.1;1;0;0;0],[q_step;q_step;0;0;0;0;0]);
% uGrid            =   UniformGrid([0;0;0.8;1;0;0;0],[1;1;1.0;1;0;0;0],[q_step;q_step;q_step;0;0;0;0]);
% uGrid           =   UniformGrid([0;0;0.9;0.999048221581858;0;0;-0.043619387365336],[1;1;0.9;0.999048221581858;0;0;-0.043619387365336],[q_step;q_step;0;0;0;0;0]);

time_elapsed    =   toc(start_tic);
fprintf('End Setup Simulation : %f seconds\n', time_elapsed);

disp('Start Running Simulation');
start_tic       =   tic;
wsim.run(uGrid);
time_elapsed    =   toc(start_tic);
fprintf('End Running Simulation : %f seconds\n', time_elapsed);

disp('Start Plotting Simulation');
start_tic = tic;
wsim.plotWorkspace();
% wsim.plotWorkspaceHigherDimension()
time_elapsed = toc(start_tic);
fprintf('End Plotting Simulation : %f seconds\n', time_elapsed);