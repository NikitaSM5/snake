library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state.all;

entity top_level_snake is
	port (
		CLOCK_50 : in std_logic;
		VGA_CLK : out std_logic;
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_R : out std_logic_vector(7 downto 0);
		VGA_G : out std_logic_vector(7 downto 0);
		VGA_B : out std_logic_vector(7 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		VGA_BLANK : out std_logic := '1';
		VGA_SYNC : out std_logic := '0';
		SW : in std_logic_vector (8 downto 0);
		HEX0 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0);
		HEX4 : out std_logic_vector(6 downto 0);
		HEX5 : out std_logic_vector(6 downto 0);
		HEX6 : out std_logic_vector(6 downto 0);
		HEX7 : out std_logic_vector(6 downto 0)
	);
end top_level_snake;

architecture rtl of top_level_snake is

	signal GAME_DIVISOR : integer := 12500000;
	signal game_clk_en : std_logic := '0';
	signal score : integer := 0;
	signal level : integer := 1;
	signal clk_25mhz : std_logic;
	signal current_direction : direction;

	component snake_game is
		port (
			clk_25mhz : in std_logic;
			hsync : out std_logic;
			vsync : out std_logic;
			r : out std_logic_vector (7 downto 0);
			g : out std_logic_vector (7 downto 0);
			b : out std_logic_vector (7 downto 0);
			current_direction_t : in direction;
			game_clk_en : in std_logic;
			reset_snake : in std_logic;
			score : out integer
		);
	end component;

	component game_divisor_module is
		port (
			clk_25mhz : in std_logic;
			switch : in std_logic_vector (8 downto 0);
			GAME_DIVISOR : out integer;
			level : out integer
		);
	end component;

	component clock_25 is
		port (
			inclk0 : in std_logic := '0';
			c0 : out std_logic
		);
	end component;

	component game_clk_counter is
		port (
			GAME_DIVISOR : in integer;
			clk_25mhz : in std_logic;
			game_clk_en : out std_logic
		);
	end component;

	component hex_handler is
		port (
			clk_25mhz : in std_logic;
			game_clk_en : in std_logic;
			level : in integer;
			score : in integer;
			rst : in std_logic;
			hex_0 : out std_logic_vector(6 downto 0);
			hex_1 : out std_logic_vector(6 downto 0);
			hex_2 : out std_logic_vector(6 downto 0);
			hex_3 : out std_logic_vector(6 downto 0);
			hex_4 : out std_logic_vector(6 downto 0);
			hex_5 : out std_logic_vector(6 downto 0);
			hex_6 : out std_logic_vector(6 downto 0);
			hex_7 : out std_logic_vector(6 downto 0)
		);
	end component;

	component key_handler is
		port (
			clk_25mhz : in std_logic;
			reset : in std_logic;
			key_in : in std_logic_vector(3 downto 0);
			current_direction : out direction
		);
	end component;

begin

	clock_25_inst : clock_25
	port map(
		inclk0 => CLOCK_50,
		c0 => clk_25mhz
	);

	game_clk_counter_inst : game_clk_counter
	port map(
		GAME_DIVISOR => GAME_DIVISOR,
		clk_25mhz => clk_25mhz,
		game_clk_en => game_clk_en
	);

	snake_game_inst : snake_game port map(
		clk_25mhz => clk_25mhz,
		hsync => VGA_HS,
		vsync => VGA_VS,
		r => VGA_R,
		g => VGA_G,
		b => VGA_B,
		current_direction_t => current_direction,
		game_clk_en => game_clk_en,
		reset_snake => SW(0),
		score => score
	);

	key_handler_inst : key_handler
	port map(
		clk_25mhz => clk_25mhz,
		reset => SW(0),
		key_in => KEY,
		current_direction => current_direction
	);

	VGA_CLK <= clk_25mhz;

	game_divisor_module_inst : game_divisor_module
	port map(
		clk_25mhz => clk_25mhz,
		switch => SW,
		GAME_DIVISOR => GAME_DIVISOR,
		level => level
	);

	hex_handler_inst : hex_handler
	port map(
		clk_25mhz => clk_25mhz,
		game_clk_en => game_clk_en,
		level => level,
		score => score,
		rst => SW(0),
		hex_0 => HEX0,
		hex_1 => HEX1,
		hex_2 => HEX2,
		hex_3 => HEX3,
		hex_4 => HEX4,
		hex_5 => HEX5,
		hex_6 => HEX6,
		hex_7 => HEX7
	);

end;