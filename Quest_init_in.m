%% Quest Initialization

function [QUEST,stim_dB,T] = Quest_init_in(threshold,T_guess,w_bl,w_min)
%% Variables Setup

% Stimulus vector (normalized)
stim = logspace(-3,0,50); 

% Stimulus vector (dB)
stim_dB = zeros(1,length(stim));

% Correct response probability vector
p = zeros(1,length(stim)); 

% Incorrect response probability vector
np = p;

% JND threshold (dB)
ratio = (w_bl-threshold)/(w_bl-w_min);
T = 20*log10(ratio); 

% Presumed slope of the psychometric curve
beta = 3.5;  

% 2AFC chance level
chance = 0.5;  

% Populating the vectors with the initial weibull presumption
for ii=1:length(stim)
    stim_dB(ii) = 20*log10(stim(ii));
    p(ii) = wblcdf_TEST(stim_dB(ii),T,beta,chance); 
    np(ii) = 1 - p(ii);
end

%% Initial QUEST Setup

% First guess threshold, mean of normal pdf (dB)
mu = 20*log10(T_guess/(w_bl-w_min));

% Standard deviation (dB)
sigma = 5;

% QUEST Parameter
QUEST = normpdf(stim_dB,mu,sigma);
QUEST = QUEST/max(QUEST);
