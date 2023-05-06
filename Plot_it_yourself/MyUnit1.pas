

unit MyUnit1;


interface
   uses MyTypes; //Types, functions and procedure definitions
   const MyKey = '111111'; //replace the value of MyKey with your Key given to you during the registration    
   
procedure Make (Player: CPlayer; NTask:integer);
//*********************** An Example of **** ******************************************************
//                 Non optimal procedure written by a green player   
//*** Input Parameters:
//    CPlayer - object representing the player                                                    
//**************************************************************************************************   

implementation
   
procedure Make (Player: CPlayer; NTask:integer);
   var
     Marks: string := '.,?!'; //remember that'...' is a punctuation mark too
     i: integer;
     c,c1: char;
     


   procedure Solve1;  //To solve the first task
   begin
   //first we delete all repeating spaces and spaces before marks  
      i:=1;
      while true do begin
         if (i > Player.LenTxt) then break;
         c:=Player.GetChar(i); c1:= Player.GetChar(i+1);
         if (c = ' ') and (c1 = ' ') then Player.DelChars(i,1) else 
           if (pos(c,Marks)<>0)and(Player.GetChar(i-1) = ' ') then Player.DelChars(i-1,1) 
              else i:=i+1;   
      end;
      //now we insert required spaces after Marks (without the last mark in the text)
      i:=1;
      while true do begin
         if (i >= Player.LenTxt) then break;
         if (Pos(Player.GetChar(i),Marks) <>0)and(Player.GetChar(i+1)<>' ') then begin
            Player.InsChar(i+1,' ');
            i:=i+2
         end
         else 
           i:=i+1;
      end;    
   end;
   
   procedure Solve2; //To solve the second task
   var
     i,j,k, CurrentLen: integer;
     s: array[1..2] of string;
     buffer: array of integer;
     indexBuffer: integer;
     c0,c4: char;
  begin
     CurrentLen:=Player.LenTxt;
     s[1]:='The';
     s[2]:='the';
     buffer := new integer[CurrentLen];
     indexBuffer := 0;
     i:=1;
     j:=0;
     while i <= 2 do begin
           k:=Player.FindStr(s[i]);         
           if (k<>0) then begin
              if (k>=2) then c0:=Player.GetChar(k-1) else c0:=' ';
              if (k<=CurrentLen-3)then c4:=Player.GetChar(k+3) else c4:=' ';
           end;
           if (k=0) then begin
              i := i + 1;
              continue;
           end;
           if (pos(c0,SSep)<>0)and(pos(c4,SSep)<>0) then begin
              if (i=1) then Player.SetChar(k,'A');
              if (i=2) then Player.SetChar(k, 'a');
              Player.DelChars(k+1,2); 
              CurrentLen:=CurrentLen-2;
           end
           else begin
             Player.SetChar(k+1, '*');
             buffer[indexBuffer] := k+1;
             indexBuffer := indexBuffer + 1
           end;
        end;
     while j < indexBuffer do begin
        Player.SetChar(buffer[j], 'h');
        j := j + 1;
      end;
   end;
   
   procedure Solve3; //To solve the third task
   begin
   
   end;   
   
   begin     // Executable part of the procedure Make
      case NTask of
         1: Solve1;
         2: Solve2;
         3: Solve3;
      end;   
   end;
end.