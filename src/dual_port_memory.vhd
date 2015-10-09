library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

library work;
use work.constants_pkg.all;

-- Dual port memory ENTITY
entity dual_port_memory is
  port(wclk          : in  std_logic;
       rclk          : in  std_logic;
       raddr         : in  std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       ren           : in  std_logic;
       waddr         : in  std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       wen           : in  std_logic;
       write_data_in : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
       read_data_out : out std_logic_vector((DATA_WIDTH - 1) downto 0));
end dual_port_memory;

architecture arch of dual_port_memory is
  type storage_t is
    array (0 to 2 ** (ADDRESS_WIDTH - 1) - 1)
    of std_logic_vector((DATA_WIDTH - 1) downto 0);

  signal storage : storage_t;

begin

  process (wclk)
  begin
    if rising_edge(wclk) then
      if wen = '1' then
        storage(to_integer(unsigned(waddr(ADDRESS_WIDTH - 2 downto 0)))) <= write_data_in;
      end if;
    end if;
  end process;

  process (raddr, ren)
  begin
    if ren = '1' then
      read_data_out <= storage(to_integer(unsigned(raddr(ADDRESS_WIDTH - 2 downto 0))));
    end if;
  end process;

end arch;
