
clear;
clc;
close all

mydictionary= ['AGMSY5','BHNTZ6','CIOU17','DJPV28','EKQW39','FLRX4_'];
predictedWORDS=[];
RealDictionary=['FOOD','MOOT','HAM','PIE','CAKE','TUNA','ZYGOT','4567'];
%%
fs=240;
len= 600/1000;
Ltr= round(len*fs);
%%
numSQ=2;% number of seqeunce
%% channels
chn=1:64;%
%% design bandpass filter
fl=0.5;
fh=40;
b=fir1(10,[fl fh]/(fs/2),'bandpass');
%% define downsampling parameters
fd= 2*fh;
[p,q]= rat(fd/fs);
%% load trained classifier
load('mymodel.mat')
for run= 1:8
    filename=['data\AAS012R0',num2str(run),'.mat'];
    load(filename)
    %% find start pints
    indx= find(PhaseInSequence==2);
    indx2=(indx-1);
    id= find(PhaseInSequence(indx2)==1);
    strartpoints= indx(id);
    
    numCHR= numel(strartpoints);
    %% find each character tiral numbers
    for i=1:numCHR
        if i<numCHR
            ind= find(samplenr>strartpoints(i) & samplenr<strartpoints(i+1) );
        else
            ind= find(samplenr>strartpoints(i) );
        end
        id0= find(Flashing(ind)==0);
        ind(id0)=[];
        trials= unique(trialnr(ind));
        %% segment each character trials
        score= zeros(1,12);
        for j=1:(12*numSQ)
            %% position
            index= find(trialnr==trials(j));
            pos=index(1);% start point of ith trial
            position= pos:pos+(Ltr-1);% position of ith trial
            X= signal(position,chn);
            %% apply desinged filter
            X= filtfilt(b,1,X);
            %% downsample signal
            X= resample(X,p,q);
            temp=X(:);
            [~,dis]= predict(mdl,temp');
            s= dis(2);
            scode= max(StimulusCode(position(1:24)));
            score(scode)= score(scode)+ s;
        end
        % target row and column
        [mc,col]= max(score(1:6));
        [mr,row]= max(score(7:12));
        % target character
        indCHR= sub2ind([6 6],row,col);
        WORD(i) = mydictionary(indCHR);
        
    end
    disp(['predicted word: ',WORD])
    predictedWORDS=[predictedWORDS,WORD];
    WORD=[];
end
Accuracy= sum(predictedWORDS==RealDictionary) / numel(RealDictionary) *100;
Error=100-Accuracy;

disp(['Accuracy: ',num2str(Accuracy),'%'])
disp(['Erorr: ',num2str(Error),'%'])







