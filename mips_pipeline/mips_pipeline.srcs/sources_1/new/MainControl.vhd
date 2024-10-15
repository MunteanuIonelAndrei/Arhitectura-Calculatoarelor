
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MainControl is
 Port (
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
end MainControl;

architecture Behavioral of MainControl is

begin

 process(opcode, func)
    begin
        case opcode is
            when "000" => 
                case func is
                    when "000" => ALUOp <= "000"; -- add
                    when "001" => ALUOp <= "001"; -- sub
                    when "010" => ALUOp <= "010"; -- and
                    when "011" => ALUOp <= "011"; -- or
                    when "100" => ALUOp <= "100"; -- sll
                    when "101" => ALUOp <= "101"; -- srl
                    when "110" => ALUOp <= "110"; -- xor
                    when "111" => ALUOp <= "111"; -- nor
                end case;
            when "001" => ALUOp <= "000"; -- addi
            when "010" => ALUOp <= "000"; -- lw
            when "011" => ALUOp <= "000"; -- sw
            when "100" => ALUOp <= "001"; -- beq
            when "101" => ALUOp <= "000"; -- noop
            when "110" => ALUOp <= "001"; -- subi
            when "111" => ALUOp <= "000"; -- jmp
        end case;
    end process;
    
process(opcode)
begin
--RegDst
if opcode = "000" then
RegDst <= '1';
else
RegDst <= '0';
end if;
            
--ExtOp

if opcode = "000" or opcode = "111" then
ExtOp <= '0';
else
ExtOp <= '1';
end if;

--ALUSrc
if opcode = "000" or opcode = "100" or opcode = "111" then
ALUSrc <= '0';
else
ALUSrc <= '1';           
end if;

--Branch
if opcode = "100" then
Branch <= '1';
else
Branch <= '0';
end if; 

--Jump
if opcode = "111" then
Jump <= '1';
else
Jump <= '0';
end if; 

--MemWrite
if opcode = "011" then
   MemWrite <= '1';
else
   MemWrite <= '0';
end if;

--MemToReg
if opcode = "010" then
MemtoReg <= '1';
else
MemtoReg <= '0';
end if;


--RegWrite
if opcode = "011" or opcode = "100" or opcode = "111" then
RegWrite <= '0';
else
RegWrite <= '1';
end if;

--   ALUOp <= opcode;

end process;


end Behavioral;
