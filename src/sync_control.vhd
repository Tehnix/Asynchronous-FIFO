library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

library work;
use work.constants_pkg.all;

-- SYNC ENTITY
entity sync_control is
  port(clk  : in  std_logic;
       ptr  : in  std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       sync : out std_logic_vector((ADDRESS_WIDTH - 1) downto 0));
end sync_control;

architecture arch of sync_control is
begin
  process (clk)
  begin
    if rising_edge(clk) then
      sync <= ptr;
    end if;
  end process;
end arch;
