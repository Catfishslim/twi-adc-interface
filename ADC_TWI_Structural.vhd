library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc_toplevel is
	port(reset_sig : IN STD_LOGIC; -- external reset signal
	     data_out_sig : OUT STD_LOGIC_VECTOR (15 downto 0)); -- 16-bit "result" of 2-byte read from ADC
end adc_toplevel;

architecture behavior of adc_toplevel is
	-- Lets define some of the signals
	signal CLK_sig    : std_logic := '0';	-- signals to connect to the TWI
	signal START_sig : std_logic := '0'; -- ADC Start signal
  	signal SRST_sig  : std_logic := '0';
  	signal SCL_sig    : std_logic;
  	signal MSG_I_sig  : std_logic;
  	signal STB_I_sig  : std_logic;
  	signal DONE_O_sig : std_logic;
  	signal ERR_O_sig  : std_logic;
  	signal SDA_sig    : std_logic;
  	signal A_I_sig    : STD_LOGIC_VECTOR (7 downto 0);
  	signal D_I_sig    : STD_LOGIC_VECTOR (7 downto 0);
  	signal D_O_sig    : STD_LOGIC_VECTOR (7 downto 0);
	
	begin

	-- The synthesized 100 MHz Clock
	main_clock : entity work.synth_clock(behavior)
		port map(clock_100MHz => CLK_sig);

	-- Clock Divider
	clock_divider : entity work.clock_divider(behavior)
		port map(mclk => CLK_sig,
			 sclk => START_sig);

	-- ADC Controller State Machine
	adc_controller : entity work.adc_controller(behavior)
		port map(clk => clk_sig,
			 srst => srst_sig,
			 stb_i => stb_i_sig,
			 msg_i => msg_i_sig,
			 a_i => a_i_sig,
			 d_i => d_i_sig,
			 done_o => done_o_sig,
			 err_o => err_o_sig,
			 d_o => d_o_sig,
			 start => start_sig,-- control signals
			 reset => reset_sig,
			 data_out => data_out_sig);

	-- TWI Control Component
	twi_controller : entity work.TWICtl(behavioral)
		generic map(CLOCKFREQ => 100)-- System clock in MHz
		port map(msg_i => msg_i_sig,
			 stb_i => stb_i_sig,
			 a_i => a_i_sig,
			 d_i => d_i_sig,
			 d_o => d_o_sig,
			 done_o => done_o_sig,
			 err_o => err_o_sig,
			 clk => clk_sig,
			 srst => srst_sig,
			 -- I2C interface lines
			 sda => sda_sig,
			 scl => scl_sig);

	-- Synthetic ADC Response
	adc_synthetic : entity work.adc_response(behavior)
			port map(scl => scl_sig,
				 sda => sda_sig);
	


end behavior;