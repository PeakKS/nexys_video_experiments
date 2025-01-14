--; led test
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leds is
    port (
        clk : in    std_logic;
        led : out   std_logic
    );
end entity leds;

architecture rtl of leds is
    signal r_count : std_logic_vector (24 downto 0);
begin
    count : process (clk)
    begin
        if rising_edge (clk) then
            r_count <= std_logic_vector (unsigned (r_count) + 1);
        end if;
    end process count;

    led <= r_count(24);
end rtl;

