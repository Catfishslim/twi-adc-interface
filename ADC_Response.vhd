library ieee;
use ieee.std_logic_1164.all;

entity adc_response is
	port(scl, sda : INOUT STD_LOGIC);
end adc_response;

architecture behavior of adc_response is

	-- This procedure waits for N number of falling edges on the specified
	-- clock signal
	
	procedure waitclocks(signal clock : std_logic;
                       N : INTEGER) is
		begin
			for i in 1 to N loop
				wait until clock'event and clock='0';	-- wait on falling edge
			end loop;
	end waitclocks;
	
  begin
  
	
	-- This process the ADC slave device on the TWI bus. It drives the SDA signal to '0' at the appropriate
	-- times to furnish an "ACK" signal to the TWI master device and '0' and 'H' at appropriate times to 
	-- simulate the data being returned from the ADC over the TWI bus.
		
	slave_stimulus : process
      		begin
			sda <= 'H';						-- not driven
			scl <= 'H';						-- not driven
	
					-- 1st series
											-- address write
			waitclocks(scl, 9);			-- wait for transmission time
			sda <= '0';
			waitclocks(scl, 1);			-- wait for ack time
			sda <= 'H';
											-- config register write
			waitclocks(scl, 8);			-- wait for transmission time
			sda <= '0';
			waitclocks(scl, 1);			-- wait for ack time
			sda <= 'H';
	
											-- address write
			waitclocks(scl, 9);			-- wait for transmission time
			sda <= '0';
			waitclocks(scl, 1);			-- wait for ack time
			sda <= 'H';
	
			sda <= 'H';					-- MSB (upper byte)
			waitclocks(scl, 1);	
			sda <= '0';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';					-- LSB
			waitclocks(scl, 1);
			sda <= 'H';					-- Release bus
	
		
			waitclocks(scl, 1);			
			sda <= '0';					-- MSB (lower byte)
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';					-- LSB (lower byte)
			waitclocks(scl, 1);
			sda <= 'H';
	
			-- 2nd series
											-- address write
			
			waitclocks(scl, 10);			-- wait for transmission time
			sda <= '0';
			waitclocks(scl, 1);			-- wait for ack time
			sda <= 'H';
											-- config register write
			waitclocks(scl, 8);			-- wait for transmission time
			sda <= '0';
			waitclocks(scl, 1);			-- wait for ack time
			sda <= 'H';
	
											-- address write
			waitclocks(scl, 9);			-- wait for transmission time
			sda <= '0';
			waitclocks(scl, 1);			-- wait for ack time
			sda <= 'H';
	
			sda <= 'H';					-- MSB (upper byte)
			waitclocks(scl, 1);	
			sda <= '0';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= '0';					-- LSB
			waitclocks(scl, 1);
			sda <= 'H';					-- Release bus
	
			
			waitclocks(scl, 1);			
			sda <= '0';					-- MSB (lower byte)
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= 'H';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= '0';
			waitclocks(scl, 1);
			sda <= 'H';					-- LSB (lower byte)
			waitclocks(scl, 1);
			sda <= 'H';

			wait; -- stop the process to avoid an infinite loop

	end process slave_stimulus;
end behavior;