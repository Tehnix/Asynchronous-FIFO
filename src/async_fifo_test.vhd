library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.constants_pkg.all;

entity async_fifo_test is
end async_fifo_test;

architecture behavior of async_fifo_test is
  type test_array is
    array (2 ** (ADDRESS_WIDTH - 1) - 1 downto 0)
    of std_logic_vector((DATA_WIDTH - 1) downto 0);

  -- Inputs
  signal reset        : std_logic := '0';
  signal wclk         : std_logic := '0';
  signal rclk         : std_logic := '0';
  signal write_enable : std_logic := '0';
  signal read_enable  : std_logic := '0';
  signal write_data_in
    : std_logic_vector((DATA_WIDTH - 1) downto 0) := (others => '0');

  -- Outputs
  signal fifo_occu_in
    : std_logic_vector((ADDRESS_WIDTH - 1) downto 0) := (others => '0');
  signal fifo_occu_out
    : std_logic_vector((ADDRESS_WIDTH - 1) downto 0) := (others => '0');
  signal read_data_out
    : std_logic_vector((DATA_WIDTH - 1) downto 0) := (others => '0');

  constant CLOCK_PERIOD_FAST : time := 10 ns;
  constant CLOCK_PERIOD_SLOW : time := 20 ns;

  constant TEST_DATA : test_array := (x"DE", x"AD", x"BE", x"EF",
                                      x"DE", x"AD", x"BE", x"EF",
                                      x"DE", x"AD", x"BE", x"EF",
                                      x"DE", x"AD", x"BE", x"EF");
  component async_fifo is
    port (reset         : in  std_logic;
          wclk          : in  std_logic;
          rclk          : in  std_logic;
          write_enable  : in  std_logic;
          read_enable   : in  std_logic;
          write_data_in : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
          fifo_occu_in  : out std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
          fifo_occu_out : out std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
          read_data_out : out std_logic_vector((DATA_WIDTH - 1) downto 0));
  end component;

begin
  -- instantiate the unit under test (uut)
  uut : async_fifo
    port map (reset         => reset,
              wclk          => wclk,
              rclk          => rclk,
              write_enable  => write_enable,
              read_enable   => read_enable,
              write_data_in => write_data_in,
              fifo_occu_in  => fifo_occu_in,
              fifo_occu_out => fifo_occu_out,
              read_data_out => read_data_out);

  -- clock process definitions
  wclk_process : process
  begin

    wclk <= '0';
    wait for CLOCK_PERIOD_SLOW / 2;

    wclk <= '1';
    wait for CLOCK_PERIOD_SLOW / 2;

  end process;

  rclk_process : process
  begin

    rclk <= '0';
    wait for CLOCK_PERIOD_FAST / 2;

    rclk <= '1';
    wait for CLOCK_PERIOD_FAST / 2;

  end process;


  -- stimulus process
  stim_proc : process
  begin
    -- reset the state
    reset <= '1';
    wait for CLOCK_PERIOD_SLOW;
    reset <= '0';

    -- Write data to memory
    for i in 0 to (2 ** (ADDRESS_WIDTH - 1)) - 1 loop
      write_enable <= '1';

      wait for CLOCK_PERIOD_SLOW;

      write_data_in <= TEST_DATA(i);

      wait for CLOCK_PERIOD_SLOW;
    end loop;

    write_enable <= '0';

    -- The write control should report a full FIFO (15)
    assert unsigned(fifo_occu_in) = (2 ** (ADDRESS_WIDTH - 1)) - 1 report
      "`fifo_occu_in' is invalid. FIFO should be full." severity failure;

    wait for 5 * CLOCK_PERIOD_SLOW;

    -- The read control should synchronized with the write controller and report a full FIFO
    -- (15)
    assert unsigned(fifo_occu_out) = unsigned(fifo_occu_in) report
      "`fifo_occu_in' is not equal," &
      "but should be synchronized with `fifo_occu_out'." severity failure;

    -- Read data from memory
    for i in 0 to (2 ** (ADDRESS_WIDTH - 1)) - 1 loop
      read_enable <= '1';

      wait for CLOCK_PERIOD_FAST;

      assert read_data_out = TEST_DATA(i) report "Wrong result!" severity failure;

      wait for CLOCK_PERIOD_FAST;
    end loop;

    read_enable <= '0';

    assert unsigned(fifo_occu_out) = 0 report
      "After read: `fifo_occu_out' should be return an empty FIFO." severity failure;

    wait;
  end process;

end;
