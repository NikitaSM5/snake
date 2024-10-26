library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- ��� �������������� ��������
use work.state.all; 

entity snake_logic is
	port (
		current_direction : in direction;
		game_clk          : in std_logic;
		o_snake            : out snake;
		o_fruit : out position
		);
end snake_logic;

architecture rtl of snake_logic is 
	
	signal next_head : position := (x => 0, y => 0);  -- ����� ��������� ������
	
	
	-- ��������� ��� ������ ������
	constant MAX_X : integer := 20;
	constant MAX_Y : integer := 20; 
	
begin 
	
	
	
	-- �������, ������� ����� ��������� ��������� ������
	process (game_clk)
		variable v_next_head : position;  -- ���������� ��� ���������� �������� ��������� ������
		variable v_tail : position_array; -- ���������� ��� �������� ������
		variable is_collision : boolean;  -- ���������� ��� ������������ ������������
		variable i : integer;  -- ���������� ��� �����
		variable snake_state_temp : snake := (
		head        => (x => 0, y => 0),     -- ������������� ������ (������� 0,0)
		tail_length => 0,                    -- ������������� ����� ������ (0)
		tail        => (others => (x => 0, y => 0))  -- ������������� ���� ��������� ������ (���������� 0,0)
		);   -- ������� ��������� ������
		variable is_fruit_eaten : std_logic;
		variable fruit :  position := (x => 5, y => 1);
		
	begin
		if rising_edge(game_clk) then
			-- 1. �������� ������� ��������� ������ � ������ � ����������
			v_next_head := snake_state_temp.head;
			v_tail := snake_state_temp.tail;
			
			-- 2. ���������� ������� ������ ������ � ����������� �� �����������
			case current_direction is
				when LEFT  => 
					if v_next_head.x = 0 then
						v_next_head.x := MAX_X;  -- ���� ������ �� ����� �������, ������������ � ������
					else
						v_next_head.x := v_next_head.x - 1;
					end if;
				
				when RIGHT =>
					if v_next_head.x = MAX_X then
						v_next_head.x := 0;  -- ���� ������ �� ������ �������, ������������ � �����
					else
						v_next_head.x := v_next_head.x + 1;
					end if;
				
				when UP =>
					if v_next_head.y = 0 then
						v_next_head.y := MAX_Y;  -- ���� ������ �� ������� �������, ������������ � ������
					else
						v_next_head.y := v_next_head.y - 1;
					end if;
				
				when DOWN =>
					if v_next_head.y = MAX_Y then
						v_next_head.y := 0;  -- ���� ������ �� ������ �������, ������������ � �������
					else
						v_next_head.y := v_next_head.y + 1;
				end if;
			end case;
			
			-- 3. �������� �� ������������ � �������
			if (v_next_head.x = fruit.x and v_next_head.y = fruit.y) then
				is_fruit_eaten := '1';
				snake_state_temp.tail_length := snake_state_temp.tail_length + 1;  -- ����������� ����� ������
			else
				is_fruit_eaten := '0';
			end if;
			
			-- 4. �������� �� ������������ � ����� �����
			is_collision := false;  -- ������� �������, ��� ������������ ���
			for i in 0 to snake_state_temp.tail_length - 1 loop
				if (v_next_head.x = v_tail(i).x and v_next_head.y = v_tail(i).y) then
					is_collision := true;  -- ���� ���������� ������� � ����� ������ ������, ��������� ������������
					exit;
				end if;
			end loop;
			
			-- 5. ���� ��� ������������, ��������� ��������� ������
			if not is_collision then
				-- ��������� ��������� ������ (����� ������)
				if snake_state_temp.tail_length > 0 then
					for i in snake_state_temp.tail_length downto 1 loop
						v_tail(i) := v_tail(i-1);  -- �������� �����
					end loop;
					v_tail(0) := snake_state_temp.head;  -- ������� ������ ���������� ������� ������
				end if;
				
				-- ��������� ������� �� ������ ����������
				snake_state_temp.head := v_next_head;   -- ��������� ��������� ������
				snake_state_temp.tail := v_tail;        -- ��������� �����
			else
				-- ��������� ������������
				assert false report "collision" severity failure;
			end if;
			
			if is_fruit_eaten then 
				fruit :=  food_generator(snake_state_temp);
			end if;
		end if;	 
		o_snake <= snake_state_temp;
		o_fruit <= fruit; 
	end process;
	
	-- �������� ������
	
	
end rtl;
