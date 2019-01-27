library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity testbench is
  --  _____ _____ ____ _____ ____  _____ _   _  ____ _   _
  -- |_   _| ____/ ___|_   _| __ )| ____| \ | |/ ___| | | |
  --   | | |  _| \___ \ | | |  _ \|  _| |  \| | |   | |_| |
  --   | | | |___ ___) || | | |_) | |___| |\  | |___|  _  |
  --   |_| |_____|____/ |_| |____/|_____|_| \_|\____|_| |_|

end testbench;

architecture Behavioural of testbench is
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

  type Code_TypeDef is array(0 to 4) of std_logic_vector(3 downto 0);
  type Code_Random_TypeDef is array(0 to 1) of std_logic_vector(3 downto 0);

  constant Accepted_Sequence        : Code_TypeDef        := (x"2", x"4", x"0", x"1", x"3");
  constant Declined_Sequence        : Code_TypeDef        := (x"2", x"4", x"3", x"2", x"1");
  constant Accepted_Random_Sequence : Code_Random_TypeDef := (x"0", x"1");
  constant Declined_Random_Sequence : Code_Random_TypeDef := (x"5", x"6");

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

    --  _   _  ___  ____  __  __        ___  _  __
    -- | \ | |/ _ \|  _ \|  \/  |  _   / _ \| |/ /
    -- |  \| | | | | |_) | |\/| |_| |_| | | | ' /
    -- | |\  | |_| |  _ <| |  | |_   _| |_| | . \
    -- |_| \_|\___/|_| \_\_|  |_| |_|  \___/|_|\_\

    -- Use Case 1 : Normal mode and correct passcode, door should unlock immediately.
    -- Entering normal operation mode

    s_BTNS(0) <= '1';
    wait for 2 us;
    s_BTNS(0) <= '0';
    wait for 2 us;

    -- Entering passcode
    normal_unlock_seq : for Code_Index in 0 to 4 loop
      s_SWITCHES <= Accepted_Sequence(Code_Index);
      wait for 100 ns;
      s_BTNS(1)  <= '1';
      wait for 2 us;
      s_BTNS(1)  <= '0';
      wait for 2 us;
    end loop;

    -- Wait for display transition
    wait for 20 us;

    -- Return to Idle
    s_SWITCHES <= "0000";
    s_BTNS(1)  <= '1';
    wait for 2 us;
    s_BTNS(1)  <= '0';
    wait for 2 us;

    --  _   _  ___  ____  __  __       _____ ____  ____
    -- | \ | |/ _ \|  _ \|  \/  |  _  | ____|  _ \|  _ \
    -- |  \| | | | | |_) | |\/| |_| |_|  _| | |_) | |_) |
    -- | |\  | |_| |  _ <| |  | |_   _| |___|  _ <|  _ <
    -- |_| \_|\___/|_| \_\_|  |_| |_| |_____|_| \_\_| \_\

    -- Use Case 2 : Normal mode and wrong code, should not unlock the door.
    -- Entering normal operation mode

    s_BTNS(0) <= '1';
    wait for 2 us;
    s_BTNS(0) <= '0';
    wait for 2 us;

    -- Entering wrong passcode
    normal_wrong_seq : for Code_Index in 0 to 4 loop
      s_SWITCHES <= Declined_Sequence(Code_Index);
      wait for 100 ns;
      s_BTNS(1)  <= '1';
      wait for 2 us;
      s_BTNS(1)  <= '0';
      wait for 2 us;
    end loop;

    -- Wait for display transition
    wait for 20 us;

    -- Return to Idle
    s_SWITCHES <= "0000";
    s_BTNS(1)  <= '1';
    wait for 2 us;
    s_BTNS(1)  <= '0';
    wait for 2 us;

    --  ____  _____ ____ _   _ ____  _____       ___  _  __
    -- / ___|| ____/ ___| | | |  _ \| ____| _   / _ \| |/ /
    -- \___ \|  _|| |   | | | | |_) |  _| _| |_| | | | ' /
    --  ___) | |__| |___| |_| |  _ <| |__|_   _| |_| | . \
    -- |____/|_____\____|\___/|_| \_\_____||_|  \___/|_|\_\

    -- Use Case 3 : Secure mode and correct passcode entered, door should unlock
    -- Entering secured operation mode

    s_BTNS(2) <= '1';
    wait for 2 us;
    s_BTNS(2) <= '0';
    wait for 10 us;

    -- LED display now returning B0 99 which are numbers 3 and 4

    secure_unlock_seq : for Code_Index in 0 to 1 loop
      s_SWITCHES <= Accepted_Random_Sequence(Code_Index);
      wait for 100 ns;
      s_BTNS(1)  <= '1';
      wait for 2 us;
      s_BTNS(1)  <= '0';
      wait for 2 us;
    end loop;

    -- Wait for display transition
    wait for 20 us;

    -- Return to Idle
    s_SWITCHES <= "0000";
    s_BTNS(1)  <= '1';
    wait for 2 us;
    s_BTNS(1)  <= '0';
    wait for 2 us;

    --  ____  _____ ____ _   _ ____  _____      _____ ____  ____
    -- / ___|| ____/ ___| | | |  _ \| ____| _  | ____|  _ \|  _ \
    -- \___ \|  _|| |   | | | | |_) |  _| _| |_|  _| | |_) | |_) |
    --  ___) | |__| |___| |_| |  _ <| |__|_   _| |___|  _ <|  _ <
    -- |____/|_____\____|\___/|_| \_\_____||_| |_____|_| \_\_| \_\

    -- Use Case 4 : Secure mode and wrong passcode entered, door should keep locked
    -- Entering secured operation mode

    s_BTNS(2) <= '1';
    wait for 2 us;
    s_BTNS(2) <= '0';
    wait for 10 us;

    -- Test sequence does not contain any numbers in the correct passcode
    -- so display content can be ignored

    secure_wrong_seq : for Code_Index in 0 to 1 loop
      s_SWITCHES <= Declined_Random_Sequence(Code_Index);
      wait for 100 ns;
      s_BTNS(1)  <= '1';
      wait for 2 us;
      s_BTNS(1)  <= '0';
      wait for 2 us;
    end loop;

    -- Wait for display transition
    wait for 20 us;

    -- Return to Idle
    s_SWITCHES <= "0000";
    s_BTNS(1)  <= '1';
    wait for 2 us;
    s_BTNS(1)  <= '0';
    wait for 2 us;

    wait for 1 ms;
  end process;
end Behavioural;
