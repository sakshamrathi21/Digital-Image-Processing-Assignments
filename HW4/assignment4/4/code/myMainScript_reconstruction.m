clear; clc; tic;

% Step 1: Load the ORL database (as done in your original code)
num_persons = 32; % Number of persons (1 to 32)
num_train = 6; % Number of training images per person
img_rows = 92; % Image height
img_cols = 112; % Image width
img_size = img_rows * img_cols;

% Load ORL dataset and organize the data (as done previously)
train_data = zeros(img_size, num_persons * num_train);
train_labels = zeros(num_persons * num_train, 1);

for person = 1:num_persons
    folder = sprintf('../../../ORL/s%d', person);
    img_files = dir(fullfile(folder, '*.pgm')); % List all .pgm files in the folder
    
    for img_num = 1:6
        img_path = fullfile(img_files(img_num).folder, img_files(img_num).name);
        img = imread(img_path);
        img_vector = double(img(:)); % Reshape to 1D vector

        % Assign to training set
        train_data(:, (person - 1) * num_train + img_num) = img_vector;
        train_labels((person - 1) * num_train + img_num) = person;
    end
end

% Step 2: Mean Center the Data
train_mean = mean(train_data, 2);
train_centered = train_data - train_mean;

% Step 3: Perform PCA using svd
[U, S, V] = svd(train_centered, 'econ'); % SVD of the centered training data
eigenfaces = U; % The left singular vectors correspond to the eigenfaces

% Normalize the eigenfaces
for i = 1:size(eigenfaces, 2)
    eigenfaces(:, i) = eigenfaces(:, i) / norm(eigenfaces(:, i)); % Normalize each eigenface to unit length
end

% Step 4: Reconstruct one face using different values of k
k_values = [2, 10, 20, 50, 75, 100, 125, 150, 175];
face_idx = 1; % Reconstruct the first face (you can change this to reconstruct any other face)

test_image = im2double(imread("../../../ORL/s1/1.pgm"));
figure(1);
imagesc(test_image); colormap("gray"); title("Original Image");
saveas(gcf, "../images/original_image.png")

figure;
for i = 1:length(k_values)
    k = k_values(i);
    
    % Select the top k eigenfaces
    selected_eigenfaces = eigenfaces(:, 1:k);
    
    % Project the selected face onto the top k eigenfaces
    face_proj = selected_eigenfaces' * (train_centered(:, face_idx));
    
    % Reconstruct the face from the top k eigenfaces
    face_reconstructed = selected_eigenfaces * face_proj + train_mean;
    
    % Reshape the face back to the original image dimensions
    face_reconstructed_img = reshape(face_reconstructed, size(test_image));
    
    % Plot the reconstructed image
    subplot(3, 3, i);
    imagesc(face_reconstructed_img); colormap("gray"); title(sprintf("k = %d", k));
end

% Save the figure of reconstructed faces
saveas(gcf, '../images/ORL_reconstructed_faces.png'); % Save as PNG (you can change the path/format)

% Step 5: Plot the first 25 eigenfaces
figure;
for i = 1:25
    eigenface_img = reshape(eigenfaces(:, i), size(test_image)); % Reshape eigenface to original image size
    subplot(5, 5, i); % 5x5 grid for the 25 eigenfaces
    imagesc(eigenface_img); colormap("gray");
end

% Save the figure of the first 25 eigenfaces
saveas(gcf, '../images/ORL_eigenfaces.png'); % Save as PNG (you can change the path/format)

toc;