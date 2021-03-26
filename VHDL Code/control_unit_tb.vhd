----------------------------------------------------------------------------------
-- Company: Physics 550 Senior Thesis
-- Engineer: Donald A Stayner
--
-- Create Date:   23:57:02 12/04/2014
-- Design Name:
-- Module Name: Control Unit - Testbench
-- C:/Users/pguest/Dropbox/Documents/Senior College/CPU Project/
-- cpu_project_v3/VHDL/control_unit_tb.vhd
-- Project Name:  cpu_project_v3
-- Target Devices: Xilinx Spartan6 XC6LS16-CS324
-- Description:
--
-- VHDL Test Bench Created by ISE for module: control_unit
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY control_unit_tb IS
END control_unit_tb;

ARCHITECTURE behavior OF control_unit_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT control_unit
    PORT(
         clk          : IN  std_logic;
         instr        : IN  std_logic_vector(15 downto 0);
         is_zero      : IN  std_logic;
         A_sel        : OUT  std_logic_vector(2 downto 0);
         B_sel        : OUT  std_logic_vector(2 downto 0);
         const        : OUT  std_logic_vector(2 downto 0);
         Reg_sel      : OUT  std_logic_vector(2 downto 0);
         OP           : OUT  std_logic_vector(3 downto 0);
         WR           : OUT  std_logic;
         RAM_mode     : OUT  std_logic;
         C_sel        : OUT  std_logic;
         constant_in  : OUT  std_logic;
         addr_out     : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    COMPONENT CODE_ROM
		Port ( memory_address     : in  STD_LOGIC_VECTOR (15 downto 0);
               data_out       : out  STD_LOGIC_VECTOR (15 downto 0));
	END COMPONENT;

   --Inputs
   signal clk     : std_logic := '0';
   signal instr   : std_logic_vector(15 downto 0) := (others => '0');
   signal is_zero : std_logic := '0';

 	--Outputs
   signal A_sel        : std_logic_vector(2 downto 0);
   signal B_sel        : std_logic_vector(2 downto 0);
   signal const        : std_logic_vector(2 downto 0);
   signal Reg_sel      : std_logic_vector(2 downto 0);
   signal OP           : std_logic_vector(3 downto 0);
   signal WR           : std_logic;
   signal RAM_mode     : std_logic;
   signal C_sel        : std_logic;
   signal constant_in  : std_logic;
   signal addr_out     : std_logic_vector(15 downto 0) := X"0000";

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

	-- instantiate the test code
	testcode: CODE_ROM
		port map (
			     memory_address => addr_out,
			     data_out       => instr);

	-- Instantiate the Unit Under Test (UUT)
   uut: control_unit PORT MAP (
          clk          => clk,
          instr        => instr,
          is_zero      => is_zero,
          A_sel        => A_sel,
          B_sel        => B_sel,
          const        => const,
          Reg_sel      => Reg_sel,
          OP           => OP,
          WR           => WR,
          RAM_mode     => RAM_mode,
          C_sel        => C_sel,
          constant_in  => constant_in,
          addr_out     => addr_out
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



      wait;
   end process;

END;
