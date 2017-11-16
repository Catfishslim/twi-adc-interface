<<<<<<< HEAD

library ieee;
use ieee.std_logic_1164.all;

entity ADC_controller is


	port( clk     : in std_logic;
				rst     : in std_logic;
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
end ADC_controller;


architecture Behavioral of ADC_controller is
	
	type state_type is (idle, configWrite, readSig, msbRead, lsbRead);
	signal present_state, next_state : state_type;
	signal count_reset : std_logic;

	constant addrAD2	 : std_logic_vector(6 downto 0) := "0101000";	-- TWI address for the ADC
  constant writeCfg	 : Std_logic_vector(7 downto 0) := "00010000";	-- configuration register value for the ADC - read VIN0
  constant read_Bit  : std_logic := '1';
  constant write_Bit : std_logic := '0';

  constant config_wait : integer := 10;
  constant srst_wait : integer := 2;
  constant stb_wait : integer := 2;
  constant bus_wait : integer := 1200;
  constant msg_wait : integer := 510;

  procedure waitclocks(signal clock : std_logic;
                       N : integer) is
		begin
			for i in 1 to N loop
				wait until falling_edge(clock);	
			end loop;
	end waitclocks;

  begin

	clocked : process(clk, rst)
			begin
	     if(rst='1') then 
	       present_state <= idle;
	    elsif(rising_edge(clk)) then
	      present_state <= next_state;
	    end if;  
	 end process clocked;

	 counter : process(clk, count_reset)
	 	begin
	 		if(count_reset='1') then 
       count <= 0;
    	elsif(rising_edge(clk)) then
      	count <= count + 1;
    END IF;  

	 	end process counter;

	nextStateDecode: process (start,done_o)
		begin
			next_state <= present_state;	--default is to stay in current state

			case(present_state) is
				when idle => 
					if(rising_edge(start)) then --can't do rising edge
						next_state <= configWrite;
					end if;
				when configWrite =>
					if(falling_edge(done_o)) then
						next_state <= readSig;
					end if;
				when readSig =>
					if(falling_edge(done_o)) then
						next_state <= msbRead;
					end if;
				when msbRead =>
					if(falling_edge(done_o)) then
						next_state <= lsbRead;
					end if;
				when lsbRead =>
					next_state <= idle;	--might have to add a delay to ensure that the data is properly read
			end case;
	end process nextStateDecode;

	outputDecode: process (present_state)
		begin
			case(present_state) is
				when idle =>
					msg_i <= '0';
					stb_i <= '0';
					srst  <= '0';
				when configWrite =>
					msg_i <= '0';					-- set signal default values
	   			stb_i <= '0';					-- inactive
					srst <= '0';					-- inactive
					a_i <= addrAD2 & write_Bit;		-- 0x50 address plus '0' for write
					d_i <= writeCfg;				-- 0x10 configuration register (convert Vin0)
					
					waitclocks(clk, 10);			-- activate reset
					srst <= '1';
					waitclocks(clk, 2);
					srst <= '0';
					
					waitclocks(clk, 1200);			-- wait > 1000 clocks for bus to be "free"
					
					stb_i <= '1';								-- start config write operation
					waitclocks(clk, 2);							-- two cycles for strobe to be captured
					stb_i <= '0';
				when readSig =>
					a_i <= addrAD2 & read_Bit;					-- 0x50 address plus '1' for read		
					msg_i <= '1';								-- signal multi-byte read
					stb_i <= '1';								-- start read operation
					waitclocks(clk, 2);							-- two cycles for message to be captured					
					msg_i <= '0';								-- leave strobe high for multi-byte operation
				when msbRead =>
					waitclocks(clk, 510);       -- you have to go past 1/2 scl cycle before dropping
					stb_i <= '0';               -- STB, I'm not sure why
					data_out(15 downto 8) <= d_o; --load msb data read
				when lsbRead =>
					data_out(7 downto 0) <= d_o;


					
			end case;
	end process outputDecode;








end Behavioral;

=======

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
end ADC_controller;


architecture behavior of ADC_controller is
	
	type state_type is (waiting, A, B, C, D, E, F, G, H, I);
	signal present_state, next_state : state_type;

	constant addrAD2	 : STD_LOGIC_VECTOR(6 downto 0) := "0101000";	-- TWI address for the ADC
  	constant writeCfg	 : STD_LOGIC_VECTOR(7 downto 0) := "00010000";	-- configuration register value for the ADC - read VIN0
  	constant read_Bit  : STD_LOGIC := '1';
  	constant write_Bit : STD_LOGIC := '0';
	SIGNAL count_reset : std_logic;
	SIGNAL count : integer := 0;



  	procedure waitclocks(signal clock : std_logic;
             	          N : INTEGER) is
			begin
				for i in 1 to N loop
					wait until falling_edge(clock);	
				end loop;
	end waitclocks;

  begin

	-- Counts the number of clock edges
	counter : PROCESS(clk)
		BEGIN
			IF(rising_edge(clk)) THEN
				IF(count_reset='1') THEN 
					count <= 0;
				ELSE
					count <= count + 1;
				END IF;
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
				WHEN A =>
					if(count < 10) then
						next_state <= present_state;
					else
						next_state <= B;-- waitclocks(clk_sig, 10);
						count_reset <= '1';-- reset counter		-- activate reset
					end if;

				WHEN B =>			
					if(count < 2) then
						next_state <= present_state;
					else
						next_state <= C;--waitclocks(clk_sig, 2);
						count_reset <= '1';-- reset counter
					end if;
						
				WHEN C =>
					if(count < 1200) then
						next_state <= present_state;
					else
						next_state <= D;			-- wait > 1000 clocks for bus to be "free"
						count_reset <= '1';-- reset counter 
					end if;
					
				WHEN D =>
					if(count < 2) then
						next_state <= present_state;
					else
						next_state <= E;--waitclocks(clk_sig, 2);							-- two cycles for strobe to be captured
						count_reset <= '1';-- reset counter
					end if;
				WHEN E =>
					if(DONE_O'event and DONE_O='0') then -- wait until DONE_O_sig'event and DONE_O_sig='0';	-- wait until TWI controller signals done
						next_state <= F;
						count_reset <= '1';-- reset the counter
					else
						next_state <= present_state;
					end if;
				WHEN F =>
					if(count < 2) then
						next_state <= present_state;
					else
						next_state <= G;-- waitclocks(clk_sig, 2);
						count_reset <= '1';-- reset thec counter					-- two cycles for message to be captured			
					end if;
				WHEN G =>			
					if(DONE_O'event and DONE_O='0')then-- wait until DONE_O_sig'event and DONE_O_sig='0';	-- wait until TWI controller signals done
						next_state <= H;
						count_reset <= '1';-- reset the counter					
					else
						next_state <= present_state;
					end if;
				WHEN H =>
					if(count > 510) then-- waitclocks(clk_sig, 510);						-- you have to go past 1/2 SCL cycle before dropping
						next_state <= I;
						count_reset <= '1';
					else
						next_state <= present_state;
					end if;
				WHEN I =>
					next_state <= waiting;
					count_reset <= '1';-- reset the coutner?

				WHEN waiting =>
					if(start'EVENT AND start = '1') then
						next_state <= A;
						count_reset <= '1';
					else
						next_state <= present_state;
					end if;
		END CASE;
	end process nextStateDecode;

	outputDecode: process (present_state)
		begin
			count_reset <= '0';
			case(present_state) is
				WHEN A =>
	    				MSG_I <= '0';					-- set signal default values
	    				STB_I <= '0';					-- inactive
					SRST <= '0';					-- inactive
					A_I <= addrAD2 & write_Bit;		-- 0x50 address plus '0' for write
					D_I <= writeCfg;				-- 0x10 configuration register (convert Vin0)
					
				WHEN B =>			
					SRST <= '1';
						
				WHEN C =>
					SRST <= '0';
					
				WHEN D =>
					STB_I <= '1';							-- start config write operation
				
				WHEN E =>
					STB_I <= '0';

				WHEN F =>
					A_I <= addrAD2 & read_Bit;					-- 0x50 address plus '1' for read		
					MSG_I <= '1';								-- signal multi-byte read
					STB_I <= '1';								-- start read operation
				
				WHEN G =>			
					MSG_I <= '0';								-- leave strobe high for multi-byte operation

				WHEN H =>
					STB_I <= '0';								-- STB, I'm not sure why
					data_out(15 downto 8) <= D_O;				-- load MSB data read

				WHEN I =>
					data_out(7 downto 0) <= D_O;					-- load LSB data read

				WHEN waiting =>
					count_reset <= '1';-- reset the counter

					
			end case;
	end process outputDecode;

end behavior;

>>>>>>> refs/remotes/origin/TrippsBranch
