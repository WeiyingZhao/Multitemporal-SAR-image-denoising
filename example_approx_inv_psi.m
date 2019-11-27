clear all
close all

addpath('mulog')
addpathrec('.');

siglist = linspace(.01, 60, 1000);
stdlog = @(L) sqrt(psi(1, L));
for k = 1:length(siglist)
    sig = siglist(k);
    ENLn(k) = exp(fminbnd(@(logL) (stdlog(exp(logL)) - sig).^2, log(0.001), log(200000)));

    k2 = sig^2 / 4;
    ENLa(k) = ...
        (1.+3.5232*k2+1.57472*k2.^2+4.8288*10^(-2)*k2.^3) ./ ...
        (-1.705*10^(-5)+4.004*k2+5.9856*k2.^2+8.6208*10^(-1)*k2.^3);
end

fancyfigure;
loglog(siglist, ENLn);
hold on
plot(siglist, ENLa, '--');
legend('Exact', 'Approx');
