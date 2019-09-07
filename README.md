Checkers


Pravidla hry:

Pravidla hry jsou stejná jako u běžné dámy, s několika ale.
První je, že není penalizace, za neskákání.
Druhé spočívá v neschopnosti kamenů dělat násobné skoky. Cíl hry je eliminovat všechny nepřítelovy kameny.
Pešáci mohou skákat dopředu diagonálně, a to po jednom políčku nebo přeskakovat kámen nepřítele a tím ho odstranit ze hry.
Pokud se Váš kámen dostane na druhý konec mapy, stává se dámou. Dáma se může pohybovat vpřed i vzad a to o libovolnou vzdálenost.

Hlavní menu:

V hlavním menu se pohybujete pomocí zadávání číslic a jejich odenterováním. Tedy pro start hry stačí zvolit obtížnost 1 - 8 a odenterovat.
Při zadání nuly se zobrazí nápověda a pak jsou další dvě speciální možnosti - přepínače pro demo a Speciální rozložení.
100 pro demo. Demo je hra počítače proti počítači - jen na koukání.
200 pro speciální rozložení kamenů. Toto rozložení je zajímavé v tom, že v něm není možné si syslit kameny na začátku boardy
a tím znemožňovat nepříteli získání dámy.

Hra:

Ve hře má hráč k dispozici ukazatel, který ukazuje.
To je dobré, protože kdyby ukazatel nebyl, hráč by nevěděl, co dělá, protože by mu to nikdo jiný neukázal.
Ukazatel je proto velice praktická záležitost. Ukazatelem se pohybuje nahorů, dolů, doleva atd. pomocí kláves WASD.
Mezerník slouží k výběru kamene. Z důvodu zachování férové hry se výběr omezuje pouze na Vaše vlastní kameny.
Po výběru kamenu následuje výběr možného tahu s daným kamenem.
Tomu se může chtít hráč vyhnout protože je nerozhodný, špatně rozhodnutý, nesvéprávný nebo k tomu má jiné osobní důvody.
Pro takové případy slouží klávesa C (C jako Co to dělám? Vždyť tohle jsem nechtěl!).
Po stisku klávesy C se hráč potupně vrátí zpět k výběru kamene pomocí naše dobrého kamaráda ukazatele.
Pokud se hráč rozhodne, že jeho vybraný kámen je vybraný dobře, vybere tah, který tento kámen může uskutečnit.
To udělá pomocí kláves A a D. Začínáte na začátku, tedy opakovaným stiskem klávesy D jistě projdete všechny možnosti.
Mezerníkem potvrdíte volbu. Počítač poté udělá všechny tyto kroky asi tak 1000x rychleji než vy, protože je šikovný a rychlý.
Pochvalte jej za to. Poté, co uvidíte, že protihráč udělal jeho tah už víte, jak postupovat dál.



Dokumentace pro programátory

Vykreslování hry:
Používá se mezera a znak █, který se dá velice efektivně napsat Pomocí Alt + 987. Barvičky umožňují rozpoznání kamenů.
Herní plocha se vykreslí vždy po změně na ploše a to ať už faktické (změna pozice kamene) nebo grafické (preview tahu).
  █ 
█   █ Ukazatel ukazuje
  █
  
Logika hry:

Umělá inteligence počítače je způsobená Minimaxovým algoritmem. Obtížnost hry je ve skutečnosti jenom zamaskovaná hloubka Minimaxu.
Organická inteligence je způsobená obrovským množstvím neuronů, které kolektivně nějak vytváří vědomí a depresi.
Otázka vědomí a svobodné vůle zatím nebyla vyřešena. Otázka deprese sice ano, ale má příliš depresivní odpověď.

Hlavní část logiky má na starost funkce find_best_move. Tato funkce projde hrací plochu odshora dolů
(Nevadilo by jí to ani zprava doleva, protože funkce zpravidla nejsou orientované v prostoru.) a najde kameny, které se mohou pohybovat.
S těmito kameny potom pohne pomocí funkce find_jumps a zavolá na nově vzniklý stav hry sama sebe.
To dělá až dokud není v hlubce rovnající se obtížnosti. Potom předá nahoru informace o stavu hry - především o počtech kamenů hráčů.
Podle těch se poté funkce zavolaná "nad" rozhodne, který stav hry je lepší pro ní (Min nebo Max) a pošle to samé nahoru.
Kořenová funkce potom vybere tu možnost, která odpovídá nejlepším tahům zvolených při znalosti stavu hry do dané hloubky oběma hráči.
