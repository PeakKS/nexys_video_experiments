--; led test
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cxxrtl is
    port (
        clk : in    std_logic;
        led : out   std_logic
    );
end entity cxxrtl;

architecture rtl of cxxrtl is
    signal r_count : std_logic_vector (7 downto 0);
begin
    counter : entity work.counter port map (
        clk => clk,
        msb => led
    );
end rtl;

