function [ p ] = wblcdf_TEST( x_dB, T, beta, chance )
%wblcdf_TEST this function is a model of a human response to a psychometric
%test
%   Weibull distribution representing response to a pinch grip task
e = (20/beta)*log10(-log(0.5));  % this factor just ensures that the threshold is halfway from chance to perfect
                                 % thus, when x_dB = T, p = 0.5*chance + 0.5

p = 1 - (1-chance)*exp(-10^(.05*beta*(x_dB - T + e)));

end

