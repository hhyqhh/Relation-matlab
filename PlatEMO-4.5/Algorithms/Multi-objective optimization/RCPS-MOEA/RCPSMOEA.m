classdef RCPSMOEA < ALGORITHM
% <multi/many> <real> <expensive>

    methods 
        function main(Algorithm,Problem)
        %% Parameterr setting
        k = Algorithm.ParameterSet(3);

        Population = Problem.Initialization();
        [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);

        [XXs, L] = GetRelationPairs(Population);


        %% Optimization
        while Algorithm.NotTerminated(Population)
            models = TrainSurrogate(XXs, L);
            MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);

            % Trial solution generation
            Trials = [];
            
            for i = 1:k
                Trials = [Trials;OperatorGA(Problem,Population(MatingPool).decs)];
            end

            % Per-selection
            rank1_index = DominationRelationUser(models,Trials,Problem.N);
            
            % Evaluation
            Offspring = Problem.Evaluation(Trials(rank1_index,:));

            % Environmental Selection
            [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
        end
          
        end

        end

end



%% Get relation pairs via FitnessCriteriaGenerator for each objective
function [XXs,Labels] = GetRelationPairs(Population)
    decs = Population.decs;
    objs = Population.objs;
    M = size(objs,2);

    Labels = [];
    for m = 1:M
        [XXs,labels] = FitnessCriteriaGenerator(decs,objs(:,m));
        Labels = [Labels,labels];
    end

end

%% Train M surrogate via Trainer_NN for each objective
function models = TrainSurrogate(XXs,Lables)
    M = size(Lables,2);
    models = cell(1, M);
    for m = 1: M
        models{m} = Trainer_NN(XXs,Lables(:,m));      
    end
end


