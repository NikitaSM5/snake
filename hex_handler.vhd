library ieee;
use ieee.std_logic_1164.all;
use work.state.all;

entity hex_handler is
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
end hex_handler;

architecture rtl of hex_handler is
    signal HEX_pos : integer range 3 to 5 := 3;
begin
    process (clk_25mhz) begin
        if rising_edge(clk_25mhz) then
            if game_clk_en = '1' then

                if rst = '0' then
                    hex_0 <= SEGMENT_MAP(score mod 10);
                    hex_1 <= SEGMENT_MAP((score / 10) mod 10);
                    hex_2 <= SEGMENT_MAP(5);

                    case HEX_pos is
                        when 3 =>
                            hex_3 <= SEGMENT_MAP(22);
                            hex_4 <= SEGMENT_MAP(23);
                            hex_5 <= SEGMENT_MAP(23);
                            HEX_pos <= 4;
                        when 4 =>
                            hex_3 <= SEGMENT_MAP(23);
                            hex_4 <= SEGMENT_MAP(22);
                            HEX_5 <= SEGMENT_MAP(23);
                            HEX_pos <= 5;
                        when 5 =>
                            hex_3 <= SEGMENT_MAP(23);
                            hex_4 <= SEGMENT_MAP(23);
                            hex_5 <= SEGMENT_MAP(22);
                            HEX_pos <= 3;
                    end case;

                else
                    hex_0 <= SEGMENT_MAP(14);
                    hex_1 <= SEGMENT_MAP(5);
                    hex_2 <= SEGMENT_MAP(18);
                    hex_3 <= SEGMENT_MAP(10);
                    hex_4 <= SEGMENT_MAP(16);
                    hex_5 <= SEGMENT_MAP(23);
                end if;

                hex_6 <= SEGMENT_MAP(level);
                hex_7 <= SEGMENT_MAP(21);

            end if;
        end if;
    end process;
end rtl;