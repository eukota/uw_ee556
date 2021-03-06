%% ybus
% Calculates the ybus matrix from bus and branch data
%%% USAGE
% * *[yb]=ybus(bus,branch)*
%%% INPUTS
% * *bus*: bus G and B admittance data
% * *branch*: branch R, X, G, and B data
%%% OUTPUTS
% * *yb*: ybus matrix
% * *err*: blank if no problems, error string if problem
function [yb,err]=ybus(BusNums,BusG,BusB,branch)
    % Parse branch
    [From,To,R,X,~,B,err]=parse_branch_data(branch);
    if(isempty(err)==0)
        disp(err);
        return;
    end
    rowcount=length(From);
    
    buscount=length(BusNums);
    yb_offdiag=zeros(buscount); % defaults to square size
    yb_B=zeros(buscount);
    
    % Off-Diagonal
    for x=1:rowcount
        f=From(x);
        t=To(x);
        yval=1/(R(x)+X(x)*1i);
        yb_offdiag(f,t)=-yval;
        yb_offdiag(t,f)=yb_offdiag(f,t);
        yb_B(f,t)=B(x)*1i;
        yb_B(t,f)=yb_B(f,t);
    end
    
    % On-Diagonal
    yb=yb_offdiag;
    for x=1:buscount
        busnum=BusNums(x);
        offdiagsum = -1*(sum(yb_offdiag(x,:)));
        offdiag_Bs = sum(yb_B(x,:))/2;
        bus_g=BusG(x);
        bus_b=BusB(x);
        yb(busnum,busnum)=offdiagsum + bus_g + bus_b*1i + offdiag_Bs;
    end
end
