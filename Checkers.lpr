program Checkers;
Uses Crt;
type T_board = array[0..7,0..7] of integer;
     T_cursor = record
           x:byte;
           y:byte;
           end;
     T_board_list = array[0..14] of T_board;
var difficulty:byte;    //Difficulty bude počet rekurzí
    board:T_board;
    cursor:T_cursor;
    game_over, take_action, {Přechod k logice}sec_move, winner,
    last_layer_debug, debug_mode, custom_board, CPUvCPU, rand_moves: boolean;
    key:char;
    rand_num,KING,RAND_KOEF:integer;


procedure menu(var difficulty:byte);
begin
  repeat
    ClrScr;
    writeln('CHECKERS');
    writeln('Pro start hry zadej obtiznost 1 - 8.');
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
      if (difficulty < 0) or (difficulty > 8) then
      begin
        writeln('Stiskni ENTER a zkus to znovu a tentokrat spravne:-P');
        readln();
      end;
  until (difficulty > 0) and (difficulty <= 8);
end;

procedure render(board:T_board);
var x,y,i:integer;
begin
  //ClrScr;
  gotoxy(1,1);
  for y:= 0 to 7 do
    for i:=0 to 2 do
      begin
        for x:=0 to 7 do
          begin
            if (x + y) mod 2 = 0 then
            begin
              TextBackground(Black);
              write('     ');
            end
            else
            begin
              TextBackground(White);
              write(' ');
              if i = 0 then
                begin
                  if board[x,y] = KING then
                    TextBackground(Red);
                  if board[x,y] = -KING then
                    TextBackground(Blue);
                end;

              if i = 1 then
                begin
                  case board[x,y] of
                    0: TextBackground(White);
                    1: TextBackground(Red);
                    -1: TextBackground(Blue);
                    69: TextBackground(Yellow);
                    70: TextBackground(Green);
                  end;
                  if board[x,y] = KING then
                    TextBackground(Red);
                  if board[x,y] = -KING then
                    TextBackground(Blue);
                end;
              write('   ');
              TextBackground(White);
              if (i=0) and (board[x,y]*board[x,y] = KING * KING) then
                begin
                  gotoxy(WhereX-2,WhereY);
                  write(' ');
                  gotoxy(WhereX+1,WhereY);
                end;
              write(' ');
            end;
        end;
        writeln();
      end;
  textBackground(Black);

                               //writeln(recursed);
end;

procedure simple_render(board:T_board);
var x,y:integer;
begin
  for y:= 0 to 7 do
    begin
      for x:=0 to 7 do
        begin
          if board[x,y]<0 then textColor(Blue);
          if board[x,y]>0 then textColor(Red);
          if board[x,y]=0 then textColor(White);
          write(board[x,y]:2);
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
  if custom_board then
  begin
    board[1,0]:= 0; board[3,0]:= 5; board[5,0]:= 0; board[7,0]:= 0;
    board[0,1]:= 1; board[2,1]:= 0; board[4,1]:= 0; board[6,1]:= -1;
    board[1,2]:= 0; board[3,2]:= 0; board[5,2]:= 0; board[7,2]:= 0;
    board[0,3]:= 0; board[2,3]:= 0; board[4,3]:= 0; board[6,3]:= 1;
    board[1,4]:= 1; board[3,4]:= 0; board[5,4]:= 0; board[7,4]:= 0;
    board[0,5]:= 0; board[2,5]:= 0; board[4,5]:= 0; board[6,5]:= 0;
    board[1,6]:= 0; board[3,6]:= 0; board[5,6]:= 0; board[7,6]:= 0;
    board[0,7]:= -5; board[2,7]:= 0; board[4,7]:= -5; board[6,7]:= 0;
  end
  else
  begin
    board[1,0]:= -1; board[3,0]:= -1; board[5,0]:= -1; board[7,0]:= -1;
  board[0,1]:= -1; board[2,1]:= -1; board[4,1]:= -1; board[6,1]:= -1;
  board[1,2]:= -1; board[3,2]:= -1; board[5,2]:= -1; board[7,2]:= -1;
  board[0,7]:= 1; board[2,7]:= 1; board[4,7]:= 1; board[6,7]:= 1;
  board[1,6]:= 1; board[3,6]:= 1; board[5,6]:= 1; board[7,6]:= 1;
  board[0,5]:= 1; board[2,5]:= 1; board[4,5]:= 1; board[6,5]:= 1;
  end;
end;

function get_color(x,y:Byte):Byte;
begin
  if (x + y) mod 2 = 0 then get_color:=Black
  else get_color:=White;
end;

procedure cursor_render(color:Byte;x,y:Byte);
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

procedure check_for_king(var board:T_board);
var x:integer;
begin
  for x:= 0 to 7 do
    begin
      if board[x,0] = 1 then
        board[x,0]:= KING;
      if board[x,7] = -1 then
        board[x,7]:= -KING;
    end;
end;

function get_difference(board:t_board):integer;
{Hráč - CPU => kladné je dobré}
var x,y:byte;
begin
  get_difference:=0;
  for y:=0 to 7 do
    for x:= 0 to 7 do
      get_difference += board[x,y];
end;

function find_jumps(board:T_board; x,y:Byte; player:integer;see_changes:boolean):T_board_list;
var index,i:byte;
begin
  for i:= 0 to 14 do find_jumps[i][0,0]:= 42;
  index:=0;
  if board[x,y] = player * 1 then //běžný kámen
    if (y > -1 + player) and (y < 8 + player) then
      begin
        if (x > 0) then
          begin
            if (board[x-1, y - player] = 0) then    //Vlevo nad je místo \\\   pro lidského hráče směr pohybu klesá
              begin
                find_jumps[index] := board;
                if see_changes then
                  begin
                    find_jumps[index][x,y]:= 69;
                    find_jumps[index][x-1, y - player]:= player * 70;
                  end
                else
                  begin
                    find_jumps[index][x,y]:= 0;
                    find_jumps[index][x-1, y - player]:= player * 1;
                  end;
                check_for_king(find_jumps[index]);
                index += 1;
              end;
            if (x>1) and (y > -1 + (2 * player)) and (y < 8 + (2*player)) then
              if (board[x-1, y - player] = player * -1) and (board[x-2, y - player*2] = 0) then
                begin
                  find_jumps[index] := board;
                  if see_changes then
                    begin
                      find_jumps[index][x,y]:= 69;
                      find_jumps[index][x-2, y - player*2]:= player * 70;
                    end
                  else
                    begin
                      find_jumps[index][x,y]:= 0;
                      find_jumps[index][x-2, y - player*2]:= player * 1;
                    end;
                  find_jumps[index][x-1,y - player]:= 0;
                  check_for_king(find_jumps[index]);
                  index += 1;
                end;
          end;
        if (x < 7) then
          begin
            if (board[x+1, y - player] = 0) then   //Vpravo nad je místo
              begin
                find_jumps[index] := board;
                if see_changes then
                  begin
                    find_jumps[index][x,y]:= 69;
                    find_jumps[index][x+1, y - player]:= player * 70;
                  end
                else
                  begin
                    find_jumps[index][x,y]:= 0;
                    find_jumps[index][x+1, y - player]:= player * 1;
                  end;
                check_for_king(find_jumps[index]);
                index += 1;
              end;
            if (x<6) and (y > -1 + (2 * player)) and (y < 8 + (2*player)) then
              if (board[x+1, y - player] = player * -1) and (board[x+2, y - player*2] = 0) then
                begin
                  find_jumps[index] := board;
                  if see_changes then
                    begin
                      find_jumps[index][x,y]:= 69;
                      find_jumps[index][x+2, y - player*2]:= player * 70;
                    end
                  else
                    begin
                      find_jumps[index][x,y]:= 0;
                      find_jumps[index][x+2, y - player*2]:= player * 1;
                    end;
                  find_jumps[index][x+1,y - player]:= 0;
                  check_for_king(find_jumps[index]);
                  index += 1;
                end;
          end;
      end;
end;

function find_best_move(var in_board:T_board;recursed:Byte;player:integer;id:integer):integer;
var y,x,i,k:Byte;
    scored_in_move:integer;
    editable_board:T_board;
    board_list,boards_to_select: T_board_list;     //boards_to_select uchovává hodnotu původních nezrekurzovaných board


begin
  editable_board:= in_board;
  find_best_move:= player * -60; //inicializace pro případ, že nelze udělat další tah
  scored_in_move:= 0;
  if recursed = difficulty  then
    begin
    find_best_move:= get_difference(editable_board);
    if last_layer_debug then
      begin
        simple_render(in_board);
        writeln(find_best_move);
        readln();
      end;
    end
  else                                                                                       // Ve skutečnosti vracim hodnotu o vrstvu výš, poto * -1
    begin
      for y:=0 to 7 do
        for x:=0 to 7 do
          begin
            if (in_board[x, y] = player) or (in_board[x, y] = player * 2) then
              begin
                board_list:= find_jumps(editable_board, x,y, player,False);
                boards_to_select:=board_list;
                for i:= 0 to 3 do
                  begin
                    if board_list[i][0,0] <> 42 then
                      begin
                        scored_in_move:= find_best_move(board_list[i], recursed + 1, -player,10*id+i);
                        rand_num:=100;
                        if  player * scored_in_move >=  player * find_best_move then
                          begin
                            if (rand_moves = True) and (scored_in_move =  find_best_move) then
                              rand_num := Random(100);
                            if rand_num > RAND_KOEF then
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
    if debug_mode then
      begin
        simple_render(in_board);
        writeln('Rekurze: ',  recursed);
        writeln('ID: ', id);
        writeln('Hrac: ', player);
        writeln('find_best_move: ',find_best_move);
        readln();
      end;
end;

procedure move_stone(var board:T_board;var continue:Boolean;var cursor:T_cursor);
var possible_moves:T_board_list;
    index:integer;
    key:char;
    take_action:boolean;
    x,y:Byte;
begin
  index:=0;
  take_action:= False;
  if board[cursor.x,cursor.y] <> 0 then
  begin
    possible_moves:= find_jumps(board,cursor.x,cursor.y,1,True);
    continue:=False;
    if possible_moves[0][0,0] <> 42 then
      begin
        continue:=True;
        while take_action = False do
          begin
            render(possible_moves[index]);
            repeat until KeyPressed;
            key:=readkey();
            case key of
              'd': if possible_moves[index+1][0,0] <> 42 then index += 1;
              'a': if index>0 then index -= 1;
              ' ':begin
                    take_action:= True;
                    for y:=0 to 7 do
                      for x:=0 to 7 do
                        begin
                          if possible_moves[index][x,y] = 69 then possible_moves[index][x,y]:= 0;
                          if possible_moves[index][x,y] = 70 then possible_moves[index][x,y]:= 1;
                          board:=possible_moves[index];
                        end;
                  end;
            end;
          end;
      end;
  end;
end;

function check_game_over (board:T_board;var winner:boolean):boolean;
  var x,y,stones_A,stones_B:integer;
begin
  check_game_over:=False;
  stones_A:= 0;
  stones_B:=0;
  for  y:=0 to 7 do
    for x:=0 to 7 do
      begin
        if board[x,y] > 0 then
          stones_A += 1;
        if board[x,y] < 0 then
          stones_B += 1;
      end;
  if stones_A = 0 then
    begin
      winner:=False;
      check_game_over:=True;
    end;
  if stones_B = 0 then
    begin
      winner:=True;
      check_game_over:=True;
    end;
end;

procedure gmovr_screen(winner:boolean);
begin
  gotoxy(1,13);
  if winner then
    begin
      Textcolor(Green);
      write('               YOU WIN!                 ');
    end
  else
    begin
      Textcolor(Red);
      write('              GAME OVER!                ');
    end;

end;

procedure demo(board:T_board;var game_over:boolean; winner:boolean);
begin
  While game_over=False do
      begin
        find_best_move(board,0,+1,0);
        render(board);
        delay(1000);
        game_over:= check_game_over(board,winner);
        find_best_move(board,0,-1,0);
        render(board);
        delay(1000);
        game_over:= check_game_over(board,winner);
      end;
end;

begin
  //dev tools
  CPUvCPU:=            False;
  custom_board:=       False;
  debug_mode:=         False;
  last_layer_debug :=  False;
  rand_moves:=         True;

  RAND_KOEF:=70;
  KING:=5;

  menu(difficulty);

  randomize();
  game_over:= False;
  winner:= False;
  board_init(board);
  Clrscr();
  cursor.x:=0;
  cursor.y:=0;
  render(board);

  if CPUvCPU then demo(board,game_over,winner);
  while game_over = False do  //Main game loop
    begin
      take_action:=False;                               //↓↓↓Controls
      while take_action = False do
        begin
          cursor_render(Yellow,board_coor(cursor.x, True),board_coor(cursor.y,False));
          repeat until KeyPressed; //Waiting for input
          cursor_render(get_color(cursor.x,cursor.y),board_coor(cursor.x, True),board_coor(cursor.y,False));
          key:=readkey();
          case key of
            'd': if cursor.x<7 then cursor.x += 1;
            'a': if cursor.x>0 then cursor.x -= 1;
            's': if cursor.y<7 then cursor.y += 1;
            'w': if cursor.y>0 then cursor.y -= 1;
            ' ': if board[cursor.x, cursor.y] = 1 then
                   begin
                     sec_move:= False;
                     move_stone(board,take_action,cursor);
                     if sec_move then
                       move_stone(board,take_action,cursor);
                   end;
          end;
        end;
        check_for_king(board);
        render(board);
        delay(1000);

        find_best_move(board,0,-1,0);
        render(board);

        game_over:= check_game_over(board,winner);
        take_action:=False;
    end;
    gmovr_screen(winner);
    readln();
end.

{Poloosa y jde odshora dolu
 player je hodnota 1 pro hráče a -1 pro protivníka
}
