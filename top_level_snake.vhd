library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state.all; 

entity top_level_snake is
	port (
		CLOCK_50 : in std_logic;
		VGA_CLK   : out  std_logic;
		VGA_HS       : out std_logic;
		VGA_VS       : out std_logic;
		VGA_R           : out std_logic_vector(7 downto 0);  
		VGA_G           : out std_logic_vector(7 downto 0);  
		VGA_B           : out std_logic_vector(7 downto 0) ;
		KEY : in std_logic_vector(3 downto 0);  
		VGA_BLANK : out std_logic := '1';
		VGA_SYNC : out std_logic := '0';
		SW : in std_logic_vector (0 downto 0);

		HEX0 : out std_logic_vector (7 downto 0);
		HEX1 : out std_logic_vector (7 downto 0);
		HEX2 : out std_logic_vector (7 downto 0);
		HEX3 : out std_logic_vector (7 downto 0);
		HEX4 : out std_logic_vector (7 downto 0);
		HEX5 : out std_logic_vector (7 downto 0);
		HEX6 : out std_logic_vector (7 downto 0);
		HEX7 : out std_logic_vector (7 downto 0)

		);
end top_level_snake;

architecture rtl of top_level_snake is
	
	constant VGA_DIVISOR : integer := 1;        
	constant GAME_DIVISOR : integer := 12500000; 
	signal clk_div : std_logic := '0';
	signal count : integer := 0;
	signal game_clk_div : std_logic := '0';
	signal current_direction : direction;
	signal game_clk_en : std_logic;
	signal vga_clk_en : std_logic;
	signal score : integer;
	signal game_count : integer := 0;

	component snake_game is
		port (
			CLOCK_50   : in  std_logic;
			game_clk_en : in std_logic;
			vga_clk_en : in std_logic;
			hsync       : out std_logic;
			vsync       : out std_logic;
			r           : out std_logic_vector(7 downto 0);  
			g           : out std_logic_vector(7 downto 0);  
			b           : out std_logic_vector(7 downto 0);  
			current_direction : in direction;
			tail_length : out integer;
			reset_snake       : in  std_logic
			);
	end component; 
	
begin
	
	snake_game_instance: snake_game
	 port map(
		CLOCK_50 => CLOCK_50,
		game_clk_en => game_clk_en,
		vga_clk_en => vga_clk_en,
		hsync => VGA_HS,
		vsync => VGA_VS,
		r => VGA_R,
		g => VGA_G,
		b => VGA_B,
		current_direction => current_direction,
		tail_length => score,
		reset_snake => SW(0)
	);
	
	process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            vga_clk_en <= not vga_clk_en;
        end if;
    end process;

	process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if vga_clk_en = '1'  then
				VGA_CLK <= '1';
			else
				VGA_CLK <= '0';
			end if;
        end if;
    end process;
	
	process (CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			if game_count = GAME_DIVISOR then
				game_count <= 0;
				game_clk_en <= not game_clk_en;  
			else
				game_count <= game_count + 1;
			end if;
		end if;
	end process;
	
	process (CLOCK_50)
	begin
	if rising_edge(CLOCK_50) and vga_clk_en = '1' then		
		if rising_edge(clk_div) then
			if (KEY = not "0001" and current_direction /= DOWN ) then
			current_direction <= UP;
			end if;
			if (KEY = not "0010" and current_direction /= UP ) then
			current_direction <= DOWN;
			end if;
			if (KEY = not "0100" and current_direction /= LEFT ) then
			current_direction <= RIGHT;
			end if;
			if (KEY = not "1000" and current_direction /= RIGHT ) then
			current_direction <= LEFT;
			end if;
			if (KEY = "0000") then
			current_direction <= current_direction;
			end if;
		end if;
	end if;	
	end process;

	HEX0 <= SEGMENT_MAP(score mod 10);
	HEX1 <= SEGMENT_MAP((score mod 100)/10);
	HEX2 <= SEGMENT_MAP((score mod 1000)/100);
	HEX3 <= SEGMENT_MAP(14);
	HEX4 <= SEGMENT_MAP(10);
	HEX5 <= SEGMENT_MAP(0);
	HEX6 <= SEGMENT_MAP(12);
	HEX7 <= SEGMENT_MAP(5);
end;	