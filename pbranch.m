%% pbranch()
% calculate the power flow on a single branch
%%% USAGE
% * *[out]=pbranch(from,to,Voltage,Theta,Ybus)*
%%% INPUTS
% * *from_bus*: bus to start at
% * *to_bus*: bus to end at
% * *Voltage*: vector of voltage data
% * *Theta*: vector of voltage angle data
% * *Ybus*: full ybus matrix
%%% OUTPUTS
% * *out*: result of the real power on the target branch for given input
function [out]=pbranch(from,to,Voltage,Theta,Ybus)
    out=Voltage(from)*Voltage(to)*(real(Ybus(from,to))*cos(Theta(from)-Theta(to))...
                                  +imag(Ybus(from,to))*sin(Theta(from)-Theta(to)));
end