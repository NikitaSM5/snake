library ieee;
use ieee.std_logic_1164.all; 
use ieee.math_real.all;

package state is
	-- ����������� ���� ��� ����������� ��������
	type direction is (LEFT, RIGHT, UP, DOWN);
	
	-- ����������� ���� ��� ������� (����������)
	type position is record
		x : integer;
		y : integer;
	end record;
	
	-- ����������� ���� ��� ������� ������� ������ ������
	type position_array is array (0 to 128) of position;
	
	-- ����������� ���� ��� ����� ������
	type snake is record
		head : position;           -- ������ ������
		tail_length : integer; -- ����� ������
		tail : position_array;      -- ������ ��� �������� ������� ������
	end record;	
	
	function generate_random(seed :  integer) return integer;
	impure function food_generator (o_snake: snake) return position;
end package; 

package body state is
	
	function generate_random(seed : integer) return integer is
		constant a : integer := 1103515245;
		constant c : integer := 12345;
		constant m : integer := 10000;  -- ������, �������� ������� �������� 
		variable t : integer := seed;
	begin
		-- ���������� ����� ��������� ����� �� ������� ��������� ������������� ����������
		t := (a * seed + c) mod m;
		
		-- ������������ ��������� ����� �� ��������� �� 0 �� 19
		return t mod 20;  -- ��� ��������� ����� � ��������� �� 0 �� 19
	end function;
	
	
	impure function food_generator(o_snake : snake) return position is
		variable new_food : position;
		variable valid_position : boolean;	
		variable seed : integer := now/1ns;
	begin
		valid_position := false;
		
		-- �������� ��������� ����
		while not valid_position loop 
			-- ��������� ��������� ��������� ��� ���
			new_food.x := generate_random(seed);
			new_food.y := generate_random(seed + 1);
			
			-- ��������, ����� ����� ������� �� ��������� � �������� ������ ��� ������
			valid_position := true;  -- ������� ������� ������� ��������
			
			if (new_food.x = o_snake.head.x and new_food.y = o_snake.head.y) then
				valid_position := false;  -- ���� ������� � �������, ���������
			end if;
			
			-- ��������� ��� ������� ������ ������
			for i in 0 to o_snake.tail_length - 1 loop
				if (new_food.x = o_snake.tail(i).x and new_food.y = o_snake.tail(i).y) then
					valid_position := false;  -- ���� ������� � ����� �� ������ ������, ���� ��������� 
					exit;
				end if;
			end loop;  
		
			
			seed := seed + 1;
		end loop;
		
		-- ���������� ��������������� �������
		return new_food;
	end function;
end package body;

