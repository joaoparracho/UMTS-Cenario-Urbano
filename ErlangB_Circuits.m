function [ErlangB_Circuits] = ErlangB_Circuits(erlangs,GoS)
   rightendpointCapacity=0;
   leftendpointCapacity=0;
   currentGoS = ErlangB_GoS(erlangs, rightendpointCapacity);
    
   while (currentGoS > GoS)
       leftendpointCapacity = rightendpointCapacity;
       rightendpointCapacity = rightendpointCapacity + 32;
       currentGoS = ErlangB_GoS(erlangs, rightendpointCapacity);
   end
    midCapacity = (leftendpointCapacity + rightendpointCapacity) / 2;
    currentGoS = ErlangB_GoS(erlangs, midCapacity);
    if( currentGoS > GoS)
       leftendpointCapacity = midCapacity;
    else
       rightendpointCapacity = midCapacity;
    end
  while ((rightendpointCapacity - leftendpointCapacity) > 1)
      midCapacity = (leftendpointCapacity + rightendpointCapacity) / 2;
     currentGoS = ErlangB_GoS(erlangs, midCapacity);
    if( currentGoS > GoS)
       leftendpointCapacity = midCapacity;
    else
       rightendpointCapacity = midCapacity;
    end
 
   end
 
   ErlangB_Circuits = rightendpointCapacity;
end