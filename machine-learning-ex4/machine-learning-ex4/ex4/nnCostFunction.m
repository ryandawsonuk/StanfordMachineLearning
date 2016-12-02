function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%
a1 = [ones(m, 1) X];
a2 = sigmoid (a1 * Theta1');
a2 = [ones(m, 1) a2];
a3 = sigmoid (a2 * Theta2');


yVec = repmat([1:num_labels], m, 1) == repmat(y, 1, num_labels);

cost = -yVec .* log(a3) - (1 - yVec) .* log(1 - a3);

Theta1WithoutBias = Theta1(:, 2:end);
Theta2WithoutBias = Theta2(:, 2:end);
J = sum(sum(cost)) ./ m + (lambda /(2*m)) .* (sum(sum(Theta1WithoutBias.^2)) + sum(sum(Theta2WithoutBias.^2)));

delta1 = zeros(size(Theta1));
delta2 = zeros(size(Theta2));

for t=1:m,
    a1t = a1(t,:)';
    a2t = a2(t,:)';
    a3t = a3(t,:)';
    yVecT = yVec(t,:)';
    
    delta3T = a3t - yVecT;
    
    z2t = [1; Theta1 * a1t];
    delta2T = (Theta2') * delta3T .* sigmoidGradient(z2t);
    delta1 = delta1 + delta2T(2:end) * (a1t)';
    delta2 = delta2 + delta3T * (a2t)';
    
end;


Theta1ZeroedBias = [ zeros(size(Theta1, 1), 1) Theta1WithoutBias ];
Theta2ZeroedBias = [ zeros(size(Theta2, 1), 1) Theta2WithoutBias ];
Theta1_grad = (1 / m) * delta1 + (lambda / m) * Theta1ZeroedBias;
Theta2_grad = (1 / m) * delta2 + (lambda / m) * Theta2ZeroedBias;

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end