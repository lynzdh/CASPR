% Script file to show how to use the inverse dynamics simulator
%
% Author        : Darwin LAU
% Created       : 2012
% Description    :

% Clear the variables, command window, and all windows
clc; clear; close all;

% Set up the type of model, trajectory and the set of cables to be used
% Following are some examples (feel free to add more):
% 1) Planar model
% model_config = ModelConfig(ModelConfigType.M_SIMPLE_PLANAR_XY);
% trajectory_id = 'x_simple';
% cable_set_id = 'basic';
% 2) Neck model
% model_config = ModelConfig(ModelConfigType.M_NECK_8S);
% trajectory_id = 'roll';
% cable_set_id = 'opensim_vasavada';
% 3) IPAnema model
model_config = ModelConfig(ModelConfigType.M_IPANEMA_2);
trajectory_id = 'traj_z_up';
cable_set_id = 'default';

% The XML objects from the model config are created
bodies_xmlobj = model_config.getBodiesPropertiesXmlObj();
cableset_xmlobj = model_config.getCableSetXmlObj(cable_set_id);
trajectory_xmlobj = model_config.getTrajectoryXmlObj(trajectory_id);

% Load the SystemKinematicsDynamics object from the XML
dynObj = SystemModel.LoadXmlObj(bodies_xmlobj, cableset_xmlobj);

%id_objective = IDObjectiveMinLinCableForce(ones(dynObj.numCables,1));
%id_solver = IDSolverLinProg(id_objective, ID_LP_SolverType.MATLAB);

id_objective = IDObjectiveMinQuadCableForce(ones(dynObj.numCables,1));
%id_objective = IDObjectiveMinInteractions(ones(6*dynObj.numLinks,1));
id_solver = IDSolverQuadProg(dynObj, id_objective, ID_QP_SolverType.MATLAB);
%id_solver = IDSolverOperationalNullSpace(id_objective, ID_QP_SolverType.MATLAB_ACTIVE_SET_WARM_START, 2*eye(dynObj.numCables));
% for i = 1:dynObj.numLinks
%     id_solver.addConstraint(IDConstraintInteractionForceAngleCone(i, [0;0;-1], 15*pi/180, 16));
% end


% Setup the inverse dynamics simulator with the SystemKinematicsDynamics
% object and the inverse dynamics solver
disp('Start Setup Simulation');
start_tic = tic;
idsim = InverseDynamicsSimulator(dynObj, id_solver);
trajectory = JointTrajectory.LoadXmlObj(trajectory_xmlobj, dynObj);
time_elapsed = toc(start_tic);
fprintf('End Setup Simulation : %f seconds\n', time_elapsed);

% Run the solver on the desired trajectory
disp('Start Running Simulation');
start_tic = tic;
idsim.run(trajectory);
time_elapsed = toc(start_tic);
fprintf('End Running Simulation : %f seconds\n', time_elapsed);

% Display information from the inverse dynamics simulator
fprintf('Optimisation computational time, mean : %f seconds, std dev : %f seconds, total: %f seconds\n', mean(idsim.compTime), std(idsim.compTime), sum(idsim.compTime));

% After running the simulator the data can be plotted
% Refer to the simulator classes to see what can be plotted.

% The neck model has many cables/muscles, so it is possible to plot a
% subset of them only

% % Right muscles
% idsim.PlotCableForces(1:38); xlabel('time [s]'); ylabel('cable forces [N]'); title('Forces (right)');
% % Left muscles
% idsim.PlotCableForces(39:76); xlabel('time [s]'); ylabel('cable forces [N]'); title('Forces (left)');

% Otherwise here is some simple example
disp('Start Plotting Simulation');
start_tic = tic;
%plot_axis = [0 1 0 1 -0.1 0.1];
plot_axis = [-0.2 0.2 -0.2 0.2 -0.1 0.3];
%idsim.plotMovie(plot_axis, [fileparts(mfilename('fullpath')), '\test.avi'], 2, 500, 640);
% idsim.plotJointSpace();
% idsim.plotAngularAcceleration();
% idsim.plotCableLengths();
% idsim.plotBodyCOG();
idsim.plotCableForces([],[]);
time_elapsed = toc(start_tic);
fprintf('End Plotting Simulation : %f seconds\n', time_elapsed);
