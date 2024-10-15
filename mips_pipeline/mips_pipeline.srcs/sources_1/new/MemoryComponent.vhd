
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MemoryComponent is
Port ( 
clk : in std_logic;
	MemWrite : in std_logic;
	en : in std_logic;
	ALUOut : in std_logic_vector(15 downto 0);
	rd2 : in std_logic_vector(15 downto 0);
	MemData : out std_logic_vector(15 downto 0)
);
end MemoryComponent;

architecture Behavioral of MemoryComponent is
type ram_type is array (0 to 255) of std_logic_vector (15 downto 0);
	signal RAM: ram_type:=(
	x"0000",
x"0002",
x"0006",
x"0003",
x"000A",
x"0008",
x"0003",
x"0000"

,others =>x"0000");

begin
process (clk,ALUOut)
	begin
	if rising_edge(clk) then
		if en = '1' then
			if MemWrite = '1' then
			RAM(conv_integer(ALUOut)) <= rd2;
		end if;
	end if;
	end if;
		MemData <= RAM( conv_integer(ALUOut));

end process;


end Behavioral;
