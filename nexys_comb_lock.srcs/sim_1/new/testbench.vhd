library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity testbench is
  --  _____ _____ ____ _____ ____  _____ _   _  ____ _   _
  -- |_   _| ____/ ___|_   _| __ )| ____| \ | |/ ___| | | |
  --   | | |  _| \___ \ | | |  _ \|  _| |  \| | |   | |_| |
  --   | | | |___ ___) || | | |_) | |___| |\  | |___|  _  |
  --   |_| |_____|____/ |_| |____/|_____|_| \_|\____|_| |_|

end testbench;

architecture Behavioral of testbench is
  component top is
    port(
      CLK100MHZ : in  std_logic;
      SEGMENTS  : out std_logic_vector(7 downto 0);
      DIGITS    : out std_logic_vector(7 downto 0);
      SWITCHES  : in  std_logic_vector(3 downto 0);
      SENSOR    : in  std_logic;
      BTNS      : in  std_logic_vector(3 downto 0);
      LED17     : out std_logic_vector(2 downto 0);
      LED16_B   : out std_logic;
      LEDS      : out std_logic_vector(3 downto 0)
      );
  end component;

  signal s_CLK100MHZ : std_logic;
  signal s_SEGMENTS  : std_logic_vector(7 downto 0);
  signal s_DIGITS    : std_logic_vector(7 downto 0);
  signal s_SWITCHES  : std_logic_vector(3 downto 0);
  signal s_SENSOR    : std_logic;
  signal s_BTNS      : std_logic_vector(3 downto 0);
  signal s_LED17     : std_logic_vector(2 downto 0);
  signal s_LED16_B   : std_logic;
  signal s_LEDS      : std_logic_vector(3 downto 0);

  constant CLK_PERIOD : time := 10 ns;

begin
  UUT : top port map(
    CLK100MHZ => s_CLK100MHZ,
    SEGMENTS  => s_SEGMENTS,
    DIGITS    => s_DIGITS,
    SWITCHES  => s_SWITCHES,
    SENSOR    => s_SENSOR,
    BTNS      => s_BTNS,
    LED17     => s_LED17,
    LED16_B   => s_LED16_B,
    LEDS      => s_LEDS
    );

  CLOCK_PROCESS : process
  begin
    s_CLK100MHZ <= '0';
    wait for CLK_PERIOD / 2;
    s_CLK100MHZ <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- BTNS Configuration
  -- +-----------+-----------+-----------+-----------+
  -- | s_BTNS(0) | s_BTNS(1) | s_BTNS(2) | s_BTNS(3) |
  -- +-----------+-----------+-----------+-----------+
  -- | Down      | Centre    | Up        | Right     |
  -- | Normal    | Enter     | Secure    | Program   |
  -- +-----------+-----------+-----------+-----------+

  -- LED display patterns as hexadecimal numbers
  -- +----------+-------------------------+
  -- | String   | Numbers series          |
  -- +----------+-------------------------+
  -- | IDLE     | F9 A1 C7 86             |
  -- | CODE     | C6 C0 A1 86             |
  -- | CODE**   | C6 C0 A1 86 BF BF       |
  -- | ACCEPTED | 88 C6 C6 86 8C 87 86 A1 |
  -- | DECLINED | A1 86 C6 C7 F9 C8 86 A1 |
  -- +----------+-------------------------+

  TEST_PROCESS : process
  begin
    s_BTNS     <= "0000";
    s_SWITCHES <= "0000";
    s_SENSOR   <= '0';
    wait for 20 us;

    -- RUN 1 : Normal mode unlocking

    s_BTNS(0) <= '1';
    wait for 2 us;
    s_BTNS(0) <= '0';
    wait for 2 us;

    s_BTNS(1) <= '1';
    wait for 2 us;
    s_BTNS(1) <= '0';
    wait for 2 us;

    wait for 1 ms;


  end process;
end Behavioral;
