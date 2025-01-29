library ieee;
use ieee.std_logic_1164.all;

entity game_divisor_module is
    port (
        clk_25mhz : in std_logic;
        switch : in std_logic_vector (8 downto 0);
        GAME_DIVISOR : out integer;
        level : out integer
    );
end game_divisor_module;

architecture rtl of game_divisor_module is
begin

    process (clk_25mhz)
        variable game_speed : integer := 5000000;
        variable current_level : integer := 1;
    begin
        if rising_edge(clk_25mhz) then
            if switch(0) = '1' then
                case switch(8 downto 1) is
                    when "10000000" =>
                        current_level := 8;
                        GAME_DIVISOR <= 78125;
                    when "01000000" =>
                        current_level := 7;
                        GAME_DIVISOR <= 156250;
                    when "00100000" =>
                        current_level := 6;
                        GAME_DIVISOR <= 312500;
                    when "00010000" =>
                        current_level := 5;
                        GAME_DIVISOR <= 625000;
                    when "00001000" =>
                        current_level := 4;
                        GAME_DIVISOR <= 1250000;
                    when "00000100" =>
                        current_level := 3;
                        GAME_DIVISOR <= 2500000;
                    when "00000010" =>
                        current_level := 2;
                        GAME_DIVISOR <= 5000000;
                    when "00000001" =>
                        current_level := 1;
                        GAME_DIVISOR <= 10000000;
                    when others =>
                        current_level := 0;
                        GAME_DIVISOR <= 20000000;
                end case;
                level <= current_level;
            end if;
        end if;
    end process;

end rtl;