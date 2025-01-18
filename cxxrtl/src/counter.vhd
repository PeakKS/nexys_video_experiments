--; led test
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port (
        clk : in    std_logic;
        msb : out   std_logic
    );
end entity counter;

architecture rtl of counter is
    signal count : std_logic_vector (7 downto 0);
begin
    cnt : process (clk)
    begin
        if rising_edge (clk) then
            count <= std_logic_vector (unsigned (count) + 1);
        end if;
    end process cnt;
    msb <= count(7);
end architecture rtl;

