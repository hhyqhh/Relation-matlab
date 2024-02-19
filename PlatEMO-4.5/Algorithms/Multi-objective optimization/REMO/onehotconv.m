function output = onehotconv(input, mode)
%ONEHOTCONV Convert labels to one-hot encoding or vice versa.
%   output = ONEHOTCONV(input, mode) converts input based on the mode.
%   If mode is 1, it converts label vector to one-hot encoding matrix.
%   If mode is 2, it converts one-hot encoding matrix to label vector.
%
%   Input:
%       input - A vector of labels or a matrix of one-hot encodings.
%       mode  - Operation mode: 1 for encoding, 2 for decoding.
%
%   Output:
%       output - A matrix of one-hot encodings or a vector of labels.

    if mode == 1
        % Convert label vector to one-hot encoding
        l = input;
        l_onehot = zeros(size(l, 1), 3);
        
        l_onehot(l == 1, 1) = 1;
        l_onehot(l == 0, 2) = 1;
        l_onehot(l == -1, 3) = 1;
        
        output = l_onehot;
        
    elseif mode == 2
        % Convert one-hot encoding to label vector
        onehot_l = input;
        res_l = zeros(size(onehot_l, 1), 1);
        
        [~, maxind] = max(onehot_l, [], 2);
        
        res_l(maxind == 1) = 1;
        res_l(maxind == 3) = -1;
        
        output = res_l;
    end
end











% function varargout = onehotconv(varargin)
% 
% 
%     if varargin{2}== 1
%         %% conv onehot
%         l        = varargin{1};      
%         l_onehot = zeros(size(l,1),3);
% 
%         l_onehot(l == 1 ,1) = 1;
%         l_onehot(l == 0,2)  = 1;
%         l_onehot(l == -1,3) = 1;
% 
%         varargout = {l_onehot};
% 
%     elseif varargin{2} == 2
%         %% deconv onehot
%         onehot_l = varargin{1};
%         res_l    = zeros(size(onehot_l,1),1);
% 
%         [~,maxind] = max(onehot_l,[],2);
% 
%         res_l(maxind==1) = 1;
%         res_l(maxind==3) = -1;
% 
%         varargout = {res_l};
%     end
% end