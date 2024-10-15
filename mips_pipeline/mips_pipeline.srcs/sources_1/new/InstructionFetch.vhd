
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity InstructionFetch is
  Port ( 
     enable: in std_logic;
     reset : in std_logic;
     jmpAddress : in std_logic_vector(15 downto 0);
     branchAddress: in std_logic_vector(15 downto 0);
     clk : in std_logic;
     Jump : in std_logic;
     PCSrc: in std_logic;
     nextPc : out  std_logic_vector(15 downto 0);
     instruction : out std_logic_vector(15 downto 0);
     egata : out std_logic
     
   
  );
end InstructionFetch;

architecture Behavioral of InstructionFetch is

type array_memorie is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
signal ROM : array_memorie := (

--b"000_001_010_101_0_000",--add $5,$1,$2 x"0550"
--b"000_110_010_100_0_001",--sub $4,$6,$2 x"1941"
--b"000_111_001_011_0_010",--and $3,$7,$1 x"1CB2"
--b"000_001_010_011_0_011",--or $3,$1,$2 x"0533"
--b"000_011_000_111_1_100",--sll $7,$3,1 x"0C7C"
--b"000_010_000_110_1_101",--srl $6,$2,1 x"086D"
--b"000_011_100_001_0_110",--xor $1,$3,$4 x"0E16"
--b"000_110_111_001_0_111",-- nor $1,$6,$7 x"1B97"
--b"001_001_101_0000001",-- addi $5,$1,1 x"2681"
--b"010_010_110_0000010",-- lw $6,$2,2 x"4B02"
--b"011_011_111_0000001",-- sw $7,3,1 x"6F81"
--b"100_101_100_0000010",-- beq $4,$5,2 x"9602"
--b"101_010_001_0000011",-- ori $1,$2,3 x"A883"
--b"110_100_011_0000001",-- subi $3,$4,1 x"D181"
--b"111_0000000000111",-- jmp 7 x"E007"

--(a+b)/2^c + (a1-b1)*2^c1, a,b,c,a1,b1,c1 fiind luate din ram de la adresele 1,2,3,4,5,6 in aceasta ordine;
-- dupa jump 1 instructiune no op ca sa mearga
--dupa beq trebuie sa fie 3 no op ca sa mearga
b"010_000_111_0000001",      --0  lw $7,$0,1 x"4381" 
b"010_000_110_0000010",      --1  lw $6,$0,2 x"4302"
b"000_000_000_000_0_000",    --2  noop
b"000_000_000_000_0_000",    --3  noop
b"000_111_110_111_0_000",    --2  add $7,$7,$6 x"1F70"
b"010_000_010_0000011",      --3  lw $2,$0,3 x"4103"
b"000_000_000_000_0_000",    --4  noop
b"000_111_000_111_1_101",    --5  srl $7,$7,1 x"1C7D"  ---aici se face jump
b"110_010_010_0000001",      --6  subi $2,$2,1 x"C901"
b"000_000_000_000_0_000",    --7  noop
b"000_000_000_000_0_000",    --8  noop
b"100_000_010_0000101",      --9  beq $2,$0,5 x"8105"
b"000_000_000_000_0_000",    --10  noop
b"000_000_000_000_0_000",    --11  noop
b"000_000_000_000_0_000",    --12  noop
b"111_0000000000111",        --13  jmp 7 x"E004"
b"000_000_000_000_0_000",    --14  noop

b"010_000_110_0000100",      --15  lw $6,$0,4 x"4304"
b"010_000_101_0000101",      --16  lw $5,$0,5 x"4285"
b"000_000_000_000_0_000",    --7  noop
b"000_000_000_000_0_000",    --8  noop
b"000_110_101_110_0_001",    --17 sub $6,$6,$5 x"1AE1"
b"010_000_010_0000110",      --18 lw $2,$0,6 x"4106"
b"000_000_000_000_0_000",    --19  noop
b"000_110_000_110_1_100",    --20 sll $6,$6,1 x"186C"  ---aici se face jump
b"110_010_010_0000001",      --21 subi $2,$2,1 x"C901"
b"000_000_000_000_0_000",    --22  noop
b"000_000_000_000_0_000",    --23  noop
b"100_000_010_0000101",      --24 beq $2,$0,5 x"8105"
b"000_000_000_000_0_000",    --25  noop
b"000_000_000_000_0_000",    --26  noop
b"000_000_000_000_0_000",    --27  noop
b"111_0000000011000",        --28 jmp 24 x"E00C"
b"000_000_000_000_0_000",    --29  noop

b"000_111_110_111_0_000",    --30 add $7,$7,$6 x"1F70"
b"011_000_111_0000111",      --31 sw $7,$0,7 x"6387"
b"010_000_010_0000111",      --32 lw $2,$0,7 x"4107"
b"000_000_000_000_0_000",    --33  noop
b"000_000_000_000_0_000",    --34  noop
b"000_000_000_000_0_000",    --35 noop
x"1212",                     --HAHA
x"3456",                     --donE
x"3456",
x"3456",
x"3456",
x"3456",
x"3456",

others => "0000000000000000"
);

    
signal pcOut: std_logic_vector(15 downto 0);
signal pcOutAdd1: std_logic_vector(15 downto 0);
signal OutFirstMux: std_logic_vector(15 downto 0);
signal OutSecondMux: std_logic_vector(15 downto 0):= (x"0000");
signal done : std_logic_vector(15 downto 0);



begin


process(clk,reset,enable)
begin
if reset ='1' then
pcOut<=x"0000";
elsif enable = '1' and rising_edge(clk)
then 
pcOut <= OutSecondMux;
end if;
end process;



process(pcOut)
begin
instruction <= ROM(conv_integer(pcOut));
done <=  ROM(conv_integer(pcOut));
end process;
pcOutAdd1<= pcOut +1;

OutFirstMux <= pcOutAdd1 when PCSrc = '0' else branchAddress;
OutSecondMux <= OutFirstMux when Jump = '0' else jmpAddress;

process (done)
begin 
if done = x"1212" or done =x"3456" then 
egata <= '1';
elsif done /= x"1212" or done /=x"3456" then 
egata <= '0';

end if;
end process;

nextPc<=pcOutAdd1;







end Behavioral;
