
library iee;
use iee.std_logic_1164.all;

entity ADC_controller is


	port( clk    : in std_logic;
				rst    : in std_logic;
				start  : in std_logic;
				done_o : in std_logic;
				err_o  : in std_logic;
				d_o    : in std_logic_vector(7 downto 0);
				srst   : out std_logic;
				stb_i  : out std_logic;
				msg_i  : out std_logic;
				a_i    : out std_logic_vector(7 downto 0);
				d_i    : out std_logic_vector(7 downto 0));
end ADC_controller;


architecture Behavioral of ADC_controller is
	
	type state_type is (idle, configWrite, readSig, msbRead, lsbRead);
	signal present_state, next_state : state_type;

	constant addrAD2	 : STD_LOGIC_VECTOR(6 downto 0) := "0101000";	-- TWI address for the ADC
  constant writeCfg	 : STD_LOGIC_VECTOR(7 downto 0) := "00010000";	-- configuration register value for the ADC - read VIN0
  constant read_Bit  : STD_LOGIC := '1';
  constant write_Bit : STD_LOGIC := '0';

	clocked : process(clk, rst)
			begin
	     if(rst='1') then 
	       present_state <= idle;
	    elsif(rising_edge(clk)) then
	      present_state <= next_state;
	    end if;  
	 end process clocked;

	nextStateDecode: process (clk)
		begin

			next_state <= current_state;	--default is to stay in current state

			case(current_state) is
				when idle => 
					if(rising_edge(start)) then
						next_state <= configWrite;
					end if;
				when configWrite =>
					if(falling_edge(done_o)) then
						next_state <= readSig;
					end if;
				when msbRead
					if(falling_edge(done_o)) then
						next_state <= lsbRead;
					end if;
				when lsbRead =>
					next_state <= idle;	--might have to add a delay to ensure that the data is properly read
			end case;







end Behavioral;

