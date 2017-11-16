library IEEE;
use IEEE.std_logic_1164.all;

entity synth_clock is
	port(clock_100MHz : OUT STD_LOGIC);
end synth_clock;

architecture behavior of synth_clock is
	constant Tperiod : time := 10 ns;
	signal clk_tick : STD_LOGIC := '0';
	BEGIN
		process(clk_tick)
      			begin
        			clk_tick <= not clk_tick after Tperiod/2;
				clock_100MHZ <= clk_tick;
    		end process;
end behavior;