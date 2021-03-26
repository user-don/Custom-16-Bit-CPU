----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:    00:27:24 12/02/2014
-- Design Name:
-- Module Name:    DATA_RAM - Behavioral
-- Project Name: CPU Project
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- Instantiation of RAM to store data output from ALU. Uses 16-bit addresses
-- and 16-bit data vectors
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DATA_RAM is
    Port ( clk 			  : in  std_logic;
           RAM_mode       : in  std_logic;
           address        : in  std_logic_vector(15 downto 0);
           data_in        : in  std_logic_vector(15 downto 0);
           data_out       : out  std_logic_vector(15 downto 0));
end DATA_RAM;

architecture Behavioral of DATA_RAM is

-- Use behaviorial description of RAM blocks; let FPGA synthesis decide how to implement
-- Instantiate RAM as array of 16-bit addresses referring to 16-bit data vectors.
	type ram_type is array (0 to (2**5) - 1) of std_logic_vector(15 downto 0);

	signal ram : ram_type := (others =>(others => '0'));

begin

RAM_Process:
process(clk, RAM_mode) begin
	if rising_edge(clk) then

		if RAM_mode = '1' then -- write to RAM
			ram(to_integer(unsigned(address))) <= data_in;
		else -- read address
			data_out <= ram(to_integer(unsigned(address)));
		end if;

	end if;
end process RAM_Process;


end Behavioral;