----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:    01:07:59 10/07/2014
-- Design Name:
-- Module Name:    ALU - Behavioral
-- Project Name: CPU Project
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- Arithmetic Logic Unit responsible for executing basic logic functions
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_MISC.ALL;
use IEEE.std_logic_ARITH.ALL;

entity ALU is
	Port ( A,B       : in std_logic_vector (15 downto 0);
		   OP         : in std_logic_vector (3 downto 0);
		   ALU_out    : out std_logic_vector (15 downto 0);
		   carry      : out std_logic;
		   is_zero    : out std_logic);
end ALU;

architecture Behavioral of ALU is

signal ALU_out_sig: std_logic_vector (16 downto 0);

begin
   WITH OP SELECT
   -- NOTE: the '0' that precedes each operation is for carry bit

	  ALU_out_sig <=
	  not '0'&A                         WHEN "0000", -- NOT gate
	  '0'&A and '0'&B                   WHEN "0001", -- AND gate
	  '0'&A or '0'&B                    WHEN "0010", -- OR gate
	  unsigned('0'&A) + unsigned('0'&B) WHEN "0011", -- signed addition
	  unsigned('0'&A) - unsigned('0'&B) WHEN "0100", -- signed subtraction
	  '0'&A                             WHEN "0101", -- pass A through ALU
	  '0'&B                             WHEN "0110", -- pass B through ALU
	  (others => '0')                   WHEN OTHERS;

   -- Output
   ALU_out <= ALU_out_sig(15 downto 0); -- Link signal to ALU output

   -- Set is_zero output high when output equals zero
   WITH ALU_out_sig(15 downto 0) SELECT is_zero <=
		'1' WHEN X"0000",
		'0' WHEN OTHERS;

	-- Carry bit wired to output
   carry <= ALU_out_sig(16); -- Top bit of signal signifies carry

end Behavioral;