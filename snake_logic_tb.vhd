library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Для арифметических операций
use work.state.all; -- Подключаем наш пакет

entity snake_logic_tb is
end snake_logic_tb;

architecture testbench of snake_logic_tb is
	
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
	
	direction_change_process : process(game_clk_tb)
	begin
		if rising_edge(game_clk_tb) then
			-- Проверяем, если положение головы змейки по X равно 99
			if o_snake_tb.head.x = 63 then
				current_direction_tb <= UP;  -- Меняем направление на UP
			end if;
		end if;
	end process;
	
	
end testbench;