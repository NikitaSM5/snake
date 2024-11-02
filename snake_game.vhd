library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state.all; 
use ieee.math_real.all;

entity snake_game is
	port (
		CLOCK_50   : in  std_logic;
		vga_clk_en : in std_logic;
		game_clk_en : in std_logic;
		reset_snake       : in  std_logic;
		hsync       : out std_logic;
		vsync       : out std_logic;
		r           : out std_logic_vector(7 downto 0); 
		g           : out std_logic_vector(7 downto 0); 
		b           : out std_logic_vector(7 downto 0); 
		current_direction : in direction;
		tail_length : out integer
		);
end entity;

architecture rtl of snake_game is
	
	component snake_logic is
		port (
			CLOCK_50 : in std_logic;
			game_clk_en          : in std_logic;
			current_direction : in direction;
			o_snake            : out snake;
			o_fruit : out position;
			reset_snake : in std_logic
			);	 
		
	end component;
	
	constant BLOCK_SIZE : integer := 10;  
	constant H_SYNC_PULSE : integer := 96;   
	constant H_BACK_PORCH : integer := 48;   
	constant H_FRONT_PORCH : integer := 16;   
	constant H_VISIBLE_AREA : integer := 640; 
	constant H_TOTAL : integer := H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA + H_FRONT_PORCH;
	constant V_SYNC_PULSE : integer := 2;     
	constant V_BACK_PORCH : integer := 33;   
	constant V_FRONT_PORCH : integer := 10;   
	constant V_VISIBLE_AREA : integer := 480; 
	constant V_TOTAL : integer := V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA + V_FRONT_PORCH;
	
	signal h_counter : integer range 0 to H_TOTAL - 1 := 0;
	signal v_counter : integer range 0 to V_TOTAL - 1 := 0;
	signal pixel_x   : integer range 0 to 639;
	signal pixel_y   : integer range 0 to 479;
	signal display_active : std_logic;
	signal blank_signal : std_logic;
	
	signal o_snake_t : snake;
	signal o_fruit_t : position;
	
begin

	process(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) and vga_clk_en = '1' then
			if h_counter = H_TOTAL - 1 then
					h_counter <= 0;
				if v_counter = V_TOTAL - 1 then
					v_counter <= 0;
				else
					v_counter <= v_counter + 1;
				end if;
			else
				h_counter <= h_counter + 1;
			end if;
		end if;
	end process;
	
	hsync <= '0' when h_counter < H_SYNC_PULSE else '1';
	vsync <= '0' when v_counter < V_SYNC_PULSE else '1';

	blank_signal <= '0' when (h_counter >= (H_SYNC_PULSE + H_BACK_PORCH) and h_counter < (H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA) and
	v_counter >= (V_SYNC_PULSE + V_BACK_PORCH) and v_counter < (V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA)) else '1';

	display_active <= '1' when (h_counter >= (H_SYNC_PULSE + H_BACK_PORCH) and h_counter < (H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA) and
	v_counter >= (V_SYNC_PULSE + V_BACK_PORCH) and v_counter < (V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA)) else '0';
	
	process (h_counter, v_counter)
	begin
		if (h_counter >= H_SYNC_PULSE + H_BACK_PORCH and h_counter < H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA) then
			pixel_x <= h_counter - (H_SYNC_PULSE + H_BACK_PORCH);
		else
			pixel_x <= 0;
		end if;

		if (v_counter >= V_SYNC_PULSE + V_BACK_PORCH and v_counter < V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA) then
			pixel_y <= v_counter - (V_SYNC_PULSE + V_BACK_PORCH);
		else
			pixel_y <= 0; 
		end if;
	end process;

	t_snake : snake_logic
	port map (
		CLOCK_50 => CLOCK_50,
		o_snake => o_snake_t,
		current_direction => current_direction,
		o_fruit => o_fruit_t,
		game_clk_en => game_clk_en,
		reset_snake => reset_snake
		);

	tail_length <= o_snake_t.tail_length;
	
	process(CLOCK_50)
		variable is_tail_segment : boolean;
	begin
		if rising_edge(CLOCK_50) and vga_clk_en = '1' then
			if display_active = '1' then
				if blank_signal = '1' then
					r <= (others => '0');
					g <= (others => '0');
					b <= (others => '0');
				else
					if (pixel_x >= o_snake_t.head.x * BLOCK_SIZE and pixel_x < (o_snake_t.head.x * BLOCK_SIZE + BLOCK_SIZE) and
						pixel_y >= o_snake_t.head.y * BLOCK_SIZE and pixel_y < (o_snake_t.head.y * BLOCK_SIZE + BLOCK_SIZE)) then
						r <= (others => '1'); 
						g <= (others => '0');
						b <= (others => '0');
					  elsif (pixel_x >= o_fruit_t.x * BLOCK_SIZE and pixel_x < (o_fruit_t.x * BLOCK_SIZE + BLOCK_SIZE) and
						pixel_y >= o_fruit_t.y * BLOCK_SIZE and pixel_y < (o_fruit_t.y * BLOCK_SIZE + BLOCK_SIZE)) then
						r <= (others => '0');
						g <= (others => '1'); 
						b <= (others => '0');
					else
						is_tail_segment := false;
						for i in 0 to MAX_TAIL_LENGTH loop
							if (pixel_x >= o_snake_t.tail(i).x * BLOCK_SIZE and pixel_x < (o_snake_t.tail(i).x * BLOCK_SIZE + BLOCK_SIZE) and
								pixel_y >= o_snake_t.tail(i).y * BLOCK_SIZE and pixel_y < (o_snake_t.tail(i).y * BLOCK_SIZE + BLOCK_SIZE) and (i <o_snake_t.tail_length )) then
								is_tail_segment := true;
							end if;
						end loop;
						if is_tail_segment then
							r <= (others => '0');
							g <= (others => '1');
							b <= (others => '0');  
						else
							r <= (others => '0');
							g <= (others => '0');
							b <= (others => '0');
						end if;
					end if;
				end if;
			else
				r <= (others => '0');
				g <= (others => '0');
				b <= (others => '0');
			end if;
		end if;
	end process;
end rtl;
