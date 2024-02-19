function output = OneHotConvert(input, mode)
% 如果是-1,0,1 则编码为 
% 如果是-1 +1 

    if mode == 1

        % 判断编码类型
        if length(unique(input)) == 2
            l = input;
            l_onehot = zeros(size(l,1),2);

            l_onehot(l == 1, 1) = 1;
            l_onehot(l == -1,2) = 1;
        else
            % Convert label vector to one-hot encoding
            l = input;
            l_onehot = zeros(size(l, 1), 3);
            
            l_onehot(l == 1, 1) = 1;
            l_onehot(l == 0, 2) = 1;
            l_onehot(l == -1, 3) = 1;
        end
        
        output = l_onehot;
        
    elseif mode == 2
        % Convert one-hot encoding to label vector
        % 判断编码类型
        onehot_l = input;
        if size(onehot_l,2) == 2
            res_l = zeros(size(onehot_l, 1), 1);
            [~, maxind] = max(onehot_l, [], 2);
            res_l(maxind == 1) = 1;
            res_l(maxind == 2) = -1;

        
        else
            res_l = zeros(size(onehot_l, 1), 1);
            
            [~, maxind] = max(onehot_l, [], 2);
            
            res_l(maxind == 1) = 1;
            res_l(maxind == 3) = -1;
        end
        
        output = res_l;
    end
end
