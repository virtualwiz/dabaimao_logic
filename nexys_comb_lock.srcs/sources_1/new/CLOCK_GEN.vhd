library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CLOCK_GEN is
  port(
    -- 100 MHz crystal oscillator input
    CLK_MAIN : in  std_logic;
    -- Divided clock output
    CLK_SEG  : out std_logic;
    CLK_USER : out std_logic
    );
end CLOCK_GEN;

architecture Behavioural of CLOCK_GEN is
  signal Seg_Counter  : std_logic_vector(17 downto 0);
  signal User_Counter : std_logic_vector(3 downto 0);  -- User : ~ 24 Hz
  signal User_Reg     : std_logic;
begin

  process(CLK_MAIN)
  begin
    if rising_edge(CLK_MAIN) then
      Seg_Counter <= Seg_Counter + 1;
    end if;
  end process;

  CLK_SEG <= Seg_Counter(17);

  process(Seg_Counter(17))
  begin
    if rising_edge(Seg_Counter(17)) then
      User_Counter <= User_Counter + 1;
    end if;
  end process;

  CLK_USER <= User_Counter(3);

end Behavioural;
