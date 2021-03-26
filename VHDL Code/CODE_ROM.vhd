----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:    00:00:59 12/05/2014
-- Design Name:
-- Module Name:    CODE_ROM - Behavioral
-- Project Name: CPU Project
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- CODE_ROM is a simulated ROM that holds instructions for the CPU.
-- Each address is associated with an instruction  in machine language
-- to be executed by the CPU. CODE_ROM is wired to the processor
-- within the high-level testbench file for simulated testing.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CODE_ROM is
    Port ( memory_address : in  STD_LOGIC_VECTOR (15 downto 0);
           data_out       : out  STD_LOGIC_VECTOR (15 downto 0));
end CODE_ROM;

architecture Behavioral of CODE_ROM is

signal data_out_sig : std_logic_vector(15 downto 0);

begin

with memory_address select data_out_sig <=


	-- LDI R1, #3  ; R1 <- '3'
	-- 001  0110  001  xxx  011
	"0010110001000011" when X"0000",

	-- LDI R0, #1   ; R0 <- '1'
	-- 001  0011  000  xxx  001
	"0010011000010001" when X"0001",

	-- ADD R4, R1, R0    ; R4 <- R1 + R0
	-- 000  0011  100  000  001
	"0000011100000001" when X"0002",

	-- STORE (R2), R4    ; M[R2] <- R4
	-- 010  xxxx  xxx  010  100
	"0100000000010100" when X"0003",

	-- LOAD R3, (R2)     ; R3 <- M[R2]
	-- 011  xxxx  R3  R2  xxx
	"0110000011010000" when X"0004",

	-- BRZ R5, #2  ;
	-- 100  xxxx  000  101  010
	"1000000000101010" when X"0005",

	-- JMP #-5
	-- 101  xxxx  111  xxx  011
	"1010000111000011" when X"0007",


	(others => '0') when others;

data_out <= data_out_sig;

end Behavioral;