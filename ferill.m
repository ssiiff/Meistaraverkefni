clear all
close all

% Define file names
file_names = {'krilli_prog_2015.csv', 'krilli_prog_2016.csv', 'krilli_prog_2017.csv', 'krilli_prog_2018.csv', 'krilli_prog_2019.csv', 'krilli_prog_2020.csv', 'krilli_prog_2021.csv', 'krilli_prog_2022.csv'};
simulated_df_hra = [];
simulated_df = [];

% Define the point of interest
% Initialize the loop variables
middle_easting = 428840;
middle_northing = 459350;
middle_elevation = 1250;

bottom_easting = 429010;
bottom_northing = 459210;
bottom_elevation = 1265;

% Initialize arrays to store the path coordinates
path_easting = [middle_easting];
path_northing = [middle_northing];
path_elevation = [middle_elevation];
path_easting_bottom = [bottom_easting];
path_northing_bottom = [bottom_northing];
path_elevation_bottom = [bottom_elevation];
bed = [1095.5];
surf = [1228]; 


% Set number of iterations to 8
num_iterations = 8;

% Iterate through the file names and update the simulated_df_hra data using a different CSV file for each loop
for i = 1:num_iterations
    
    % Update simulated_df_hra data
    data_table = readtable(file_names{i});
    simulated_df_hra = table2array(data_table);
    easting = simulated_df_hra(:, 29);
    northing = simulated_df_hra(:, 30);
    elevation = simulated_df_hra(:, 31);
    velocity0 = simulated_df_hra(:, 14);
    velocity1 = simulated_df_hra(:, 15);
    velocity2 = simulated_df_hra(:, 16);
    beddem = simulated_df_hra(:,4);
    zsdem = simulated_df_hra(:,5);
    simulated_df = [easting, northing, elevation, velocity0, velocity1, velocity2, beddem, zsdem];
    
    % Find the row in simulated_df that is closest to the current point
    
    distances = sqrt((simulated_df(:,1) - middle_easting).^2 + ...
                     (simulated_df(:,2) - middle_northing).^2 + ...
                     (simulated_df(:,3) - middle_elevation).^2);
    [~, closest_index] = min(distances);
    distances_bottom = sqrt((simulated_df(:,1) - bottom_easting).^2 + ...
                     (simulated_df(:,2) - bottom_northing).^2 + ...
                     (simulated_df(:,3) - bottom_elevation).^2);
    [~, closest_index_bottom] = min(distances_bottom);
    
    % Extract the velocity values at the matching row
        velocity = simulated_df(closest_index, 4:6);
        velocity_bottom = simulated_df(closest_index_bottom, 4:6);

        % Extract the bed and surdem values at the matching row
        bed = [bed, simulated_df(closest_index, 7)];
        surf = [surf, simulated_df(closest_index, 8)];

        % Compute the new point by adding the velocities
        new_latitude = middle_easting + velocity(1);
        new_longitude = middle_northing + velocity(2);
        new_elevation = middle_elevation + velocity(3); 

        new_latitude_bottom = bottom_easting + velocity_bottom(1);
        new_longitude_bottom = bottom_northing + velocity_bottom(2);
        new_elevation_bottom = bottom_elevation + velocity_bottom(3); 

        % Add the new coordinates to the path arrays
        path_easting = [path_easting, new_latitude];
        path_northing = [path_northing, new_longitude];
        path_elevation = [path_elevation, new_elevation];

        path_easting_bottom = [path_easting_bottom, new_latitude_bottom];
        path_northing_bottom = [path_northing_bottom, new_longitude_bottom];
        path_elevation_bottom = [path_elevation_bottom, new_elevation_bottom];
    
        % Print the new point
        fprintf(['Iteration %d: Latitude = %f, Longitude = %f, Elevation = %f\n' ...
        'Velocity0: %f, Velocity1: %f, Velocity2: %f \n'], ...
            i, new_latitude, new_longitude, new_elevation, velocity(1), velocity(2), velocity(3));
    
        % Update the loop variables
        middle_easting = new_latitude;
        middle_northing = new_longitude;
        middle_elevation = new_elevation;

        bottom_easting = new_latitude_bottom;
        bottom_northing = new_longitude_bottom;
        bottom_elevation = new_elevation_bottom;

end

%Vista upplýsingar um path
path = [path_easting, path_northing, path_elevation];
path_reshape = reshape(path, [length(path)/3,3]);
writematrix(path_reshape, 'Path_A105_Qplus_massbalance_8ar.txt', 'Delimiter','tab')

path_bottom = [path_easting_bottom, path_northing_bottom, path_elevation_bottom];
path_reshape = reshape(path_bottom, [length(path_bottom)/3,3]);
writematrix(path_reshape, 'Path_A105_Qplus_massbalance_8ar_bottom.txt', 'Delimiter','tab')
