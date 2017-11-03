
function [stim_dB_test,p_test,QUEST,resp] = Quest_main_in(send,trial_count,trial_num,threshold,stim_dB,QUEST,w_min,w_bl)
%% Main Code

% Initial-------------------------------------------------------

% JND threshold (dB)
T = 20*log10(threshold); 

% Presumed slope of the psychometric curve
beta = 3.5;  

% 2AFC chance level
chance = 0.5;

% Trial 1--------------------------------------------------------
if trial_num == 1
    
    % Start with a large stimulus relative to the baseline
    percent_diff = 0.8;
    stim_test = -percent_diff*(w_bl-w_min)+w_bl;
    stim_dB_test = 20*log10(percent_diff);

    % First test begins here...

    % Send trial 1 to tablet
    if send == 1
        sendstatus = 0;
        while sendstatus == 0
            sendstatus = sendTrial([stim_test w_bl 0 0 trial_count]);
        end
    end
    
    disp(['Test:',num2str(stim_test)])
    disp(['Base:',num2str(w_bl)])

    % Compute the probability of a correct response
    p_test = wblcdf_TEST(stim_dB_test,T,beta,chance);

    % Ask subject for response
    prompt = sprintf('Do you notice a difference between A and B (1=yes, 2=no)?\n');
    str = input(prompt,'s');

    % Response is "yes"
    if str == '1'
        for ii=1:length(stim_dB)
            % Take into account current and previous trials
            QUEST(ii) = QUEST(ii).*wblcdf_TEST(-stim_dB(ii),-stim_dB_test,beta,chance);
        end

    % Response is "no"
    else
        for ii=1:length(stim_dB)
            % Take into account current and previous trials
            QUEST(ii) = QUEST(ii).*( 1- wblcdf_TEST(-stim_dB(ii),-stim_dB_test,beta,chance));
        end
    end

    % Normalize QUEST
    QUEST = QUEST/max(QUEST);
    
% Other Trials--------------------------------------------------------
else
    % Find the max of the QUEST function
    [~,max_index] = max(QUEST);
    
    % Use the stimulus value corresponding to the max of QUEST for the next test
    stim_dB_test = stim_dB(max_index);

    stim_test = -(10^(stim_dB_test/20))*(w_bl-w_min)+w_bl;
    
    % Send trial 1 to tablet
    if send == 1
        sendstatus = 0;
        while sendstatus == 0
            sendstatus = sendTrial([stim_test w_bl 0 0 trial_count]);
        end
    end
    
    disp(['Test:',num2str(stim_test)])
    disp(['Base:',num2str(w_bl)])
    
    % Compute the probability of a correct response
    p_test = wblcdf_TEST(stim_dB_test,T,beta,chance);
    
    % Ask subject for response
    prompt = sprintf('Do you notice a difference between A and B (1=yes, 2=no)?\n');

    str = input(prompt,'s');
    
    % Response is "yes"
    if str == '1'
        for ii=1:length(stim_dB)
            % Take into account current and previous trials
            QUEST(ii) = QUEST(ii).*wblcdf_TEST(-stim_dB(ii),-stim_dB_test,beta,chance);
        end

    % Response is "no"
    else
        for ii=1:length(stim_dB)
            % Take into account current and previous trials
            QUEST(ii) = QUEST(ii).*(1-wblcdf_TEST(-stim_dB(ii),-stim_dB_test,beta,chance));
        end
    end
    
    % Normalize QUEST
    QUEST = QUEST/max(QUEST);

end

%% Populate output

if str == '1'
    resp = 1;
else
    resp = 0;
end


