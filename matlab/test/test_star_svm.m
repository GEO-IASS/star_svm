clear all;
close all;
clc;

addpath('..');
addpath('../../data');

%% PARAMS
DEBUG = 0; % show debug statements
WARM_START = 1; % use warm-start for TWO-SVM
%% Dataset (sig, C)
% text1 (3.5, 31)
% coil20 (2900, 37)
% USPST (7.4, 38)
% g50c (38, 19)
sig = 7.4;
C = 38;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% If Using the SSL,set1:9 datasets %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SSL,set=1:9
% data_file = 'SSL,set=1,data.mat';
% split_file = 'SSL,set=1,splits,labeled=100.mat';
% load(data_file);
% load(split_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% If Using the following datasets           %%
%% Datasets coil20, uspst, g10n, g50c, text1 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('uspst.mat');

num_splits = size(idxLabs,1);
K = create_kernel(X, 'rbf', 'sig', sig);

classes = unique(y);
num_classes = length(classes);
avg_error = 0;

for i = 1:num_splits
   labeled_ind = idxLabs(i,:);
   unlabeled_ind = idxUnls(i,:);   
   multi_predict = zeros(num_classes, length(unlabeled_ind));

   tic
   for j = 1:num_classes
       y_bin = (y == classes(j)) - (y ~= classes(j));
       r = sum(max(0, y_bin(labeled_ind)))/length(labeled_ind);
       [predict, ranking, alpha, error, F, AUC] = star_svm(K, y_bin,...
           labeled_ind, 'C', C, 'debug', 0, 'gamma', 0.9, 'warm_start', 1); 
              
       multi_predict(j,:) = ranking(unlabeled_ind);
   end
   toc

   [~, final_predict] = max(multi_predict, [], 1);
   final_predict = classes(final_predict);
   error = sum(final_predict ~= y(unlabeled_ind))/length(unlabeled_ind);
   fprintf('(STAR-SVM) Split #%d: error = %f\n', i, error);
   avg_error = avg_error + error/num_splits;
end
fprintf('(STAR-SVM) Average Error = %f\n', avg_error);