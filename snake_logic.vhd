library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state.all; 

entity snake_logic is
	port (
		CLOCK_50 : in std_logic;
		game_clk_en          : in std_logic;
		current_direction : in direction;
		o_snake            : out snake;
		o_fruit : out position;
		reset_snake : in std_logic
		);
end snake_logic;

architecture rtl of snake_logic is 	 
	
	constant MAX_X : integer := 63;
	constant MAX_Y : integer := 47; 
	signal snake_state : snake := SNAKE_START_POSITION;  
	
begin 
	
	process (CLOCK_50)
		variable v_next_head : position;  
		variable v_tail : position_array; 
		variable is_collision : boolean; 
		variable is_fruit_eaten : boolean;
		variable i : integer; 
		variable fruit : position := (x => 2, y => 0);

		constant a : integer := 1103515245;
		constant c : integer := 12345;
		constant m : integer := 20;
		variable seed_x : integer := 7;
		variable seed_y : integer := 13;
	begin
		if rising_edge(CLOCK_50) and game_clk_en = '1' then
			v_next_head := snake_state.head;
			v_tail := snake_state.tail;
			
			case current_direction is
				when LEFT  => 
					if v_next_head.x = 0 then
						v_next_head.x := MAX_X;  
					else
						v_next_head.x := v_next_head.x - 1;
					end if;
				
				when RIGHT =>
					if v_next_head.x = MAX_X then
						v_next_head.x := 0;  
					else
						v_next_head.x := v_next_head.x + 1;
					end if;
				
				when UP =>
					if v_next_head.y = 0 then
						v_next_head.y := MAX_Y;  
					else
						v_next_head.y := v_next_head.y - 1;
					end if;
				
				when DOWN =>
					if v_next_head.y = MAX_Y then
						v_next_head.y := 0; 
					else
						v_next_head.y := v_next_head.y + 1;
				end if;
			end case;	

			if (v_next_head.x = fruit.x and v_next_head.y = fruit.y) then
				is_fruit_eaten := true;
				snake_state.tail_length <= snake_state.tail_length + 1; 
			else
				is_fruit_eaten := false;
			end if;
			
			is_collision := false; 
			for i in 0 to MAX_TAIL_LENGTH loop
				if (v_next_head.x = v_tail(i).x and v_next_head.y = v_tail(i).y and i < snake_state.tail_length) then	
					is_collision := true; 
					exit;
				end if;
			end loop;

			if not is_collision then
				if snake_state.tail_length > 0 then
					for i in MAX_TAIL_LENGTH downto 1 loop
						v_tail(i) := v_tail(i-1); 
					end loop;
					v_tail(0) := snake_state.head; 
				end if;

				snake_state.head <= v_next_head;  
				snake_state.tail <= v_tail;        
			else
				snake_state <= SNAKE_START_POSITION;
				fruit  		:= FRUIT_START_POSITION;
			end if;
			
			if is_fruit_eaten then 
				fruit := (x => (a * snake_state.head.x + c) mod MAX_X, y=> (a * snake_state.head.y + c) mod MAX_Y);
			end if;
		end if;     
		
		if (reset_snake = '1') then
			snake_state <= SNAKE_START_POSITION;
			fruit  		:= FRUIT_START_POSITION;
		end if;	
		
		o_snake <= snake_state;
		o_fruit <= fruit; 

	end process;
end rtl;

