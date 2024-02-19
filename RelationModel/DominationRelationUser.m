function rank1_index = DominationRelationUser(Surrogates,Us,N)
    UUs = FitnessCriteriaGenerator(Us);
    Labels = [];
    for m = 1:length(Surrogates)
        surrogate = Surrogates{m};
        pre_data_nor = mapminmax('apply', UUs', surrogate.nor_struct)';
        pre_out = surrogate.model(pre_data_nor')';
        pre_out = OneHotConvert(pre_out,2);

        Labels = [Labels,pre_out];
    end

    domainmatrix = paretoconv(Labels);
    domainmatrix = domainmatrix - diag(diag(domainmatrix));

    [rank1_index,~,~] = NDSort_nsga2(domainmatrix,N);

end




%% 
function domina_mat = paretoconv(pre_L)
    max_size  = sqrt(size(pre_L,1));
    dom_vector  = sum(pre_L,2);
    
    %横向支配纵向
    domina_mat = reshape(dom_vector,max_size,max_size)./2;
    
end



%% 利用NSGAII 的支配机构造方法

function varargout = NDSort_nsga2(domainmatrix,nSort)
    popsize = size(domainmatrix,1);
    rank = ones(popsize,1)*inf;
    P = (1:popsize)';
    i= 0;
    while 1
        i = i+1;
        [ndfIndex,dfIndex]=NonDominatedFront(domainmatrix(P,P));
        rank(P(ndfIndex)) = i;
        P = P(dfIndex);
        if (popsize-size(P,1)) >= nSort
            break;
        end
    end
    FrontNo = rank' ;
    MaxFNo  =  i;
    [c1,c2] = sort(FrontNo);
    resInd = 1:popsize;
    selected_ind = resInd(FrontNo == 1);
    if size(selected_ind,2) > 100
        selected_ind = c2(1:nSort);
    end
    
    varargout={selected_ind,FrontNo,MaxFNo};
    %fprintf('offs size %d \n',size(selected_ind,2));
end



%% 
function [ndxIndex,dxIndex] = NonDominatedFront(domain)
    popSize = size(domain,1);
    dxIndex = []; ndxIndex = [];
    
    for i = 1:popSize
        domain_pre = domain(:,i)';
        if sum(domain_pre == 1)> 2
            dxIndex = [dxIndex,i];
        else
            ndxIndex = [ndxIndex,i];
        end
           
    end
    if isempty(ndxIndex)
        ndxIndex = dxIndex;dxIndex = [];
    end
 
end


