library ieee;
use ieee.std_logic_1164.all; 
use ieee.math_real.all;

package state is

	constant MAX_TAIL_LENGTH : integer := 5;
	
	type direction is (LEFT, RIGHT, UP, DOWN);
	
	type position is record
		x : integer;
		y : integer;
	end record;
	
	type position_array is array (0 to MAX_TAIL_LENGTH) of position;
	
	type snake is record
		head : position;        
		tail_length : integer; 
		tail : position_array;      
	end record;	

	constant SNAKE_START_POSITION : snake := 
	(head       => (x => 5, y => 8),    
   	tail_length => 0,                  
   	tail        => (others => (x => 0, y => 0)));

	constant FRUIT_START_POSITION : position := (x => 5, y => 8);
	
	type segment_map_t is array (0 to 15) of std_logic_vector(7 downto 0);
	constant SEGMENT_MAP : segment_map_t := (
    "11111100",  -- 0 // O
    "01100000",  -- 1
    "11011010",  -- 2
    "11110010",  -- 3
    "01100110",  -- 4
    "10110110",  -- 5 // S
    "10111110",  -- 6
    "11100000",  -- 7
    "11111110",  -- 8
    "11110110",  -- 9
    "11101110",  -- A // R
    "00111110",  -- B
    "10011100",  -- C
    "01111010",  -- D
    "10011110",  -- E
    "10001110"   -- F
);

	function food_generator (o_snake: snake) return position;
end package; 

package body state is
	
	function food_generator(o_snake : snake) return position is
		variable new_food : position;
		constant a : integer := 1103515245;
		constant c : integer := 12345;
		constant m : integer := 20;
		variable seed_x : integer := 7;
		variable seed_y : integer := 13;
		variable valid_position : boolean;
	begin

		valid_position := false;
		
		for attempt in 1 to 10 loop
		seed_x := (a*seed_x + c) mod m;
		seed_y := (a*seed_y + c) mod m;
		new_food.x := seed_x;
		new_food.x := seed_x;
		valid_position := true;

		if ((new_food.x = o_snake.head.x) and new_food.y = o_snake.head.y) then
		valid_position := false;
		end if;
		
		for i in 0 to MAX_TAIL_LENGTH loop
			if ((new_food.x = o_snake.tail(i).x) and new_food.y = o_snake.tail(i).y) then
			valid_position := false;
			exit;
		end if;

		end loop;	
		if valid_position then 		
		return new_food;
		end if;
		end loop;
	
		return new_food;
	end function;
end package body;

