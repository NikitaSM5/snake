library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state.all; 

entity snake_output is
    port (
        clk_25mhz : in  std_logic;
        reset     : in  std_logic;
        hsync     : out std_logic;
        vsync     : out std_logic;
        blank     : out std_logic;  -- ������ blank
        sync      : out std_logic;  -- ������ �������������
        r         : out std_logic_vector(9 downto 0);  -- ������� ����� (10 ���)
        g         : out std_logic_vector(9 downto 0);  -- ������ ����� (10 ���)
        b         : out std_logic_vector(9 downto 0);  -- ����� ����� (10 ���)
        o_snake   : in  snake;  -- ��������� ������ (������ � �����)
        o_fruit   : in  position -- ������� ���
    );
end entity;

architecture rtl of snake_output is
    signal pixel_x, pixel_y : integer range 0 to 639;
    signal display_active   : std_logic;
    signal blank_signal     : std_logic;

    component vga_controller
        port (
            clk_25mhz       : in std_logic;
            reset           : in std_logic;
            hsync           : out std_logic;
            vsync           : out std_logic;
            blank           : out std_logic;
            sync            : out std_logic;
            pixel_x         : out integer range 0 to 639;
            pixel_y         : out integer range 0 to 479;
            display_active  : out std_logic
        );
    end component;

begin
    -- ���������� VGA ����������
    vga_inst : vga_controller
        port map (
            clk_25mhz => clk_25mhz,
            reset     => reset,
            hsync     => hsync,
            vsync     => vsync,
            blank     => blank_signal,  -- ������ blank
            sync      => sync,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            display_active => display_active
        );

    -- ��������� �����������
    process(clk_25mhz)
        variable is_tail_segment : boolean;  -- ���� ��� ��������, �������� �� ������� ������ ������
    begin
        if rising_edge(clk_25mhz) then
            if display_active = '1' then
                -- ���� ������ blank �������, ������� ������ ����
                if blank_signal = '1' then
                    r <= (others => '0');
                    g <= (others => '0');
                    b <= (others => '0');
                else
                    -- ��������, �������� �� ������� ������� ������� ������
                    if (pixel_x = o_snake.head.x and pixel_y = o_snake.head.y) then
                        r <= "1111111111";  -- ������� ��� ������ ������ (10 ���)
                        g <= "0000000000";
                        b <= "0000000000";

                    -- ��������, �������� �� ������� ������� ����
                    elsif (pixel_x = o_fruit.x and pixel_y = o_fruit.y) then
                        r <= "0000000000";  -- ������ ��� ��� (10 ���)
                        g <= "1111111111";
                        b <= "0000000000";
                    
                    -- �������� ��� ������ ������
                    else
                        is_tail_segment := false;  -- ���������� ������������, ��� ������� �� ����� ������
                        for i in 0 to o_snake.tail_length - 1 loop
                            -- �������� ��� ������ ����� ������
                            if (pixel_x = o_snake.tail(i).x and pixel_y = o_snake.tail(i).y) then
                                is_tail_segment := true;
                            end if;
                        end loop;

                        -- ���� ������� ��������� � ����������� ����� ������
                        if is_tail_segment then
                            r <= "0000000000";  -- ����� ��� ������ ������ (10 ���)
                            g <= "0000000000";
                            b <= "1111111111";
                        else
                            -- ������ ���� ��� ����
                            r <= "0000000000";
                            g <= "0000000000";
                            b <= "0000000000";
                        end if;
                    end if;
                end if;
            else
                -- ������ ����, ���� ��� ��������� ������
                r <= "0000000000";
                g <= "0000000000";
                b <= "0000000000";
            end if;
        end if;
    end process;

end rtl;
