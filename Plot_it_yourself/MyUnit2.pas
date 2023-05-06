unit MyUnit2;

interface
   uses MyTypes; //Types, functions and procedure definitions
   const MyKey = '222222'; //replace the value of MyKey with your Key given to you during the registration    
   
   procedure Make (Player: CPlayer; NTask:integer);
//*********************** An Example of **** ******************************************************
//*** Input Parameters:
//    CPlayer - object representing the player                                                    
//**************************************************************************************************   

implementation
   procedure Make (Player: CPlayer; NTask:integer);
   const MaxWords = 500;
   
   var
     SMarks: string := '.,?!'; 
     SSep: string := ' .,?!';
     SEng: string :='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
     SEngCaps: string :='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
     SEngSmall:  string :='abcdefghijklmnopqrstuvwxyz';
     i,j,k,m,nwords, CurrentLen: integer;
     c, c1, c2: char;
     updated: boolean;
     

   function ToCaps (s:string):string;
      var i,j : integer;
      begin
        for i:=1 to Length(s)do begin
          for j:=1 to Length(SEngSmall) do begin
            if s[i]=SEngSmall[j] then begin
               s[i]:=SEngCaps[j];
               break;
            end;
         end;
        end;
        ToCaps:=s;
      end;
 
   procedure Solve1; //To solve the first task
      begin
         CurrentLen:=Player.LenTxt;
         k:=1;
         c:=Player.GetChar(k);
         while k <= CurrentLen do begin 
            updated:=false;
            if (c=' ')and(k < CurrentLen) then begin
                c1:=Player.GetChar(k+1);
                if (c1 = ' ') then begin
                Player.DelChars(k+1,1);
                CurrentLen:=CurrentLen-1;
                updated:=true;
             end
             else begin
                if (pos(c1,SMarks)<>0) then begin
                   Player.DelChars(k,1);
                   CurrentLen:=CurrentLen-1;
                   c:=c1;
                   updated:=true;
                end
                else begin                   
                   k:=k+1;
                   c:=c1;
                   updated:=true;
                end;
             end;
         end;
         if (pos(c,SMarks)<>0)then begin
            c1:=Player.GetChar(k+1);
            if (c1 <> ' ') and (k < CurrentLen) then begin
               Player.InsChar(k+1,' ');
               CurrentLen:=CurrentLen+1;                
             end;
             k:=k+1;
             c:=c1;
             updated:=true;
          end; 
          if not updated then begin
             k:=k+1;
             c:=Player.GetChar(k);
          end;           
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
   type
      RWord = record
         s: string;
         start: integer;
         len: integer;
         deleted: boolean;
      end;
   
   var start, finish, len: integer;
       str:string;
       Words: array[1..MaxWords]of RWord; 
       i,j,k : integer;
      
   begin
      CurrentLen:=Player.LenTxt;
      start:=0; finish:=0;
      i:=1;
      j:=1;
      c1:=' ';
      c:=Player.GetChar(i);
      if (i+1)<=CurrentLen then c2:= Player.GetChar(i+1) else c2:=' ';
      str:='';
      while i<=CurrentLen do begin //separate words and write them to the Words array 
         str:='';
         if (pos(c1,SSep)<>0)and(pos(c,SEng)<>0) then begin //found first letter of a word 
            start:=i;
            str:=str+c;
            while true do begin    //while the word continues
              i:=i+1;
              c1:=c;
              c:=c2;
              if (i+1)<=CurrentLen then c2:= Player.GetChar(i+1) else c2:=' ';
              if (pos(c,SEng)<>0) then str:=str+c
              else break;
            end;  
            finish:=i-1;      //the word ended, we fix it start index in s, 
            len:=finish-start+1;
            Words[j].s:=ToCaps(str);
            Words[j].start:=start;
            Words[j].len:=len;
            Words[j].deleted:=false;
            writeln ('====',j,' **** ',Words[j].start:4,' ',Words[j].len:4,' *',Words[j].s,'*');            
            nwords:=j;
            j:=j+1;           
         end;
         i:=i+1;
         c1:=c;
         c:=c2;
         if (i+1)<=CurrentLen then c2:= Player.GetChar(i+1)else c2:=' ';   
      end;
      writeln ('*** nwords = ',nwords);
      
      for j:=1 to nwords do begin
        if Words[j].deleted then continue;
        for i:=j+1 to nwords do begin
          if Words[i].s=Words[j].s then begin  //delete the i-th word 
             Player.DelStr(Words[i].start, Words[i].len);
             Words[i].deleted:=true;
             for k:=1 to nwords do
               if (Words[k].start > Words[i].start) then Words[k].start:= Words[k].start-Words[i].len; 
          end;
        end;
        
      end;     
   end;   
    
   
   
   begin     // Executable part of the procedure Make
      case NTask of
         1: Solve1;
         2: Solve2;
         3: Solve3;
      end;   
   end;
     
end.