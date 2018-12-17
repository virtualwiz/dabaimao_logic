library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DISP_DRV is
  port(
    -- Slower clock input from CLOCK_GEN
    DISP_CLK     : in  std_logic;
    -- Display binary data and extended characters select
    DISP_BIN     : in  std_logic_vector(31 downto 0);
    DISP_EXT     : in  std_logic_vector(7 downto 0);
    -- Drive output
    DISP_ANODE   : out std_logic_vector(7 downto 0);  -- Digit select
    DISP_CATHODE : out std_logic_vector(7 downto 0)   -- Segment select
    );
end DISP_DRV;

architecture Behavioural of DISP_DRV is
  signal Decode_ROM_Address  : std_logic_vector(2 downto 0);
  signal Pattern_ROM_Address : std_logic_vector(4 downto 0);
begin

  process(DISP_CLK)
  begin
    if rising_edge(DISP_CLK) then
      Decode_ROM_Address <= Decode_ROM_Address + 1;
    end if;
  end process;

  with Decode_ROM_Address select        -- Binary anode select to one-hot
    DISP_ANODE <=
    "11111110" when "000",
    "11111101" when "001",
    "11111011" when "010",
    "11110111" when "011",
    "11101111" when "100",
    "11011111" when "101",
    "10111111" when "110",
    "01111111" when "111";

  with Decode_ROM_Address select  -- Binary anode select to pattern ROM address
    Pattern_ROM_Address <=
    DISP_EXT(0) & DISP_BIN(3 downto 0)   when "000",
    DISP_EXT(1) & DISP_BIN(7 downto 4)   when "001",
    DISP_EXT(2) & DISP_BIN(11 downto 8)  when "010",
    DISP_EXT(3) & DISP_BIN(15 downto 12) when "011",
    DISP_EXT(4) & DISP_BIN(19 downto 16) when "100",
    DISP_EXT(5) & DISP_BIN(23 downto 20) when "101",
    DISP_EXT(6) & DISP_BIN(27 downto 24) when "110",
    DISP_EXT(7) & DISP_BIN(31 downto 28) when "111";

  with Pattern_ROM_Address select       -- Pattern ROM
    --      0
    --     ---
    --  5 |   | 1
    --     ---   <- 6
    --  4 |   | 2
    --     ---
    --      3
    DISP_CATHODE <=
    "11000000" when "00000",            --0
    "11111001" when "00001",            --1
    "10100100" when "00010",            --2
    "10110000" when "00011",            --3
    "10011001" when "00100",            --4
    "10010010" when "00101",            --5
    "10000010" when "00110",            --6
    "11111000" when "00111",            --7
    "10000000" when "01000",            --8
    "10010000" when "01001",            --9
    "10001000" when "01010",            --A
    "10000011" when "01011",            --b
    "11000110" when "01100",            --C
    "10100001" when "01101",            --d
    "10000110" when "01110",            --E
    "10001110" when "01111",            --F
    "10111111" when "10000",            --_
    "10001100" when "10001",            --p
    "11001000" when "10010",            --n
    "10000111" when "10011",            --t
    "11000111" when "10100",            --l
    "11111111" when others;

end Behavioural;
