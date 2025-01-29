library ieee;
use ieee.std_logic_1164.all;

entity game_clk_counter is
    port (
        GAME_DIVISOR : in integer;
        clk_25mhz : in std_logic;
        game_clk_en : buffer std_logic

    );
end game_clk_counter;

architecture rtl of game_clk_counter is
    signal game_count : integer := 0;

begin
    process (clk_25mhz)
    begin
        if rising_edge(clk_25mhz) then
            if game_count > GAME_DIVISOR then
                game_count <= 0;
                game_clk_en <= not game_clk_en;
            else
                game_count <= game_count + 1;
            end if;
        end if;
    end process;
end rtl;