{TODO

viz tady bude asi chyba

}
program Checkers;
Uses Crt;
type T_board = array[0..7,0..7] of integer;
     T_cursor = record
           x:byte;
           y:byte;
           end;
     T_board_list = array[0..3] of T_board;
var difficulty:byte;    //Difficulty bude počet rekurzí
    board, pos_state:T_board;
    cursor:T_cursor;
    game_over, take_action {Přechod k logice}
      ,sec_move: boolean;
    key:char;

procedure menu(var difficulty:byte);
begin
  repeat
    ClrScr;
    writeln('CHECKERS');
    writeln('Pro start hry zadej obtiznost 1 - 5.');
    writeln();
    writeln('Pro napovedu zadej 0');
    write('>>>  ');
    readln(difficulty);
    if difficulty = 0 then
      begin
        writeln('Hra se ovlada klavesami:');
        writeln('W,A,S,D   = Pohyb');
        writeln('SPACE     = Zvolit');
        writeln('C         = Zrusit');
        writeln('Pravidla damy jsou na wikipedii.');
        writeln('Pro navrat do menu stiskni ENTER');
        readln();
      end
    else
      if (difficulty < 0) or (difficulty > 5) then
      begin
        writeln('Stiskni ENTER a zkus to znovu a tentokrat spravne:-P');
        readln();
      end;
  until (difficulty > 0) and (difficulty < 8);
end;

procedure render(board:T_board;recursed:Byte);
var x,y,i:integer;
begin
  //ClrScr;
  gotoxy(1,1);
  for y:= 0 to 7 do
    for i:=0 to 2 do
      begin
        for x:=0 to 7 do
          begin                                                 //-------------
            if (x + y) mod 2 = 0 then
            begin                                               //Recursed a readln smaž!
              TextBackground(Black);
              write('     ');
            end                                                //-----------------
            else
            begin
              TextBackground(White);
              write(' ');
              if i = 1 then
                case board[x,y] of
                  0: TextBackground(White);
                  1: TextBackground(Red);
                  -1: TextBackground(Blue);
                end;
              write('   ');
              TextBackground(White);
              write(' ');
            end;
        end;
        writeln();
      end;
  textBackground(Black);

                               //writeln(recursed);
end;

procedure simple_render(board:T_board);
var x,y,i:integer;
begin
  ClrScr;
  for y:= 0 to 7 do
    begin
      for x:=0 to 7 do
        begin
          write(board[x,y]:3);
        end;
      writeln();
    end;
end;

procedure board_init(var board:T_board);
var x,y:integer;
begin
  for y:=0 to 7 do
    for x:=0 to 7 do
      board[x,y]:= 0;
  board[1,0]:= 0; board[3,0]:= 0; board[5,0]:= 0; board[7,0]:= 0;
  board[0,1]:= 0; board[2,1]:= 0; board[4,1]:= 0; board[6,1]:= 0;
  board[1,2]:= 0; board[3,2]:= 0; board[5,2]:= 0; board[7,2]:= -1;
  board[0,7]:= 0; board[2,7]:= 0; board[4,7]:= 0; board[6,7]:= 0;
  board[1,6]:= 0; board[3,6]:= 0; board[5,6]:= 0; board[7,6]:= 0;
  board[0,5]:= 0; board[2,5]:= 1; board[4,5]:= 1; board[6,5]:= 0;
end;

function get_color(x,y:Byte):Byte;
begin
  if (x + y) mod 2 = 0 then get_color:=Black
  else get_color:=White;
end;

procedure cursor_blink(color:Byte;x,y:Byte);
begin
TextBackground(color);
gotoxy(x-2, y);
write(' ');
gotoxy(x, y+1);
write(' ');
gotoxy(x+2, y);
write(' ');
gotoxy(x, y-1);
write(' ');
end;

function board_coor(k:Byte;x:Boolean):Byte; //Converting board to screen
begin
  if x = True then
    board_coor:= 5*k + 3
  else
    board_coor:= 3*k + 2;
end;

procedure move_stone(var board:T_board;x,y:Byte;var continue,sec_move:Boolean;var cursor:T_cursor);
var scr_x,scr_y,L_clr,R_clr:Byte;
    go_on:Boolean;
    choice_x,choice_y:Byte;
    chosen_x,chosen_y:Byte;
    choL_Y,choL_X,choR_Y,choR_X:Byte;
begin
   //Sec_move je pro nássobné skoky v tahu
  continue:=False;  //Continue zabraňuje pokračování v hlavní smyčce při nemožném tahu
  go_on:=False;
  L_clr:= 0;   //1 je pro možnost pohybu, 2 pro skok a 0 je nic.
  R_clr:= 0;
  scr_x:= board_coor(x,True);   //Načtení hodnot pro display
  scr_y:= board_coor(y,False);

  if y>0 then
    begin   //Podmínky pro volbu tahu (Volné pravé/levé políčko)
      if (x<7) and (board[x+1,y-1] = 0) then
        begin
          R_clr:= 1;
          choice_x:=scr_x+4;      //Choice je volba na obrazovce
          choice_y:=scr_y-3;
          chosen_x:= x+1;         //Chosen je volba na boardě
          chosen_y:=y-1;
        end
      else if (y>1) and (x<6) and (board[x+1,y-1] = -1) and (board[x+2,y-2] = 0) then
        begin
          R_clr:= 2;
          choice_x:=scr_x+9;
          choice_y:=scr_y-6;
          chosen_x:= x+2;
          chosen_y:=y-2;
        end;
      choR_X:= chosen_x;        //Chi ukládají hodnoty, pro manipulaci s kurzorem
      choR_Y:= chosen_y;
      if (x>0) and (board[x-1,y-1] = 0) then
        begin
          L_clr:= 1;
          choice_x:=scr_x-6;
          choice_y:=scr_y-3;
          chosen_x:= x-1;
          chosen_y:=y-1;
        end
      else if (y>1) and (x>1) and (board[x-1,y-1] = -1) and (board[x-2,y-2] = 0) then
        begin
          L_clr:= 2;
          choice_x:=scr_x-11;
          choice_y:=scr_y-6;
          chosen_x:= x-2;
          chosen_y:=y-2;
        end;
      choL_X:= chosen_x;
      choL_Y:= chosen_y;
    end;

  if sec_move = True then
    begin
      continue:=True;
      if choL_X = x-1 then L_clr:=0;
      if choR_x = x+1 then R_clr:=0;
    end;

  if (L_clr<>0) or (R_clr<>0) then
    begin
      continue:=True;   //Tohlw zařizuje postup k renderu a AI

      gotoxy(scr_x-1,scr_y);
      textBackground(Yellow);
      write('   ');
      textBackground(Black);
      while go_on = False do
        begin
          //--------------------------↓↓Toto se stará o kurzor
          gotoxy(choice_x,choice_y);
          textBackground(Green);
          write('   ');
          repeat until KeyPressed;
          key:=readkey();
          gotoxy(choice_x,choice_y);
          textBackground(White);
          write('   ');
          textBackground(Black);
          //-----------------------------
          case key of
            'a': if L_clr<>0 then
                   begin
                     chosen_x:=choL_X;
                     chosen_y:=choL_Y; //chosen je boarda, choice je pro render
                     choice_x:=board_coor(chosen_x ,True) - 1;
                     choice_y:=board_coor(chosen_y,False);
                   end;
            'd': if R_clr <>0 then
                   begin
                     chosen_x:=choR_X;
                     chosen_y:=choR_Y;
                     choice_x:=board_coor(chosen_x,True) - 1;
                     choice_y:=board_coor(chosen_y,False);
                   end;
            ' ': begin
                   cursor.x:=chosen_x;
                   cursor.y:=chosen_y;
                   if (chosen_x = x-2) then
                     begin
                       board[x-1,y-1]:=0;
                       sec_move:= True;
                     end;
                   if (chosen_x = x+2) then
                     begin
                       board[x+1,y-1]:=0;
                       sec_move:= True;
                     end;
                   board[x,y]:=0;
                   board[chosen_x,chosen_y]:= 1;
                   go_on:=True;
                 end;//TODO Remove piece after being jumped over, modify procedure to be AI friendly
          end;

        end
    end;
end;

function get_difference(board:t_board):integer;
{Hráč - CPU => kladné je dobré
 Dáma je za pětinásobek}
var x,y:byte;
begin
  get_difference:=0;
  for y:=0 to 7 do
    for x:= 0 to 7 do
      get_difference += board[x,y];
end;

function find_jumps(board:T_board; x,y:Byte; player:integer):T_board_list;
var index,i:byte;
begin
  for i:= 0 to 3 do find_jumps[i][0,0]:= 42;
  index:=0;
  if board[x,y] = player * 1 then //běžný kámen
    if (y > -1 + player) and (y < 8 + player) then
      begin
        if (x > 0) then
          begin
            if (board[x-1, y - player] = 0) then    //Vlevo nad je místo \\\   pro lidského hráče směr pohybu klesá
              begin
                find_jumps[index] := board;
                find_jumps[index][x,y]:= 0;
                find_jumps[index][x-1, y - player]:= player * 1;
                index += 1;
              end;
            if (x>1) and (y > -1 + (2 * player)) and (y < 8 + (2*player)) then
              if (board[x-1, y - player] = player * -1) and (board[x-2, y - player*2] = 0) then
                begin
                  find_jumps[index] := board;
                  find_jumps[index][x,y]:= 0;
                  find_jumps[index][x-1,y - player]:= 0;
                  find_jumps[index][x-2, y - player*2]:= player * 1;
                  index += 1;
                end;
          end;
        if (x < 7) then
          begin
            if (board[x+1, y - player] = 0) then   //Vpravo nad je místo
              begin
                find_jumps[index] := board;
                find_jumps[index][x,y]:= 0;
                find_jumps[index][x+1, y - player]:= player * 1;
                index += 1;
              end;
            if (x<6) and (y > -1 + (2 * player)) and (y < 8 + (2*player)) then
              if (board[x+1, y - player] = player * -1) and (board[x+2, y - player*2] = 0) then
                begin
                  find_jumps[index] := board;
                  find_jumps[index][x,y]:= 0;
                  find_jumps[index][x+1,y - player]:= 0;
                  find_jumps[index][x+2, y - player*2]:= player * 1;
                  index += 1;
                end;
          end;
      end;
end;

function find_best_move (var in_board:T_board;recursed:Byte;player:integer):integer;
var y,x,i,k:Byte;
    scored_in_move:integer;
    editable_board:T_board;
    board_list,boards_to_select: T_board_list;     //boards_to_select uchovává hodnotu původních nezrekurzovaných board


begin
  editable_board:= in_board;
  find_best_move:= 0; //inicializace pro případ, že nelze udělat další tah
  scored_in_move:= 0;
  if recursed = difficulty  then find_best_move:= get_difference(editable_board)  // Human musí hrát co nejlíp taky -> proto * player
  else                                                                                       // Ve skutečnosti vracim hodnotu o vrstvu výš, poto * -1
  begin
    for y:=0 to 7 do
      for k:=0 to 3 do
        begin
          x:= k * 2 + ((y+1) mod 2);
          if (board[x, y] = player) or (board[x, y] = player * 2) then
            begin
              board_list:= find_jumps(editable_board, x,y, player);
              boards_to_select:=board_list;
              for i:= 0 to 3 do
                begin
                  if board_list[i][0,0] <> 42 then
                    begin

                      render(board_list[i], recursed);
                      writeln('Rekurze!',  recursed);
                      scored_in_move:= find_best_move(board_list[i], recursed + 1, -player);
                      if  player * scored_in_move >=  player * find_best_move then          //Tady bude asi chyba !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        begin
                          find_best_move:= scored_in_move;
                          in_board:= board_list[i];   // !!!!! Toto je strašně důležitý - f-ce f_b_m upraví boardu na nejlepší, co našla.

                          if recursed=0 then in_board:= boards_to_select[i];
                        end;
                    end;
                end;
            end;

        end;
  end;
end;

begin
  game_over:= False;
  cursor.x:=0;
  cursor.y:=0;           //Inicializace
  board_init(board);

  menu(difficulty);
  Clrscr();
  render(board,0);
  while game_over = False do  //Main game loop
    begin
                                     //↓↓↓Controls
      while take_action = False do
        begin
          cursor_blink(Yellow,board_coor(cursor.x, True),board_coor(cursor.y,False));
          repeat until KeyPressed; //Waiting for input
          cursor_blink(get_color(cursor.x,cursor.y),board_coor(cursor.x, True),board_coor(cursor.y,False));
          key:=readkey();
          case key of
            'd': if cursor.x<7 then cursor.x += 1;
            'a': if cursor.x>0 then cursor.x -= 1;
            's': if cursor.y<7 then cursor.y += 1;
            'w': if cursor.y>0 then cursor.y -= 1;
            ' ': if board[cursor.x, cursor.y] = 1 then
                   begin
                     sec_move:= False;
                     move_stone(board, cursor.x, cursor.y,take_action,sec_move,cursor);
                     if sec_move then
                       move_stone(board, cursor.x, cursor.y,take_action,sec_move,cursor);
                   end;
          end;
        end;
        render(board,0);
        delay(1000);
        //AI! Hurá!

        find_best_move(board,0,-1);

        render(board,0);

        take_action:=False;
    end;
end.

{Poloosa y jde odshora dolu
 player je hodnota 1 pro hráče a -1 pro protivníka
}
