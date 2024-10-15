
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ALUMips is
 Port ( 
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
end ALUMips;

architecture Behavioral of ALUMips is
signal ALUIn2 : std_logic_vector(15 downto 0);
signal ao : std_logic_vector(15 downto 0);
signal branch : std_logic_vector(15 downto 0);
begin

with ALUSrc select
ALUIn2 <= rd2 when '0',
          Ext_Imm when '1',
          (others => 'X') when others;
          
          process(ALUOp, rd1, ALUIn2)
          begin
          case ALUOp is
          when "000" => ALUOut <= rd1 + ALUIn2;
          when "001" => ALUOut <= rd1 - ALUIn2;
          when "010" => ALUOut <= rd1 and ALUIn2;
          when "011" => ALUOut <= rd1 or ALUIn2;
          when "100" => ALUOut <= rd1(14 downto 0)& '0'; --sll
          when "101" => ALUOut <= '0' & rd1(15 downto 1); --srl
          when "110" => ALUOut <= rd1 xor ALUIn2; --xor
          when "111" => ALUOut <= rd1 nor ALUIn2; --nor
          end case;
          end process;
          
          
        process(ao,rd1,ALUIn2)
          begin
          ao<=rd1 - ALUIn2;
          if ao = x"0000" then
            Zero<= '1';
            else Zero<='0';
          end if;
        end process;
        
        process(nextPc,Ext_Imm)
          begin 
                BranchAddress<= nextPc+Ext_Imm;
                 
         end process;


end Behavioral;
