----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:   08:25:40 12/05/2014
-- Design Name:
-- Module Name:   hltb.vhd
-- Project Name:  cpu_project_v3
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
-- This is a VHDL Test Bench Created for module: high_level.
-- The testbench wires CODE_ROM to the processor and allows us to validate
-- the processor's execution via simulation with ISim
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hltb IS
END hltb;

ARCHITECTURE behavior OF hltb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT high_level
    PORT(
         clk      : IN  std_logic;
         instr    : IN  std_logic_vector(15 downto 0);
         addr_out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    COMPONENT CODE_ROM
    Port ( memory_address     : in   STD_LOGIC_VECTOR (15 downto 0);
               data_out       : out  STD_LOGIC_VECTOR (15 downto 0));
  END COMPONENT;


   --Inputs
   signal clk          : std_logic := '0';
   signal instr        : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal addr_out     : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

  -- instantiate the test code
  testcode: CODE_ROM
    port map (
           memory_address => addr_out,
           data_out       => instr);

	-- Instantiate the Unit Under Test (UUT)
   uut: high_level PORT MAP (
          clk      => clk,
          instr    => instr,
          addr_out => addr_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_period*10;

      -- insert stimulus here

      wait;
   end process;

END;
