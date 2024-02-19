prob = {@DTLZ1, @DTLZ2, @DTLZ3, @DTLZ4, @DTLZ5, @DTLZ6, @DTLZ7};
Ms = [3, 4, 6, 8, 10];
times = 30;

numWorkers = 8; 
pool = gcp('nocreate'); 
if isempty(pool)
    parpool(numWorkers); 
elseif pool.NumWorkers ~= numWorkers
    delete(pool); 
    parpool(numWorkers); 
end


parfor r = 1:times
    for i = 1:length(prob)
        for j = 1:length(Ms)
            platemo('algorithm',@REMOHH,'problem',prob{i},'N',50,'M',Ms(j),'D',10,'maxFE',300,'save',300);
        end
    end
end
