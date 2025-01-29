library ieee;
use ieee.std_logic_1164.all;
use work.state.all;

entity key_handler is
    port (
        clk_25mhz : in std_logic;
        reset : in std_logic;
        key_in : in std_logic_vector(3 downto 0);
        current_direction : buffer direction

    );
end key_handler;

architecture rtl of key_handler is

    signal temp_dir : direction;
    constant SW_DIVISOR : integer := 125000;
    signal sw_clk_en : std_logic := '0';
    signal sw_counter : integer range 0 to 250001 := 0;
    signal key_last : std_logic_vector(3 downto 0);

begin

    process (clk_25mhz)
    begin
        if rising_edge(clk_25mhz) then
            if sw_counter > SW_DIVISOR then
                sw_counter <= 0;
                sw_clk_en <= not sw_clk_en;
            else
                sw_counter <= sw_counter + 1;
            end if;
        end if;
    end process;

    process (clk_25mhz)
        variable keys_pressed : std_logic_vector(3 downto 0);
        variable key_pressed_edge : std_logic_vector (3 downto 0);
    begin
        if rising_edge(clk_25mhz) then
            current_direction <= temp_dir;
            if sw_clk_en = '1' then
                if reset = '0' then
                    keys_pressed := not key_in;
                    key_pressed_edge := (keys_pressed and key_last);

                    key_last <= not key_in;

                    if key_pressed_edge(0) = '1' and key_pressed_edge(1) = '1' then
                        key_pressed_edge(0) := '0';
                        key_pressed_edge(1) := '0';
                    end if;
                    if key_pressed_edge(2) = '1' and key_pressed_edge(3) = '1' then
                        key_pressed_edge(2) := '0';
                        key_pressed_edge(3) := '0';
                    end if;

                    if current_direction = UP or current_direction = DOWN then
                        if key_pressed_edge(3) = '1' then
                            temp_dir <= LEFT;
                        elsif key_pressed_edge(2) = '1' then
                            temp_dir <= RIGHT;
                        elsif key_pressed_edge(0) = '1' and current_direction /= DOWN then
                            temp_dir <= UP;
                        elsif key_pressed_edge(1) = '1' and current_direction /= UP then
                            temp_dir <= DOWN;
                        end if;
                    elsif current_direction = LEFT or current_direction = RIGHT then
                        if key_pressed_edge(0) = '1' then
                            temp_dir <= UP;
                        elsif key_pressed_edge(1) = '1' then
                            temp_dir <= DOWN;
                        elsif key_pressed_edge(3) = '1' and current_direction /= RIGHT then
                            temp_dir <= LEFT;
                        elsif key_pressed_edge(2) = '1' and current_direction /= LEFT then
                            temp_dir <= RIGHT;
                        end if;
                    end if;
                else
                    temp_dir <= RIGHT;
                end if;
            end if;
        end if;
    end process;
end rtl;