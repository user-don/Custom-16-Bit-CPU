----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:    07:24:48 12/05/2014
-- Design Name:
-- Module Name:    high_level - Behavioral
-- Project Name: CPU Project
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- High-level module for processor that wires together the control_unit and
-- datapath. The RAM is instantiated in the datapath. The ROM is *not* instantiated
-- within the scope of this code. Rather, it is wired to the high_level entity
-- in the high_level testbench file used for simulation.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;


entity high_level is
    Port ( clk      : in  STD_LOGIC;
           instr    : in  STD_LOGIC_VECTOR (15 downto 0);
           addr_out : out  STD_LOGIC_VECTOR (15 downto 0));
end high_level;

architecture Behavioral of high_level is

----------------------------------------------------------------------------------
----------------------------  Define Components  ---------------------------------
----------------------------------------------------------------------------------

component control_unit is
	Port (
			-- Inputs
			 clk          : in std_logic;
			 instr        : in std_logic_vector(15 downto 0);
			 is_zero      : in std_logic; -- signal from ALU for BRZ (branch if jump)
			 -- Outputs
			 A_sel        : out std_logic_vector(2 downto 0); -- select register for bus A
			 B_sel        : out std_logic_vector(2 downto 0); -- select register for bus B
			 const        : out std_logic_vector(2 downto 0); -- constant operand (if needed)
			 Reg_sel      : out std_logic_vector(2 downto 0); -- select reg for writing output
			 OP           : out std_logic_vector(3 downto 0); -- function selector for ALU
			 WR           : out std_logic; -- enables writing to a register
			 RAM_mode     : out std_logic; -- enables writing data to RAM
			 C_sel        : out std_logic; -- select ALU or RAM outputs for writing to register
			 constant_in  : out std_logic; -- set bus B to constant operand
			 addr_out     : out std_logic_vector(15 downto 0));
end component;

component Datapath is
	Port ( clk         : in  STD_LOGIC;
		   WR           : in  STD_LOGIC; -- enables writing to a register
		   RAM_mode     : in  STD_LOGIC; -- enables writing data to RAM
		   C_sel        : in  STD_LOGIC; -- select ALU or RAM outputs for writing to register
		   constant_in  : in  STD_LOGIC; -- set bus B to constant operand
		   A_sel        : in std_logic_vector(2 downto 0); -- select register for bus A
		   B_sel        : in std_logic_vector(2 downto 0); -- select register for bus B
		   const        : in std_logic_vector(2 downto 0);
		   Reg_sel      : in std_logic_vector(2 downto 0); -- select reg for writing output
		   OP           : in std_logic_vector(3 downto 0); -- function selector for ALU
		   is_zero      : out STD_LOGIC);
end component;


-- Signals: Used to wire together the control_unit and datapath
signal A_sel_s        : std_logic_vector(2 downto 0);
signal B_sel_s        : std_logic_vector(2 downto 0);
signal const_s        : std_logic_vector(2 downto 0);
signal Reg_sel_s      : std_logic_vector(2 downto 0);
signal OP_s           : std_logic_vector(3 downto 0);
signal WR_s           : std_logic;
signal RAM_mode_s     : std_logic;
signal C_sel_s        : std_logic;
signal constant_in_s  : std_logic;
signal is_zero_s      : std_logic;



begin

-- Wire the inputs and outputs of each component either to signals or entity ports
ctrl_unit: control_unit
	port map (
			clk          => clk,
			instr        => instr,
			is_zero      => is_zero_s,
			A_sel        => A_sel_s,
			B_sel        => B_sel_s,
			const        => const_s,
			Reg_sel      => Reg_sel_s,
			OP           => OP_s,
			WR           => WR_s,
			RAM_mode     => RAM_mode_s,
			C_sel        => C_sel_s,
			constant_in  => constant_in_s,
			addr_out     => addr_out);

dpath: Datapath
	port map (
			clk          => clk,
			is_zero      => is_zero_s,
			A_sel        => A_sel_s,
			B_sel        => B_sel_s,
			const        => const_s,
			Reg_sel      => Reg_sel_s,
			OP           => OP_s,
			WR           => WR_s,
			RAM_mode     => RAM_mode_s,
			C_sel        => C_sel_s,
			constant_in  => constant_in_s);


end Behavioral;