library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

library work;
use work.constants_pkg.all;

-- FIFO Control ENTITY
entity fifo_control is
  port(clk          : in  std_logic;
       reset        : in  std_logic;
       enable       : in  std_logic;
       sync_pointer : in  std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       pointer      : out std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       fifo_occu    : out std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       -- Full/Empty flag
       flag         : out std_logic;
       address      : out std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
       mem_en       : out std_logic);
end fifo_control;

architecture arch of fifo_control is
  signal pointer : std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
begin

  process (sync_pointer, pointer)
  begin
    if sync_pointer(n) = pointer(n) then
      fifo_occu <= sync_pointer(ADDRESS_WIDTH - 1 downto 0) -
                   pointer(ADDRESS_WIDTH - 1 downto 0);
      flag <= '1';
    else
      fifo_occu <= 2 ** ADDRESS_WIDTH -
                   (sync_pointer(ADDRESS_WIDTH - 1 downto 0) -
                    pointer(ADDRESS_WIDTH - 1 downto 0));
      flag <= '0';
    end if;
  end process;

  process (clk, reset, enable)
  begin
    if reset = '1' then
      pointer   <= (others => '0');
      fifo_occu <= (others => '0');
      flag      <= '0';
      address   <= (others => '0');
      mem_en    <= '0';
    elsif rising_edge(clk) then
      if enable = '1' then
        mem_en <= '1';

      end if;
    end if;
  end process;
end arch;
