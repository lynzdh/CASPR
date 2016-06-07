% Library of tensor operation utilities. This can be used to compute the product of tensors used in
% linearisation and hessian computation.
%
% Author        : Jonathan EDEN
% Created       : 2016
% Description    :
classdef TensorOperations 
    methods (Static)
        function C = VectorProduct(A_ten,b,index,flag)
            assert((index>=1)&&(index<=3),'index input must be between 1 and 3');
            s = size(A_ten);
            if(length(s) == 2)
                s(3) = 1;
            end
            assert(s(index) == length(b),'Invalid multiplication b must be the same length as s(index)');
            switch index
                case 1
                    C = MatrixOperations.Initialise(s(2:3),flag);
                    for l = 1:s(1)
                        % Compute the multiplication
                        temp = A_ten(l,:,:)*b(l);
                        Ab = zeros(s(2:3));
                        for j = 1:s(2)
                            Ab(j,:) = temp(1,j,:);
                        end
                        C = C + Ab;
                    end
                case 2
                    % There appears to be no use for this multiplication at
                    % this point int time.
                    C = MatrixOperations.Initialise(s([1,3]),flag);
                    for l = 1:s(2)
                        % Compute the multiplication
                        temp = A_ten(:,l,:)*b(l);
                        Ab = MatrixOperations.Initialise(s([1,3]),flag);
                        for j = 1:s(1)
                            Ab(j,:) = temp(j,1,:);
                        end
                        C = C + Ab;
                    end
                case 3
                    C = MatrixOperations.Initialise(s(1:2),flag);
                    for l = 1:s(3)
                        C = C + A_ten(:,:,l)*b(l);
                    end
                otherwise
                    disp('This case should not be possible');
            end
        end
        
        function C = RightMatrixProduct(A_ten,B,flag)
            s_A = size(A_ten); s_B = size(B);
            C = MatrixOperations.Initialise([s_A(1),s_B(2),s_A(3)],flag);
            for j = 1:s_B(2)
                for l = 1:s_A(2)
                    C(:,j,:) = C(:,j,:) + A_ten(:,l,:)*B(l,j);
                end
            end
        end
        
        function C = LeftMatrixProduct(A,B_ten,flag)
            s_A = size(A); s_B = size(B_ten);
            % I will need to change the check here at a later time
            if(length(s_B) == 2)
                s_B(3) = 1;
            end
            C = MatrixOperations.Initialise([s_A(1),s_B(2),s_B(3)],flag);
            for i = 1:s_A(1)
                for l = 1:s_A(2)
                    C(i,:,:) = C(i,:,:) + A(i,l)*B_ten(l,:,:);
                end
            end
        end
        
        function C = LeftRightMatrixProduct(A,B_ten,flag)
            % I think it should be transpose
            C_temp  =   TensorOperations.RightMatrixProduct(B_ten,A,flag);
            C       =   TensorOperations.LeftMatrixProduct(A,C_temp,flag);
        end
        
        function C = Transpose(A,index,flag)
            assert(length(index)==2,'Two indices must be given for the transpose');
            assert(sum(index>3)+sum(index<0)==0,'Transpose only supported for Tensors of order 3');
            % Acts like a transpose operation for a 3 dimensional array.
            % The indices to switch are assumed to be given.
            s = size(A);
            if(sum(index==1)==0)
                % The transpose if acting on index 2 and 3
                C = MatrixOperations.Initialise([s(1),s(3),s(2)],flag);
                for j =1:s(2)
                    for k = 1:s(3)
                        C(:,k,j) = A(:,j,k);
                    end
                end
            elseif(sum(index==2)==0)
                % The transpose if acting on index 1 and 3
                C = MatrixOperations.Initialise([s(3),s(2),s(1)],flag);
                for j =1:s(1)
                    for k = 1:s(3)
                        C(k,:,j) = A(j,:,k);
                    end
                end
            else
                % The transpose if acting on index 1 and 2
                C = MatrixOperations.Initialise([s(2),s(1),s(3)],flag);
                for j =1:s(1)
                    for k = 1:s(2)
                        C(k,j,:) = A(j,k,:);
                    end
                end
            end
        end
    end
end
