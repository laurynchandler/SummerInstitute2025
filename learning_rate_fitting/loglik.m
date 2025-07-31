function [ll] = loglik(R, sigma)
%
% log likelihood for my task
%
% R = residuals, sigma = estimate from regress
%

ll = length(R)*log(sum(R.^2)*2*pi)./2;

