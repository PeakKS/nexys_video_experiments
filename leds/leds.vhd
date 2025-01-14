--; led test
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leds is
    port (
        clk  : in    std_logic;
        leds : out   std_logic_vector (0 to 7)
    );
end entity leds;

architecture rtl of leds is
    signal r_count : std_logic_vector (30 downto 0);
begin
    count : process (clk)
    begin
        if rising_edge (clk) then
            r_count <= std_logic_vector (unsigned (r_count) + 1);
        end if;
    end process count;

    leds(0) <= r_count(23);
    leds(1) <= r_count(24);
    leds(2) <= r_count(25);
    leds(3) <= r_count(26);
    leds(4) <= r_count(27);
    leds(5) <= r_count(28);
    leds(6) <= r_count(29);
    leds(7) <= r_count(30);
end rtl;

