library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Для арифметических операций
use work.state.all; -- Подключаем наш пакет	 
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;			

entity snake_logic_tb is
end snake_logic_tb;

architecture testbench of snake_logic_tb is
	
	constant FIELD_SIZE_X : integer := 20; -- Ширина игрового поля
	constant FIELD_SIZE_Y : integer := 20; -- Высота игрового поля
	
	component snake_logic is
		port (
			current_direction : in direction;
			game_clk          : in std_logic;
			o_snake            : out snake;
			o_fruit : out position
			);	 
		
	end component;
	
	signal current_direction_tb :  direction := RIGHT;
	signal game_clk_tb          :  std_logic;
	signal o_snake_tb            : snake;
	signal o_fruit_tb :  position; 
	signal iteration_tb : integer;
	
	file snake_file : text open write_mode is "snake_position.txt";
	
	
begin
	
	test : snake_logic port map (current_direction => current_direction_tb, game_clk => game_clk_tb, o_snake => o_snake_tb, o_fruit => o_fruit_tb);
	
	process 
	begin
		game_clk_tb <= '1';
		wait for 10 ns;
		game_clk_tb <= '0';
		wait for 10 ns;
	end process;
	
	--process 
	--	begin
	--		
	--	end process;
	
	control : process(game_clk_tb)
		variable step : integer := 0;
	begin 
		
		if rising_edge(game_clk_tb) then
			step := step + 1;	
		end if;
		
		if step = 19 then
			current_direction_tb <= DOWN;
		end if;
		if step = 20 then
			current_direction_tb <= LEFT;
		end if;
		if step = 39 then
			current_direction_tb <= DOWN;
		end if;							 
		if step = 40 then
			current_direction_tb <= RIGHT;
			step := 0;
		end if;
		
		
	end process;
	
	
																														  																						
	-- Процесс для записи положения змейки в файл																			  																																							   
	process (game_clk_tb)  
		variable line_data : line;
		variable game_field : string(1 to FIELD_SIZE_X * FIELD_SIZE_Y); -- Игровое поле
		variable x, y : integer;
		variable index : integer;
		variable iteration_counter : integer := 0;
	begin
		if rising_edge(game_clk_tb) then
			-- Инициализируем игровое поле пробелами
			if(iteration_counter mod 1 = 0) then
			for i in 1 to FIELD_SIZE_X * FIELD_SIZE_Y loop
				game_field(i) := ' ';  -- Все пустые клетки — пробелы
			end loop;
			
			-- Обозначаем голову змейки (символ '0')
			if (o_snake_tb.head.x >= 0 and o_snake_tb.head.x < FIELD_SIZE_X and
				o_snake_tb.head.y >= 0 and o_snake_tb.head.y < FIELD_SIZE_Y) then
				index := (o_snake_tb.head.y * FIELD_SIZE_X) + o_snake_tb.head.x + 1;
				game_field(index) := '0';
			end if;
			
			-- Обозначаем хвост змейки (символ 'o')
			for i in 0 to o_snake_tb.tail_length - 1 loop
				if (o_snake_tb.tail(i).x >= 0 and o_snake_tb.tail(i).x < FIELD_SIZE_X and
					o_snake_tb.tail(i).y >= 0 and o_snake_tb.tail(i).y < FIELD_SIZE_Y) then
					index := (o_snake_tb.tail(i).y * FIELD_SIZE_X) + o_snake_tb.tail(i).x + 1;
					game_field(index) := 'o';
				end if;
			end loop;
			
			-- Обозначаем еду (символ 'F')
			if (o_fruit_tb.x >= 0 and o_fruit_tb.x < FIELD_SIZE_X and
				o_fruit_tb.y >= 0 and o_fruit_tb.y < FIELD_SIZE_Y) then
				index := (o_fruit_tb.y * FIELD_SIZE_X) + o_fruit_tb.x + 1;
				game_field(index) := 'F';
			end if;
			
			-- Записываем текущее положение поля в файл
			for y in 0 to FIELD_SIZE_Y - 1 loop
				write(line_data, string'(""));  -- Обнуляем строку
				for x in 0 to FIELD_SIZE_X - 1 loop
					index := (y * FIELD_SIZE_X) + x + 1;
					write(line_data, game_field(index));
				end loop;
				writeline(snake_file, line_data);  -- Записываем строку в файл
			end loop;
			
			-- Записываем разделительную строку с номером итерации
			write(line_data, "Iteration: " & integer'image(iteration_counter));
			writeline(snake_file, line_data);
			
			-- Увеличиваем счетчик итераций
			end if;
			iteration_counter := iteration_counter + 1;
			iteration_tb <= iteration_counter;
		end if;
	end process;
	
end testbench;