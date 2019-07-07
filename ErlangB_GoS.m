function [ErlangB_GoS] = ErlangB_GoS(erlangs,Circuits)
   if (erlangs == 0)
       ErlangB_GoS = 0;
   else
       s = 0;
       for i = 1 : Circuits
           s = (1 + s) * i / erlangs;
       end
       ErlangB_GoS = 1 / (1 + s);
    end 
end 
 

