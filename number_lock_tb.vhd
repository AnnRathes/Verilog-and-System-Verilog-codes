------------------------------------------------------------------------------
--	A vhdl testbench to test the number_lock_tb
--	
--	File name: number_lock_tb.vhd 
------------------------------------------------------------------------------
-- Compile in modelsim and simulate for about 4000 ns
------------------------------------------------------------------------------
-- Libraries and use clauses

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
------------------------------------------------------------------------------
entity number_lock_tb is
end number_lock_tb;

------------------------------------------------------------------------------

architecture behave of number_lock_tb is
	
	-- clock period
	
		constant clk_period: time := 200 ns;
		---------------
	-- local signals
	-- names may be chosen as <design_signal_name>_tb
		---------------
		signal u_tb, z_tb, unlock_tb: std_logic;
		signal clk_tb, resetb_tb: std_logic;
	
		signal clock_count: integer range 0 to 9999;
		---------------
	-- component declarations
		---------------
	component number_lock 
	
	port	(
            clk, resetb : IN  std_logic;
            u, z : IN  std_logic;
            unlock : OUT std_logic
		    );
	
	end  component ;
		---------------

begin -- start of the body of the architecture

  -- component instantiations 
  -- instantiate the UUT (Unit Under Test), also called DUT (Design Under Test),

  UUT: number_lock
	  port map(
               clk_tb, resetb_tb,
               u_tb, z_tb,
               unlock_tb
		      );
	---------------
  -- concurrent statements

	-- reset generation by a simple concurrent statement
	  resetb_tb <= '0', '1' after (clk_period * 1.1); 
	---------------
   -- processes
   ---------------
	clock_generate: process
	begin
	  clk_tb <= '0', '1' after (clk_period/2);
	  wait for clk_period;
	end process clock_generate;
   ---------------
   clock_counting: process (clk_tb, resetb_tb)
	begin
		if (resetb_tb = '0') then
		   clock_count <= 0;
		elsif clk_tb'event and clk_tb = '1' then
		   clock_count  <=  clock_count  +  1;  
		end if;
	end process clock_counting;
   ---------------	

	stim_num_lock : process
	begin
	  u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 4.1);   

	  -- Stimulus set #1 beginning ---------------
	  u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);	  
	  u_tb <= '0';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
	  --wait for (clk_period * 1.1); 	
      u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= 'X';  
	  z_tb <= 'X';  
      wait for (clk_period * 1.1); 
	  -- Stimulus set #1 ending ------------------

	 

	 u_tb <= '0';  
	 z_tb <= '0';  
	  wait for (clk_period * 1.1);    

	  -- Stimulus set #2 beginning ---------------
	  u_tb <= '1';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
	  u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '0';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
      u_tb <= '0';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);  
      u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1); 
      u_tb <= '1';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
	  u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);   
	  u_tb <= '0';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
      u_tb <= '0';  
	  z_tb <= '1';  
      wait for (clk_period * 1.1);   
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);  
      u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1); 	
      u_tb <= '1';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= '0';  
	  z_tb <= '0';  
      wait for (clk_period * 1.1);
      u_tb <= 'X';  
	  z_tb <= 'X';  
      wait for (clk_period * 1.1); 		  

	  -- Stimulus set #2 ending ------------------
	  
	 wait; -- suspend testing by waiting indefinitely

	end process stim_num_lock;

end behave;

------------------------------------------------------------------------------
