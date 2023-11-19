% Number of test cases
numTestCases = 500;
% Generate and save test cases
for testCase = 1:numTestCases
     testCaseMatrix = randi([100, 1000], 4, 4);
     save(['test_case_', num2str(testCase), '.mat'], 'testCaseMatrix');
end
 % Run optimization for each test case
 for testCase = 1:numTestCases
     % Load test case matrix
     load(['test_case_', num2str(testCase), '.mat'], 'testCaseMatrix');
     % Run optimization function
     [optimizedMatrix, minDeviation, swapInfo, globalSwapMatrix] = optimizePVArray(testCaseMatrix);
     % Save results
     save(['result_test_case_', num2str(testCase), '.mat'], 'optimizedMatrix', 'minDeviation', 'globalSwapMatrix', 'testCaseMatrix');
 end
% Load and analyze results for each test case
data = cell(numTestCases, 4); % Each row contains {testCaseMatrix, optimizedMatrix, swapInfo, minDeviation}

for testCase = 1:numTestCases
    % Load results
    load(['result_test_case_', num2str(testCase), '.mat']); 
    % Store data
    data{testCase, 1} = optimizedMatrix;
    data{testCase, 2} = minDeviation; % Corrected variable name
    data{testCase, 3} = globalSwapMatrix;
    data{testCase, 4} = testCaseMatrix;
end

% Convert cell array to a table
dataTable = cell2table(data, 'VariableNames', {'TestCaseMatrix', 'OptimizedMatrix', 'globalSwapMatrix', 'MinDeviation'});

% Write the table to an Excel file
writetable(dataTable, 'PVArrayData.xlsx');


function [bestMatrix, minDeviation, swapMatrix,globalSwapMatrix] = optimizePVArray(matrix)
    % Declare global variable to store the best swap matrix
    globalSwapMatrix=repmat((1:size(matrix, 1))', 1, size(matrix, 2));

    % Initialize variables to store the best matrix, minimum deviation, and swap matrix
    bestMatrix = matrix;
    minDeviation = calculateCurrentDeviation(matrix);
    swapMatrix = repmat((1:size(matrix, 1))', 1, size(matrix, 2));

    % Get the size of the matrix
    [rows, cols] = size(matrix);

    % Recursive function to explore all possible swaps
    function exploreSwaps(currentRow, currentCol)
        % Base case: If we have reached the last column of the last row,
        % calculate deviation and update if necessary
        if currentRow == rows && currentCol == cols
            deviation = calculateCurrentDeviation(matrix);
            if deviation < minDeviation
                minDeviation = deviation;
                bestMatrix = matrix;
                % Update the global swap matrix when deviation is less than minDeviation
                globalSwapMatrix = swapMatrix;
            end
            return;
        end
        % Move to the next column or next row
        nextRow = currentRow;
        nextCol = currentCol + 1;
        if nextCol > cols
            nextCol = 1;
            nextRow = currentRow + 1;
        end
        % Try swapping the current element with any element in the same column
        originalValue = matrix(currentRow, currentCol);
        for swapRow = currentRow:rows
            % Swap the values
            matrix(currentRow, currentCol) = matrix(swapRow, currentCol);
            matrix(swapRow, currentCol) = originalValue;

            % Update the swap matrix
            temp=swapMatrix(currentRow, currentCol);
            swapMatrix(currentRow, currentCol) = swapMatrix(swapRow, currentCol);
            swapMatrix(swapRow, currentCol) = temp;

            % Recursively explore the next column or next row
            exploreSwaps(nextRow, nextCol);

            % Swap back to the original values for backtracking
            matrix(swapRow, currentCol) = matrix(currentRow, currentCol);
            matrix(currentRow, currentCol) = originalValue;

            % Reset the swap matrix entry after backtracking
            temp=swapMatrix(currentRow, currentCol);
            swapMatrix(currentRow, currentCol) = swapMatrix(swapRow, currentCol);
            swapMatrix(swapRow, currentCol) = temp;
        end
    end

    % Start the recursive exploration from the first element
    exploreSwaps(1, 1);
end

function deviation = calculateCurrentDeviation(matrix)
    % Calculate the current deviation based on the maximum difference in row sums
    rowSums = sum(matrix, 2);
    deviation = max(rowSums) - min(rowSums);
end
