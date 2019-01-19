library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DISP_GFX is
  port(
    -- Data and opcode input
    GFX_OPCODE : in  std_logic_vector(2 downto 0);   -- 0..5 for state select
    GFX_DATA   : in  std_logic_vector(19 downto 0);  -- XXXX_XXXX_XXXX_XXXX_XXXX
    -- Signals to DISP_DRV
    GFX_BIN    : out std_logic_vector(31 downto 0);
    GFX_EXT    : out std_logic_vector(7 downto 0)
    );
end DISP_GFX;

architecture Behavioural of DISP_GFX is
begin
  process(GFX_OPCODE, GFX_DATA)
  begin
    case GFX_OPCODE is
      when "000" =>                     -- Idle
        GFX_EXT <= "00101111";
        GFX_BIN <= x"1d4effff";
      when "001" =>                     -- Code****
        GFX_EXT <= "00001111";
        if GFX_DATA = 0 then
          GFX_BIN <= x"c0deffff";
        elsif GFX_DATA = 1 then
          GFX_BIN <= x"c0de0fff";
        elsif GFX_DATA = 2 then
          GFX_BIN <= x"c0de00ff";
        elsif GFX_DATA = 3 then
          GFX_BIN <= x"c0de000f";
        elsif GFX_DATA = 4 then
          GFX_BIN <= x"c0de0000";
        else
          GFX_BIN <= x"c0deeeee";
        end if;
      when "010" =>                     -- 5 Digits
        GFX_EXT <= "00000111";
        GFX_BIN <= GFX_DATA & x"fff";
      when "011" =>                     -- Accepted
        GFX_EXT <= "00001100";
        GFX_BIN <= x"acce13ed";
      when "100" =>                     -- Declined
        GFX_EXT <= "00010100";
        GFX_BIN <= x"dec412ed";
      when "101" =>                     -- CodeXX**
        GFX_EXT <= "00000011";
        if GFX_DATA(0) = '0' then
          GFX_BIN <= x"c0de" & (x"55" - GFX_DATA(8 downto 1)) & x"ff";
        else
          GFX_BIN <= x"c0de" & (x"55" - GFX_DATA(8 downto 1)) & x"f0";
        end if;
      when "110" =>                     -- 2 Digits
        GFX_EXT <= "00111111";
        GFX_BIN <= GFX_DATA(19 downto 12) & x"ffffff";
      when others =>
        GFX_EXT <= "11111111";
        GFX_BIN <= x"00000000";
    end case;
  end process;
end Behavioural;
