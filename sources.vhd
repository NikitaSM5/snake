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
	
	function generate_random(seed :  integer) return integer;
	impure function food_generator (o_snake: snake) return position;
end package; 

package body state is
	
	function generate_random(seed : integer) return integer is
		constant a : integer := 1103515245;
		constant c : integer := 12345;
		constant m : integer := 10000;  -- Модуль, выбираем большое значение 
		variable t : integer := seed;
	begin
		-- Генерируем новое случайное число по формуле линейного конгруэнтного генератора
		t := (a * seed + c) mod m;
		
		-- Масштабируем случайное число до диапазона от 0 до 19
		return t mod 20;  -- Для генерации числа в диапазоне от 0 до 19
	end function;
	
	
	impure function food_generator(o_snake : snake) return position is
		variable new_food : position;
		variable valid_position : boolean;	
		variable seed : integer := now/1ns;
	begin
		valid_position := false;
		
		-- Алгоритм генерации пищи
		while not valid_position loop 
			-- Генерация случайных координат для еды
			new_food.x := generate_random(seed);
			new_food.y := generate_random(seed + 1);
			
			-- Проверка, чтобы новая позиция не совпадала с позицией головы или хвоста
			valid_position := true;  -- Сначала считаем позицию валидной
			
			if (new_food.x = o_snake.head.x and new_food.y = o_snake.head.y) then
				valid_position := false;  -- Если совпало с головой, невалидно
			end if;
			
			-- Проверяем все позиции хвоста змейки
			for i in 0 to o_snake.tail_length - 1 loop
				if (new_food.x = o_snake.tail(i).x and new_food.y = o_snake.tail(i).y) then
					valid_position := false;  -- Если совпало с одной из частей хвоста, тоже невалидно 
					exit;
				end if;
			end loop;  
		
			
			seed := seed + 1;
		end loop;
		
		-- Возвращаем сгенерированную позицию
		return new_food;
	end function;
end package body;

