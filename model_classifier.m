
clear; 
clc;
close all 



load dataset
% data1, data2
trainingdata= [data1,data2];
traininglabels= [ones(1,size(data1,2)),-ones(1,size(data2,2))];
mdl= fitcsvm(trainingdata',traininglabels,'Standardize',1);

save mymodel mdl