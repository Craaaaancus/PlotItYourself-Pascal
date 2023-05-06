unit MyTypes;

interface

   
const
   Separator='*#*#*#*#';   //A string to separate user's debug print from the output log
   NUsers = 2; //number of users
   MaxNumberOfSteps =10000;
//   NoTexts = 15; //number of source texts
   NoSpaces = 10;  //number of spaces to be inserted in the source text
   NoTasks =3; //number of tasks 
   MaxWords=500;
   
type
  
   MaxStepExceed = class (System.exception) end; //if player exceeds max number of steps we raise this exception
   
   THistory = record   //log record
     Step: integer;
     TypeMove: char; //G - get, S - set, I - insert, D - delete, L - get length
     MoveResult: char; //N - normal, O - out of array bounds 
     Txt: string; //current text modified by the user
     Position: integer; // position of letter for which the function was applied
   end;
   
   


   CPlayer = class  
   private  
      fID: integer; //player ID 
      fKey: string; //player key 
      fName: string; //player name 
      fTxt : string;   //current player's text
      fStep: integer;  //number of steps done by the player
      fHistory: array [0..MaxNumberOfSteps]of THistory;  //log of the user
   public
      
      constructor Create(Txt:string);
      var i: integer;
      begin
         fID:=0;
         fKey:='';
         fName:='';
         fTxt:=Txt;
         fStep:=0;
         for i:=0 to MaxNumberOfSteps do begin
            fHistory[i].Step:=i;
            fHistory[i].TypeMove:='*';
            fHistory[i].MoveResult:='*';
            fHistory[i].Txt:=Txt;
            fHistory[i].Position:=-1
         end;
      end;
      destructor Free; begin end;  //to free allocated memory in Free Pascal
      
      function GetChar(i: integer):char;   //functions and procedures provided for the players (defined in the implementation section)
      procedure SetChar(i: integer; ch:char);
      procedure InsChar(i: integer; ch:char);
      procedure InsStr(i: integer; s:string);
      procedure DelChars(i,n: integer);
      procedure DelStr(i,n: integer);
      function FindStr(s:string):integer; 
      function LenTxt:integer;
      
      
      function GetStep: integer; begin GetStep:=fStep; end;
      function GetTxt:string; begin GetTxt:=fTxt; end;
      procedure SetUserId(ID: integer); begin fID:=ID; end;
      function GetUserID:integer; begin GetUserID:=fID; end;
      procedure SetUserKey(Key: string); begin fKey:=Key; end;
      function GetUserKey:string; begin GetUserKey:=fKey; end;
      procedure SetUserName(Name: string); begin fName:=Name; end;
      function GetUserName:string; begin GetUserName:=fName; end;
      procedure SetHistory(Step:integer; Hist:THistory); begin fHistory[Step]:=Hist; end;
      function GetHistory(Step:integer):THistory; begin GetHistory:=fHistory[Step]; end;      
   end; //class CPlayer description
   
   function SetTarget(NTask:integer;Src:string):string;  //to make reference resulting text 
   function GetNotask: integer; 
   function GetSource: string;
   function GetTarget: string;
   function GetMaxSteps: integer;

   
   procedure CreatePlayers; //to allocate memory for an array of players
   procedure DestroyPlayers; //to free allocated memory
   
   procedure PrintInit; // input data output to the console 
   procedure ReadInit (InputFile: text); //read and generate input data  
   procedure OutputLog(OutputFile: text); //log output for visualization
   procedure PrintResults; //results of the game output to the console
   
   
var
  Players: array[1..NUsers] of CPlayer; //array of pointers to the players
  Winner: array [1..3] of integer; //service array
  SMarks: string := '.,?!'; 
  SSep: string := ' .,?!';
  SEng: string :='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  SEngCaps: string :='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  SEngSmall:  string :='abcdefghijklmnopqrstuvwxyz'; 
 
  Eng: set of char:=['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                     'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
  Cyr: set of char:=['А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ь','Ы','Ъ','Э','Ю','Я',
                     'а','б','в','г','д','е','ё','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ь','ы','ъ','э','ю','я'];
  Marks: set of char:=['.',',','?','!'];  
 

implementation
   uses MyUnit1, MyUnit2; //the uses statement placed in this section to avoid recursive modules reference
    
   var 
     MaxSteps : integer; //the number of steps after which the game will be over
     Source_: string;  //source text obtained by random inserting spaces into text entered from a configuration file 
     Target_: string;  //Sample text for players to complete
     NoTask: integer;  //number of the task to be solved
     

procedure deleteBlanks(var Str: string); //delete blanks from the end of the Str
   var l, i: integer;
   begin
      l := length(Str);
      for i := l downto 1 do 
         if Str[i] = ' ' then Delete(Str, i, 1)
         else break;
      end;
   
procedure CreatePlayers; //allocate memory for players array
   var i: integer;
   begin
     for i:=1 to NUsers do
        Players[i]:= CPlayer.Create('');   
   end;
   
procedure DestroyPlayers; //free memory allocated for players array
   var i: integer;
   begin
     for i:=1 to NUsers do
        Players[i].Free;   
   end;

procedure ReadInit (InputFile: text); // Read data from the configuration file, init and modify some data
   var
     i, i1,i2: integer;
     s1, s2: string;
     Hist: Thistory;
   
   begin
      Console.OutputEncoding := System.Text.Encoding.GetEncoding(1251); //russian texts console encoding table 
      CreatePlayers;  //allocate memory for players array
      
      reset(InputFile);
      randomize;
      
      MaxSteps:=0;
      NoTask:=0;
      Target_:='';
      for i:=1 to 3 do winner[i]:=0;
               
      readln(InputFile,i1,i2);       //reading data 
      Players[1].SetUserID(i1); Players[2].SetUserID(i2); 
      
      readln(InputFile,s1);                       
      deleteBlanks(s1);
      Players[1].SetUserKey(s1);
      readln(InputFile,s2);                       
      deleteBlanks(s2);
      Players[2].SetUserKey(s2);
      
      readln(InputFile,s1);                       
      deleteBlanks(s1);
      Players[1].SetUserName(s1);
      readln(InputFile,s2);                       
      deleteBlanks(s2);
      Players[2].SetUserName(s2);
 
      readln(InputFile,MaxSteps);
      if (MaxSteps > MaxNumberOfSteps) then MaxSteps := MaxNumberOfSteps;
      readln(InputFile,NoTask);
      if (GetNoTask > NoTasks) then NoTask := NoTasks;
      if (GetNoTask < 1) then NoTask := 1;
      
      readln(inputFile,Source_);
      deleteBlanks(Source_); //deletes blanks from the end of the source
      
      i:=1;  //insert random spaces to the text
      while true do begin
        if  i>=Length(Source_) then break;
        if (Source_[i] = ' ') or (Source_[i] in Marks) then begin
          if random(2)=0 then insert(' ',Source_,i+1);
        end; 
        if (Source_[i] in Marks)then begin
          if random(2)=0 then insert(' ',Source_,i);
          i:=i+1;
        end; 
        i:=i+1;
      end;
            
      Target_:=SetTarget(GetNoTask,Source_);  //make sample text
      
      for i1:=1 to NUsers do begin  //init log file
         Players[i1].fTxt:=Source_;
         Hist.Step:=0;
         Hist.TypeMove:='N';
         Hist.MoveResult:='N';
         Hist.Txt:=Players[i1].fTxt;
         Hist.Position:=-1;
         Players[i1].SetHistory(0,Hist);
         for i2:=1 to MaxNumberOfSteps do begin
            Hist.Step:=i1;
            Hist.TypeMove:='*';
            Hist.MoveResult:='*';
            Hist.Txt:='';
            Hist.Position:=-1;
            Players[i1].SetHistory(i2,Hist);
         end;
      end;
   end; //readInit 
   
procedure PrintInit; // initial data output to console

   begin
      writeln ('********* Initial Settings:');
      writeln ('User & Opponent   ID: ' ,Players[1].GetUserId,'  ',Players[2].GetUserId);
      writeln ('User & Opponent Keys     from WeaZet   : ' ,Players[1].GetUserKey,'  ',Players[2].GetUserKey);
      writeln ('User & Opponent Keys declared in Units : ' ,MyUnit1.MyKey,'  ',MyUnit2.Mykey);
      writeln ('User & Opponent names: ', Players[1].GetUserName,'  ',Players[2].GetUserName);     
      
      writeln ('Max number of steps = ',GetMaxSteps);
      writeln;
      writeln ('Source text of ',Length(GetSource),' characters:');
      writeln (GetSource);
      writeln ('Target text of ',Length(GetTarget),' characters:');
      writeln (GetTarget);
   end; //PrintInit
   
procedure OutputLog(OutputFile: text);  //writes log History to outputFile. History[0] is the start position for both hunters
   var NoStep, i, AllPlayersSteps: integer;        
   
   begin
      rewrite (OutputFile);  
      writeln (OutputFile,Separator);
      writeln (OutputFile, Winner [1],'  ', Winner[2],'  ', Winner[3]);
      writeln (OutputFile, Players[1].GetUserId,'  ',Players[2].GetUserId);
      writeln (OutputFile, Players[1].GetUserKey,'  ',Players[2].GetUserKey);
      writeln (OutputFile, Players[1].GetUserName);
      writeln (OutputFile, Players[2].GetUserName);
      writeln (OutputFile, GetMaxSteps);
      writeln (OutputFile, Length(GetSource),' ',Length(GetTarget));
      writeln (OutputFile, GetNotask);
      writeln (OutputFile, GetSource);
      writeln (OutputFile, GetTarget); 
      AllPlayersSteps:=0;
      for i:=1 to NUsers do AllPlayersSteps:=AllPlayersSteps+Players[i].GetStep;      
      
      writeln (OutputFile,AllPlayersSteps);
      
      for NoStep:=0 to MaxNumberOfSteps do begin
         for i:=1 to NUsers do begin
            if (NoStep <=Players[i].fStep) then begin
               writeln (OutputFile, i:3,' ',Players[i].fHistory[NoStep].Step:5,' ',Players[i].fHistory[NoStep].TypeMove,' ',Players[i].fHistory[NoStep].MoveResult, ' ', Players[i].fHistory[NoStep].Position);
               writeln (OutputFile,Players[i].fHistory[NoStep].Txt); 
            end;   
         end;       
      end;
      
     close (OutputFile);                 
   end; //OutputLog
   

procedure PrintResults; // Results output to console
   var
      i: integer;
   begin
      writeln ('********* Results:');
      for i:=1 to NUsers do begin 
         writeln ('For Player ', Players[i].GetUserId);
         writeln ('Steps done: ',Players[i].GetStep);     
         writeln ('Result:');
         writeln(Players[i].fTxt);
         writeln;
      end;

      if (winner[3]=0)then begin
        writeln ('Player ',winner[1], ' won, player ',winner[2], ' lost');
      end;
      if (winner[3]=1)then writeln ('Draw'); 
      if (winner[3]=2)then writeln ('Both players lost');     
   end; //PrintResults   
     
         
function CPlayer.GetChar(i: integer):char;
   
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded');
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='G';
      if (i<1)or (i>length(fTxt)) then begin
         GetChar:=' ';
         fHistory[fStep].MoveResult:='O'; //out of bounds
         fHistory[fStep].Position:=-1;
      end
      else begin 
         GetChar:=fTxt[i];
         fHistory[fStep].MoveResult:='N'; //normal
         fHistory[fStep].Position:= i-1; // i - 1 поскольку индексация должна начинаться с 0
      end;
      fHistory[fStep].Txt:=fTxt;
   end;
     
procedure CPlayer.DelChars(i,n: integer);   
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded');
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='D';
      if (i<1)or (i>length(fTxt)) then begin 
         fHistory[fStep].MoveResult:='O'; //out of bounds
         fHistory[fStep].Position:=-1;
      end
      else begin
         delete(fTxt,i,n);
         fHistory[fStep].MoveResult:='N'; //normal
         fHistory[fStep].Position:= i-1; // i - 1 поскольку индексация должна начинаться с 0
      end;
      fHistory[fStep].Txt:=fTxt;
   end;
   
procedure CPlayer.DelStr(i,n: integer); 
  begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded');
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='D';
      if (i<1)or (i>length(fTxt)) then begin 
         fHistory[fStep].MoveResult:='O'; //out of bounds
         fHistory[fStep].Position:=-1;
      end
      else begin
         delete(fTxt,i,n);
         fHistory[fStep].MoveResult:='N'; //normal
         fHistory[fStep].Position:=i-1; // i - 1 поскольку индексация должна начинаться с 0
      end;
      fHistory[fStep].Txt:=fTxt;
   end;
  
     
procedure CPlayer.SetChar(i: integer; ch:char);
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded');  
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='S';
      if (i<1)and (i>length(fTxt)) then begin
         fHistory[fStep].MoveResult:='O'; //out of bounds
         fHistory[fStep].Position:=-1;
      end
      else begin
         fTxt[i]:=ch;
         fHistory[fStep].MoveResult:='N'; //normal
         fHistory[fStep].Position:=i-1; // i - 1 поскольку индексация должна начинаться с 0
      end;
      fHistory[fStep].Txt:=fTxt;
   end;
     
procedure CPlayer.InsChar(i: integer; ch:char);
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded'); 
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='I';
      if (i<1)and (i>length(fTxt)) then begin
         fHistory[fStep].MoveResult:='O';//out of bounds
         fHistory[fStep].Position:=-1;
      end
      else begin
         insert(ch,fTxt,i);
         fHistory[fStep].MoveResult:='N'; //normal
         fHistory[fStep].Position:=i-1; // i - 1 поскольку индексация должна начинаться с 0
      end;
      fHistory[fStep].Txt:=fTxt;
   end;
   
procedure CPlayer.InsStr(i: integer; s:string);
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded'); 
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='I';
      if (i<1)and (i>length(fTxt)) then begin
         fHistory[fStep].MoveResult:='O';//out of bounds
         fHistory[fStep].Position:=-1;
      end
      else begin
         insert(s,fTxt,i);
         fHistory[fStep].MoveResult:='N'; //normal
         fHistory[fStep].Position:=i-1; // i - 1 поскольку индексация должна начинаться с 0
      end;
      fHistory[fStep].Txt:=fTxt;
   end;
   
function CPlayer.FindStr(s:string):integer;
   var find : integer;
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded'); 
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='F';
      fHistory[fStep].MoveResult:='N'; //normal
      find:=Pos(s,fTxt);
      fHistory[fStep].Position:=find-1; // Pos - 1 поскольку индексация должна начинаться с 0
      if find = 0 then begin
        fHistory[fStep].MoveResult:='F'; //not found
      end;
      FindStr:=find;
      fHistory[fStep].Txt:=fTxt;
   end; 
      
function CPlayer.LenTxt: integer;
   begin
      if (fStep>=GetMaxSteps) then raise new MaxStepExceed ('MaxStep exceeded'); 
      fStep:=fStep+1;
      fHistory[fStep].Step:=fStep;
      fHistory[fStep].TypeMove:='L';
      fHistory[fStep].MoveResult:='N'; //normal
      fHistory[fStep].Position:=-1;
      LenTxt:=length(fTxt);
      fHistory[fStep].Txt:=fTxt;
   end;
   
function GetSource: string;
   begin
      GetSource:=Source_;  
   end;
   
   function GetTarget: string;
   begin
      GetTarget:=Target_;    
   end; 
   
function GetMaxSteps: integer;
   begin
      GetMaxSteps:=MaxSteps;    
   end; 
   
function GetNoTask: integer;
   begin
      GetNoTask:=NoTask;    
   end; 
   

function SetTarget1(Src:string):string;  //makes sample string for the task1 
   var
     k,CurrentLen : integer; 
     updated: boolean;
   begin
      SetTarget1:=Src;
      CurrentLen:=length(Src);
      k:=1;
      while k <= CurrentLen do begin  
         updated:=false;
         if (Src[k]=' ')and(k < CurrentLen) then begin
             if (Src[k+1] = ' ') then begin
                delete (Src,k+1,1);
                CurrentLen:=CurrentLen-1;
                updated:=true;
             end
             else begin
             if (Src[k+1] in Marks) then begin
                delete (Src,k,1);
                CurrentLen:=CurrentLen-1;
                updated:=true;
             end
             else begin                   
                k:=k+1;
                updated:=true;
             end;
          end;
        end;
        if (Src[k] in Marks)and (k < CurrentLen)then begin
           if Src[k+1] <> ' ' then begin
              insert(' ',Src,k+1);
              CurrentLen:=CurrentLen+1;                
            end;
            k:=k+1;
            updated:=true;
         end; 
         if not updated then begin
            k:=k+1;
         end;            
      end;  
      SetTarget1:=Src;
   end;  //SetTarget1 

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
  
function SetTarget2(Src:string):string;  //makes sample string for the task2 
   var
     i,j,k, CurrentLen: integer;
     s: array[1..2] of string;
     buffer: array of integer;
     indexBuffer: integer;
     c0,c4: char;
   begin
     CurrentLen:= Length(Src);
     s[1]:='The';
     s[2]:='the';
     buffer := new integer[CurrentLen];
     indexBuffer := 0;
     i:=1;
     j:=0;
     while i <= 2 do begin
           k:= Pos(s[i], Src);      
           if (k<>0) then begin
              if (k>=2) then c0:= Src[k-1] else c0:=' ';
              if (k<=CurrentLen-3) then c4:=Src[k+3] else c4:=' ';
           end;
           if (k=0) then begin
              i := i + 1;
              continue;
           end;
           if (pos(c0,SSep)<>0)and(pos(c4,SSep)<>0) then begin
              if (i=1) then Src[k] := 'A';
              if (i=2) then Src[k] := 'a';
              delete(Src, k+1, 2);
              CurrentLen:=CurrentLen-2;
           end
           else begin
             Src[k+1] := '*';
             buffer[indexBuffer] := k+1;
             indexBuffer := indexBuffer + 1
           end;
        end;
     while j < indexBuffer do begin
        Src[buffer[j]]:='h';
        j := j + 1;
      end;
      SetTarget2:=Src
   end;  


function SetTarget3(Src:string):string;  //makes sample string for the task3 
   type
      RWord = record
         s: string;
         start: integer;
         len: integer;
         deleted: boolean;
      end;
   
   var start, finish, len: integer;
       CurrentLen: integer;
       str:string;
       Words: array[1..MaxWords]of RWord; 
       i,j,k, nwords : integer;
       c,c1,c2 : char;
      
   begin
      SetTarget3:=Src;
      CurrentLen:=length(Src);
      start:=0; finish:=0;
      i:=1;
      j:=1;
      c1:=' ';
      c:=src[i];
      if (i+1)<=CurrentLen then c2:= src[i+1] else c2:=' ';
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
              if (i+1)<=CurrentLen then c2:= src[i+1] else c2:=' ';
              if (pos(c,SEng)<>0) then str:=str+c
              else break;
            end;  
            finish:=i-1;      //the word ended, we fix it start index in s, 
            len:=finish-start+1;
            Words[j].s:=ToCaps(str);
            Words[j].start:=start;
            Words[j].len:=len;
            Words[j].deleted:=false;
 //           writeln ('====',j,' **** ',Words[j].start:4,' ',Words[j].len:4,' *',Words[j].s,'*');            
            nwords:=j;
            j:=j+1;           
         end;
         i:=i+1;
         c1:=c;
         c:=c2;
         if (i+1)<=CurrentLen then c2:= src[i+1]else c2:=' ';   
      end;
//      writeln ('*** nwords = ',nwords);
      
      for j:=1 to nwords do begin
        if Words[j].deleted then continue;
        for i:=j+1 to nwords do begin
          if Words[i].s=Words[j].s then begin  //delete the i-th word 
             Delete(src,Words[i].start, Words[i].len);
             Words[i].deleted:=true;
             for k:=1 to nwords do
               if (Words[k].start > Words[i].start) then Words[k].start:= Words[k].start-Words[i].len; 
          end;
        end;        
      end;  
      SetTarget3:=Src;
   end;   
    
   
function SetTarget(NTask:integer;Src:string):string;  //makes sample text that players should make for the task NTask from the string Src
   begin
     SetTarget:=Src;     
     case NTask of
       1: SetTarget:=SetTarget1(Src);
       2: SetTarget:=SetTarget2(Src);
       3: SetTarget:=SetTarget3(Src)
     else
       SetTarget:=Src;    
     end; 
   end; //SetTarget
   
 
   
end.  //unit MyTypes