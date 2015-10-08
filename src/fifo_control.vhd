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
  signal mem_pointer : std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
begin

  pointer <= mem_pointer;
  fifo_occu <= std_logic_vector(unsigned(mem_pointer) - unsigned(sync_pointer));

  process (sync_pointer, mem_pointer)
  begin
    -- Write POV
    if sync_pointer(ADDRESS_WIDTH - 1) = mem_pointer(ADDRESS_WIDTH - 1) then
      flag <= '0';
    else
      flag <= '1';
    end if;
  end process;

  process (clk, reset, enable)
  begin
    if reset = '1' then
      mem_pointer   <= (others => '0');
      address   <= (others => '0');
      mem_en    <= '0';
    elsif rising_edge(clk) then
      mem_en <= '0';

      if enable = '1' then
        mem_en <= '1';
        address <= mem_pointer;
        mem_pointer <= std_logic_vector(unsigned(mem_pointer) + 1);
      end if;
    end if;
  end process;
end arch;
