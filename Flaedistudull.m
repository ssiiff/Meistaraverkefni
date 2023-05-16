close all
clear all

% Import data
measured_df_hra = importdata('L09-L11Hradi-minus4-utlagar.csv');
latitude = measured_df_hra.data(:, 12);
longitude = measured_df_hra.data(:, 13);
velocity = measured_df_hra.data(:, 5);
measured_df = [latitude, longitude, velocity];

% List of file names
file_names = {
    "krillajokull_noslip_250m_20layers_A24_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A38_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A55_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A93_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A100_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A105_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A110_Q60til115.csv"
    "krillajokull_noslip_250m_20layers_A150_Q60til115.csv"
};
A =[24,38,55,93,100,105,110,150];

% open output file for writing
fid = fopen('A_RMSE_PEARSON_Q60til115.txt', 'w');
fprintf(fid, 'A RMSE    Pearson\n');

% Loop over each file
for i = 1:length(file_names)
    % Import data
    simulated_df_hra = importdata(file_names{i});
    latitude = simulated_df_hra.data(:, 27);
    longitude = simulated_df_hra.data(:, 28);
    velocity0 = simulated_df_hra.data(:, 12);
    velocity1 = simulated_df_hra.data(:, 13);
    velocity2 = simulated_df_hra.data(:, 14);
    velocity = [velocity0, velocity1, velocity2];
    velocity_magnitude = sqrt(sum(velocity(:,2:end).^2, 2));
    simulated_df = [latitude, longitude, velocity_magnitude];

    % Create a Delaunay triangulation from the points.
    dt_simulated = delaunayTriangulation(simulated_df);

    %find the index of its corresponding nearest neighbor in yfirb using the dsearchn function.
    xi_simulated = dsearchn(simulated_df, measured_df);

    % Remove any zero indices from xi_simulated
    xi_simulated = xi_simulated(xi_simulated ~= 0);

    %Add the query points to the plot and add line segments joining the query points to their nearest neighbors.
    %Hér búum við til fylki með öllum þeim yfirborðspunktum sem eru næstu
    %nágrannar ganganna
    xnn_simulated = simulated_df(xi_simulated,:);

    %Fylki sem inniheldur upplýsingar um hvern punkt í
    %göngunum og hvern botn/yfirborðspunkt sem tengist þeim.
    nagrannar = [measured_df_hra.data(:,2), measured_df, xnn_simulated];

    % Load the data
    column_4 = nagrannar(:, 4);
    column_7 = nagrannar(:, 7);

    % Root mean square error (RMSE) analysis
    RMSE = sqrt(mean((column_4 - column_7).^2));
    disp(['RMSE = ' num2str(RMSE)]);

    % Pearson correlation coefficient
    corr_coef = corrcoef(column_4, column_7);
    disp(['Pearson correlation coefficient = ' num2str(corr_coef(1, 2))]);
    
    % write data to output file
    fprintf(fid, '%d', A(i));
    fprintf(fid, '\t%f', RMSE);
    fprintf(fid, '\t%f\n', corr_coef(1, 2));
end

% close output file
fclose(fid);


RMSE_PEARSON_DATA = importdata("A_RMSE_PEARSON_Q60til115.txt");
A_plot = RMSE_PEARSON_DATA.data(:,1);
RMSE_plot = RMSE_PEARSON_DATA.data(:,2);
Pearson_plot = RMSE_PEARSON_DATA.data(:,3);

% Royal Blue
royal_blue = [0, 0.4470, 0.7410];

% Crimson Red
crimson_red = [0.8500, 0.3250, 0.0980];

figure;
plot(A_plot, RMSE_plot,'o', 'Color',royal_blue, 'LineWidth',2 );
hold on
plot(A_plot, Pearson_plot, 'o', 'Color',crimson_red, 'LineWidth',2);
xlabel('A_0 (10^{-25} s^{-1} Pa^{-3})')
legend('RMSE', 'Pearson Correlation Coefficient')
