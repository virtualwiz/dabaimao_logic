library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RAND_GEN is
  port(
    -- Latch new random numbers
    RAND_CLK : in  std_logic;
    RAND_EN  : in  std_logic;
    -- Output
    RAND_OUT : out std_logic_vector(5 downto 0)  -- XXX_XXX 4..0 in each group
    );
end RAND_GEN;

architecture Behavioural of RAND_GEN is
  signal LFSR_Reg : std_logic_vector(7 downto 0) := b"01011110";  -- LFSR init seq
begin

  process(RAND_CLK)
  begin
    if (rising_edge(RAND_CLK)) then
      LFSR_Reg(7 downto 1) <= LFSR_Reg(6 downto 0);
      LFSR_Reg(0)          <= not(LFSR_Reg(7) xor LFSR_Reg(6) xor LFSR_Reg(4));
    end if;
  end process;

  process(RAND_EN)
  begin
    if (rising_edge(RAND_EN))then
      RAND_OUT <= LFSR_Reg(5 downto 0);
    end if;
  end process;

end Behavioural;


