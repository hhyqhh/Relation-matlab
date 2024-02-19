classdef CREMO < ALGORITHM
% <multi/many> <real> <expensive>
% Expensive multiobjective optimization by relation learning and prediction
% k    ---    6 --- Number of reference solutions
% gmax --- 3000 --- Number of solutions evaluated by surrogate model


%------------------------------- Reference --------------------------------
% H. Hao, A. Zhou, H. Qian, and H. Zhang, Expensive multiobjective
% optimization by relation learning and prediction, IEEE Transactions on
% Evolutionary Computation, 2022.

    methods
        function main(Algorithm,Problem)
            [k,local_max] = Algorithm.ParameterSet(6,3000);

            %% Initalize the population by Latin hypercube sampling
            if Problem.D <= 10
                N = 11*Problem.D-1;
            else
                N = 100;
            end
            PopDec     = UniformPoint(N,Problem.D,'Latin');
            Population = Problem.Evaluation(repmat(Problem.upper-Problem.lower,N,1).*PopDec+repmat(Problem.lower,N,1));
            Archive    = Population;

            %% Optimization
            while Algorithm.NotTerminated(Archive)
                [catalog,Ref] = SplitPopMoPBI(Population,k);
                [XXs,Ls] = CategoryCriteriaGenerator(Population.decs,catalog);
                surrogate = Trainer_CNN(XXs,Ls);

                % Surrogate assisted selection 
                Us = OperatorGA(Problem,[Population.decs;Ref.decs],{1,15,1,5});
                i = 0;
                while  i < local_max
                    [soerted_index,scores] = CategoryCriteriaUser(surrogate,Us,Population.decs,catalog);
                    Us = OperatorGA(Problem,[Us(soerted_index(1:length(Ref)),:);Ref.decs],{1,15,1,5});
                    i     = i + size(Us,1);
                end

                Us = Us(soerted_index,:);
                Us = Us(1:4,:);
                Archive = [Archive,Problem.Evaluation(Us)];
                Population = RefSelect(Archive,Problem.N);
      
            end
        end
    end

end

