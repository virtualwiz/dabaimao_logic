library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
  port(
    CLK100MHZ    : in  std_logic;
    SEGMENTS     : out std_logic_vector(7 downto 0);
    DIGITS       : out std_logic_vector(7 downto 0);
    SWITCHES     : in  std_logic_vector(2 downto 0);
    LED_CLK_USER : out std_logic
    );
end top;

architecture Structural of top is
  component CLOCK_GEN
    port(
      -- 100 MHz crystal oscillator input
      CLK_MAIN : in  std_logic;
      -- Divided clock output
      CLK_SYS  : out std_logic;
      CLK_SEG  : out std_logic;
      CLK_USER : out std_logic
      );
  end component;

  component DISP_DRV is
    port(
      -- Slower clock input from CLOCK_GEN
      DISP_CLK     : in  std_logic;
      -- Display binary data and extended characters select
      DISP_BIN     : in  std_logic_vector(31 downto 0);
      DISP_EXT     : in  std_logic_vector(7 downto 0);
      -- Drive output
      DISP_ANODE   : out std_logic_vector(7 downto 0);  -- Digit select
      DISP_CATHODE : out std_logic_vector(7 downto 0)  -- Segment select
      );
  end component;

  component DISP_GFX is
    port(
      -- Data and opcode input
      GFX_OPCODE : in  std_logic_vector(2 downto 0);   -- 0..5 for state select
      GFX_DATA   : in  std_logic_vector(19 downto 0);  -- XXXX_XXXX_XXXX_XXXX_XXXX
      -- Signals to DISP_DRV
      GFX_BIN    : out std_logic_vector(31 downto 0);
      GFX_EXT    : out std_logic_vector(7 downto 0)
      );
  end component;

  signal CLK_SEG_Signal    : std_logic;
  signal GFX_DATA_Signal   : std_logic_vector(19 downto 0);
  signal GFX_OPCODE_Signal : std_logic_vector(2 downto 0);
  signal GFX_BIN_Signal    : std_logic_vector(31 downto 0);
  signal GFX_EXT_Signal    : std_logic_vector(7 downto 0);

begin

  CLOCK_GEN_Inst : CLOCK_GEN port map(
    CLK_MAIN => CLK100MHZ,
    CLK_SEG  => CLK_SEG_Signal,
    CLK_USER => LED_CLK_USER
    );

  DISP_DRV_Inst : DISP_DRV port map(
    DISP_CLK     => CLK_SEG_Signal,
    DISP_BIN     => GFX_BIN_Signal,
    DISP_EXT     => GFX_EXT_Signal,
    DISP_ANODE   => DIGITS,
    DISP_CATHODE => SEGMENTS
    );

  DISP_GFX_Inst : DISP_GFX port map(
    GFX_OPCODE => GFX_OPCODE_Signal,
    GFX_DATA   => GFX_DATA_Signal,
    GFX_BIN    => GFX_BIN_Signal,
    GFX_EXT    => GFX_EXT_Signal
    );

  GFX_DATA_Signal   <= x"00000";
  GFX_OPCODE_Signal <= SWITCHES;

end Structural;
