

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionDecode is
port (
clk : in std_logic;
enable : in std_logic;
Instruction : in std_logic_vector (12 downto 0);
WriteAdress : in std_logic_vector (2 downto 0);
WriteData : in std_logic_vector (15 downto 0);
RegWrite : in std_logic;
ExtOp : in std_logic;
rd1 : out std_logic_vector (15 downto 0);
rd2 : out std_logic_vector (15 downto 0);
Ext_Imm : out std_logic_vector (15 downto 0);
func : out std_logic_vector (2 downto 0);
sa : out std_logic


);
end InstructionDecode;

architecture Behavioral of InstructionDecode is

type reg_array is array (0 to 15) of std_logic_vector(15 downto 0);
signal reg_file : reg_array:=(
x"0000",
x"0000",
x"0000",
x"0000",
x"0000",
x"0000",
x"0000",
x"0000"

,others =>x"0000");


begin


process(clk, RegWrite,enable)
begin
if falling_edge(clk) then
if enable ='1' and RegWrite ='1' then
reg_file(conv_integer(WriteAdress)) <= WriteData;
end if;
end if;
end process;



rd1 <= reg_file(conv_integer(Instruction(12 downto 10)));
rd2 <= reg_file(conv_integer(Instruction(9 Downto 7)));

with ExtOp select
    Ext_Imm <= "000000000" & Instruction (6 downto 0) when '1', --rd
                  "000000000" &  Instruction (6 downto 0) when '0', --rt
                    (others => 'X') when others;

func<= Instruction(2 downto 0);
sa <= Instruction(3);

end Behavioral;
