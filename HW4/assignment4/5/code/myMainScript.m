clear; tic; clc;

% The location of the ORL folder (containing the images should be): "../../../ORL" with respect to the location of this script (Basically outside the zipped folder)

% Step 1: Load and Organize the Data
num_persons = 32; % Number of persons (1 to 32)
num_train = 6; % Number of training images per person
num_test = 4; % Number of testing images per person
img_rows = 92; % Image height
img_cols = 112; % Image width
img_size = img_rows * img_cols;

% Initialize matrices for training and test data
train_data = [];
test_data = [];
train_labels = [];
test_labels = [];

% Load images using dir command
for person = 1:num_persons
    folder = sprintf('../../../ORL/s%d', person);
    img_files = dir(fullfile(folder, '*.pgm')); % List all .pgm files in the folder
    
    for img_num = 1:10
        img_path = img_files(img_num).folder + "/" + img_files(img_num).name;
        img = imread(img_path);
        img_vector = im2double(img(:)); % Reshape to 1D vector

        if (img_num <= num_train)
            train_data = cat(2, train_data, img_vector);
            train_labels = cat(2, train_labels, person);
        else
            test_data = cat(2, test_data, img_vector);
            test_labels = cat(2, test_labels, person);
        end
    end
end

% Adding the last 32 images to the test set as well
for person = num_persons+1:40
    folder = sprintf('../../../ORL/s%d', person);
    img_files = dir(fullfile(folder, '*.pgm')); % List all .pgm files in the folder
    
    for img_num = 7:10
        img_path = img_files(img_num).folder + "/" + img_files(img_num).name;
        img = imread(img_path);
        img_vector = im2double(img(:)); % Reshape to 1D vector

        test_data = cat(2, test_data, img_vector);
        test_labels = cat(2, test_labels, -1);
    end
end

% Step 2: Mean Center the Data
train_mean = mean(train_data, 2);
train_centered = train_data - train_mean;
test_centered = test_data - train_mean;

% Step 3: Get eigenfaces using svd
[U, S, V] = svd(train_centered); % SVD of the centered training data
eigenfaces = U; % The left singular vectors correspond to the eigenfaces

% For no matching identity we need to find a threshold value for the PCA eigen coefficients in mean squared sense
% We find the threshold by cross validation
threshold_values = linspace(30, 300, 100);
k = 75; % say

selected_eigenfaces = eigenfaces(:, 1:k);
train_projections = selected_eigenfaces' * train_centered;
test_projections = selected_eigenfaces' * test_centered;

% Get the list of mse_min and closest_idx of all test data
test_data_size = size(test_projections, 2);
mse_min_list = zeros(1, test_data_size);
closest_idx_list = zeros(1, test_data_size);

for test_img_idx = 1:test_data_size
    test_img_proj = test_projections(:, test_img_idx);
    mse = sum((train_projections - test_img_proj) .^ 2, 1);
    [mse_min, closest_idx] = min(mse);
    mse_min_list(test_img_idx) = mse_min;
    closest_idx_list(test_img_idx) = closest_idx;
end

% Let's see the mean and std-dev of mse_min for all test data
fprintf("Mean of Test Error is %f...\n", mean(mse_min_list));
fprintf("Standard Deviation of Test Error is %f...\n\n", std(mse_min_list));

% Getting the best threshold for the following metrics...
get_best_threshold("accuracy", threshold_values, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size);
get_best_threshold("f1_score", threshold_values, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size);
get_best_threshold("youden_index", threshold_values, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size);
get_best_threshold("my_score", threshold_values, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size);

% Testing threshold = 140 (say)
test_threshold(140, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size);

function get_best_threshold(metric, threshold_values, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size)
    best_score = 0;
    best_threshold = 0;
    TP = 0;
    FP = 0;
    TN = 0;
    FN = 0;
    accuracy_ = 0;
    f1_score_ = 0;
    youden_index_ = 0;
    my_score_ = 0;
    recognition_rate = 0;
    
    for threshold_index = 1:length(threshold_values)
        threshold = threshold_values(threshold_index);
    
        correct_classifications = 0;
        TP_count = 0;
        FP_count = 0;
        TN_count = 0;
        FN_count = 0;
   
        for test_img_idx = 1:test_data_size
            mse_min = mse_min_list(test_img_idx);
            closest_idx = closest_idx_list(test_img_idx);
            test_img_label = test_labels(test_img_idx);
            predicted_label = train_labels(closest_idx);
    
            if (mse_min > threshold)
                % This means there are no matching eigen faces
                if (test_img_label == -1)
                    TN_count = TN_count + 1;
                else
                    FN_count = FN_count + 1;
                end
    
            else
                % This means there are matching eigen faces
                if (test_img_label == -1)
                    FP_count = FP_count + 1;
                else
                    TP_count = TP_count + 1;
    
                    if predicted_label == test_img_label
                        correct_classifications = correct_classifications + 1;
                    end
    
                end
    
            end
    
        end
    
        accuracy = (TP_count + TN_count) / test_data_size;
        f1_score = TP_count / (TP_count + 0.5 * (FP_count + FN_count));
        youden_index = TP_count / (TP_count + FN_count) + TN_count / (TN_count + FP_count) - 1;
        my_score = 1 / (FP_count + 1) + 1 / (FN_count + 1);

        metric_var = 0;

        if (metric == "accuracy")
            metric_var = accuracy;
        elseif (metric == "f1_score")
            metric_var = f1_score;
        elseif (metric == "youden_index")
            metric_var = youden_index;
        elseif (metric == "my_score")
            metric_var = my_score;
        end

        if (metric_var > best_score)
            best_score = metric_var;
            accuracy_ = accuracy;
            f1_score_ = f1_score;
            youden_index_ = youden_index;
            my_score_ = my_score;
            best_threshold = threshold;
            FP = FP_count;
            FN = FN_count;
            TP = TP_count;
            TN = TN_count;
            recognition_rate = correct_classifications / test_data_size;
        end
    end

    fprintf("Maximising %s...\n", metric);
    fprintf("Accuracy: %f\n", accuracy_);
    fprintf("F1 Score: %f\n", f1_score_);
    fprintf("Youden's Index: %f\n", youden_index_);
    fprintf("My Score: %f\n", my_score_);
    fprintf("Best Threshold: %f\n", best_threshold);
    
    % Print the confusion matrix
    fprintf("Confusion matrix:\n");
    fprintf("TP: %d\tFP: %d\n", TP, FP);
    fprintf("FN: %d\tTN: %d\n", FN, TN);
    
    fprintf("Recognition rate: %f\n\n", recognition_rate);
end

function test_threshold(threshold, mse_min_list, closest_idx_list, train_labels, test_labels, test_data_size)
    correct_classifications = 0;
    TP_count = 0;
    FP_count = 0;
    TN_count = 0;
    FN_count = 0;

    for test_img_idx = 1:test_data_size
        mse_min = mse_min_list(test_img_idx);
        closest_idx = closest_idx_list(test_img_idx);
        test_img_label = test_labels(test_img_idx);
        predicted_label = train_labels(closest_idx);

        if (mse_min > threshold)
            % This means there are no matching eigen faces
            if (test_img_label == -1)
                TN_count = TN_count + 1;
            else
                FN_count = FN_count + 1;
            end

        else
            % This means there are matching eigen faces
            if (test_img_label == -1)
                FP_count = FP_count + 1;
            else
                TP_count = TP_count + 1;

                if predicted_label == test_img_label
                    correct_classifications = correct_classifications + 1;
                end

            end

        end

    end

    accuracy = (TP_count + TN_count) / test_data_size;
    f1_score = TP_count / (TP_count + 0.5 * (FP_count + FN_count));
    youden_index = TP_count / (TP_count + FN_count) + TN_count / (TN_count + FP_count) - 1;
    my_score = 1 / (FP_count + 1) + 1 / (FN_count + 1);
    recognition_rate = correct_classifications / test_data_size;

    fprintf("Testing threshold = %f...\n", threshold);
    fprintf("Accuracy: %f\n", accuracy);
    fprintf("F1 Score: %f\n", f1_score);
    fprintf("Youden's Index: %f\n", youden_index);
    fprintf("My Score: %f\n", my_score);
    
    % Print the confusion matrix
    fprintf("Confusion matrix:\n");
    fprintf("TP: %d\tFP: %d\n", TP_count, FP_count);
    fprintf("FN: %d\tTN: %d\n", FN_count, TN_count);
    
    fprintf("Recognition rate: %f\n\n", recognition_rate);
end

toc;