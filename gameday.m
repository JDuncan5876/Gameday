function gameday                                                            % primary function

global Hfig;                                                                % global variable declaration
global imPos;
global icon;
global backgroundImage;
global backRows; global backCols;
global timeKeeper; global time;
global previous;
global prevPos;
global tailgatePositions;
global gtTailgate; global ugaTailgate;
global gtTailgates; global ugaTailgates;
global hype; global hunger; global money;
global inGTgate; global inSicGate;
global isDining; global isEating; global inDodd;
global hypeBar; global hungerBar;

hype = 100; hunger = 100; money = 20;                                       % global variable initialization
inGTgate = false; inSicGate = false;
isDining = false; isEating = false; inDodd = false;

hypeBar = uint8(ones(20,20,3));
hypeBar(:,:,1) = 255;
hypeBar(:,:,2) = 255;
hypeBar(:,:,3) = 0;

hungerBar = uint8(ones(20,20,3));
hungerBar(:,:,1) = 0;
hungerBar(:,:,2) = 0;
hungerBar(:,:,3) = 255;

time = 0;                                                                   % time variable initialization
timeKeeper = timer('TimerFcn', @timerExecute, ...                           % timer variable: every 1 second call is made to timerExecute
                    'ExecutionMode', 'fixedRate', ...  
                    'Name', 'timeKeeper', ...
                    'Period', 1);
start(timeKeeper);

tailgatePositions = [320 355 425 650 650 290 355 680 870 915 935 975 805 860 720 745 865  965  820  900  805  855  675 770  1075 1215 1260 1205 1125 1330 1395 1390 1500 1135 1265 1325 1495;...
                     455 490 460 800 825 675 420 475 560 615 675 745 725 775 690 855 1015 1075 1055 1440 1430 1225 380 1415 1270 1335 1400 915  920  1380 1410 1515 1460 765  705  400  375];
gtTailgates = [];
ugaTailgates = [];
                 
gtTailgate = imread('GTTailgate.jpg');

ugaTailgate = imread('GATailgate.jpg');

icon = imread('buzz.jpg');                                                  % read in images, get sizes
backgroundImage = imread('map(resized).png');
[backRows, backCols, ~] = size(backgroundImage);

[rows, cols, ~] = size(icon);
rowVals = round(linspace(1, rows, 20));                                     % resize icon
colVals = round(linspace(1, cols, 20));
icon = icon(rowVals, colVals, :);
imPos = [225, 310];
prevPos = imPos;

window = backgroundImage(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, :);  % get window
rowVals = round(linspace(1, 120, 400));                                     % resize window
colVals = round(linspace(1, 180, 600));
image = window(rowVals, colVals, :);

image(191:210, 291:310, :) = icon;                                          % superimpose icon
rowVals = round(linspace(1, backRows, 100 * backRows / backCols));
colVals = round(linspace(1, backCols, 100));
image(396-length(rowVals):395, 5:4+length(colVals), :) = ...
        backgroundImage(rowVals, colVals, :);

Hfig = figure('Position', [150,150,backCols, backRows], 'Resize', 'off',... % initialize figure: call to execute made with each key press
                'Menubar', 'None', 'KeyPressFcn', @keystrokeExecute,...
                'DeleteFcn', @deletionExecute);

image = barmaker(image, hype, [300, 570], hypeBar, 20);                     % place status bars on image
image = barmaker(image, hunger, [300, 540], hungerBar, 20);
imshow(image);
previous = image;

end

function timerExecute(~, ~)                                                 % runs once per second as timeKeeper's TimerFcn

global Hfig;
global time;
global tailgatePositions;
global gtTailgate; global ugaTailgate;
global backgroundImage;
global gtTailgates; global ugaTailgates;
global hype; global hunger; global money;
global inGTgate; global inSicGate;
global isDining; global isEating; global inDodd;

time = time + 1;                                                            % increments time variable

[~, tailgatesLeft] = size(tailgatePositions);                               % places a randomly chosen tailgate of a randomly chosen team
if mod(time, 3) == 0 && tailgatesLeft > 0                                   % once every 3 seconds
    ind = ceil(rand * tailgatesLeft);
    pos = tailgatePositions(:,ind);
    tailgatePositions(:,ind) = [];
    
    if rand < 0.5
        tailgate = gtTailgate;
        gtTailgates(1:2, end+1) = pos;
    else
        tailgate = ugaTailgate;
        ugaTailgates(1:2, end+1) = pos;
    end
    
    backgroundImage(pos(1):pos(1)+19, pos(2):pos(2)+19, :) = tailgate;
end

if inGTgate && ~inSicGate && hype <= 195                                    % changes hype status based on character placement with respect to tailgates
    hype = hype + 5;
elseif inSicGate && ~inGTgate && hype >= 25
    hype = hype - 25;
elseif ~inGTgate && ~inSicGate && hype > 0
    hype = hype - 1;
end

if isDining && hunger <= 190                                                % changes hunger status based on character placement with respect to
    hunger = hunger + 10;                                                   % the dining halls and/or the student center (which costs money)
elseif isEating && hunger <= 185 && money > 0
    hunger = hunger + 15;
    money = money - 3;
elseif hunger > 0
    hunger = hunger - 1;
end

disp(300 - time);                                                           % display time left to command window

if hype == 0                                                                % end case 1: hype runs out
    delete(Hfig);
    disp('Uh oh! It looks like you lost your hype!');
elseif hunger == 0                                                          % end case 2: hunger runs out
    delete(Hfig);
    disp('Uh oh! You got too hungry and had to go to Cookout instead of going to the game.');
elseif time >= 300 && ~inDodd                                               % end case 3: time runs out
    delete(Hfig);
    disp('Uh oh! You missed the game!');
elseif time >= 270 && inDodd                                                % end case 4: you win!
    score = hype + hunger + money*10;
    message = sprintf('Congratulations! Your final score is %d.', score);
    disp(message);
    delete(Hfig);
end

end

function keystrokeExecute(~, ~)                                             % executes with each key press

global Hfig;                                                                % access global variables
global imPos;
global icon;
global backgroundImage;
global backRows; global backCols;
global previous;
global prevPos;
global gtTailgates; global ugaTailgates;
global inGTgate; global inSicGate;
global isDining; global isEating; global inDodd;
global hype; global hunger;
global hypeBar; global hungerBar;

keystroke = get(Hfig, 'CurrentCharacter');                                  % read keystroke
switch keystroke                                                            % make move, accounting for edges
    case {'w', char(30)}
        if imPos(1) > 5
            imPos(1) = imPos(1) - 5;
        end
    case {'a', char(28)}
        if imPos(2) > 5
            imPos(2) = imPos(2) - 5;
        end
    case {'s', char(31)}
        if imPos(1) < backRows - 125
            imPos(1) = imPos(1) + 5;
        end
    case {'d', char(29)}
        if imPos(2) < backCols - 185
            imPos(2) = imPos(2) + 5;
        end
end

window = backgroundImage(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, :);  % get window
rowVals = round(linspace(1, 120, 400));                                     % resize window
colVals = round(linspace(1, 180, 600));
img = window(rowVals, colVals, :);

iconPlace = img(191:210, 291:310, :);                                       % take location of icon in supposed next move                                       
wallMask = iconPlace(:,:,1) < 40 & iconPlace(:,:,1) > 30 ...                % determine if that place is on top of a wall
            & iconPlace(:,:,2) < 40 & iconPlace(:,:,2) > 30 ...
            & iconPlace(:,:,3) < 40 & iconPlace(:,:,3) > 30;
        
diningMask = iconPlace(:,:,1) <= 5 & iconPlace(:,:,2) <= 5 ...              % determine if that place is on top of a dining hall
            & iconPlace(:,:,3) >= 250;
isDining = length(find(diningMask)) >= 20;
        
scMask = iconPlace(:,:,1) <= 5 & iconPlace(:,:,2) >= 250 ...                % determine if that place is on top of the student center
            & iconPlace(:,:,3) >= 250;
isEating = length(find(scMask)) >= 100;
        
doddMask = iconPlace(:,:,1) <= 5 & iconPlace(:,:,2) >= 250 ...              % determine if that place is on top of Bobby Dodd
            & iconPlace(:,:,3) <= 5;
inDodd = length(find(doddMask)) >= 100;

img = barmaker(img, hype, [300, 570], hypeBar, 20);                         % update screen with status bars
img = barmaker(img, hunger, [300, 540], hungerBar, 20);
        
if length(find(wallMask)) > 10                                              % reset to previous frame if you hit a wall
    img = previous;
    imPos = prevPos;
else
    img(191:210, 291:310, :) = icon;                                        % superimpose icon
    
    backIm = backgroundImage;                                               % put map in bottom left corner with blue square where window is
    backIm(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, 1) = ...
        backIm(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, 1) - 100;
    backIm(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, 2) = ...
        backIm(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, 2) - 100;
    backIm(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, 3) = ...
        backIm(imPos(1):imPos(1)+119, imPos(2):imPos(2)+179, 3) + 100;
    
    rowVals = round(linspace(1, backRows, 100 * backRows / backCols));
    colVals = round(linspace(1, backCols, 100));
    img(396-length(rowVals):395, 5:4+length(colVals), :) = ...
            backIm(rowVals, colVals, :);
end

if ~isempty(gtTailgates)                                                    % figure out if you're inside a tailgate
    inGTgate = any(imPos(1) + 57 > gtTailgates(1,:) - 20 & imPos(1) + 57 < gtTailgates(1,:) + 40 ...
                    & imPos(2) + 87 > gtTailgates(2,:) - 20 & imPos(2) + 87 < gtTailgates(2,:) + 40);
end
if ~isempty(ugaTailgates)
    inSicGate = any(imPos(1) + 57 > ugaTailgates(1,:) - 20 & imPos(1) + 57 < ugaTailgates(1,:) + 40 ...
                    & imPos(2) + 87 > ugaTailgates(2,:) - 20 & imPos(2) + 87 < ugaTailgates(2,:) + 40);
end

imshow(img);
previous = img;
prevPos = imPos;

end

function deletionExecute(~, ~)                                              % delete timer on deletion of figure

global timeKeeper;
stop(timeKeeper);
delete(timeKeeper);

end

function [newimage] = barmaker(image,score,position,barIm,width)            % barmaker function for status bars

newimage = double(image);
[rows,~,~] = size(barIm);

rowVals = round(linspace(1,rows,score));

barIm = barIm(rowVals,:,:);

r = position(1);
c = position(2);


newimage(r-score+1:r,c:c+width-1,:) = barIm;
newimage = uint8(newimage);


end