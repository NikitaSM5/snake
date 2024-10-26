library ieee;
use ieee.std_logic_1164.all; 
use ieee.math_real.all;

package state is
	-- Определение типа для направления движения
	type direction is (LEFT, RIGHT, UP, DOWN);
	
	-- Определение типа для позиции (координаты)
	type position is record
		x : integer;
		y : integer;
	end record;
	
	-- Определение типа для массива позиций хвоста змейки
	type position_array is array (0 to 128) of position;
	
	-- Определение типа для самой змейки
	type snake is record
		head : position;           -- Голова змейки
		tail_length : integer; -- Длина хвоста
		tail : position_array;      -- Массив для хранения позиций хвоста
	end record;															  
	
	function food_generator (o_snake: snake) return position;
end package; 

package body state is
	-- Реализация функции генерации пищи
	function food_generator(o_snake : snake) return position is
		variable new_food : position;
		variable valid_position : boolean;
		variable rand_val1, rand_val2 : real;  -- Переменные для хранения случайных чисел
		variable seed1, seed2 : integer := 1;  -- Начальные значения (seed) для генератора случайных чисел
	begin
		valid_position := false;
		
		-- Алгоритм генерации пищи
		while not valid_position loop 
			
			uniform(seed1, seed2, rand_val1);  
			uniform(seed1, seed2, rand_val2);  
			
			-- Преобразуем случайные числа в координаты поля (например, 128x128)
			new_food.x := integer(rand_val1 * 128.0);  -- Масштабируем случайное число до диапазона 0-127
			new_food.y := integer(rand_val2 * 128.0);
			
			-- Проверка, чтобы новая позиция не совпадала с позицией головы или хвоста
			valid_position := true;  -- Сначала считаем позицию валидной
			if (new_food.x = o_snake.head.x and new_food.y = o_snake.head.y) then
				valid_position := false;  -- Если совпало с головой, невалидно
			end if;
			
			-- Проверяем все позиции хвоста змейки
			for i in 0 to o_snake.tail_length loop
				if (new_food.x = o_snake.tail(i).x and new_food.y = o_snake.tail(i).y) then
					valid_position := false;  -- Если совпало с одной из частей хвоста, тоже невалидно
					exit;
				end if;
			end loop;
		end loop;
		
		-- Возвращаем сгенерированную позицию
		return new_food;
	end function;
end package body;

