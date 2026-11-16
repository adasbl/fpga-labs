# Zadanie 6 — PicoBlaze

Otwórz `06-picoblaze-processor.xpr` w Vivado. Układ docelowy:
Nexys A7, `xc7a100tcsg324-1`, zegar 100 MHz.

Zaimplementowano podstawowy zakres polecenia:

- SW7: reset do `0000`.
- BTNU: zwiększenie najmłodszej cyfry, BTND: zmniejszenie.
- Licznik modulo 16: `000F + 1 = 0000`, `0000 - 1 = 000F`.
- Jedna zmiana na naciśnięcie, bez powtarzania podczas przytrzymania.
- Filtracja naciśnięcia i zwolnienia: 10 ms stabilnego poziomu.
- Jednoczesne BTNU i BTND są ignorowane; BTNL i BTNR nie są używane.
- Sprzęt multipleksuje cztery prawe cyfry, zmieniając pozycję co 1 ms.

Program `firmware/counter.psm` odczytuje przyciski z portu `00`,
wykrywa naciśnięcia, wykonuje zliczanie i zapisuje wynik do portu `01`.
Plik `counter_rom.vhd` jest już wygenerowany i dołączony do projektu.
Po zmianie programu wygeneruj go ponownie:

```powershell
python firmware/build_rom.py
```

Generator obsługuje wyłącznie podzbiór instrukcji użyty w tym programie.

Rdzeń `kcpsm6.vhd` autorstwa Kena Chapmana / Xilinx (wersja 1.3) pochodzi
z [repozytorium Koheron](https://github.com/Koheron/koheron-sdk/blob/master/fpga/cores/kcpsm6_v1_0/kcpsm6.vhd).
Zachowano jego oryginalny nagłówek praw autorskich i warunki Xilinx;
licencja głównego repozytorium nie zastępuje warunków tego pliku.
