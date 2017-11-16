library ieee;
use ieee.std_logic_1164.all;

entity adc_controller is
	port( clk     : in std_logic;
				reset     : in std_logic;
				start   : in std_logic;
				done_o  : in std_logic;
				err_o   : in std_logic;
				d_o     : in std_logic_vector(7 downto 0);
				srst    : out std_logic;
				stb_i   : out std_logic;
				msg_i   : out std_logic;
				a_i     : out std_logic_vector(7 downto 0);
				d_i     : out std_logic_vector(7 downto 0);
				data_out: out std_logic_vector(15 downto 0));
end adc_controller;


architecture behavior of ADC_controller is
	
	type state_type is (waiting, addressWrite, resetState, resetWait, configWrite, configWait, startRead, msgLow, readWait, msbRead, lsbRead);
	signal present_state, next_state : state_type;

	constant addrAD2	 : STD_LOGIC_VECTOR(6 downto 0) := "0101000";	-- TWI address for the ADC
  	constant writeCfg	 : STD_LOGIC_VECTOR(7 downto 0) := "00010000";	-- configuration register value for the ADC - read VIN0
  	constant read_Bit  : STD_LOGIC := '1';
  	constant write_Bit : STD_LOGIC := '0';
	SIGNAL count_reset : std_logic := '0';
	SIGNAL count : integer := 0;



  	procedure waitclocks(signal clock : std_logic;
             	          N : INTEGER) is
			begin
				for lsbRead in 1 to N loop
					wait until falling_edge(clock);	
				end loop;
	end waitclocks;

  begin

	-- Counts the number of clock edges
	counter : PROCESS(clk)
		BEGIN
			IF(count_reset='1' ) THEN 
					count <= 0;
					--count_reset <='0';

			ELSIF(rising_edge(clk)) THEN
					count <= count + 1;
				END IF;
			  
	END PROCESS counter;

	clocked : process(clk, reset)
			begin
	     if(reset='1') then 
	       present_state <= waiting;
	    elsif(rising_edge(clk)) then
	      present_state <= next_state;
	    end if;  
	 end process clocked;

	nextStateDecode: process (start,done_o, present_state, count)
		begin
		count_reset <= '0';
			case(present_state) is
				WHEN addressWrite =>
					if(count < 10) then
						next_state <= present_state;
					else
						next_state <= resetState;-- waitclocks(clk_sig, 10);
						count_reset <= '1';-- reset counter		-- activate reset
					end if;

				WHEN resetState =>			
					if(count < 2) then
						next_state <= present_state;
					else
						next_state <= resetWait;--waitclocks(clk_sig, 2);
						count_reset <= '1';-- reset counter
					end if;
						
				WHEN resetWait =>
					if(count < 1200) then
						next_state <= present_state;
					else
						next_state <= configWrite;			-- wait > 1000 clocks for bus to be "free"
						count_reset <= '1';-- reset counter 
					end if;
					
				WHEN configWrite =>
					if(count < 2) then
						next_state <= present_state;
					else
						next_state <= configWait;--waitclocks(clk_sig, 2);							-- two cycles for strobe to be captured
						count_reset <= '1';-- reset counter
					end if;
				WHEN configWait =>
					if(DONE_O'event and DONE_O='0') then -- wait until DONE_O_sig'event and DONE_O_sig='0';	-- wait until TWI controller signals done
						next_state <= startRead;
						count_reset <= '1';-- reset the counter
					else
						next_state <= present_state;
					end if;
				WHEN startRead =>
					if(count < 2) then
						next_state <= present_state;
					else
						next_state <= msgLow;-- waitclocks(clk_sig, 2);
						count_reset <= '1';-- reset thec counter					-- two cycles for message to be captured			
					end if;
				WHEN msgLow =>			
					if(DONE_O'event and DONE_O='0')then-- wait until DONE_O_sig'event and DONE_O_sig='0';	-- wait until TWI controller signals done
						next_state <= readWait;
						count_reset <= '1';-- reset the counter					
					else
						next_state <= present_state;
					end if;
				WHEN readWait =>
					if (count < 510) then -- waitclocks(clk_sig, 510);
						next_state <= present_state;
					else
							next_state <= msbRead;
							count_reset <= '1';
					end if;
				WHEN msbRead =>
					if(DONE_O'event and DONE_O = '0') then						-- you have to go past 1/2 SCL cycle before dropping
						next_state <= lsbRead;
						count_reset <= '1';
					else
						next_state <= present_state;
					end if;
				WHEN lsbRead =>
					next_state <= waiting;
					count_reset <= '1';-- reset the coutner?

				WHEN waiting =>
					if(start'EVENT AND start = '1') then
						next_state <= addressWrite;
						count_reset <= '1';
					else
						next_state <= present_state;
					end if;
		END CASE;
	end process nextStateDecode;

	outputDecode: process (present_state)
		begin
			--count_reset <= '0';
			case(present_state) is
				WHEN addressWrite =>
	    				MSG_I <= '0';					-- set signal default values
	    				STB_I <= '0';					-- inactive
					SRST <= '0';					-- inactive
					A_I <= addrAD2 & write_Bit;		-- 0x50 address plus '0' for write
					D_I <= writeCfg;				-- 0x10 configuration register (convert Vin0)
					
				WHEN resetState =>			
					SRST <= '1';
						
				WHEN resetWait =>
					SRST <= '0';
					
				WHEN configWrite =>
					STB_I <= '1';							-- start config write operation
				
				WHEN configWait =>
					STB_I <= '0';

				WHEN startRead =>
					A_I <= addrAD2 & read_Bit;					-- 0x50 address plus '1' for read		
					MSG_I <= '1';								-- signal multi-byte read
					STB_I <= '1';								-- start read operation
				
				WHEN msgLow =>			
					MSG_I <= '0';								-- leave strobe high for multi-byte operation

				WHEN readWait =>

				WHEN msbRead =>
					STB_I <= '0';								-- STB, lsbRead'm not sure why
					data_out(15 downto 8) <= D_O;				-- load MSB data read

				WHEN lsbRead =>
					data_out(7 downto 0) <= D_O;					-- load LSB data read

				WHEN waiting =>
					--count_reset <= '1';-- reset the counter

					
			end case;
	end process outputDecode;

end behavior;