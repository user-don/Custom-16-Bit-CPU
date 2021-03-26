----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:    05:40:51 12/05/2014
-- Design Name:
-- Module Name:    Datapath - Behavioral
-- Project Name: CPU Project
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- Full datapath as described in report
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity Datapath is
	Port ( clk         : in  STD_LOGIC;
		   WR           : in  STD_LOGIC; -- enables writing to a register
		   RAM_mode     : in  STD_LOGIC; -- enables writing data to RAM
		   C_sel        : in  STD_LOGIC; -- select ALU or RAM outputs for writing to register
		   constant_in  : in  STD_LOGIC; -- set bus B to constant operand
		   A_sel        : in std_logic_vector(2 downto 0); -- select register for bus A
		   B_sel        : in std_logic_vector(2 downto 0); -- select register for bus B
		   const        : in std_logic_vector(2 downto 0); -- constant operand (if applicable)
		   Reg_sel      : in std_logic_vector(2 downto 0); -- select reg for writing output
		   OP           : in std_logic_vector(3 downto 0); -- function selector for ALU
		   is_zero      : out  STD_LOGIC);
end Datapath;

architecture Behavioral of Datapath is

-- Components

component DATA_RAM is
    Port ( clk 			  : in  std_logic;
           RAM_mode       : in  std_logic;
           address        : in  std_logic_vector(15 downto 0);
           data_in        : in  std_logic_vector(15 downto 0);
           data_out       : out  std_logic_vector(15 downto 0));
end component;

component ALU is
	Port ( A,B       : in std_logic_vector (15 downto 0);
		   OP         : in std_logic_vector (3 downto 0);
		   ALU_out    : out std_logic_vector (15 downto 0);
		   carry      : out std_logic;
		   is_zero    : out std_logic);
end component;

component simple_register is
    Port ( clk      : in  STD_LOGIC;
           data_in  : in  STD_LOGIC_VECTOR (15 downto 0);
           load_en  : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

-- Signals
signal bus_A     : std_logic_vector(15 downto 0);
signal bus_B     : std_logic_vector(15 downto 0);
signal carry     : std_logic;
signal ALU_out   : std_logic_vector(15 downto 0);
signal RAM_out   : std_logic_vector(15 downto 0);
signal bus_C     : std_logic_vector(15 downto 0);
signal mux_B_out : std_logic_vector(15 downto 0);

type register_array is array (0 to 7) of std_logic_vector(15 downto 0);
signal reg_data_outputs : register_array;

signal reg_en   : std_logic_vector(7 downto 0);
signal reg_en_s : std_logic_vector(7 downto 0);

begin

DATA_RAM_one: DATA_RAM
port map (  clk       => clk,
			RAM_mode     => RAM_mode,
			address      => bus_A,
			data_in      => bus_B,
			data_out     => RAM_out);

ALU_one: ALU
port map (  A         => bus_A,
			B            => bus_B,
			OP           => OP,
			ALU_out      => ALU_out,
			carry        => carry,
			is_zero      => is_zero);

-- Instantiate general registers
registers : for reg in 0 to 7 generate

	gen_reg: simple_register
	port map (  clk   => clk,
				data_in  => bus_C,
				load_en  => reg_en(reg),
				data_out => reg_data_outputs(reg));

end generate registers;

-- Routes WR signal to specified register
with WR select reg_en <=
	reg_en_s when '1',
	"00000000" when others;

with Reg_sel select reg_en_s <=
	"00000001" when "000",
	"00000010" when "001",
	"00000100" when "010",
	"00001000" when "011",
	"00010000" when "100",
	"00100000" when "101",
	"01000000" when "110",
	"10000000" when "111",
	"00000000" when others;


-- Mux A
with A_sel select bus_A <=
	reg_data_outputs(0) when "000",
	reg_data_outputs(1) when "001",
	reg_data_outputs(2) when "010",
	reg_data_outputs(3) when "011",
	reg_data_outputs(4) when "100",
	reg_data_outputs(5) when "101",
	reg_data_outputs(6) when "110",
	reg_data_outputs(7) when "111",
	(others => '0')     when others;

-- Mux B
with B_sel select mux_B_out <=
	reg_data_outputs(0) when "000",
	reg_data_outputs(1) when "001",
	reg_data_outputs(2) when "010",
	reg_data_outputs(3) when "011",
	reg_data_outputs(4) when "100",
	reg_data_outputs(5) when "101",
	reg_data_outputs(6) when "110",
	reg_data_outputs(7) when "111",
	(others => '0')     when others;

-- Constant input mux
with constant_in select bus_B <=
	std_logic_vector(resize(signed(const),bus_B'length)) when '1',
	mux_B_out when '0',
	(others => '0') when others;

-- output mux
with C_sel select bus_C <=
	ALU_out when '0',
	RAM_out when '1',
	(others => '0') when others;


end Behavioral;