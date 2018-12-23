library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FSM is
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
    FSM_RAND_EN       : out std_logic;
    FSM_RAND          : in  std_logic_vector(5 downto 0);
    -- Signals to display
    FSM_GFX_OPCODE    : out std_logic_vector(2 downto 0);
    FSM_GFX_DATA      : out std_logic_vector(19 downto 0);
    -- Signals to servo motor
    LATCH_DRIVE       : out std_logic
    );
end FSM;

architecture Behavioural of FSM is
  function BUF_Addressing(
    MEM         : std_logic_vector(19 downto 0);
    ADDR_IN_BIN : std_logic_vector(2 downto 0)
    )
    return std_logic_vector is
    variable DATA : std_logic_vector(3 downto 0);
  begin
    if ADDR_IN_BIN = "000" then
      DATA := MEM(3 downto 0);
    elsif ADDR_IN_BIN = "001" then
      DATA := MEM(7 downto 4);
    elsif ADDR_IN_BIN = "010" then
      DATA := MEM(11 downto 8);
    elsif ADDR_IN_BIN = "011" then
      DATA := MEM(15 downto 12);
    elsif ADDR_IN_BIN = "100" then
      DATA := MEM(19 downto 16);
    else
      DATA := x"f";
    end if;
    return std_logic_vector(DATA);
  end BUF_Addressing;


-- Use descriptive names for the States, like st1_reset, st2_search
  type TypeDef_State is (
    st0_idle,
    st1_p1, st2_p2, st3_p3, st4_p4, st5_p5,
    st6_accepted, st7_accepted_code_disp,
    st8_declined, st9_declined_code_disp,
    stX_activate,
    stC_compare
    );
  signal State, Next_State      : TypeDef_State;
-- Declare internal signals for all outputs of the State-machine
  signal LATCH_Signal           : std_logic;
  signal FSM_G_Data_Signal      : std_logic_vector(19 downto 0);
  signal FSM_G_Opcode_Signal    : std_logic_vector(2 downto 0);
-- Passcode buffer registers
  signal BUF_Passcode           : std_logic_vector(19 downto 0);
  signal BUF_Passcode_Preset    : std_logic_vector(19 downto 0) := x"24013";
  signal BUF_Passcode_Part      : std_logic_vector(7 downto 0)  := x"00";
-- Mode flag
  signal FSM_Secure_Mode_Enable : std_logic;
-- Register pointers
  signal BUF_Pointer            : std_logic_vector(2 downto 0);
begin

  FSM_RAND_EN                   <= KEY_ACTIVATE_PART;
  BUF_Passcode_Part(7 downto 4) <= BUF_Addressing(BUF_Passcode, FSM_RAND(5 downto 3));
  BUF_Passcode_Part(3 downto 0) <= BUF_Addressing(BUF_Passcode, FSM_RAND(2 downto 0));

  process (KEY_CONFIRM)
  begin
    if rising_edge(KEY_CONFIRM) then
      case BUF_Pointer is
        when "000" =>
          BUF_Passcode(19 downto 16) <= KEYPAD;
        when "001" =>
          BUF_Passcode(15 downto 12) <= KEYPAD;
        when "010" =>
          BUF_Passcode(11 downto 8) <= KEYPAD;
        when "011" =>
          BUF_Passcode(7 downto 4) <= KEYPAD;
        when "100" =>
          BUF_Passcode(3 downto 0) <= KEYPAD;
        when others =>
          null;
      end case;
    end if;
  end process;

  SYNC_PROC : process (FSM_CLK)
  begin
    if (rising_edge(FSM_CLK)) then
      State          <= Next_State;
      LATCH_DRIVE    <= LATCH_Signal;
      FSM_GFX_DATA   <= FSM_G_Data_Signal;
      FSM_GFX_OPCODE <= FSM_G_Opcode_Signal;
    end if;
  end process;

  --MEALY State-Machine - Outputs based on State and inputs
  OUTPUT_DECODE : process (State, KEY_ACTIVATE_NORM, KEY_ACTIVATE_PART, KEY_CONFIRM)
  begin
    --insert Statements to decode internal output signals
    --below is simple example
    if State = st0_idle then            --Idling, waiting for mode selection
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"000";
      FSM_G_Data_Signal   <= (others => '0');
    elsif State = st1_p1 then
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"001";
      FSM_G_Data_Signal   <= x"00001";
    elsif State = st2_p2 then
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"001";
      FSM_G_Data_Signal   <= x"00002";
    elsif State = st3_p3 then
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"001";
      FSM_G_Data_Signal   <= x"00003";
    elsif State = st4_p4 then
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"001";
      FSM_G_Data_Signal   <= x"00004";
    elsif State = st6_accepted then     -- Passcode accepted, unlock
      LATCH_Signal        <= '1';
      FSM_G_Opcode_Signal <= b"011";
      FSM_G_Data_Signal   <= (others => '0');
    elsif State = st7_accepted_code_disp then  -- Display entered passcode 5 digits
      LATCH_Signal        <= '1';
      FSM_G_Opcode_Signal <= b"010";
      FSM_G_Data_Signal   <= BUF_Passcode;
    elsif State = st8_declined then     -- Passcode declined, do not unlock
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"100";
      FSM_G_Data_Signal   <= (others => '0');
    elsif State = st9_declined_code_disp then  -- Display entered passcode 2 digits
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"010";
      FSM_G_Data_Signal   <= BUF_Passcode;
    elsif State = stX_activate then
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"001";
      FSM_G_Data_Signal   <= x"00000";
    else
      LATCH_Signal        <= '0';
      FSM_G_Opcode_Signal <= b"111";
      FSM_G_Data_Signal   <= x"00000";
    end if;
  end process;

  NEXT_STATE_DECODE : process (State, KEY_ACTIVATE_NORM, KEY_ACTIVATE_PART, KEY_CONFIRM)
  begin
    --declare default State for Next_State to avoid latches
    Next_State <= State;                --default is to stay in current State
    --insert Statements to decode Next_State
    --below is a simple example
    case (State) is
      when st0_idle =>
        if KEY_ACTIVATE_NORM = '1' then
          FSM_Secure_Mode_Enable <= '0';
          Next_State             <= stX_activate;
        elsif KEY_ACTIVATE_PART = '1' then
          FSM_Secure_Mode_Enable <= '1';
          Next_State             <= stX_activate;
        end if;
      when stX_activate =>
        BUF_Pointer <= "000";
        if KEY_CONFIRM = '1' then
          Next_State <= st1_p1;
        end if;
      when st1_p1 =>
        BUF_Pointer <= "001";
        if KEY_CONFIRM = '1' then
          Next_State <= st2_p2;
        end if;
      when st2_p2 =>
        if FSM_Secure_Mode_Enable = '1' then
          BUF_Pointer <= "000";
          Next_State  <= stC_compare;
        else
          BUF_Pointer <= "010";
          if KEY_CONFIRM = '1' then
            Next_State <= st3_p3;
          end if;
        end if;
      when st3_p3 =>
        BUF_Pointer <= "011";
        if KEY_CONFIRM = '1' then
          Next_State <= st4_p4;
        end if;
      when st4_p4 =>
        BUF_Pointer <= "100";
        if KEY_CONFIRM = '1' then
          Next_State <= st5_p5;
        end if;
      when st5_p5 =>
        BUF_Pointer <= "000";
        Next_State  <= stC_compare;
      when stC_compare =>
        if FSM_Secure_Mode_Enable = '0' then
          if BUF_Passcode = BUF_Passcode_Preset then
            Next_State <= st6_accepted;
          else
            Next_State <= st8_declined;
          end if;
        else
          if BUF_Passcode(19 downto 12) = BUF_Passcode_Part then
            Next_State <= st6_accepted;
          else
            Next_State <= st8_declined;
          end if;
        end if;
      when st6_accepted =>
        if FSM_DELAY_S = '1' then
          Next_State <= st7_accepted_code_disp;
        elsif DR_SENSOR = '1' then
          Next_State <= st0_idle;
        end if;
      when st8_declined =>
        if FSM_DELAY_S = '1' then
          Next_State <= st9_declined_code_disp;
        elsif KEY_CONFIRM = '1' then
          Next_State <= st0_idle;
        end if;
      when st7_accepted_code_disp =>
        if FSM_DELAY_S = '1' then
          Next_State <= st6_accepted;
        elsif DR_SENSOR = '1' then
          Next_State <= st0_idle;
        end if;
      when st9_declined_code_disp =>
        if FSM_DELAY_S = '1' then
          Next_State <= st8_declined;
        elsif KEY_CONFIRM = '1' then
          Next_State <= st0_idle;
        end if;
      when others =>
        Next_State <= st0_idle;
    end case;
  end process;

end Behavioural;
