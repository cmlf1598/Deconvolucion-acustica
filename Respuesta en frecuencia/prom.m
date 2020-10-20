n = 3;

load freqVector

m = numel(freqVector);

sumFreqResponse = zeros(m,1);

for i = 1:n
    load("freqResponse" + n);
    sumFreqResponse = sumFreqResponse + freqResponse;
end

promFreqResponse = sumFreqResponse./3;

semilogx(freqVector, promFreqResponse);
xlabel('Frequency (Hz)');
ylabel('Power (dBm)');
title('Audio Device Frequency Response');
