library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Для арифметических операций
use work.state.all; 

entity snake_logic is
	port (
		current_direction : in direction;
		game_clk          : in std_logic;
		o_snake            : out snake;
		o_fruit : out position
		);
end snake_logic;

architecture Behavioral of snake_logic is 
	signal snake_state : snake := (
		head        => (x => 1, y => 1),     -- Инициализация головы (позиция 0,0)
		tail_length => 0,                    -- Инициализация длины хвоста (0)
		tail        => (others => (x => 0, y => 0))  -- Инициализация всех элементов хвоста (координаты 0,0)
	);   -- Текущее состояние змейки
	signal next_head : position := (x => 0, y => 0);  -- Новое положение головы
	signal is_fruit_eaten : std_logic;  -- Флаг того, что фрукт был съеден	
	signal fruit :  position := (x => 64, y => 64);
	
	-- Константы для границ экрана
	constant MAX_X : integer := 127;
	constant MAX_Y : integer := 127; 
	
begin 

	
	
	-- Процесс, который будет обновлять состояние змейки
	process (game_clk)
		variable v_next_head : position;  -- Переменная для временного хранения положения головы
		variable v_tail : position_array; -- Переменная для хранения хвоста
	begin
		if rising_edge(game_clk) then
			-- 1. Копируем текущее положение головы и хвоста в переменные
			v_next_head := snake_state.head;
			v_tail := snake_state.tail;
			
			-- 2. Обновление позиции головы змейки в зависимости от направления
			case current_direction is
				when LEFT  => 
					if v_next_head.x = 0 then
						v_next_head.x := MAX_X;  -- Если уходим за левую границу, возвращаемся к правой
					else
						v_next_head.x := v_next_head.x - 1;
					end if;
				
				when RIGHT =>
					if v_next_head.x = MAX_X then
						v_next_head.x := 0;  -- Если уходим за правую границу, возвращаемся к левой
					else
						v_next_head.x := v_next_head.x + 1;
					end if;
				
				when UP =>
					if v_next_head.y = 0 then
						v_next_head.y := MAX_Y;  -- Если уходим за верхнюю границу, возвращаемся к нижней
					else
						v_next_head.y := v_next_head.y - 1;
					end if;
				
				when DOWN =>
					if v_next_head.y = MAX_Y then
						v_next_head.y := 0;  -- Если уходим за нижнюю границу, возвращаемся к верхней
					else
						v_next_head.y := v_next_head.y + 1;
				end if;
			end case;
			
			-- 3. Проверка на столкновение с фруктом
			if (v_next_head.x = fruit.x and v_next_head.y = fruit.y) then
				is_fruit_eaten <= '1';
				snake_state.tail_length <= snake_state.tail_length + 1;  -- Увеличиваем длину хвоста
				fruit <= food_generator(snake_state);
			else
				is_fruit_eaten <= '0';
			end if;
			
			-- 4. Обновляем положение хвоста (сдвиг частей)
			if snake_state.tail_length > 0 then
				for i in snake_state.tail_length downto 1 loop
					v_tail(i) := v_tail(i-1);  -- Сдвигаем хвост
				end loop;
				v_tail(0) := snake_state.head;  -- Текущая голова становится началом хвоста
			end if;
			
			-- 5. Обновляем сигналы на основе переменных
			snake_state.head <= v_next_head;   -- Обновляем положение головы
			snake_state.tail <= v_tail;        -- Обновляем хвост
			
		end if;
	end process;
	
	-- Выходной сигнал
	o_fruit <= fruit; 
	o_snake <= snake_state;
end Behavioral;
