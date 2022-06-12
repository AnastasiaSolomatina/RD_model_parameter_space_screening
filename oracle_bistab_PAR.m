function inside = oracle_bistab_PAR(x)
%x is a vector with k_AP and k_PA

%C = [6,0];%center of a circle

    global k_AP k_PA
%if number ==1
   % f1 = ( ((sum(abs(x-C).^2)).^(1/2)) <=2)';
    
    k_AP = x(1);
    k_PA = x(2);
    
    if ((k_AP > 0.0) && (k_PA > 0.0) && (k_AP < 3.0) && (k_PA < 3.0))
    
        A_min = 0.0;
        A_max = 3.3;%RhoA/Phi;
        P_min = 0.0;
        P_max = 3.3;%RhoP/Phi;
        nIC = 6; %number of init.cond. for each parameter set

        [A,P] = allSS_PAR(A_min, A_max, P_min, P_max, nIC);
        [value,~] = JacPAR(A,P);
        %numStab(it_1,it_2) = value;
        if (value >1)
            inside = 1;
%             x0 = x';
%             save('myFeasPoints.txt', 'x0', '-ASCII','-append');                
        else
            inside = 0;
        end
    else 
        inside = 0;
    end
  
end
    
    
    
