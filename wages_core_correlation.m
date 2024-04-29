%% housekeeping 
clear all
filePath = "D:\matlab\heat_map";

%% settings 
% short term rates 
range=12;                                                                   %Range of y-axis (in business days) i.e. maximum lead/lad distance between HICP and wage data
rollingWindowSize = 12*4;                                                   %sample over which rolling correlation is estimated (in business days)
varX = 'Core HICP';
varY = 'Comp per employee';

%% uploading data - core HICP and negotiated wages 

data = readtable("data.xlsx", "Sheet", "hicp_neg_wages"); 
data = table2struct(data, 'ToScalar', true); 

% Assuming you have two time series X and Y of equal length
X = data.HICP;
Y = data.WAGES;

% Define the range of lags for positive and negative separately
posLags = 0:range; % X with future Y
negLags = -range:0; % X with past Y

% Define

% Initialize the matrix to store rolling correlation coefficients
C = nan(length(negLags) + length(posLags) - 1, length(X) - rollingWindowSize + 1);

% Calculate rolling correlation for each lag and each time point
% HICP leading
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

% WAGES leading
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

%invert C to have leading WAGES on top. 
C = flipud(C);

% Define the time vector for the rolling correlation
time = (data.date(rollingWindowSize:end,1))';

% Convert 'time' to a numerical array that 'imagesc' can handle
timeNum = datenum(time);

% Plot the rolling correlation heat map
figure;
h=imagesc(timeNum, [negLags posLags(2:end)], C);
colormap(jet);
axis xy; % Place the negative lags at the bottom
colorbar; % Show the color scale

% Set NaN values to be transparent
set(h, 'AlphaData', ~isnan(C));

% Label the axes
xlabel('Time');
ylabel('HICP leading Wages/ Wages leading HICP');
%title(titleStr);
datetick('x','yyyy','keeplimits');
yticks([-range:2:range]);
yticklabels({'12','10', '8', '6', '4','2','0', '-2', '-4', '-6','-8','-10','-12'});

% Get the current figure handle
fig = gcf;

% Undock the figure window
fig.WindowStyle = 'normal';

% Set the figure's size
% Note: The 'Position' vector is [left bottom width height]
%fig.Position = [fig.Position(2) fig.Position(1) 350 450];

saveas(fig,fullfile(filePath,string(datetime('today'),"yyyy-MM-dd")+"wages"),'svg');

