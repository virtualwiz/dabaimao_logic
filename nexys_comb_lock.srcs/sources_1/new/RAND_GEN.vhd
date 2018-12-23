library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RAND_GEN is
  port(
    -- Unscaled clock
    RAND_CLK   : in  std_logic;
    -- Latch new random numbers
    RAND_LATCH : in  std_logic;
    -- Output
    RAND_OUT   : out std_logic_vector(5 downto 0)  -- XXX_XXX 4..0 in each group
    );
end RAND_GEN;

architecture Behavioural of RAND_GEN is
  signal Count_Reg_0 : std_logic_vector(2 downto 0);
  signal Count_Reg_1 : std_logic_vector(2 downto 0);  -- Mem_3bx2;

  function Range_Limiter(RNG_LMT_IN : in std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable RNG_LMT_OUT : std_logic_vector(2 downto 0);
  begin
    if RNG_LMT_IN = "101" then
      RNG_LMT_OUT := "000";
    else
      RNG_LMT_OUT := RNG_LMT_IN;
    end if;
    return std_logic_vector(RNG_LMT_IN);
  end Range_Limiter;

begin
  process(RAND_CLK)
  begin
    if rising_edge(RAND_CLK) then
      Count_Reg_0 <= Range_Limiter(Count_Reg_0 + 1);
    end if;
  end process;

  process(Count_Reg_0(2))
  begin
    if rising_edge(Count_Reg_0(2)) then
      Count_Reg_1 <= Range_Limiter(Count_Reg_1 + 1);
    end if;
  end process;

  process(RAND_LATCH)
  begin
    if rising_edge(RAND_LATCH) then
      RAND_OUT(5 downto 3) <= Count_Reg_1;
      if Count_Reg_1 = Count_Reg_0 then
        RAND_OUT(2 downto 0) <= Range_Limiter(Count_Reg_0 + 1);
      else
        RAND_OUT(2 downto 0) <= Range_Limiter(Count_Reg_0);
      end if;
    end if;
  end process;

end Behavioural;


