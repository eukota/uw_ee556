%% nrpfjacobian Newton-Raphson Power Flow Jacobian
% Calculates the Jacobian for a provided power system
function [itermap]=nrpf_jac(BusTypes,P,Q,V,T,ybus_matrix)
    [pcount,qcount,err]=jacobianCount(BusTypes); % P and Q equation counts
    if(isempty(err)==0)
        disp(err);
        return;
    end
    itermap=containers.Map;
    
    % Jacobian Submatrixes
    j11=zeros(pcount,pcount);
    j12=zeros(pcount,qcount);
    j21=zeros(qcount,pcount);
    j22=zeros(qcount,qcount);
    % Jacobian Submatrix Indexes
    j11_i=1; j12_i=1; j21_i=1; j22_i=1;
    j11_j=1; j12_j=1; j21_j=1; j22_j=1;
    
    % Iteration
    buscount=length(BusTypes);
    for n=1:buscount
        if(BusTypes(n)==1) % Slack Bus
            continue;
        elseif(BusTypes(n)==2) % PQ Bus
            for m=1:buscount
                if(BusTypes(m)==1) % Slack
                    continue;
                end
                % Partial of P with respect to Theta
                j11(j11_i,j11_j)=jptheta(n,m,V,T,ybus_matrix);
                j11_j=j11_j+1;
                % Partial of Q with respect to Theta
                j21(j21_i,j21_j)=jqtheta(n,m,V,T,ybus_matrix);
                j21_j=j21_j+1;
                % Only do partials with respect to V for PQ buses
                if(BusTypes(m)==2) 
                    % Partial of P with respect to V
                    j12(j12_i,j12_j)=jpv(n,m,V,T,ybus_matrix);
                    j12_j=j12_j+1;
                    % Partial of Q with respect to V
                    j22(j22_i,j22_j)=jqv(n,m,V,T,ybus_matrix);
                    j22_j=j22_j+1;
                end
            end
            j21_i=j21_i+1; j21_j=1;
            j22_i=j22_i+1; j22_j=1;
        elseif(BusTypes(n)==3) % PV Bus
            for m=1:buscount
                if(BusTypes(m)==1) % Slack
                    continue;
                end
                % Partial of P with respect to Theta
                j11(j11_i,j11_j)=jptheta(n,m,V,T,ybus_matrix);
                j11_j=j11_j+1;
                if(BusTypes(m)==2) % PQ
                    % Partial of P with respect to V
                    j12(j12_i,j12_j)=jpv(n,m,V,T,ybus_matrix);
                    j12_j=j12_j+1;
                end
            end
        end
        j11_i=j11_i+1; j11_j=1;
        j12_i=j12_i+1; j12_j=1;
    end
    jfull=[j11,j12;j21,j22];
    itermap('jacobian')=jfull;

    [Pmm,Qmm,err]=mismatch(P,Q,V,T,BusTypes,ybus_matrix);
    if(isempty(err)==0)
        disp(err);
        return;
    end
    itermap('Pmm')=Pmm;
    itermap('Qmm')=Qmm;

    % Invert Jacobian
    deltas=-1*jfull^-1*[Pmm;Qmm];

    % Update State Variables
    deltas_index=1;
    for n=1:buscount
        if BusTypes(n)==1 % slack
            continue;
        end
        T(n)=T(n)+deltas(deltas_index);
        deltas_index=deltas_index+1;
    end
    for n=1:buscount
        if BusTypes(n)==1 % slack
            continue;
        elseif BusTypes(n)==3 % PV
            continue;
        end
        V(n)=V(n)+deltas(deltas_index);
        deltas_index=deltas_index+1;
    end
    itermap('V')=V;
    itermap('T')=T;
end


