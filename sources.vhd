library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package state is

	constant SNAKE_MAX_TAIL_LENGTH : integer := 2;

	type direction is (LEFT, RIGHT, UP, DOWN);

	type position is record
		x : integer;
		y : integer;
	end record;

	type position_array is array (0 to SNAKE_MAX_TAIL_LENGTH) of position;

	type snake is record
		head : position;
		tail_length : integer;
		tail : position_array;
	end record;

	type segment_map_t is array (0 to 23) of std_logic_vector(6 downto 0);
	constant SEGMENT_MAP : segment_map_t := (
		"1000000", -- 0
		"1111001", -- 1
		"0100100", -- 2
		"0110000", -- 3
		"0011001", -- 4
		"0010010", -- 5
		"0000010", -- 6
		"1111000", -- 7
		"0000000", -- 8
		"0010000", -- 9
		"0001000", -- A
		"0000011", -- B
		"1000110", -- C
		"0100001", -- D
		"0000110", -- E
		"0001110", -- F
		"0001100", -- P  16
		"0001000", -- A  17
		"1000001", -- U  18
		"0010010", -- S  19
		"0000110", -- E  20
		"1000111", -- L  21
		"1110111", -- _  22
		"1111111" -- off 23
	);

	type block_pattern_t is array (0 to 9, 0 to 9) of std_logic;

	constant SNAKE_HEAD_PATTERN : block_pattern_t := (
		('0', '0', '0', '1', '1', '1', '1', '0', '0', '0'),
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0'),
		('0', '1', '1', '0', '1', '1', '0', '1', '1', '0'),
		('0', '1', '0', '1', '1', '1', '1', '0', '1', '0'),
		('1', '1', '0', '0', '1', '1', '0', '0', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('0', '1', '0', '1', '1', '1', '1', '0', '1', '0'),
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0'),
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0')
	);

	constant SNAKE_TAIL_PATTERN : block_pattern_t := (
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0'),
		('0', '1', '1', '1', '1', '1', '1', '1', '1', '0'),
		('1', '1', '1', '1', '1', '0', '0', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '0', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('0', '1', '1', '1', '1', '1', '1', '1', '1', '0'),
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0')
	);

	constant FRUIT_PATTERN : block_pattern_t := (
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0'),
		('0', '1', '1', '1', '1', '1', '1', '1', '1', '0'),
		('1', '1', '1', '1', '1', '0', '0', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '0', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
		('0', '1', '1', '1', '1', '1', '1', '1', '1', '0'),
		('0', '0', '1', '1', '1', '1', '1', '1', '0', '0')
	);

	impure function food_generator(o_snake : snake) return position;
	function get_head_pixel(x, y : integer; dir : direction) return std_logic;
end package;

package body state is

	impure function food_generator(o_snake : snake) return position is
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
			seed_x := (a * seed_x + c) mod m;
			seed_y := (a * seed_y + c) mod m;
			new_food.x := seed_x;
			new_food.x := seed_x;
			valid_position := true;
			if ((new_food.x = o_snake.head.x) and new_food.y = o_snake.head.y) then
				valid_position := false;
			end if;

			for i in 0 to SNAKE_MAX_TAIL_LENGTH loop
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

	function get_head_pixel(x, y : integer; dir : direction) return std_logic is
	begin
		case dir is
			when UP =>
				return SNAKE_HEAD_PATTERN(y, x);
			when DOWN =>
				return SNAKE_HEAD_PATTERN(9 - y, 9 - x);
			when RIGHT =>
				return SNAKE_HEAD_PATTERN(9 - x, y);
			when LEFT =>
				return SNAKE_HEAD_PATTERN(x, 9 - y);
			when others =>
				return '0';
		end case;
	end function;

end package body;