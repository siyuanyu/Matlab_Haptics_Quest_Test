%% MAIN RUN CODE FOR ME495 HAPTICS PSYCHOPHYSICS PROJECT (ASCENDING METHOD)

close all;
clear;
clc;

%% ADJUSTABLE PARAMETERS

% Send trials to TPAD?
send = 1;

% Max and baseline test wavelengths
w1_max = 0.8;
w1_bl = 0.2;

w2_max = 3;
w2_bl = 1.16;

% Just noticeable stimulus guesses (use experimental values from method of limits)
threshold1 = 0.3;
threshold2 = 1.8;

% Threshold guesses (guess more liberally) 
T1_guess = 1.2*(threshold1-w1_bl);
T2_guess = 1.2*(threshold2-w2_bl);

% Stopping condition: max # of trials or tolerance
nmax = 30;
tol1 = 0.005;
tol2 = 0.005;

%% Initial test parameters

% Generating initial QUEST and stimulus vectors
[QUEST1,stim1_dB] = Quest_init_de(threshold1,T1_guess,w1_bl,w1_max);
[QUEST2,stim2_dB] = Quest_init_de(threshold2,T2_guess,w2_bl,w2_max);

% Current trial number for each test
n1 = 1;
n2 = 1;
trial_count = 1;

% Presumed slope of the psychometric curve
beta = 3.5;  

% 2AFC chance level
chance = 0.5;

%% Initializing the results matrices

% QUEST matrix
QUEST1_mat = zeros(nmax,size(QUEST1,2));
QUEST2_mat = QUEST1_mat;

QUEST1_mat(1,:) = QUEST1;
QUEST2_mat(1,:) = QUEST2;

% Test stimulus matrix (dB)
stim1_dB_test_mat = zeros(nmax,1);
stim2_dB_test_mat = zeros(nmax,1);

% Correct response probability matrix
p1_test_mat = zeros(nmax,1);
p2_test_mat = zeros(nmax,1);

% Test response matrix
resp1_mat = zeros(nmax,1);
resp2_mat = zeros(nmax,1);

%% Procedure for Tests 1 and 2

% 1 means active, 0 means complete
status = 1;
flag1 = 1;
flag2 = 1;

% Interweaves tests 1 and 2
while status == 1;
    
% Tests 1 and 2 are both active
    if and(flag1,flag2)
        test = randi([0 1],1);
        % Test 1
        if test == 1
            disp([sprintf('\n'),'(Test 1, Trial ',num2str(n1),')'])
            [stim1_dB_test_mat(n1),p1_test_mat(n1),QUEST1_mat(n1+1,:),resp1_mat(n1)] = Quest_main_de(send,trial_count,n1,threshold1,stim1_dB,QUEST1_mat(n1,:),w1_max,w1_bl);
            n1 = n1+1;
        % Test 2
        else
            disp([sprintf('\n'),'(Test 2, Trial ',num2str(n2),')'])
            [stim2_dB_test_mat(n2),p2_test_mat(n2),QUEST2_mat(n2+1,:),resp2_mat(n2)] = Quest_main_de(send,trial_count,n2,threshold2,stim2_dB,QUEST2_mat(n2,:),w2_max,w2_bl);
            n2 = n2+1;
        end
        
% Only one of the tests is active
    elseif xor(flag1,flag2)
        % Test 1
        if flag2 == 0
            disp([sprintf('\n'),'(Test 1, Trial ',num2str(n1),')'])
            [stim1_dB_test_mat(n1),p1_test_mat(n1),QUEST1_mat(n1+1,:),resp1_mat(n1)] = Quest_main_de(send,trial_count,n1,threshold1,stim1_dB,QUEST1_mat(n1,:),w1_max,w1_bl);
            n1 = n1+1;
        % Test 2
        else
            disp([sprintf('\n'),'(Test 2, Trial ',num2str(n2),')'])
            [stim2_dB_test_mat(n2),p2_test_mat(n2),QUEST2_mat(n2+1,:),resp2_mat(n2)] = Quest_main_de(send,trial_count,n2,threshold2,stim2_dB,QUEST2_mat(n2,:),w2_max,w2_bl);
            n2 = n2+1;
        end
        
% No tests are active
    else
        status = 0;
    end
    
% Test 1 Plots
    if n1 > 1;
        figure(1)
        suptitle(sprintf('TEST 1\n\n'))

        % Wavelength threshold vs trial #
        subplot(3,1,1)
        threshold_vec1 = (w1_max-w1_bl)*10.^(stim1_dB_test_mat(1:n1-1)/20);
        plot(1:n1-1,threshold_vec1)
        axis([1,n1,0,w1_max-w1_bl]);
        title(['JND Wavelength Threshold, (Threshold Est: ',num2str(threshold_vec1(n1-1)),')'])
        xlabel('Trial #')
        ylabel('JND Threshold')
        grid on

        % Psychometric function estimate
        subplot(3,1,2)
        for i=1:length(stim1_dB)
            p1_vec(i) = wblcdf_TEST(stim1_dB(i),stim1_dB_test_mat(n1-1),beta,chance); 
        end

        plot(stim1_dB,p1_vec,stim1_dB,0.75*ones(1,length(stim1_dB)))
        title('Psychometric Curve p(x)')
        xlabel('% Change in Stimulus (dB)')
        ylabel('Probability of Detection')
        grid on

        % Quest function
        subplot(3,1,3)
        plot(stim1_dB,QUEST1_mat(n1-1,:))
        axis([-40,0,0,1]);
        title('QUEST Function')
        xlabel('% Change in Stimulus (dB)')
        ylabel('Probability')
        grid on
    end
    
% Test 2 Plots
    if n2 > 1;
        figure(2)
        suptitle(sprintf('TEST 2\n\n'))

        % Wavelength threshold vs trial #
        subplot(3,1,1)
        threshold_vec2 = (w2_max-w2_bl)*10.^(stim2_dB_test_mat(1:n2-1)/20);
        plot(1:n2-1,threshold_vec2)
        axis([1,n2,0,w2_max-w2_bl]);
        title(['JND Wavelength Threshold, (Threshold Est: ',num2str(threshold_vec2(n2-1)),')'])
        xlabel('Trial #')
        ylabel('JND Threshold')
        grid on

        % Psychometric function estimate
        subplot(3,1,2)
        for i=1:length(stim2_dB)
            p2_vec(i) = wblcdf_TEST(stim2_dB(i),stim2_dB_test_mat(n2-1),beta,chance); 
        end

        plot(stim2_dB,p2_vec,stim2_dB,0.75*ones(1,length(stim2_dB)))
        title('Psychometric Curve p(x)')
        xlabel('% Change in Stimulus (dB)')
        ylabel('Probability of Detection')
        grid on
        
        % Quest function
        subplot(3,1,3)
        plot(stim2_dB,QUEST2_mat(n2-1,:))
        axis([-40,0,0,1]);
        title('QUEST Function')
        xlabel('% Change in Stimulus (dB)')
        ylabel('Probability')
        grid on
    end
    
% Update flags wrt stopping conditions
    if n1 > 10
        if n1 > nmax
            flag1 = 0;
        elseif abs(threshold_vec1(n1-1)-mean(threshold_vec1(n1-5:n1-2))) < tol1
            flag1 = 0;
        end
    end
    
    if n2 > 10
        if n2 > nmax
            flag2 = 0;
        elseif abs(threshold_vec2(n2-1)-mean(threshold_vec2(n2-5:n2-2))) < tol2
            flag2 = 0;
        end
    end
    
% Increase trial count
    trial_count = trial_count + 1;
end       
        
%% Trim matrices to size

% QUEST matrix
QUEST1_mat = QUEST1_mat(1:n1-1,:);
QUEST2_mat = QUEST2_mat(1:n2-1,:);

% Test stimulus matrix (dB)
stim1_dB_test_mat = stim1_dB_test_mat(1:n1-1);
stim2_dB_test_mat = stim2_dB_test_mat(1:n2-1);

% Correct response probability matrix
p1_test_mat = p1_test_mat(1:n1-1);
p2_test_mat = p2_test_mat(1:n2-1);

% Test response matrix
resp1_mat = resp1_mat(1:n1-1);
resp2_mat = resp2_mat(1:n2-1);
        