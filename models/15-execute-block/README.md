# 15-execute-block

Ten model służy do testowania poprawności parsowania części imperatywnej języka OPL (IBM ILOG Script).
Głównym celem jest weryfikacja, czy parser poprawnie odróżnia konstrukcje deklaratywne od skryptowych:
- Bloków `execute` (pre-processing i post-processing).
- Pętli `for` oraz zmiennych lokalnych `var` wewnątrz skryptu.
- Zaawansowanego sterowania przepływem w bloku `main` z wykorzystaniem klas `OplModelSource`, `OplModelDefinition`, `OplDataSource` oraz `OplModel`.
