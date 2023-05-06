Program Plot_It_Yourself;

uses 
   MyUnit1, MyUnit2, MyTypes;

var 
   InputFile, OutputFile: text;

//***************************************************************************
//    Here the executable part of the Main program begins
//***************************************************************************
 
begin
  
   assign(InputFile, 'C:\Pascal\Plot_it_yourself\input.txt');
   MyTypes.ReadInit(InputFile);  
   MyTypes.PrintInit;
   writeln;
   writeln('************* Starting');
   writeln;
      
   try
       MyUnit1.Make(Players[1],GetNoTask);       
    except
       on e:MaxStepExceed do writeln('Player 1 exceeds the max number of steps');      
   end;
   try
      MyUnit2.Make(Players[2],GetNotask);       
    except
      on e:MaxStepExceed do writeln('Player 2 exceeds the max number of steps');      
   end;  
   
 //set the winner 
   if (Players[1].GetTxt = GetTarget)and( Players[2].GetTxt<>GetTarget) then begin //first player won
      winner[1] := Players[1].GetUserId; winner[2] :=Players[2].GetUserId; winner[3]:=0;  
   end;
   if (Players[1].GetTxt <> GetTarget) and( Players[2].GetTxt=GetTarget) then begin //second player won
      winner[1] := Players[2].GetUserId; winner[2] :=Players[1].GetUserId; winner[3]:=0; 
   end;
   if (Players[1].GetTxt <> GetTarget)and( Players[2].GetTxt<>GetTarget) then begin //both players lost
      winner[1] := Players[1].GetUserId; winner[2] :=Players[2].GetUserId; winner[3]:=2; 
   end;
   if (Players[1].GetTxt = GetTarget)and( Players[2].GetTxt=GetTarget) then begin 
      if (Players[1].GetStep < Players[2].GetStep) then begin //first player won
         winner[1] := Players[1].GetUserId; winner[2] :=Players[2].GetUserId; winner[3]:=0;    
      end; 
      if (Players[1].GetStep > Players[2].GetStep) then begin //second player won
         winner[1] := Players[2].GetUserId; winner[2] :=Players[1].GetUserId; winner[3]:=0;    
      end; 
      if (Players[1].GetStep = Players[2].GetStep) then begin //draw
         winner[1] := Players[1].GetUserId; winner[2] :=Players[2].GetUserId; winner[3]:=1;    
      end;          
   end;         

   assign (OutputFile,'C:\Pascal\Plot_it_yourself\output.txt');
   MyTypes.OutputLog (OutputFile); 
   MyTypes.PrintResults;
   MyTypes.DestroyPlayers;

   writeln ('************* The End');

end.