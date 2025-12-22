#!/bin/bash

echo "=== Тест 1: Линейная интерполяция с шагом 0.7 ==="
echo -e "0 0\n1 1\n2 2\n3 3" | dune exec my_lab3 -- --linear --step 0.7
echo ""

echo "=== Тест 2: Линейная интерполяция с шагом 1.0 ==="
echo -e "0 0\n1 1\n2 2" | dune exec my_lab3 -- --linear --step 1.0
echo ""

echo "=== Тест 3: Интерполяция Ньютона (окно 4) ==="
cat tests/examples/newton_test.txt | dune exec my_lab3 -- --newton -n 4 --step 0.5
echo ""

echo "=== Тест 4: Квадратичная функция линейной интерполяцией ==="
cat tests/examples/complex_test.txt | dune exec my_lab3 -- --linear --step 1.0
echo ""

echo "=== Тест 5: CSV формат с точкой с запятой ==="
echo -e "0;0\n1;1\n2;4\n3;9" | dune exec my_lab3 -- --newton -n 3 --step 0.5
echo ""

echo "✓ Все тесты завершены!"
