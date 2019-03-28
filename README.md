# Checkers
ToDo:
- Doladit AI (V některých případech a obvzláště, když je na hře už jen několik málo kamenů, má oponent tendenci se chovat zdánlivě nelogicky)
       Myšlenka:    Toto je možná způsobeno tím, že oponent vidí tak daleko do budoucnosti, že ví, že už prohraje v každém případě. 
                    To by znamenalo, že jsem omylem implementoval tzv. chování "mladšího bratra", který při prohrávání hru záměrně      
                    sabotuje, protože už to "nemá cenu".
              
- Tu a tam se stane, že se kamen nebo dva rozhodnou spáchat sebevraždu a prostě zmizí. To by bylo fajn doladit. Stává se to nejspíš jen u DEMA. Během normální hry hráče jsem si toho zatím nevšiml. Tam je problém spíš s tím, že oponent občas jaksi zapomene hrát.

- Zkultivovat kód = odstranit fragmenty ze starých verzí a přidat všechny komentáře, které chybí (tedy všechny komentáře)

- Pokusit se přidat pravidlo "Vynuceného skoku". Zatím netušim, jak to udělat bez brutálního zvýšení časové náročnosti (před vyhledáváním tahů je vyhledávat znova a vést si záznam jen o tom, jestli je možné útočit, pak vyhledat tahy a počítat s možností útoku, by šlo ale... to zní nechutně). Update: Nejspíš to ale lépe neudělám.
