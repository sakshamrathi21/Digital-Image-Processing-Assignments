clear; tic; clc;

% Step 1: Load and Organize the Data
num_persons = 39; % Number of persons (1 to 39, with person 14 missing)
num_train = 40; % Number of training images per person
num_test = 24; % Number of testing images per person
img_rows = 192; % Image height
img_cols = 168; % Image width
img_size = img_rows * img_cols;

% Get data points
train_data = [];
train_labels = [];
test_data = [];
test_labels = [];

for i = [1:13, 15:39]
    imagefiles = dir("../../../CroppedYale/yaleB" + num2str(i, '%02d') + "/*.pgm");

    for img_num = 1:length(imagefiles)
        currentfilename = imagefiles(img_num).folder + "/" + imagefiles(img_num).name;
        currentimage = im2double(imread(currentfilename));

        if (img_num <= num_train)
            train_data = cat(2, train_data, currentimage(:));
            train_labels = cat(2, train_labels, i);
        else
            test_data = cat(2, test_data, currentimage(:));
            test_labels = cat(2, test_labels, i);
        end
    end
end

%save("Yale_Face_data.mat");
%load("Yale_Face_data.mat");

% Step 2: Mean Center the Data
train_mean = mean(train_data, 2);
train_centered = train_data - train_mean;
test_centered = test_data - train_mean;

% Step 3: Perform PCA using eig or svd
% ------ Use eig method ------
L = train_centered' * train_centered; % Small covariance matrix
[V, D] = eig(L, "vector"); % Eigen decomposition
eigenfaces = train_centered * V; % Compute the actual eigenfaces
eigenfaces = eigenfaces(:, end:-1:1); % Sort in descending order of eigenvalues

% Normalize the eigenfaces
for i = 1:size(eigenfaces, 2)
    eigenfaces(:, i) = eigenfaces(:, i) / norm(eigenfaces(:, i)); % Normalize each eigenface to unit length
end

k_values = [1, 2, 3, 5, 10, 15, 20, 30, 50, 60, 65, 75, 100, 200, 300, 500, 1000];

% (a) part
plot_recognition_rates(k_values, train_centered, train_labels, test_centered, test_labels, eigenfaces, false);

% (b) part
plot_recognition_rates(k_values, train_centered, train_labels, test_centered, test_labels, eigenfaces, true);

function plot_recognition_rates(k_values, train_centered, train_labels, test_centered, test_labels, eigenfaces, top3)
    recognition_rates = zeros(length(k_values), 1);
    for idx = 1:length(k_values)
        k = k_values(idx);
        selected_eigenfaces = eigenfaces(:, 1:k); % Use top k eigenfaces
        
        % Project training data onto the selected eigenfaces
        train_projections = selected_eigenfaces' * train_centered;
        if top3 == true
            train_projections = train_projections(4:end, :);
        end
        
        % Project test data onto the selected eigenfaces
        test_projections = selected_eigenfaces' * test_centered;
        if top3 == true
            test_projections = test_projections(4:end, :);
        end
        
        % Classify test images
        correct_classifications = 0;
        for test_img_idx = 1:size(test_projections, 2)
            test_img_proj = test_projections(:, test_img_idx);
            
            % Compute squared differences with all training images
            diffs = train_projections - test_img_proj;
            sq_diffs = sum(diffs .^ 2);
            
            % Find the closest training image
            [~, closest_idx] = min(sq_diffs);
            predicted_label = train_labels(closest_idx);
            true_label = test_labels(test_img_idx);
            
            if predicted_label == true_label
                correct_classifications = correct_classifications + 1;
            end
        end
        
        recognition_rate = correct_classifications / size(test_projections, 2);
        recognition_rates(idx) = recognition_rate;
    end

    % Plot
    figure;
    plot(k_values, recognition_rates, '-o');
    xlabel('Number of Eigenfaces (k)');
    ylabel('Recognition Rate');
    grid on;
    if top3 == false
        title('Yale Recognition Rate vs Number of Eigenfaces (ALL) (Using eig)');
        saveas(gcf, "../images/Yale_a.png");
    else
        title('Yale Recognition Rate vs Number of Eigenfaces (Except the 3 Coeff) (Using eig)');
        saveas(gcf, "../images/Yale_b.png");
    end
end

toc;