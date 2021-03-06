dbstop if error

characters = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', ...
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', ...
    'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', ...
    'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', ...
    'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', ...
    'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', ...
    '8', '9'
    };

TRIALS = 1000;
trial_differences = zeros(TRIALS, 3);
collisions = zeros(100, 1);

for trial = 1 : TRIALS
    fprintf('current in trial: %d\n', trial);
    %% setup the Recurrent Neural Network
    rnn = rnn_setup(8, 200, 64, 'tanh', 'linear');
    % load('rnn.mat');
    
    %% hash process
    rnn = rnn_initialize(rnn);
    password1 = '1b2FC1Pe6B94aZbD4740D7kd9L9B844f9g';
    hash_code_1 = hash(password1, rnn, 2);
    
    rnn = rnn_initialize(rnn);
    password2 = '2b2FC1Pe6B94aZbD4740D7kd9L9B844f9g';
    hash_code_2 = hash(password2, rnn, 2);
    
    rnn = rnn_initialize(rnn);
    password3 = '1b2FC1Pe6B94aZbD4840D7kd9L9B844f9g';
    hash_code_3 = hash(password3, rnn, 2);
    
    rnn = rnn_initialize(rnn);
    password4 = '1b2FC1Pe6B94aZbD4740D7kd9L9B844f9h';
    hash_code_4 = hash(password4, rnn, 2);
    
    rnn = rnn_initialize(rnn);
    password5 = password1;
    pwd_index = max(1, fix(rand(1) * length(password1)));
    char_index = max(1, fix(rand(1) * length(characters)));
    while isequal(password5(pwd_index), characters{char_index})
        char_index = max(1, fix(rand(1) * length(characters)));
    end
    password5(pwd_index) = characters{char_index};
    hash_code_5 = hash(password5, rnn, 2);
    
    hash_codes = [hash_code_1; hash_code_2; hash_code_3; hash_code_4; hash_code_5];
    
    %% show the binary results
    hash_bin = cell(size(hash_codes, 1), 1);
    code = cell(size(hash_codes, 1), 1);
    for i = 1 : size(hash_codes, 1)
        hash_bin{i} = dec2bin(hex2dec(hash_codes(i, :)), 4);
        hash_bin{i} = reshape(hash_bin{i}', 1, size(hash_bin{i}, 1) * size(hash_bin{i}, 2));
        for k = 1 : length(hash_bin{i})
            code{i} = [code{i} str2num(hash_bin{i}(k))];
        end
%         figure;stairs(code{i});
%         ylim([0, 1.2]); xlim([0, 128]);
%         ylabel(strcat('����', num2str(i)), 'FontSize', 14, 'FontName', '΢���ź�');
    end

    %% Sensibility
    differences = zeros(size(hash_codes, 1) - 1, 1);
    for i = 1 : size(hash_codes, 1) - 1
        differences(i) = length(find(code{1} ~= code{i+1}));
        trial_differences(trial, i) = differences(i);
    end
    
    %% Information Entropy
    entropy = zeros(size(hash_codes, 1), 1);
    for k = 1 : size(hash_codes, 1)
        values = unique(hash_codes());
        percents = zeros(length(values), 1);
        for i = 1 : length(values)
            count = 0;
            for j = 1 : size(hash_codes, 2)
                if isequal(hash_codes{k, j}, values{i})
                    count = count + 1;
                end
            end
            percent = count / size(hash_codes, 2);
            if percent > 0
                entropy(k) = entropy(k) - percent * log2(percent);
            end
        end
    end
    
    %% Collision Test
    count = 0;
    for i = 1 : size(hash_codes, 2);
        if isequal(hash_codes{1, i}, hash_codes{5, i})
            count = count + 1;
        end
    end
    collisions(count) = collisions(count) + 1;
end


