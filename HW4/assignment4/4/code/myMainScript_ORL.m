clear; tic; clc;

% Step 1: Load and Organize the Data
num_persons = 32; % Number of persons (1 to 32)
num_train = 6; % Number of training images per person
num_test = 4; % Number of testing images per person
img_rows = 92; % Image height
img_cols = 112; % Image width
img_size = img_rows * img_cols;

% Initialize matrices for training and test data
train_data = zeros(img_size, num_persons * num_train);
test_data = zeros(img_size, num_persons * num_test);
train_labels = zeros(num_persons * num_train, 1);
test_labels = zeros(num_persons * num_test, 1);

count_train = 1;
count_test = 1;

% Load images using dir command
for person = 1:num_persons
    folder = sprintf('../../../ORL/s%d', person);
    img_files = dir(fullfile(folder, '*.pgm')); % List all .pgm files in the folder
    
    for img_num = 1:10
        img_path = img_files(img_num).folder + "/" + img_files(img_num).name;
        img = imread(img_path);
        img_vector = double(img(:)); % Reshape to 1D vector

        if img_num <= num_train
            % Assign to training set
            train_data(:, count_train) = img_vector;
            train_labels(count_train) = person;
            count_train = count_train + 1;
        else
            % Assign to testing set
            test_data(:, count_test) = img_vector;
            test_labels(count_test) = person;
            count_test = count_test + 1;
        end
    end
end

N = size(train_data, 2);
k_values = [1, 2, 3, 5, 10, 15, 20, 30, 50, 75, 100, 150, 170];

% Step 2: Mean Center the Data
train_mean = mean(train_data, 2);
train_centered = train_data - train_mean;
test_centered = test_data - train_mean;

% Step 3: Perform PCA using eig or svd
% ------ Use eig method ------
method = "eig";
L = (train_centered' * train_centered); % Covariance matrix
[eigenvectors, ~] = eig(L); % Eigen decomposition
eigenfaces = train_centered * eigenvectors;
% Normalize the eigenfaces
for i = 1:size(eigenfaces, 2)
    eigenfaces(:, i) = eigenfaces(:, i) / norm(eigenfaces(:, i)); % Normalize each eigenface to unit length
end
eigenfaces = eigenfaces(:, end:-1:1); % Sort in descending order of eigenvalues

% ------ Alternatively, use svd (uncomment this and comment the eig method above) ------
% method = "svd";
% [U, S, V] = svd(train_centered); % SVD of the centered training data
% eigenvectors = U; % The left singular vectors correspond to the eigenfaces

% Step 4: Recognition using squared difference
recognition_rates = zeros(length(k_values), 1);

for idx = 1:length(k_values)
    k = k_values(idx);
    selected_eigenfaces = eigenfaces(:, 1:k); % Use top k eigenfaces
    
    % Project training data onto the selected eigenfaces
    train_projections = selected_eigenfaces' * train_centered;
    
    % Project test data onto the selected eigenfaces
    test_projections = selected_eigenfaces' * test_centered;
    
    % Classify test images
    correct_classifications = 0;
    for test_img_idx = 1:size(test_projections, 2)
        test_img_proj = test_projections(:, test_img_idx);
        
        % Compute squared differences with all training images
        diffs = train_projections - test_img_proj;
        sq_diffs = sum(diffs .^ 2, 1);
        % fprintf("sq_diffs size = %d x %d\n", size(sq_diffs, 1), size(sq_diffs, 2));
        
        % Find the closest training image
        [~, closest_idx] = min(sq_diffs);
        predicted_label = train_labels(closest_idx);
        true_label = test_labels(test_img_idx);

        if predicted_label == true_label
            correct_classifications = correct_classifications + 1;
        end
    end
    
    recognition_rate = correct_classifications / size(test_projections, 2);
    fprintf("k = %d, rate (in percent) = %f\n", k, 100 * recognition_rate);
    recognition_rates(idx) = recognition_rate;
end

% Step 5: Plot the recognition rates
figure;
plot(k_values, recognition_rates, '-o');
xlabel('Number of Eigenfaces (k)');
ylabel('Recognition Rate');
title(sprintf('ORL Recognition Rate vs Number of Eigenfaces (Using %s)', method));
grid on;
saveas(gcf, sprintf("../images/ORL_%s.png", method));

toc;