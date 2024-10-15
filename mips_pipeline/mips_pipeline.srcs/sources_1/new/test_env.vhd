
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity test_env is
    Port (
          clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
           
end test_env;

architecture Behavioral of test_env is

component MPG
port (
   btn: in std_logic;
    clk: in std_logic;
    enable: out std_logic
    );
    end component;
    
    component SSD
    port (
               clk : in STD_LOGIC;
               nr : in STD_LOGIC_VECTOR (15 downto 0);
               cat : out STD_LOGIC_VECTOR (6 downto 0);
               an : out STD_LOGIC_VECTOR (3 downto 0));
        end component;
        

component InstructionFetch
port (
  enable: in std_logic;
  reset :in std_logic;
  jmpAddress : in std_logic_vector(15 downto 0);
  branchAddress: in std_logic_vector(15 downto 0);
  clk : in std_logic;
  Jump : in std_logic;
  PCSrc: in std_logic;
  nextPc : out  std_logic_vector(15 downto 0);
  instruction : out std_logic_vector(15 downto 0);
  egata : out std_logic


);
end component;

component InstructionDecode
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
end component;

component MainControl
port (
 opcode : in std_logic_vector (2 downto 0);
func : in std_logic_vector (2 downto 0);
ALUOp : out std_logic_vector(2 downto 0);
RegDst : out std_logic;
ExtOp : out std_logic;
ALUSrc : out std_logic;
Branch : out std_logic;
Jump : out std_logic;
MemWrite : out std_logic;
MemtoReg : out std_logic;
RegWrite : out std_logic
);
end component;

component ALUMips
port (
nextPc : in  std_logic_vector(15 downto 0);
      rd1 : in  std_logic_vector(15 downto 0);
      rd2 : in  std_logic_vector(15 downto 0);
      Ext_Imm : in  std_logic_vector(15 downto 0);
      ALUOp : in std_logic_vector(2 downto 0);
      ALUSrc : in std_logic;
      BranchAddress : out std_logic_vector(15 downto 0);
      ALUOut : out std_logic_vector(15 downto 0);
      Zero : out std_logic
);
end component;

component MemoryComponent
port (
    clk : in std_logic;
	MemWrite : in std_logic;
	en : in std_logic;
	ALUOut : in std_logic_vector(15 downto 0);
	rd2 : in std_logic_vector(15 downto 0);
	MemData : out std_logic_vector(15 downto 0)
);
end component;

component SSDFinal
port (
           clk : in STD_LOGIC;
           nr : in STD_LOGIC_VECTOR (15 downto 0);
           done : in std_logic;
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0)
);
end component;


--InstructionFetch
signal en,rst : std_logic;
signal digits : std_logic_vector(15 downto 0);
signal nextInstr : std_logic_vector(15 downto 0);
signal Instruction : std_logic_vector(15 downto 0);
signal nextPc : std_logic_vector(15 downto 0);
signal done : std_logic;

--InstructionDecode
signal WriteData, rd1, rd2, Ext_Imm : std_logic_vector(15 downto 0);
signal func : std_logic_vector (2 downto 0);
signal sa : std_logic;

--controls
signal RegDst, ALUSrc,ExtOp,Branch,Jump,MemWrite,MemtoReg,RegWrite : std_logic;
signal ALUOp : std_logic_vector(2 downto 0);

--ALUMips
signal BranchAddress, JumpAddress : std_logic_vector(15 downto 0);
signal ALUOut : std_logic_vector(15 downto 0);
signal Zero : std_logic;
signal PCSrc : std_logic;

-- MemoryComponent
signal MemData : std_logic_vector(15 downto 0);

--MipsPipeline
signal InstructionIn : std_logic_vector(15 downto 0);
signal InstructionOut : std_logic_vector(15 downto 0);
signal nextInstrIn : std_logic_vector(15 downto 0);
signal nextInstrOut : std_logic_vector(15 downto 0);
signal ifidIn : std_logic_vector(31 downto 0);
signal ifidOut : std_logic_vector(31 downto 0);
signal enReg : std_logic;

signal idexIn : std_logic_vector(78 downto 0);
signal idexOut : std_logic_vector(78 downto 0);

signal MemtoRegidexout : std_logic;
signal RegWriteidexout : std_logic;
signal MemWriteidexout : std_logic;
signal Branchidexout : std_logic;
signal ALUOpidexout : std_logic_vector(2 downto 0);
signal ALUSrcidexout : std_logic;
signal RegDstidexout : std_logic;
signal nextInstrOutidexout : std_logic_vector(15 downto 0);
signal rd1idexout : std_logic_vector(15 downto 0);
signal rd2idexout : std_logic_vector(15 downto 0);
signal Ext_Immidexout : std_logic_vector(15 downto 0);
signal rtidexout : std_logic_vector(2 downto 0);
signal rdidexout : std_logic_vector(2 downto 0);
signal muxidexout : std_logic_vector(2 downto 0);

signal exmemIn : std_logic_vector(55 downto 0);
signal exmemOut : std_logic_vector(55 downto 0);

signal MemtoRegexmemout : std_logic;
signal RegWriteexmemout : std_logic;
signal MemWriteexmemout : std_logic;
signal Branchexmemout : std_logic;
signal BranchAddressexmemout : std_logic_vector(15 downto 0);
signal ALUOutexmemout : std_logic_vector(15 downto 0);
signal Zeroexmemout : std_logic;
signal rd2exmemout : std_logic_vector(15 downto 0);
signal muxexmemout : std_logic_vector(2 downto 0);


signal memIn : std_logic_vector(36 downto 0);
signal memOut : std_logic_vector(36 downto 0);

signal MemtoRegmemout : std_logic;
signal RegWritememout : std_logic;
signal MemDatamemout : std_logic_vector(15 downto 0);
signal ALUOutmemout : std_logic_vector(15 downto 0);
signal muxmemout : std_logic_vector(2 downto 0);




begin

--ifid start

ifidIn(31 downto 16) <= InstructionIn;
ifidIn(15 downto 0) <= nextInstrIn;

process(clk,en)
begin
 if rising_edge(clk) and en= '1' then
 ifidOut <= ifidIn;
 end if;
end process;

InstructionOut<= ifidOut(31 downto 16);
nextInstrOut <= ifidOut(15 downto 0);

--idex start

-- pt reg id/ex: avem: memtoreg,regwrite,memwrite,branch,aluop(3 biti) alusrc, regdst -9 biti
--                   : nextInstrOut (16 biti), rd1,rd2(ambii 32biti), extimm pe 16 biti,- 64 biti
--                   : rd (instructionout 6 downto 4   )rt(instructionout 9 downto 7   ): 6 biti amandoua --- total 79 biti

idexIn(78) <= MemtoReg;
idexIn(77) <= RegWrite;
idexIn(76) <= MemWrite;
idexIn(75) <= Branch;
idexIn(74 downto 72) <= ALUOp;
idexIn(71) <= ALUSrc;
idexIn(70) <= RegDst;
idexIn(69 downto 54) <= nextInstrOut;
idexIn(53 downto 38) <= rd1;
idexIn(37 downto 22) <= rd2;
idexIn(21 downto 6) <= Ext_Imm;
idexIn(5 downto 3) <= InstructionOut(6 downto 4);--rd
idexIn(2 downto 0) <= InstructionOut(9 downto 7);--rt

process(clk,en)
begin
 if rising_edge(clk) and en= '1' then
 idexOut <= idexIn;
 end if;
end process;

MemtoRegidexout<=idexOut(78);
RegWriteidexout<=idexOut(77);
MemWriteidexout<=idexOut(76);
Branchidexout<=idexOut(75);
ALUOpidexout<=idexOut(74 downto 72);
ALUSrcidexout<=idexOut(71);
RegDstidexout<=idexOut(70);
nextInstrOutidexout<=idexOut(69 downto 54);
rd1idexout<=idexOut(53 downto 38);
rd2idexout<=idexOut(37 downto 22);
Ext_Immidexout<=idexOut(21 downto 6);
rdidexout <=idexOut(5 downto 3);
rtidexout <=idexOut(2 downto 0);

with RegDstidexout select
muxidexout <= rdidexout when '1',
           rtidexout when '0',
           (others =>'X')when others;
           
           
           --exmem start
           --MemtoRegidexout, RegWriteidexout, MemWriteidexout, Branchidexout --------------4 biti
           --BranchAddress 16, ALUOut 16, zero 1, rd2idexout 16, muxidexout 3--------52 biti
            --56 biti total
 
exmemIn(55)<=MemtoRegidexout;  
exmemIn(54)<=RegWriteidexout; 
exmemIn(53)<=MemWriteidexout;                                                                                 
exmemIn(52)<=Branchidexout;       
exmemIn(51 downto 36)<=BranchAddress;
exmemIn(35 downto 20)<=ALUOut;
exmemIn(19)<=Zero;     
exmemIn(18 downto 3)<=rd2idexout;
exmemIn(2 downto 0)<=muxidexout;
  

process(clk,en)
begin
 if rising_edge(clk) and en= '1' then
 exmemOut <= exmemIn;
 end if;
end process;

MemtoRegexmemout<=exmemOut(55);
RegWriteexmemout<=exmemOut(54);
MemWriteexmemout<=exmemOut(53);   -- exmemout
Branchexmemout<=exmemOut(52);
BranchAddressexmemout<=exmemOut(51 downto 36);
ALUOutexmemout<=exmemOut(35 downto 20);
Zeroexmemout<=exmemOut(19);
rd2exmemout<=exmemOut(18 downto 3);
muxexmemout<=exmemOut(2 downto 0);

-- memwb start

--MemtoRegexmemout, RegWriteexmemout 2 biti
-- MemData 16,ALUOutexmemout 16, muxexmemout 3 ----total 37
memIn(36)<=MemtoRegexmemout;  
memIn(35)<=RegWriteexmemout; 
memIn(34 downto 19)<=MemData;
memIn(18 downto 3)<=ALUOutexmemout;
memIn(2 downto 0)<=muxexmemout;

process(clk,en)
begin
 if rising_edge(clk) and en= '1' then
 memOut <= memIn;
 end if;
end process;


MemtoRegmemout<=memOut(36);
RegWritememout<=memOut(35);
MemDatamemout<=memOut(34 downto 19);
ALUOutmemout<=memOut(18 downto 3);
muxmemout<=memOut(2 downto 0);




monopulse1 : MPG port map(btn(0),clk,en);
monopulse2 : MPG port map(btn(1),clk,rst);
--monopulse3 : MPG port map(btn(2),clk,enReg);




portInstructionFetch : InstructionFetch port map(en,rst,JumpAddress,BranchAddressexmemout,clk,Jump,PCSrc,nextInstrIn,InstructionIn,done);
portInstructionDecode : InstructionDecode port map(clk, en, InstructionOut(12 downto 0),muxmemout, WriteData , RegWritememout, ExtOp, rd1, rd2, Ext_Imm, func,sa);
portMainControl : MainControl port map (InstructionOut(15 downto 13),InstructionOut(2 downto 0),AluOp,RegDst,ExtOp,ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite);
portALUMips : ALUMips port map (nextInstrOutidexout,rd1idexout,rd2idexout,Ext_Immidexout,ALUOpidexout,ALUSrcidexout,BranchAddress,ALUOut,Zero);
portMemoryComponent : MemoryComponent port map (clk,MemWriteexmemout,en,ALUOutexmemout,rd2exmemout,MemData);


PCSrc<=Zeroexmemout and Branchexmemout;
JumpAddress <= nextInstrOut(15 downto 13)&InstructionOut(12 downto 0);

with MemtoRegmemout select
WriteData <= MemDatamemout when '1',
           ALUOutmemout when '0',
           (others =>'X')when others;


with sw(2 downto 0) select
digits<= InstructionIn when "000",
        nextInstr when "001",
        rd1idexout when "010",
        rd2idexout when "011",
        ALUOut when "100",
        Ext_Immidexout when "101",
        x"000"&'0'& muxmemout when "110",
        --BranchAddress when "111",
       WriteData when "111",
        (others => 'X') when others;
            display : SSDFinal port map(clk,digits,done,cat,an);




led(13 downto 0) <=MemtoRegmemout & PCSrc & Zero & ALUOpidexout & RegDst & ExtOp & ALUSrc& Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;
