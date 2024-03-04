
clear;
clc;
close all



fs =240; % sampling rate signal is 240 hz
length_tr = 600/1000;% 600 ms is length of each trails
Ltr = length_tr *fs; % 144 samples for each trails
%% filter bandpass 0.5-20hz for smoothing signal 
fl=0.5;
fh=30;
% a =1 , in FIR filter a is 1
b=fir1(10, [fl fh]/(fs/2) ,'bandpass');

%% downsampling for reduce dimension of feature vector
fd= 2*fh;
[p,q]= rat(fd/fs);

%%
c1=0;
c2=0;

for run=1:5
    filename=['data\AAS010R0',num2str(run),'.mat'];
    load(filename);
    for i = 1:max(trialnr)

        index = find(trialnr == i);
        temp_pos = index(1);
        position = temp_pos :temp_pos + Ltr -1 ;
        X = signal(position,:);
        %%
        X= filtfilt(b,1,X);% apply bandpass filter
        %%
        X= resample(X,p,q);% downsample signal

  %polting for comparision signal after apply filtering & downsampling
        
%         subplot(2,1,1)
%         plot(X(:,11),'linewidth',2);%show row signal for channel 11(Cz) 
%         hold on
%         plot(X1(:,11),'linewidth',2);%shwo signal after bandpass filtering
%         subplot(2,1,2)
%         plot(X2(:,11),'linewidth',2);%show signal after downsampling
        
        %using type for find trials (contian p300 & non p300)
        st_temp = StimulusType(index);
        type = max(st_temp);

        if type ==1
            c1 = c1 +1;
            data1(:,c1) = X(:);% data1 contians about trails with p300
        else
            c2 = c2 +1;
            data2(:,c2) = X(:);% data2 contians about trails with non-p300
        end
    end
    disp(['run: ',num2str(run)])
end

%%
clearvars -except data1 data2

%% Imbalance
indx= randperm(size(data2,2),size(data1,2));
data2= data2(:,indx);


%%
%traindataset= [data1,data2];
%labels= [ones(1,size(data1,2)),-ones(1,size(data2,2))];
save mydataset data1 data2
%save dataset labels traindataset