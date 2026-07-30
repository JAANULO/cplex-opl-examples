# Shortest Path Problem

Problem polegający na znalezieniu najkrótszej drogi między węzłem startowym a końcowym w grafie skierowanym.
Minimalizowana jest suma kosztów krawędzi wchodzących w skład wybranej ścieżki. Model wykorzystuje
warunki zachowania przepływu (flow conservation) ustawiając bilans na 1 dla źródła, -1 dla celu
oraz 0 dla pozostałych węzłów.
