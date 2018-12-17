library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DISP_GFX is
  port(
    -- Data and opcode input
    GFX_OPCODE : in  std_logic_vector(2 downto 0);   -- 0..5 for state select
    GFX_DATA   : in  std_logic_vector(19 downto 0);  -- XXXX_XXXX_XXXX_XXXX_XXXX
    -- Clock
    GFX_CLK    : in  std_logic;
    -- Signals to DISP_DRV
    GFX_BIN    : out std_logic_vector(31 downto 0);
    GFX_EXT    : out std_logic_vector(7 downto 0)
    );
end DISP_GFX;

architecture Behavioural of DISP_GFX is
begin
  process(GFX_CLK)
  begin
    case GFX_OPCODE is
      when "000" =>                     -- Idle
        GFX_EXT <= "00101111";
        GFX_BIN <= x"1d4effff";
      when "001" =>                     -- Code****
        GFX_EXT <= "00001111";
        GFX_BIN <= x"c0deffff" when GFX_DATA = 0,
                   x"c0de0fff" when GFX_DATA = 1,
                   x"c0de00ff" when GFX_DATA = 2,
                   x"c0de000f" when GFX_DATA = 3,
                   x"c0de0000" when GFX_DATA = 4;
      when "010" =>                     -- 5 Digits
        GFX_EXT <= "00000111";
        GFX_BIN <= GFX_DATA & x"fff";
      when "011" =>                     -- Accepted
        GFX_EXT <= "00001100";
        GFX_BIN <= x"acce13ed";
      when "100" =>                     -- Declined
        GFX_EXT <= "00010100";
        GFX_BIN <= x"dec512ed";
      when "101" =>                     -- CodeXX**
        GFX_EXT <= "00000011";
        GFX_BIN <= x"c0de" + GFX_DATA(8 downto 1) + x"ff" when GFX_DATA(0) = "0",
                   x"c0de" + GFX_DATA(8 downto 1) + x"f0" when GFX_DATA(0) = "1";
      when "110" =>                     -- 2 Digits
        GFX_EXT <= "00111111";
        GFX_BIN <= GFX_DATA(7 downto 0) & x"ffffff";
    end case;
  end process;
end Behavioural;
