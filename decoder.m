clear; clc; close all;
pix_size=0.001;

recObj = audiorecorder(44100, 16, 2);
recordblocking(recObj, 15);
yyy = getaudiodata(recObj);
wavwrite(yyy,44100,'geri.wav');

disp('fft') %command window da baslik olarak gorunur.

fft_size  =128; %window size       (unit:samples)
hopsize   =16;  %fft window hopsize (unit:samples)    
do_visu   = 1; %create some figures
dB_max=96;    
   
[ wav fs ]=audioread('geri.wav');

wav=wav(:,1);
wavdB = wav * (10^(dB_max/20)); %% rescale to dB max (default is 96dB = 2^16)

 %% Genlik ve faz hesaplamasi
 
 % frame sayisini belirlemek
frames = 0;
idx =fft_size;
while idx <= length(wav), 
    frames = frames + 1; 
    idx = idx + hopsize;
end

fspix=fs*pix_size;
%zeros komutuyla uzunlugunu bildiginiz bir vektor olusturabilirsiniz.
amp=zeros((fft_size/2)+1,frames);

idx = 1:fft_size;
w = hann(fft_size); %hanning pencereleme fonksiyonu 
for i=1:frames 
    X = fft(wavdB(idx).*w,fft_size);%% FFT
    amp(:,i) = abs(X(1:fft_size/2+1)/sum(w)*2).^2;

    idx = idx + hopsize;
end

  
%% Grafikleri cizdirmek

% x ve y eksenlerini belirlemek
   max_freq = fs/2;
   freq_increment = max_freq/(fft_size/2);
   ff=0:freq_increment:max_freq;
   t=1:frames;
   time=linspace(0,length(wav)/fs,length(wav));
if do_visu
    figure; 
    
    hs(1) = subplot(2,1,1); %% audio signal
    plot(time,wav,'k'); axis tight;
    ylabel('Genlik'),xlabel('Zaman(sn)'),title('sinyal')
    
    hs(2) = subplot(2,1,2); %% amplitude
    tmp.amp = amp; tmp.amp(tmp.amp<1)=1; %% for dB 
    imagesc(t,ff,10*log10(tmp.amp));set(gca,'ydir','normal');
    colormap(gray)

    ylabel('Frekans(Hz)'),xlabel('Pencere Say?s?'),title('Genlik')
    
   
end

frekler =10*log10(tmp.amp);

maxlar=zeros(1,frames+20);

[mmm iii]=max(frekler);

for i=1:frames
    maxlar(i)=ff(iii(i));
end
maxlar(frames+1:frames+20)=0;

med1000=[];
for i=1001:1000:frames-1
    med1000=[med1000 median(maxlar(i-1000:i))];
end
med_senk=med1000<3200 & med1000>2800;
med1000_last =find(med_senk, 1, 'last' );

med5=[];
for i=1:5:1999
    med5=[med5 median(maxlar((med1000_last-1)*1000+i:(med1000_last-1)*1000+i+4))];
end
med5_senk=med5<3200 & med5>2800;
med5_last =find(med5_senk, 1, 'last' );

senk=maxlar((med1000_last-1)*1000+(med5_last-1)*5:(med1000_last-1)*1000+(med5_last+1)*5)<3200 & maxlar((med1000_last-1)*1000+(med5_last-1)*5:(med1000_last-1)*1000+(med5_last+1)*5)>2800;
senk_last =find(senk, 1, 'last' )+(med1000_last-1)*1000+(med5_last-1)*5;

so_im = maxlar(senk_last:senk_last+(fspix*(128*128/hopsize)-1));

im = zeros(128,128);
pix_fr=fspix/hopsize;
for i=1:128
    for j=1:128
        im(j,i)=median(so_im((((j+128*(i-1))-1)*pix_fr)+1:(j+128*(i-1))*pix_fr));
    end
end

im=im-6000;
im(im<500)=0;
im(im>499 & im<1500)=36;
im(im>1499 & im<2500)=72;
im(im>2499 & im<3500)=108;
im(im>3499 & im<4500)=144;
im(im>4499 & im<5500)=180;
im(im>5499 & im<6500)=216;
im(im>6499)=255;

im = reshape(im,128,128);
im=uint8(im);
figure;
imagesc(im);
colormap(gray)


