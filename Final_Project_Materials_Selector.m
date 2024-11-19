
%----------------MATERIALS SELECTOR APPLICATION-----------------------------

% This program allows users to compare materials they are considering
% for a project by carrying out the following operations:
%        1) Reads in a data table containing a handful of common metals to
%           help users find input properties. Users have the option to view
%           the table via the command window, i.e "If you wish to view a
%           table of mechanical properties of some common engineering
%           metals, enter DATA in the command window."
%
%        2) Asks user to input the number of metals they want to compare
%           along with 5 commonly known mechanical properties.
%
%        3) Produces a stress-strain plot with graphs of the selected
%           metals.
%
%        4) Generates values for MOR, toughness, and Specific Strength
%           along with comparison charts for each quality.
%
%        5) Delivers a .txt file with a table of all the metals'
%           collected/calculated properties.

clc; clear; close all;

fprintf (['Welcome to CAMP, the Comparison Application for Mechanical Properties! Just enter a few commonly\n' ...
    'available metrics for each metal you want to compare and the program will do the rest.\n\n' ...
    '\t\t\t\t\t---DISCLAIMER---\nThis utility makes rough estimates for the purpose of narrowing down material ' ...
    'selections.\nActual mechanical properties are likely to vary, sometimes significantly!\n\n'])

% Offer to read in a useful data sheet to help the user find input values.

fprintf(['Before we get started, would you like to review a table of mechanical ' ...
    'properties for some\ncommon engineering materials? (yes/no)']);
chart=input(': ','s');
while ~strcmpi(chart,'y') & ~strcmpi(chart,'yes') & ~strcmpi(chart,'n') & ~strcmpi(chart,'no')
    chart=input('Error! Please enter yes or no: ','s');
end

% If the user says yes, read tabulated Excel data in to a new table, give
% the variables purdy names, and display it in all its glory. Otherwise
% the program continues
if strcmpi(chart,'y') | strcmpi(chart,'yes')
    Mechanical_Properties_Table = readtable('Final Metals data.csv');
    Mechanical_Properties_Table.Properties.VariableNames = [{'Material'} {'Density (g/m^3)'} {'Yield Str (MPa)'} ...
        {'Tensile Str (Mpa)'} {'Young''s Mod (GPa)'} {'%EL'} {'Fatigue Str (MPa)'} {'HB'} {'Cost ($/kg)'} ];
    Mechanical_Properties_Table
    Continue=input('Press Enter to continue: ','s'); % Pauses the code until the user enters anything
    clear;   % Gets rid of useless 'chart' and 'continue' variables                                                 
else
    clear;
end

num=[];
fprintf('\n\n');
num=input('How many metals do you wish to compare? Enter up to 10: '); 
while  isempty(num) | num~=round(num) | num > 10 | length(num)>1 |num<=0 
    num=input('Error! Please enter a positive integer between 1 and 10: ');
end

fprintf('Great! You''ll need to enter some common properties.\nNo need to worry about entering units.');

S=1:10;  % Declares a small initial stress vector whose size will be redefined later based on 
         % user inputs, which will make the plot look nice at the end.

% User is now prompted to input the name along with various mechanical properties of each 
% desired metal. The data is stored in a structure to keep things organized. 
for k=1:num
    fprintf('\nMetal #%i: ',k)
    metals(k).name=input('What is the name of the metal? ','s');
    while length(metals(k).name)<1
        metals(k).name=input('Error! What is the name of the metal? ','s');
    end
   
    metals(k).rho=input('Enter the density in g/cm^3: ');
    while isempty(metals(k).rho) | metals(k).rho<=0  
        metals(k).rho=input('Error! Enter a positive value: ');
    end
   
    metals(k).Sy=input('Enter the yield strength in MPa: ');
    while isempty(metals(k).Sy) |metals(k).Sy<=0
        metals(k).Sy=input('Error! Enter a positive value: ');
    end
    
    metals(k).Su=input('Enter the tensile strength in MPa: ');
    while isempty(metals(k).Su) |metals(k).Su<=0
        metals(k).Su=input('Error! Enter a positive value: ');
    end
    
    metals(k).E=input('Enter Young''s Modulus in GPa: ')*1000;
    while isempty(metals(k).E) |metals(k).E<=0
        metals(k).E=input('Error! Enter a positive value: ');
    end
    
    metals(k).ef=input('Enter the % elongation at fracture: ')/100;
    while isempty(metals(k).ef) |metals(k).ef<=0 | metals(k).ef > 100
        metals(k).ef=input('Error! Enter a positive value between 0 and 100: ');
    end
   
    % Call the user-defined s2w to get the specific strength of each metal:
    metals(k).s2w=s2w(metals(k).Su,metals(k).rho);
  
    % Call user-defined ROexp function to get the Ramberg_Osgood exponent n:
    metals(k).n = ROexp(metals(k).ef,metals(k).Su,metals(k).Sy);
   
   
    if metals(k).Su > S                      % As promised, restructures S 
        S=1:.1:ceil(metals(k).Su/100)*110;   % to be slightly bigger than the 
    end                                      % UTS of the strongest metal.

    
end

% Now to find elongation as a function of stress. Call user defined function
% elong, which is a manipulated version of the Ramberg-Osgood equation.
for k=1:num
    EL(k,:)=elong(S,metals(k).E,metals(k).Sy,metals(k).n);
    for m=1:length(S)
        if EL(k,m) >metals(k).ef+.005  % cuts off EL at the fracture point for the
            EL(k,m)=NaN;               % given metal while preserving array dimensions
        end
    end
    
    % Find toughness for all metals:
    metals(k).EL=EL(k,:);                  % Puts elongation-vs-stress value into the struct.
    metals(k).EL(isnan(metals(k).EL))=[];  % Trims the EL to the pertinent length for integrating.
    metals(k).toughness=trapz(metals(k).EL,S(1:length(metals(k).EL))); % Get area under curve!
   
    % Make it easier to plot bar charts for toughness and specific strength.
    stw(k)=metals(k).s2w;
    tough(k)=metals(k).toughness;
    names(k)=string(metals(k).name);
end


if num==1
    plot(EL,S); %Prints the stress/strain curve of the single metal.
    title('Mechanical Properties of',metals.name);
    ylim([0 max(S)]);
    xlabel('Strain (%EL/100)')
    ylabel('Stress (MPa)')
    legend(metals.metal,location="southeast");

elseif num>1
    % Print the stress/strain curve of all metals selected.
    figure(1); 
    plot(EL,S);                                    
    pos1 = get(gcf,'Position');                    % Get position of Figure(1) 
    set(gcf,'Position', pos1 - [pos1(3)/2,0,50,0]) % Shift position and width of Figure(1)
    title('Stress vs. Strain');
    xlabel('Strain (%EL/100)')
    ylabel('Stress (MPa)')
    ylim([0 max(S)]);
    legend(metals.name,location="southeast");

    figure(2);  
    %Compare toughness and specific strength of the metals.
    subplot(2,1,1);          
    bar(tough);
    pos2 = get(gcf,'Position');                      % get position of Figure(2) 
    set(gcf,'Position', pos2 + [pos1(3)/2,0,-800/num,0]) % Shift position, width depends on num for Figure(2)
    set(gca, 'XTickLabel',names, 'XTick',1:numel(names));
    title('Toughness');
    ylabel('Toughness (MPa)')
    ylim([0 max(tough)*1.1]);
    xtickangle(30);

    subplot(2,1,2); 
    bar(stw,'g');
    set(gca, 'XTickLabel',names, 'XTick',1:numel(names));
    title('Strength-to-Weight Ratio');
    ylabel('TS\cdot\rho^{-1} (kN\cdotm/kg)');
    ylim([0 max(stw)*1.1]);
    xtickangle(30);
   
end