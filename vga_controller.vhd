library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
    port (
        clk_25mhz     : in  std_logic;  -- 25 ��� �������� ������ ��� VGA clock
        reset         : in  std_logic;
        hsync         : out std_logic;  -- �������������� �������������
        vsync         : out std_logic;  -- ������������ �������������
        blank         : out std_logic;  -- ������ blank ��� ���������� ������
        sync          : out std_logic;  -- ���������������� ������
        pixel_x       : out integer range 0 to 639;  -- ������� ���������� ������� �� ��� X
        pixel_y       : out integer range 0 to 479;  -- ������� ���������� ������� �� ��� Y
        display_active : out std_logic  -- ���� ���������� �������
    );
end entity;

architecture rtl of vga_controller is
    -- ��������� ��� VGA 640x480 @ 60Hz
    constant H_SYNC_PULSE : integer := 96;    -- ������������ �������� HSYNC
    constant H_BACK_PORCH : integer := 48;    -- ������ �������
    constant H_FRONT_PORCH : integer := 16;   -- �������� �������
    constant H_VISIBLE_AREA : integer := 640; -- ������� �������
    constant H_TOTAL : integer := H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA + H_FRONT_PORCH;

    constant V_SYNC_PULSE : integer := 2;     -- ������������ �������� VSYNC
    constant V_BACK_PORCH : integer := 33;    -- ������ �������
    constant V_FRONT_PORCH : integer := 10;   -- �������� �������
    constant V_VISIBLE_AREA : integer := 480; -- ������� �������
    constant V_TOTAL : integer := V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA + V_FRONT_PORCH;

    signal h_counter : integer range 0 to H_TOTAL - 1 := 0;
    signal v_counter : integer range 0 to V_TOTAL - 1 := 0;

begin
    -- ��������� ��������������� ��� HSYNC � VSYNC
    process(clk_25mhz)
    begin
        if rising_edge(clk_25mhz) then
            if reset = '1' then
                h_counter <= 0;
                v_counter <= 0;
            else
                -- �������������� �������
                if h_counter = H_TOTAL - 1 then
                    h_counter <= 0;
                    -- ������������ �������
                    if v_counter = V_TOTAL - 1 then
                        v_counter <= 0;
                    else
                        v_counter <= v_counter + 1;
                    end if;
                else
                    h_counter <= h_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- ��������� �������� ������������� HSYNC � VSYNC
    hsync <= '0' when h_counter < H_SYNC_PULSE else '1';
    vsync <= '0' when v_counter < V_SYNC_PULSE else '1';

    -- ��������� ������� blank
    blank <= '0' when (h_counter >= (H_SYNC_PULSE + H_BACK_PORCH) and h_counter < (H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA) and
                      v_counter >= (V_SYNC_PULSE + V_BACK_PORCH) and v_counter < (V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA)) else '1';

    -- ��������� ������� sync (������ �� ������������ ��� VGA, �� ����� ���� �������)
    sync <= '1';

    -- ���������� ������� ��������� �������
    pixel_x <= h_counter - H_SYNC_PULSE - H_BACK_PORCH;
    pixel_y <= v_counter - V_SYNC_PULSE - V_BACK_PORCH;

    -- ���� ���������� �������
    display_active <= '1' when (h_counter >= (H_SYNC_PULSE + H_BACK_PORCH) and h_counter < (H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA) and
                                v_counter >= (V_SYNC_PULSE + V_BACK_PORCH) and v_counter < (V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA)) else '0';
end rtl;
