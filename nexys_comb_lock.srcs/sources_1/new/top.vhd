library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
  port(
    CLK100MHZ : in  std_logic;
    SEGMENTS  : out std_logic_vector(7 downto 0);
    DIGITS    : out std_logic_vector(7 downto 0);
    SWITCHES  : in  std_logic_vector(3 downto 0);
    SENSOR    : in  std_logic;
    BTNS      : in  std_logic_vector(4 downto 0);
    LED17     : out std_logic_vector(2 downto 0);
    LED16_R   : out std_logic;
    LEDS      : out std_logic_vector(15 downto 0)
    );
end top;

architecture Structural of top is
  component CLOCK_GEN
    port(
      -- 100 MHz crystal oscillator input
      CLK_MAIN   : in  std_logic;
      -- Divided clock output
      CLK_SEG    : out std_logic;
      CLK_USER   : out std_logic;
      CLK_SECOND : out std_logic
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
      DISP_CATHODE : out std_logic_vector(7 downto 0)   -- Segment select
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

  component DEBOUNCER is
    port(
      DEB_CLK : in  std_logic;
      DEB_IN  : in  std_logic;
      DEB_OUT : out std_logic
      );
  end component;

  component FSM is
    port(
      -- Clock for FSM
      FSM_CLK           : in  std_logic;
      FSM_DELAY_S       : in  std_logic;
      -- Keys input
      KEYPAD            : in  std_logic_vector(3 downto 0);
      KEY_ACTIVATE_NORM : in  std_logic;
      KEY_ACTIVATE_PART : in  std_logic;
      KEY_CONFIRM       : in  std_logic;
      DR_SENSOR         : in  std_logic;
      -- Random numbers operations
      FSM_RAND          : in  std_logic_vector(5 downto 0);
      FSM_RAND_EN       : out std_logic;
      -- Signals to display
      FSM_GFX_OPCODE    : out std_logic_vector(2 downto 0);
      FSM_GFX_DATA      : out std_logic_vector(19 downto 0);
      -- Signals to servo motor
      LATCH_DRIVE       : out std_logic;
      DEBUG             : out std_logic_vector(7 downto 0)
      );
  end component;

  component RAND_GEN is
    port(
      -- Latch new random numbers
      RAND_CLK : in  std_logic;
      RAND_EN  : in  std_logic;
      -- Output
      RAND_OUT : out std_logic_vector(5 downto 0)  -- XXX_XXX 4..0 in each group
      );
  end component;


  signal CLK_SEG_Signal    : std_logic;
  signal CLK_USER_Signal   : std_logic;
  signal CLK_SECOND_Signal : std_logic;
  signal GFX_DATA_Signal   : std_logic_vector(19 downto 0);
  signal GFX_OPCODE_Signal : std_logic_vector(2 downto 0);
  signal GFX_BIN_Signal    : std_logic_vector(31 downto 0);
  signal GFX_EXT_Signal    : std_logic_vector(7 downto 0);
  signal BTNS_Signal       : std_logic_vector(3 downto 0);
  signal RAND_DATA_Signal  : std_logic_vector(5 downto 0);
  signal RAND_NEXT_Signal  : std_logic;

begin

  CLOCK_GEN_Inst : CLOCK_GEN port map(
    CLK_MAIN   => CLK100MHZ,
    CLK_SEG    => CLK_SEG_Signal,
    CLK_USER   => CLK_USER_Signal,
    CLK_SECOND => CLK_SECOND_Signal
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

  DEB_Array :
  for DEB_Address in 0 to 3 generate
    DEBOUNCER_Inst : DEBOUNCER port map(
      DEB_CLK => CLK_USER_Signal,
      DEB_IN  => BTNS(DEB_Address),
      DEB_OUT => BTNS_Signal(DEB_Address)
      );
  end generate DEB_Array;

  FSM_Inst : FSM port map(
    FSM_CLK           => CLK_USER_Signal,
    FSM_DELAY_S       => CLK_SECOND_Signal,
    KEYPAD            => SWITCHES,
    FSM_RAND          => RAND_DATA_Signal,
    FSM_RAND_EN       => RAND_NEXT_Signal,
    DR_SENSOR         => SENSOR,
    FSM_GFX_OPCODE    => GFX_OPCODE_Signal,
    FSM_GFX_DATA      => GFX_DATA_Signal,
    KEY_ACTIVATE_NORM => BTNS_Signal(0),
    KEY_ACTIVATE_PART => BTNS_Signal(2),
    KEY_CONFIRM       => BTNS_Signal(1),
    DEBUG             => LEDS(7 downto 0)
    );

  RAND_GEN_Inst : RAND_GEN port map(
    RAND_CLK => CLK100MHZ,
    RAND_EN  => RAND_NEXT_Signal,
    RAND_OUT => RAND_DATA_Signal
    );


  -- LED17   <= BTNS_Signal(2 downto 0);
  -- LED16_R <= CLK_SECOND_Signal;
  -- LEDS(3 downto 0) <= SWITCHES;

end Structural;
