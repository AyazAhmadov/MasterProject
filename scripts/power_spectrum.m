function [P, f, Fs] = power_spectrum(signal, t, options)
% POWER_SPECTRUM    Calculates the power spectrum of the `signal`
%
% [P, f] = POWER_SPECTRUM(signal, t) Calculates the power spectrum of
% `signal` with the sampling frequency calculated from time `t`
%
% [P, f, Fs] = POWER_SPECTRUM(signal, t) Also returns the calculted
% sampling frequency `Fs`
%
% __ = POWER_SPECTRUM(__, __, 'dBScale', true) Returns the power spectrum
% `P` in the dB scale
    arguments
        signal
        t
        options.dBScale = false
    end
    L = length(t);
    fs = 1/seconds(mean(diff(t)));

    Y = fft(signal)/L;

    f = fs/L*(-L/2:L/2-1);
    P = fftshift(Y);
    if options.dBScale
        P = 20*log10(abs(P));
    else
        P = abs(P).^2;
    end

    idx = (f >= 0);
    f = f(idx);
    P = P(idx);

    if nargout == 3
        Fs = fs;
    end
end