----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:    00:58:58 12/02/2014
-- Design Name:
-- Module Name:    control_unit - Behavioral
-- Project Name: CPU Project
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- The control unit pulls instructions from ROM. Based on the instruction, the control
-- unit determines what function the ALU will use on the inputs, as well as where this
-- result will be stored.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_MISC.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_SIGNED.ALL;

entity control_unit is
	Port (
			-- Inputs
			 clk        : in  std_logic;
			 instr      : in std_logic_vector(15 downto 0); -- 16-bit instruction from ROM
			 is_zero    : in std_logic; -- signal from ALU for BRZ (branch if jump)

			 -- Outputs to control datapath
			 A_sel        : out std_logic_vector(2 downto 0); -- select register for bus A
			 B_sel        : out std_logic_vector(2 downto 0); -- select register for bus B
			 Reg_sel      : out std_logic_vector(2 downto 0); -- select reg for writing output
			 const        : out std_logic_vector(2 downto 0); -- constant operand (if needed)
			 OP           : out std_logic_vector(3 downto 0); -- function selector for ALU
			 WR           : out std_logic; -- enables writing to a register
			 RAM_mode     : out std_logic; -- enables writing data to RAM
			 C_sel        : out std_logic; -- select ALU or RAM outputs for writing to register
			 constant_in  : out std_logic; -- set bus B to constant operand

			 -- Output to instruction ROM
			 addr_out     : out std_logic_vector(15 downto 0));
end control_unit;

architecture Behavioral of control_unit is

signal instr_type         : std_logic_vector(2 downto 0);
signal next_instr_address : std_logic_vector(15 downto 0) := (others => '0');
signal counter            : std_logic_vector(1 downto 0); -- counter for multi cycle instructions
signal jmp_value          : std_logic_vector(5 downto 0);

begin


-- To decode our 16-bit instruction, we first start with the instruction type,
-- as discussed in table 3. The instruction type determines following parameters:
-- (1) Whether we are inserting a constant operand (constant_in)
-- (2) Setting ALU vs RAM output to register input (C_sel)
-- (3) Whether we are writing to a register (WR)
-- (4) Whether we are writing data to the RAM (RAM_mode)

-- We also set OP to bits 9-12 of the instruction for register and immmediate
-- ALU operations, and to "0101" (A passthru) for the BRZ command, which
-- requires us to check if a specified register equals zero.

---------------------------------- Instruction Decoder ---------------------------
instr_type <= instr(15 downto 13); -- for case select below

InstructionDecoder: process(clk, instr, instr_type) begin

	case instr_type is

		when "000" => -- register-format ALU operation
			constant_in  <= '0';
			C_sel        <= '0';
			WR           <= '1';
			RAM_mode     <= '0';
			OP           <= instr(12 downto 9);

		when "001" => -- Immediate ALU operation
			constant_in  <= '1';
			C_sel        <= '0';
			WR           <= '1';
			RAM_mode     <= '0';
			OP           <= instr(12 downto 9);

		when "010" => -- memory write from registers
			constant_in  <= '0';
			C_sel        <= '0';
			WR           <= '0';
			RAM_mode     <= '1';
			OP           <= "1111";

		when "011" => -- memory read to registers
			constant_in  <= '0';
			C_sel        <= '1';
			WR           <= '1';
			RAM_mode     <= '0';
			OP           <= "1111";

		when "100" => -- conditional branch
			constant_in  <= '0';
			C_sel        <= '0';
			WR           <= '0';
			RAM_mode     <= '0';
			OP           <= "0101"; -- register to test is passed thru ALU to chk for 0

		when "101" => -- jump
			constant_in  <= '0';
			C_sel        <= '0';
			WR           <= '0';
			RAM_mode     <= '0';
			OP           <= "1111";

		when others =>
			constant_in  <= '0';
			C_sel        <= '0';
			WR           <= '0';
			RAM_mode     <= '0';
			OP           <= "1111";

	end case instr_type;
end process InstructionDecoder;

---------------------- Generating register file addresses ---------------------

-- Due to the design of our 16-bit instructions, the register file addresses
-- can be taken directly out of the instructions.
Reg_sel <= instr(8 downto 6);
A_sel   <= instr(5 downto 3);
B_sel   <= instr(2 downto 0);
const   <= instr(2 downto 0);



---------------------------------- Program Counter ----------------------------
jmp_value <= instr(8 downto 6) & instr(2 downto 0);
addr_out <= next_instr_address;

program_counter: process(clk) begin
	if rising_edge(clk) then

		case instr_type is


		-- For register and immediate ALU operations, execution of instructions
		-- only requires one clock cycle. Thus, for these instructions we simply
		-- increment the program counter so the next instruction is selected
		-- for the next clock cycle.
			when "000" =>
				next_instr_address <= unsigned(next_instr_address) + 1;
			when "001" =>
				next_instr_address <= unsigned(next_instr_address) + 1;

		-- Writing to the RAM requires two clock cycles: one to specify the
		-- RAM address, and another for the RAM to actually write to memory
		-- Likewise, reading from the RAM requires one cycle to specify the
		-- address, and another to pull the data to the specified register.
		-- To address this, we insert a counter for 2 cycles.
			when "010" =>
				case counter is
					when "00" =>
						next_instr_address <= next_instr_address;
						counter            <= unsigned(counter) + 1;
					when others =>
						next_instr_address <= unsigned(next_instr_address) + 1;
						counter            <= (others => '0');
				end case;

			when "011" =>
				case counter is
					when "00" =>
						next_instr_address <= next_instr_address;
						counter            <= unsigned(counter) + 1;
					when others =>
						next_instr_address <= unsigned(next_instr_address) + 1;
						counter            <= (others => '0');
				end case;

		-- For unconditional jumps, we add or subtract the address value based on input
		-- SXT extends a std_logic_vector to given length using value of left-most bit
		-- We use this to preserve negative numbers coded in two's complement.
			when "101" =>
				next_instr_address <= unsigned(next_instr_address) +
									  unsigned(SXT(jmp_value, next_instr_address'length));

		-- For branches (ie conditional jumps), we only change next instruction
		-- address if conditions are met. We will have our processor support
		-- the BRZ, or break if zero command, which jumps if the specified
		-- register equals zero
			when "100" =>
				case counter is
					when "00" =>
						next_instr_address <= next_instr_address;
						counter            <= unsigned(counter) + 1;
					when others =>
						if is_zero = '1' then
							next_instr_address <= unsigned(next_instr_address) +
									  unsigned(SXT(jmp_value, next_instr_address'length));
						else
							next_instr_address <= unsigned(next_instr_address) + 1;
						end if;
				end case;
			when others =>
				next_instr_address <= unsigned(next_instr_address) + 1;


		end case;
	end if;
end process program_counter;

end Behavioral;