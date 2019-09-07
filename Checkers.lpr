program Checkers;
Uses Crt;
const
    EMPTY_FIELD = 0;
    PLAYER_STONE = 1;
    ENEMY_STONE = -1;
    PLAYER_KING = 5;
    ENEMY_KING = -5;
    FORMER_POS = 69;
    NEXT_POS = 70;
    FORMER_POS_KING = 79;
    NEXT_POS_KING = 80;
    RAND_KOEF = 70;
    BLANK_MOVE = 42;
    TOO_HIGH = 200;
    BOARD_LAST_INDEX = 7;
    MOVES_MEMORY_SIZE = 6;
type T_board = array[0..BOARD_LAST_INDEX,0..BOARD_LAST_INDEX] of integer;
     T_cursor = record
           x:byte;
           y:byte;
           end;
     T_board_list = array[0..MOVES_MEMORY_SIZE] of T_board;

var difficulty:byte;    //Difficulty bude počet rekurzí
    board:T_board;
    cursor:T_cursor;
    game_over, take_action, {Přechod k logice} winner,
    last_layer_debug, debug_mode, custom_board, CPUvCPU, rand_moves,end_menu,
    special_board: boolean;
    key:char;
    rand_num:integer;


procedure menu(var difficulty:byte);
begin
  end_menu:=False;
  repeat
    ClrScr;
    writeln('CHECKERS');
    writeln('Pro start hry zadej obtiznost 1 - 8.');
    writeln('Pro DEMO zadej [100]                               Demo            = ', CPUvCPU);
    writeln('Pro Spesl rozlozeni kamenu zadej [200]             Spesl rozlozeni = ',special_board);
    writeln();
    writeln('Pro napovedu zadej 0');
    write('>>>  ');
    readln(difficulty);

    if difficulty = 100 then CPUvCPU:= not CPUvCPU
    else if difficulty = 200 then special_board:= not special_board
    else if difficulty = 0 then
      begin
        writeln();
        writeln('Hra se ovlada klavesami:');
        writeln('W,A,S,D   = Pohyb');
        writeln('SPACE     = Zvolit kamen');
        writeln('C         = Zrusit');
        writeln();
        writeln('Po volbe kamene se pomoci klaves A a D najde pozadovany tah');
        writeln('POZOR! U damy se k pozadovanemu tahu da vzdy dostat pomoci klavesy D.');
        writeln('       Mate totiz k dispozici pole, ktere prochazite doleva a doprava');
        writeln('       a zacinate na prvni moznosti.');
        writeln();
        writeln('Pro rychlejsi vykreslovani doporucuji kliknout na ikonu konzole pravym');
        writeln('tlacitkem mysi, zvolit "deafults", zaskrtnout policko "Use legacy');
        writeln('console" a spustit program znovu');
        writeln();
        writeln('PRAVIDLA: ');
        writeln('    Pravidla teto verze jsou mirne vykastrovana od tech, ktere mozna znate.');
        writeln('Kameny se pohybuji po diagonalach. Pesaci mohou preskocit kamen, ktery se');
        writeln('jim postavi do cesty. Pokud se pesak dostane na druhy konec sachovnice,');
        writeln('stava se damou. Dama se muze pohybovat libovolne daleko ve vsech ctyrech smerech.');
        writeln('    Na rozdil od klasickych pravidel jsou zde dve upravy. Nejsou mozne nasobne');
        writeln('skoky a pokud pesak nebo dama mohou preskocit a neucini tak, tak nebudou sebrany.');
        writeln('');
        writeln('Pro navrat do menu stiskni ENTER');
        readln();
      end
    else if ((difficulty < 0) or (difficulty > 8)) then
      begin
        writeln('Stiskni ENTER a zkus to znovu a tentokrat spravne:-P');
        readln();
      end
    else if (difficulty > 0) or (difficulty <= 8) then end_menu:= True;
  until end_menu;
end;

procedure render(board:T_board);
var x,y,i:integer;
begin
  //ClrScr;
  gotoxy(1,1);
  for y:= 0 to BOARD_LAST_INDEX do
    for i:=0 to 2 do
      begin
        for x:=0 to BOARD_LAST_INDEX do
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
                  if board[x,y] = PLAYER_KING then
                    TextBackground(Red);
                  if board[x,y] = ENEMY_KING then
                    TextBackground(Blue);
                end;

              if i = 1 then
                begin
                  case board[x,y] of
                    EMPTY_FIELD: TextBackground(White);//  0 = prázdné pole
                    PLAYER_STONE: TextBackground(Red);  //  1/-1 = pěšák hráč/CPU
                    ENEMY_STONE: TextBackground(Blue);
                    FORMER_POS: TextBackground(Yellow);//  Pomocné číslo značící původní polohu pěšáka
                    NEXT_POS: TextBackground(Green); // Pomocné číslo značící vykreslení zelené ikony možného tahu pěšáka
                    FORMER_POS_KING: TextBackground(Yellow);  // Zde podobně, ale týkající se dámy
                    NEXT_POS_KING: TextBackground(Green);
                  end;
                  if board[x,y] = PLAYER_KING then
                    TextBackground(Red);
                  if board[x,y] = ENEMY_KING then
                    TextBackground(Blue);
                end;
              write('   ');
              TextBackground(White);
              //Podsud se řeší pouze pěšáci. Pokud se má vykreslit dáma, tak se vykreslí pomocí kódu dole
              if (i=0) and ((board[x,y]*board[x,y] = PLAYER_KING * PLAYER_KING) or (board[x,y] = FORMER_POS_KING) or (board[x,y] = NEXT_POS_KING)) then
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
var x,y:integer;          //Jednoduchá verze renderu pro debugování
begin
  for y:= 0 to BOARD_LAST_INDEX do
    begin
      for x:=0 to BOARD_LAST_INDEX do
        begin
          if board[x,y]<0 then textColor(Blue);   //Menší než 0 jsou nepřítelovy kameny
          if board[x,y]>0 then textColor(Red);
          if board[x,y]=0 then textColor(White);
          write(board[x,y]:2);
        end;
      writeln();
    end;
end;

procedure board_init(var board:T_board);
var x,y:integer;        //Inicialize board (Základní, vylepšená a debugovací
begin
  for y:=0 to BOARD_LAST_INDEX do
    for x:=0 to BOARD_LAST_INDEX do
      board[x,y]:= EMPTY_FIELD;
  if custom_board then
    begin
      board[1,0]:= ENEMY_STONE; board[3,0]:= ENEMY_STONE; board[5,0]:= EMPTY_FIELD; board[7,0]:= EMPTY_FIELD;
      board[0,1]:= PLAYER_STONE; board[2,1]:= EMPTY_FIELD; board[4,1]:= EMPTY_FIELD; board[6,1]:= EMPTY_FIELD;
      board[1,2]:= EMPTY_FIELD; board[3,2]:= EMPTY_FIELD; board[5,2]:= EMPTY_FIELD; board[7,2]:= EMPTY_FIELD;
      board[0,3]:= EMPTY_FIELD; board[2,3]:= EMPTY_FIELD; board[4,3]:= EMPTY_FIELD; board[6,3]:= EMPTY_FIELD;
      board[1,4]:= ENEMY_STONE; board[3,4]:= EMPTY_FIELD; board[5,4]:= EMPTY_FIELD; board[7,4]:= EMPTY_FIELD;
      board[0,5]:= EMPTY_FIELD; board[2,5]:= EMPTY_FIELD; board[4,5]:= EMPTY_FIELD; board[6,5]:= EMPTY_FIELD;
      board[1,6]:= EMPTY_FIELD; board[3,6]:= EMPTY_FIELD; board[5,6]:= EMPTY_FIELD; board[7,6]:= EMPTY_FIELD;
      board[0,7]:= EMPTY_FIELD; board[2,7]:= EMPTY_FIELD; board[4,7]:= EMPTY_FIELD; board[6,7]:= EMPTY_FIELD;
    end
  else if special_board then
    begin
      board[1,0]:= ENEMY_STONE; board[3,0]:= EMPTY_FIELD; board[5,0]:= EMPTY_FIELD; board[7,0]:= ENEMY_STONE;
      board[0,1]:= ENEMY_STONE; board[2,1]:= ENEMY_STONE; board[4,1]:= ENEMY_STONE; board[6,1]:= ENEMY_STONE;
      board[1,2]:= ENEMY_STONE; board[3,2]:= ENEMY_STONE; board[5,2]:= ENEMY_STONE; board[7,2]:= ENEMY_STONE;
      board[0,5]:= PLAYER_STONE; board[2,5]:= PLAYER_STONE; board[4,5]:= PLAYER_STONE; board[6,5]:= PLAYER_STONE;
      board[1,6]:= PLAYER_STONE; board[3,6]:= PLAYER_STONE; board[5,6]:= PLAYER_STONE; board[7,6]:= PLAYER_STONE;
      board[0,7]:= PLAYER_STONE; board[2,7]:= EMPTY_FIELD; board[4,7]:= EMPTY_FIELD; board[6,7]:= PLAYER_STONE;
    end
  else
    begin
      board[1,0]:= ENEMY_STONE; board[3,0]:= ENEMY_STONE; board[5,0]:= ENEMY_STONE; board[7,0]:= ENEMY_STONE;
      board[0,1]:= ENEMY_STONE; board[2,1]:= ENEMY_STONE; board[4,1]:= ENEMY_STONE; board[6,1]:= ENEMY_STONE;
      board[1,2]:= ENEMY_STONE; board[3,2]:= ENEMY_STONE; board[5,2]:= ENEMY_STONE; board[7,2]:= ENEMY_STONE;
      board[0,5]:= PLAYER_STONE; board[2,5]:= PLAYER_STONE; board[4,5]:= PLAYER_STONE; board[6,5]:= PLAYER_STONE;
      board[1,6]:= PLAYER_STONE; board[3,6]:= PLAYER_STONE; board[5,6]:= PLAYER_STONE; board[7,6]:= PLAYER_STONE;
      board[0,7]:= PLAYER_STONE; board[2,7]:= PLAYER_STONE; board[4,7]:= PLAYER_STONE; board[6,7]:= PLAYER_STONE;
    end;
end;

function get_color(x,y:Byte):Byte;
begin              //vrátí barvu, jakou má mít dané pole na hrací ploše
  if (x + y) mod 2 = 0 then get_color:=Black
  else get_color:=White;
end;

procedure cursor_render(color:Byte;x,y:Byte);
begin     //Vykreslení kurzoru okolo zadané soouřadnice
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

function board_coor(k:Byte;x:Boolean):Byte; //Konverze souřdnic z skutečných souřadnic plochy na souřadnice "pixelů" v konsoli
begin
  if x = True then  // pokud je x true, tak se vypočítá hodnoty pro x, jinak pro y;
    board_coor:= 5*k + 3
  else
    board_coor:= 3*k + 2;
end;

procedure check_for_king(var board:T_board);
var x:integer; //Zjistí se, jestli jeden z hráčů nedošel až na druhý konec a pokud ano, dá mu tam dámu
begin
  for x:= 0 to BOARD_LAST_INDEX do
    begin
      if board[x,0] = PLAYER_STONE then
        board[x,0]:= PLAYER_KING;
      if board[x,BOARD_LAST_INDEX] = ENEMY_STONE then
        board[x,BOARD_LAST_INDEX]:= ENEMY_KING;
    end;
end;

function get_difference(board:t_board):integer;
{Zjistí, jak se liší součet kamenů hráče a CPU.  Hráč - CPU => kladné je dobré pro hráče}
var x,y:byte;
begin
  get_difference:=0;
  for y:=0 to BOARD_LAST_INDEX do
    for x:= 0 to BOARD_LAST_INDEX do
      get_difference += board[x,y];
end;

function find_jumps(board:T_board; x,y:Byte; player:integer;see_changes:boolean):T_board_list;
var index,i,x0,y0,obstacles,enemy_x,enemy_y:byte;
    dir_ctr_x:array[0..3] of integer = (+1,+1,-1,-1);
    dir_ctr_y:array[0..3] of integer = (+1,-1,+1,-1);
begin
  {Tato procedura vrací typ T_board_list. Tedy seznam dvourozměrných polí. Od začátku je v každém poli buď nějaký stav hry
nebo na souřadnici 0 0 hodnota 42, což značí, že je toto pole nevyužité}

  for i:= 0 to MOVES_MEMORY_SIZE do find_jumps[i][0,0]:= BLANK_MOVE;
  index:=0;
  if board[x,y] = player * 1 then //běžný kámen
    begin
      if (y > -1 + player) and (y < BOARD_LAST_INDEX+1 + player) then
        begin
          if (x > 0) then
            begin
              if (board[x-1, y - player] = EMPTY_FIELD) then    //Vlevo nad je místo \\\   pro lidského hráče směr pohybu klesá
                begin
                  find_jumps[index] := board;
                  if see_changes then  //See changes vytvoří hrací plochu pro renderování (zelené a žluté preview)
                    begin
                      find_jumps[index][x,y]:= FORMER_POS;
                      find_jumps[index][x-1, y - player]:= player * RAND_KOEF;
                    end
                  else
                    begin
                      find_jumps[index][x,y]:= EMPTY_FIELD;
                      find_jumps[index][x-1, y - player]:= player * 1;
                    end;
                  check_for_king(find_jumps[index]);//Možný vznik dámy a její přidání na hrací plochu
                  index += 1;
                end;
              if (x>1) and (y > -1 + (2 * player)) and (y < BOARD_LAST_INDEX + 1 + (2*player)) then
                if (board[x-1, y - player] * -player > 0) and (board[x-2, y - player*2] = EMPTY_FIELD) then
                  begin
                    find_jumps[index] := board;
                    if see_changes then
                      begin
                        find_jumps[index][x,y]:= FORMER_POS;
                        find_jumps[index][x-2, y - player*2]:= player * RAND_KOEF;
                      end
                    else
                      begin
                        find_jumps[index][x,y]:= EMPTY_FIELD;
                        find_jumps[index][x-2, y - player*2]:= player * 1;
                      end;
                    find_jumps[index][x-1,y - player]:= EMPTY_FIELD;
                    check_for_king(find_jumps[index]);
                    index += 1;
                  end;
            end;
          if (x < BOARD_LAST_INDEX) then
            begin
              if (board[x+1, y - player] = 0) then   //Vpravo nad je místo
                begin
                  find_jumps[index] := board;
                  if see_changes then
                    begin
                      find_jumps[index][x,y]:= FORMER_POS;
                      find_jumps[index][x+1, y - player]:= player * RAND_KOEF;
                    end
                  else
                    begin
                      find_jumps[index][x,y]:= EMPTY_FIELD;
                      find_jumps[index][x+1, y - player]:= player * 1;
                    end;
                  check_for_king(find_jumps[index]);
                  index += 1;
                end;
              if (x<BOARD_LAST_INDEX-1) and (y > -1 + (2 * player)) and (y < BOARD_LAST_INDEX+1 + (2*player)) then
                if (board[x+1, y - player] * -player > 0) and (board[x+2, y - player*2] = 0) then
                  begin
                    find_jumps[index] := board;
                    if see_changes then
                      begin
                        find_jumps[index][x,y]:= FORMER_POS;
                        find_jumps[index][x+2, y - player*2]:= player * RAND_KOEF;
                      end
                    else
                      begin
                        find_jumps[index][x,y]:= EMPTY_FIELD;
                        find_jumps[index][x+2, y - player*2]:= player * 1;
                      end;
                    find_jumps[index][x+1,y - player]:= EMPTY_FIELD;
                    check_for_king(find_jumps[index]);
                    index += 1;
                  end;
            end;
      end;
    end
  else if board[x,y] = player * PLAYER_KING then  //Dáma
    begin
      for i:= 0 to 3 do
        begin
          x0:=x;
          y0:=y;
          obstacles:=0;
          enemy_x:=TOO_HIGH;
          enemy_y:=TOO_HIGH;
          while True do
            begin
              x0 += dir_ctr_x[i];
              y0 += dir_ctr_y[i];
              if (x0<=BOARD_LAST_INDEX) and (y0<=BOARD_LAST_INDEX) and (x0 >= 0) and (y0 >= 0) then
                begin
                  if board[x0,y0] = 0 then
                    begin
                      find_jumps[index]:=board;
                      if enemy_x <> TOO_HIGH then
                        begin
                          find_jumps[index][enemy_x,enemy_y]:=0;
                        end;
                      if see_changes then
                        begin
                          find_jumps[index][x,y]:=FORMER_POS_KING;
                          find_jumps[index][x0,y0]:=NEXT_POS_KING;
                        end
                      else
                        begin
                          find_jumps[index][x,y]:=EMPTY_FIELD;
                          find_jumps[index][x0,y0]:=PLAYER_KING*player;
                        end;
                        index +=1;
                    end;
                  if (board[x0,y0] = -player) or (board[x0,y0] = -player * PLAYER_KING)  then
                    begin
                      obstacles+=1;
                      enemy_x:=x0;
                      enemy_y:=y0;
                    end;
                  if (board[x0,y0] = player) or (board[x0,y0] = player * PLAYER_KING)  then
                    begin
                      break;
                    end;
                  if obstacles = 2 then break;

                end
              else
                break;

            end;
        end;
    end;

end;

function find_best_move(var in_board:T_board;recursed:Byte;player:integer;id:integer):integer;
var y,x,i:Byte;                  //Minimmaxový algoritmus
    scored_in_move:integer;
    editable_board:T_board;
    board_list,boards_to_select: T_board_list;     //boards_to_select uchovává hodnotu původních nezrekurzovaných board


begin
  editable_board:= in_board;
  find_best_move:= player * -100; //inicializace pro případ, že nejllepší možný tah je pořád dost špatný (ekvivalent inf
  scored_in_move:= 0;
  if recursed = difficulty  then  //Pokud jsme v nejhlubší fázi rekurze, jen vrátíme, jaký je rozdíl ve skore
    begin
    find_best_move:= get_difference(editable_board);
    if last_layer_debug then
      begin
        simple_render(in_board);
        writeln(find_best_move);
        readln();
      end;
    end
  else
    begin
      for y:=0 to BOARD_LAST_INDEX do
        for x:=0 to BOARD_LAST_INDEX do
          begin
            if (in_board[x, y] = player) or (in_board[x, y] = player * 5) then
              begin
                board_list:= find_jumps(editable_board, x,y, player,False);
                boards_to_select:=board_list;
                for i:= 0 to MOVES_MEMORY_SIZE do
                  begin
                    if board_list[i][0,0] <> BLANK_MOVE then
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
var possible_moves:T_board_list;         //Tato procedura řeší volbu tahu hráče.
    index:integer;
    key:char;
    take_action:boolean;
    x,y:Byte;
begin
  index:=0;
  take_action:= False;
  if board[cursor.x,cursor.y] <> EMPTY_FIELD then    //Pokud hráč zvolil pole s kamenem
  begin
    possible_moves:= find_jumps(board,cursor.x,cursor.y,1,True);   //Possible moves je T_board_list tedy uchovává pole možných stavů hry
    continue:=False;
    if possible_moves[0][0,0] <> BLANK_MOVE then //Hodnota 42 na začátku značí neexistující tah
      begin
        continue:=True;
        while take_action = False do
          begin
            render(possible_moves[index]);
            repeat until KeyPressed;
            key:=readkey();
            case key of
              'd': if possible_moves[index+1][0,0] <> BLANK_MOVE then index += 1;  //a a d procházejí polem possible moves a vykreslují boardy v něm uložené
              'a': if index>0 then index -= 1;
              ' ':begin                  //Pokud se hráč konečně rozhodne, převedou se preview boardy na skutečné a vykreslí
                    take_action:= True;
                    for y:=0 to BOARD_LAST_INDEX do
                      for x:=0 to BOARD_LAST_INDEX do
                        begin
                          if possible_moves[index][x,y] = FORMER_POS then possible_moves[index][x,y]:= EMPTY_FIELD;
                          if possible_moves[index][x,y] = NEXT_POS then possible_moves[index][x,y]:= PLAYER_STONE;
                          if possible_moves[index][x,y] = FORMER_POS_KING then possible_moves[index][x,y]:= EMPTY_FIELD;
                          if possible_moves[index][x,y] = NEXT_POS_KING then possible_moves[index][x,y]:= PLAYER_KING;
                          board:=possible_moves[index];
                        end;
                  end;
              'c':begin
                    take_action:=True;
                    continue:=False;
                    render(board);
                  end;
            end;
          end;
      end;
  end;
end;

function check_game_over (board:T_board;var winner:boolean):boolean;
  var x,y,stones_A,stones_B:integer;    //Pokud nezbývají kameny, nastaví se game_over na false
begin
  check_game_over:=False;
  stones_A:= 0;
  stones_B:=0;
  for  y:=0 to BOARD_LAST_INDEX do
    for x:=0 to BOARD_LAST_INDEX do
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
begin                 //Při konnci hry se hráč dozví, jetli vyhrál nebo prohrál
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
begin                         //Toto je CPU proti CPU - nevídaná akční zábava pro celou rodinu
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

function check_jammed( board:T_board):Boolean;
var x,y:Byte;        //Vrátí hodnotu True, pokud nelze provést další tah
begin
    check_jammed:=True;
    for y:=0 to BOARD_LAST_INDEX do
      for x:=0 to BOARD_LAST_INDEX do
          if find_jumps(board,x,y,1,false)[0][0,0] <> BLANK_MOVE then check_jammed:= False;
end;


begin
  //Dev tools
  custom_board:=       False;
  debug_mode:=         False;
  last_layer_debug :=  False;
  rand_moves:=         True;


  //Inicializace
  randomize();
  game_over:= False;
  winner:= False;//Winner je true, pokud vyhrál hráč a naopak

  menu(difficulty);//Procedura menu zavolá hlavní menu a zjistí parametry hry
  Clrscr();
  cursor.x:=0;
  cursor.y:=0;
  board_init(board);
  render(board);//Počáteční vykreslení hrací plochy


  if CPUvCPU then demo(board,game_over,winner);//Spuštění dema, pokud je vyžadováno
  while game_over = False do  //Hlavní cyklus, ve kterém se vždy pohne kurzor
                              //napožadované pole,zahraje a pak se provede tah nepřítele
    begin
      take_action:=False; //Take_action určuje, zda hráč odehrál tah a je na řadě AI.
      while take_action = False do
        begin
          take_action:= check_jammed(board); //V případě, že není možné provést tah se tah předá nepříteli
          cursor_render(Yellow,board_coor(cursor.x, True),board_coor(cursor.y,False));//počáteční cursor render
          repeat until KeyPressed; //Waiting for input
          cursor_render(get_color(cursor.x,cursor.y),board_coor(cursor.x, True),board_coor(cursor.y,False)); //Vymazání původního kurzoru
          key:=readkey();
          case key of
            'd': if cursor.x<BOARD_LAST_INDEX then cursor.x += 1;
            'a': if cursor.x>0 then cursor.x -= 1;
            's': if cursor.y<BOARD_LAST_INDEX then cursor.y += 1;
            'w': if cursor.y>0 then cursor.y -= 1;
            ' ': if board[cursor.x, cursor.y] > 0 then
                   begin
                     move_stone(board,take_action,cursor);
                   end;
          end;
        end;
        check_for_king(board);      //Zjištění, zda hráč nedostal dámu
        render(board);
        delay(1000);

        find_best_move(board,0,-1,0);   //zavolání Minimaxu
        render(board);

        game_over:= check_game_over(board,winner); //Zjistí, jestli jeden z hráčů nevyhrál a požadovanou hodnotu uloží do game_over
        take_action:=False;//V příštím kole se bude opět čekat na zahrání hráče
    end;
    gmovr_screen(winner);  //Vykreslení konce hry se zprávou vyhrál/prohrál jsi
    readln();
end.

{Poloosa y jde odshora dolu
 player je hodnota 1 pro hráče a -1 pro protivníka
}
