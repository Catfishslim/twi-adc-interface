
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

	constant addrAD2	 : STD_LOGIC_VECTOR(6 downto 0) := "0101000";	-- TWI address for the ADC
  constant writeCfg	 : STD_LOGIC_VECTOR(7 downto 0) := "00010000";	-- configuration register value for the ADC - read VIN0
  constant read_Bit  : STD_LOGIC := '1';
  constant write_Bit : STD_LOGIC := '0';

  procedure waitclocks(signal clock : std_logic;
                       N : INTEGER) is
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

	nextStateDecode: process (start,done_o)
		begin
			next_state <= present_state;	--default is to stay in current state

			case(present_state) is
				when idle => 
					if(rising_edge(start)) then
						next_state <= configWrite;
					end if;
				when configWrite =>
					if(falling_edge(done_o)) then
						next_state <= readSig;
					end if;
				when msbRead =>
					if(falling_edge(done_o)) then
						next_state <= lsbRead;
					end if;
				when lsbRead =>
					waitclocks(clk, 2);
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

