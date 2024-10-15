

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity MPG is
 Port ( btn: in std_logic;
    clk: in std_logic;
    enable: out std_logic);
end MPG;

architecture Behavioral of MPG is

signal cnt : std_logic_vector (15 downto 0);
signal ok: std_logic;
signal Q1 : std_logic; 
signal Q2 : std_logic; 
signal Q3 : std_logic; 

begin

process (clk,cnt)
begin
if rising_edge(clk) then
cnt <= cnt +1;
end if;
end process;

ok<='1' when cnt = x"ffff"
else '0';

process(clk, ok,btn)
begin
if (rising_edge(clk))then 
if ok = '1' then
 Q1 <= btn;
 end if;
 end if;
end process;

process(clk, Q1)
begin
 if rising_edge(clk) then
 Q2 <= Q1;
 end if;
end process;

process(clk, Q2)
begin
 if rising_edge(clk) then
 Q3 <= Q2;
 end if;
end process;

enable<= ((not Q3) and Q2);

end Behavioral;
