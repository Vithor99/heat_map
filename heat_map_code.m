%% housekeeping 
clear all
filePath = "D:\matlab\heat_map";
% sheets:
% short_rates (business)
% inflation (monthly)
% output (monthly)


%% settings 
% short term rates 
range= 21*10;                                                              % Range of y-axis (in business days) i.e. maximum lead/lad distance between EA and US data
rollingWindowSize = 260*2;                                                 %sample over which rolling correlation is estimated (in business days)
varX = 'EA OIS 3M';
varY = 'US SWAPS 3M';

%% uploading data - short term rates 

data = readtable("data.xlsx", "Sheet", "short_rates"); 
data = table2struct(data, 'ToScalar', true); 

% Assuming you have two time series X and Y of equal length
X = data.EA;
Y = data.US;

% Define the range of lags for positive and negative separately
posLags = 0:range; % X with future Y
negLags = -range:0; % X with past Y

% Define

% Initialize the matrix to store rolling correlation coefficients
C = nan(length(negLags) + length(posLags) - 1, length(X) - rollingWindowSize + 1);

% Calculate rolling correlation for each lag and each time point
for i = 1:length(posLags)
    k = posLags(i);
    for j = rollingWindowSize:length(X) - k
        currentX = X(j-rollingWindowSize+1:j);
        futureY = Y(j-rollingWindowSize+1+k:j+k);
        if length(currentX) == rollingWindowSize && length(futureY) == rollingWindowSize
            C(i + length(negLags) - 1, j-rollingWindowSize+1) = corr(currentX, futureY, 'Rows', 'complete');
        end
    end
end

for i = 1:length(negLags)
    k = negLags(i);
    for j = rollingWindowSize-k:length(X)
        currentX = X(j-rollingWindowSize+1:j);
        pastY = Y(j-rollingWindowSize+1+k:j+k);
        if length(currentX) == rollingWindowSize && length(pastY) == rollingWindowSize
            C(i, j-rollingWindowSize+1) = corr(currentX, pastY, 'Rows', 'complete');
        end
    end
end


%invert C to have leading US on top. 
C = flipud(C);

% Define the time vector for the rolling correlation
time = (data.date(rollingWindowSize:end,1))';

% Convert 'time' to a numerical array that 'imagesc' can handle
timeNum = datenum(time);

% Plot the rolling correlation heat map
figure;
h=imagesc(timeNum, [negLags posLags(2:end)], C);
axis xy; % Place the negative lags at the bottom
colorbar; % Show the color scale

% Set NaN values to be transparent
set(h, 'AlphaData', ~isnan(C));

%set title 
%titleStr = sprintf('Rolling Lead-Lag Correlation between %s and %s', varX, varY);
% changing the y axis label 

% Label the axes
xlabel('Time');
ylabel('EA leading / EA lagging');
%title(titleStr);
datetick('x','yyyy','keeplimits');
yticks(linspace(-210, 210, 11)); % This creates a linear space of ticks from -300 to 300
yticklabels({'10', '8', '6', '4','2','0', '-2', '-4', '-6','-8','-10'});


% Get the current figure handle
fig = gcf;

% Undock the figure window
fig.WindowStyle = 'normal';

% Set the figure's size
% Note: The 'Position' vector is [left bottom width height]
fig.Position = [fig.Position(2) fig.Position(1) 350 450];

saveas(fig,fullfile(filePath,string(datetime('today'),"yyyy-MM-dd")+"3M"),'svg');

%% settings 
% short term rates 
range=10;                                                                 % Range of y-axis (in business days) i.e. maximum lead/lad distance between EA and US data
rollingWindowSize = 12*2;                                                   %sample over which rolling correlation is estimated (in business days)
varX = 'EA HICP';
varY = 'US HICP';

%% uploading data - short term rates 

data = readtable("data.xlsx", "Sheet", "inflation"); 
data = table2struct(data, 'ToScalar', true); 

% Assuming you have two time series X and Y of equal length
X = data.EA;
Y = data.US;

% Define the range of lags for positive and negative separately
posLags = 0:range; % X with future Y
negLags = -range:0; % X with past Y

% Define

% Initialize the matrix to store rolling correlation coefficients
C = nan(length(negLags) + length(posLags) - 1, length(X) - rollingWindowSize + 1);

% Calculate rolling correlation for each lag and each time point
% EA leading
for i = 1:length(posLags)
    k = posLags(i);
    for j = rollingWindowSize:length(X) - k
        currentX = X(j-rollingWindowSize+1:j);
        futureY = Y(j-rollingWindowSize+1+k:j+k);
        if length(currentX) == rollingWindowSize && length(futureY) == rollingWindowSize
            C(i + length(negLags) - 1, j-rollingWindowSize+1) = corr(currentX, futureY, 'Rows', 'complete');
        end
    end
end

% US leading
for i = 1:length(negLags)
    k = negLags(i);
    for j = rollingWindowSize-k:length(X)
        currentX = X(j-rollingWindowSize+1:j);
        pastY = Y(j-rollingWindowSize+1+k:j+k);
        if length(currentX) == rollingWindowSize && length(pastY) == rollingWindowSize
            C(i, j-rollingWindowSize+1) = corr(currentX, pastY, 'Rows', 'complete');
        end
    end
end

%invert C to have leading US on top. 
C = flipud(C);

% Annukka modification 
% 

% Define the time vector for the rolling correlation
time = (data.date(rollingWindowSize:end,1))';

% Convert 'time' to a numerical array that 'imagesc' can handle
timeNum = datenum(time);

% Plot the rolling correlation heat map
figure;
h=imagesc(timeNum, [negLags posLags(2:end)], C);
axis xy; % Place the negative lags at the bottom
colorbar; % Show the color scale

% Set NaN values to be transparent
set(h, 'AlphaData', ~isnan(C));

%set title 
%titleStr = sprintf('Rolling Lead-Lag Correlation between %s and %s', varX, varY);

% Label the axes
xlabel('Time');
ylabel('EA leading / EA lagging');
%title(titleStr);
datetick('x','yyyy','keeplimits');
yticklabels({'10', '8', '6', '4','2','0', '-2', '-4', '-6','-8','-10'});

% Get the current figure handle
fig = gcf;

% Undock the figure window
fig.WindowStyle = 'normal';

% Set the figure's size
% Note: The 'Position' vector is [left bottom width height]
fig.Position = [fig.Position(2) fig.Position(1) 350 450];

saveas(fig,fullfile(filePath,string(datetime('today'),"yyyy-MM-dd")+"HICP"),'svg');

%% settings 
% GDP
range=10;                                                                 % Range of y-axis (in business days) i.e. maximum lead/lad distance between EA and US data
rollingWindowSize = 12*2;                                                   %sample over which rolling correlation is estimated (in business days)
varX = 'EA GDP growth';
varY = 'US GDP growth';

%% uploading data - output

data = readtable("data.xlsx", "Sheet", "output2"); 
data = table2struct(data, 'ToScalar', true); 

% Assuming you have two time series X and Y of equal length
X = data.EA;
Y = data.US;

% Define the range of lags for positive and negative separately
posLags = 0:range; % X with future Y
negLags = -range:0; % X with past Y

% Define

% Initialize the matrix to store rolling correlation coefficients
C = nan(length(negLags) + length(posLags) - 1, length(X) - rollingWindowSize + 1);

% Calculate rolling correlation for each lag and each time point
for i = 1:length(posLags)
    k = posLags(i);
    for j = rollingWindowSize:length(X) - k
        currentX = X(j-rollingWindowSize+1:j);
        futureY = Y(j-rollingWindowSize+1+k:j+k);
        if length(currentX) == rollingWindowSize && length(futureY) == rollingWindowSize
            C(i + length(negLags) - 1, j-rollingWindowSize+1) = corr(currentX, futureY, 'Rows', 'complete');
        end
    end
end

for i = 1:length(negLags)
    k = negLags(i);
    for j = rollingWindowSize-k:length(X)
        currentX = X(j-rollingWindowSize+1:j);
        pastY = Y(j-rollingWindowSize+1+k:j+k);
        if length(currentX) == rollingWindowSize && length(pastY) == rollingWindowSize
            C(i, j-rollingWindowSize+1) = corr(currentX, pastY, 'Rows', 'complete');
        end
    end
end


%invert C to have leading US on top. 
C = flipud(C);

% Define the time vector for the rolling correlation
time = (data.date(rollingWindowSize:end,1))';

% Convert 'time' to a numerical array that 'imagesc' can handle
timeNum = datenum(time);

% Plot the rolling correlation heat map
figure;
h=imagesc(timeNum, [negLags posLags(2:end)], C);
axis xy; % Place the negative lags at the bottom
colorbar; % Show the color scale

% Set NaN values to be transparent
set(h, 'AlphaData', ~isnan(C));

%set title 
%titleStr = sprintf('Rolling Lead-Lag Correlation between %s and %s', varX, varY);

% Label the axes
xlabel('Time');
ylabel('EA leading / EA lagging');
%title(titleStr);
datetick('x','yyyy','keeplimits');
yticklabels({'10', '8', '6', '4','2','0', '-2', '-4', '-6','-8','-10'});

% Get the current figure handle
fig = gcf;

% Undock the figure window
fig.WindowStyle = 'normal';

% Set the figure's size
% Note: The 'Position' vector is [left bottom width height]
fig.Position = [fig.Position(2) fig.Position(1) 350 450];

saveas(fig,fullfile(filePath,string(datetime('today'),"yyyy-MM-dd")+"GDP"),'svg');