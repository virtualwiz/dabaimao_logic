library ieee;
use ieee.std_logic_1164.all;

entity DEBOUNCER is
  port(
    DEB_CLK   : in  std_logic;
    DEB_RESET : in  std_logic;
    DEB_IN    : in  std_logic;
    DEB_OUT   : out std_logic
    );
end DEBOUNCER;

architecture Dataflow of DEBOUNCER is
  signal Q1, Q2, Q3 : std_logic;
begin
  process(DEB_CLK)
  begin
    if (falling_edge(DEB_CLK)) then
      if (DEB_RESET = '1') then
        Q1 <= '0';
        Q2 <= '0';
        Q3 <= '0';
      else
        Q1 <= DEB_IN;
        Q2 <= Q1;
        Q3 <= Q2;
      end if;
    end if;
  end process;

  DEB_OUT <= Q1 and Q2 and (not Q3);

end Dataflow;
