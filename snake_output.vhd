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
        blank     : out std_logic;  -- Сигнал blank
        sync      : out std_logic;  -- Сигнал синхронизации
        r         : out std_logic_vector(9 downto 0);  -- Красный канал (10 бит)
        g         : out std_logic_vector(9 downto 0);  -- Зелёный канал (10 бит)
        b         : out std_logic_vector(9 downto 0);  -- Синий канал (10 бит)
        o_snake   : in  snake;  -- Состояние змейки (голова и хвост)
        o_fruit   : in  position -- Позиция еды
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
    -- Подключаем VGA контроллер
    vga_inst : vga_controller
        port map (
            clk_25mhz => clk_25mhz,
            reset     => reset,
            hsync     => hsync,
            vsync     => vsync,
            blank     => blank_signal,  -- Сигнал blank
            sync      => sync,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            display_active => display_active
        );

    -- Генерация изображения
    process(clk_25mhz)
        variable is_tail_segment : boolean;  -- Флаг для проверки, является ли пиксель частью хвоста
    begin
        if rising_edge(clk_25mhz) then
            if display_active = '1' then
                -- Если сигнал blank активен, выводим чёрный цвет
                if blank_signal = '1' then
                    r <= (others => '0');
                    g <= (others => '0');
                    b <= (others => '0');
                else
                    -- Проверка, является ли текущий пиксель головой змейки
                    if (pixel_x = o_snake.head.x and pixel_y = o_snake.head.y) then
                        r <= "1111111111";  -- Красный для головы змейки (10 бит)
                        g <= "0000000000";
                        b <= "0000000000";

                    -- Проверка, является ли текущий пиксель едой
                    elsif (pixel_x = o_fruit.x and pixel_y = o_fruit.y) then
                        r <= "0000000000";  -- Зелёный для еды (10 бит)
                        g <= "1111111111";
                        b <= "0000000000";
                    
                    -- Проверка для хвоста змейки
                    else
                        is_tail_segment := false;  -- Изначально предполагаем, что пиксель не часть хвоста
                        for i in 0 to o_snake.tail_length - 1 loop
                            -- Проверка для каждой части хвоста
                            if (pixel_x = o_snake.tail(i).x and pixel_y = o_snake.tail(i).y) then
                                is_tail_segment := true;
                            end if;
                        end loop;

                        -- Если пиксель совпадает с координатой части хвоста
                        if is_tail_segment then
                            r <= "0000000000";  -- Синий для хвоста змейки (10 бит)
                            g <= "0000000000";
                            b <= "1111111111";
                        else
                            -- Черный цвет для фона
                            r <= "0000000000";
                            g <= "0000000000";
                            b <= "0000000000";
                        end if;
                    end if;
                end if;
            else
                -- Черный цвет, если вне активного экрана
                r <= "0000000000";
                g <= "0000000000";
                b <= "0000000000";
            end if;
        end if;
    end process;

end rtl;
