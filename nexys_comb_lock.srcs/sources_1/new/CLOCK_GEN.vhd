library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CLOCK_GEN is
  port(
    -- 100 MHz crystal oscillator input
    CLK_MAIN   : in  std_logic;
    -- Divided clock output
    CLK_SEG    : out std_logic;
    CLK_USER   : out std_logic;
    CLK_SECOND : out std_logic
    );
end CLOCK_GEN;

architecture Behavioural of CLOCK_GEN is
--  constant Sys_Prescaler_Width : integer := 17;  -- SYNTHESIS
  constant Sys_Prescaler_Width : integer := 1;   -- SIMULATION

  -- SYNTHESIS Configuration :
  -- +-----------+------------+--------------+
  -- | SEG Speed | USER Speed | SECOND Speed |
  -- +-----------+------------+--------------+
  -- | 763 Hz    | 24 Hz      | 1 Hz         |
  -- +-----------+------------+--------------+

  -- SIMULATION Configuration :
  -- +-----------+------------+--------------+
  -- | SEG Speed | USER Speed | SECOND Speed |
  -- +-----------+------------+--------------+
  -- | 50 MHz    | 1.57 MHz   | 65.5 kHz     |
  -- | 20 ns     | 637 ns     | 15.2 us      |
  -- +-----------+------------+--------------+

  signal Seg_Counter    : std_logic_vector(Sys_Prescaler_Width downto 0) := (others => '0');
  signal User_Counter   : std_logic_vector(3 downto 0) := (others => '0');  -- User : ~ 24 Hz
  signal Second_Counter : std_logic_vector(4 downto 0) := (others => '0');
  signal Second_Reg     : std_logic := '0';

begin

  process(CLK_MAIN)
  begin
    if rising_edge(CLK_MAIN) then
      Seg_Counter <= Seg_Counter + 1;
    end if;
  end process;

  CLK_SEG <= Seg_Counter(Sys_Prescaler_Width);

  process(Seg_Counter(Sys_Prescaler_Width))
  begin
    if rising_edge(Seg_Counter(Sys_Prescaler_Width)) then
      User_Counter <= User_Counter + 1;
    end if;
  end process;

  CLK_USER <= User_Counter(3);

  process(User_Counter(3))
  begin
    if falling_edge(User_Counter(3)) then
      Second_Counter <= Second_Counter + 1;
      if Second_Counter = "11000" then
        Second_Reg     <= '1';
        Second_Counter <= (others => '0');
      else
        Second_Reg <= '0';
      end if;
    end if;
  end process;

  CLK_SECOND <= Second_Reg;

end Behavioural;
