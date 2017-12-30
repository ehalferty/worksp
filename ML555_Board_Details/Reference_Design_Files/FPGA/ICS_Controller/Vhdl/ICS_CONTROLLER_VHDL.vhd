--//////////////////////////////////////////////////////////////////////////////////
--// Company: Xilinx
--// Engineer: Brandond Day
--// 
--// Create Date:    13:47:19 05/03/2006 
--// Design Name:  ICS CONTROLLER
--// Module Name:    ICS_CONTROLLER_VHDL 
--// Project Name:
--// Target Devices:LX50TFF1136-2 
--// Tool versions: I.30
--// Description: The purpose of this code is to serial reconfigure the ICS external PLL.
--// The intereface is to present parallel data in the FPGA then have the state machine 
--// serial send it to the PLL. Please see the ICS8442 data sheet for more detail on the PLL.
--// The ML555 User guide also has more information on this.
--//
--// Dependencies: 
--// This design was tested with ML555 board on both ICS 1 and 2. This can be swapped between
--// the two controller through the UCF.  If you reconfigure this design in Chipscope CLOSE
--// VIO window then re-open it.  It is possible to have both controllers in the design the user
--// will need to modif the code according to thier needs.
--//
--// Revision: 
--// Revision 0.9 - File Created
--// Additional Comments: 
--// There is a VHDL version of Chipscope project included for this design.  The VHDL and Verilog version
--// of this design share a common UCF file.
--//
--//////////////////////////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ICS_CONTROLLER_VHDL is
    Port ( 
               SATA_MGT_CLKSEL :  out STD_LOGIC;

		   clk : in  STD_LOGIC;
			
			pushbutton_1 : in STD_LOGIC;
			pushbutton_2 : in STD_LOGIC;
			pushbutton_3 : in STD_LOGIC;
			
			LED_1 : OUT STD_LOGIC;
			LED_2 : OUT STD_LOGIC;
			LED_3 : OUT STD_LOGIC;
			
			--ICS PLL 1
			PLL_IN_P_1 : in  STD_LOGIC;
			PLL_IN_N_1 : in  STD_LOGIC;
			PLL_OUT_P_1 : out  STD_LOGIC;
         STROBE_1 : out  STD_LOGIC;
         PLOAD_1 : out  STD_LOGIC;
         SDATA_1 : out  STD_LOGIC;
         SCLOCK_1 : out  STD_LOGIC;
			--ICS PLL 2
			PLL_IN_P_2 : in  STD_LOGIC;
			PLL_IN_N_2 : in  STD_LOGIC;
			PLL_OUT_P_2 : out  STD_LOGIC;
         STROBE_2 : out  STD_LOGIC;
         PLOAD_2 : out  STD_LOGIC;
         SDATA_2 : out  STD_LOGIC;
         SCLOCK_2 : out  STD_LOGIC);
end ICS_CONTROLLER_VHDL;

 




architecture Behavioral of ICS_CONTROLLER_VHDL is

type state is (
s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD,sE, sF, 
s10,s11, s12, s13, s14, s15, s16, s17, s18, s19, s1A, s1B, s1C, s1D, s1E, s1F);


signal next_state: state; 

signal control : std_logic_vector(35 downto 0);
signal reset :  STD_LOGIC;
signal reconfigure_pll : STD_LOGIC;
signal pll_value : std_logic_vector (10 downto 0);

signal pll_value_chipscope : std_logic_vector (10 downto 0);
signal pll_value_min : std_logic_vector (10 downto 0):= "11011000011";
signal pll_value_max : std_logic_vector (10 downto 0):= "00111000011";
signal pll_value_mid : std_logic_vector (10 downto 0):= "10011000011";

signal PLL_SIG_2 : std_logic;
--signal PLL_SIG_2_DIVIDE : STD_LOGIC;
--signal count_2: std_logic_vector (2 downto 0);
signal STROBE_2_sig :  STD_LOGIC;
signal PLOAD_2_sig :  STD_LOGIC;
signal SDATA_2_sig :  STD_LOGIC;
signal SCLOCK_2_sig :  STD_LOGIC;

signal PLL_SIG_1 : std_logic;
--signal PLL_SIG_1_DIVIDE : STD_LOGIC;
--signal count_1: std_logic_vector (2 downto 0);
signal STROBE_1_sig :  STD_LOGIC;
signal PLOAD_1_sig :  STD_LOGIC;
signal SDATA_1_sig :  STD_LOGIC;
signal SCLOCK_1_sig :  STD_LOGIC;

signal pushbutton_1_sig :  STD_LOGIC;
signal pushbutton_1_debounce :  STD_LOGIC;
signal Q1, Q2, Q3 : std_logic;

signal pushbutton_2_sig :  STD_LOGIC;
signal pushbutton_2_debounce :  STD_LOGIC;
signal Q4, Q5, Q6 : std_logic;

signal pushbutton_3_sig :  STD_LOGIC;
signal pushbutton_3_debounce :  STD_LOGIC;
signal Q7, Q8, Q9 : std_logic;

--Chipscope controller
component icon
    port
    (
      control0    :   out std_logic_vector(35 downto 0)
    );
  end component;
  
  --Chipscope VIO
    component vio
    port
    (
      control    : in    std_logic_vector(35 downto 0);
      async_in    : in    std_logic_vector(2 downto 0);
      async_out   :   out std_logic_vector(12 downto 0)
    );
  end component;

--Termination needed for clock to come into design  
attribute DIFF_TERM : string;
attribute DIFF_TERM of U2 : label is "TRUE";
attribute DIFF_TERM of U1 : label is "TRUE";
--
begin

STROBE_2 <= STROBE_2_sig;
SDATA_2 <= SDATA_2_sig;
PLOAD_2 <= PLOAD_2_sig;

STROBE_1 <= STROBE_2_sig;
SDATA_1 <= SDATA_2_sig;
PLOAD_1 <= PLOAD_2_sig;

-- PLOAD signal is not used in this design but the user
-- can perform a PLOAD on the board by pushing the button on the board
-- the PLOAD value will over ride until another serial configurtion of the PLL is performed
PLOAD_2_sig <= '0';
SCLOCK_2 <= SCLOCK_2_sig;

PLOAD_1_sig <= '0';
SCLOCK_1 <= SCLOCK_2_sig;

LED_1 <= pushbutton_1;
LED_2 <= pushbutton_2;
LED_3 <= pushbutton_3;

SATA_MGT_CLKSEL <= '1';


--Brings PLL clock signal into design
U1: IBUFGDS
 generic map (
     IOSTANDARD => "LVDS_25")
port map (
I => PLL_IN_P_1,
IB => PLL_IN_N_1,
O => PLL_SIG_1
);

--process (PLL_SIG_1, count_1)
--begin
--if PLL_SIG_1'event and PLL_SIG_1 ='1' then
--	if count_1 <= "100" then
--		pll_sig_1_divide <= '1';
--	else
--		pll_sig_1_divide <= '0';
--	end if;
--	count_1 <= count_1 + '1';
--end if;

--end process;


U2: IBUFGDS
 generic map (
     IOSTANDARD => "LVDS_25")
port map (
I => PLL_IN_P_2,
IB => PLL_IN_N_2,
O => PLL_SIG_2
);

--Outputs PLL clock signal not needed only for test purposes

--process (PLL_SIG_2, count_2)
--begin
--if PLL_SIG_2'event and PLL_SIG_2 ='1' then
--	if count_2 <= "100" then
--		pll_sig_2_divide <= '1';
--	else
--		pll_sig_2_divide <= '0';
--	end if;
--	count_2 <= count_2 + '1';
--end if;
--
--end process;
U3: OBUF
port map (
O => PLL_OUT_P_1,
I => PLL_SIG_1
);


U4: OBUF
port map (
O => PLL_OUT_P_2,
I => PLL_SIG_2
);

--Maps internal signals to VIO
i_vio : vio
    port map
    (
      control   => control,
		async_in(0)  => STROBE_2_sig,
		async_in(1)	 => SDATA_2_sig,
		async_in(2)  => SCLOCK_2_sig,
		async_out(12) => reset,
      async_out(11) => reconfigure_pll,
		async_out (10 downto 0) => pll_value_chipscope
		
    );


 i_icon : icon
    port map
    (
      control0    => control
    );
	 
--pushbutton 1 debounce circuit	 
pushbutton_1_debounce <= pushbutton_1;
process(clk)
begin
   if (clk'event and clk = '1') then
      if (reset = '1') then
         Q1 <= '0';
         Q2 <= '0';
         Q3 <= '0'; 
      else
         Q1 <= not pushbutton_1_debounce;
         Q2 <= Q1;
         Q3 <= Q2;
      end if;
   end if;
end process;
 

pushbutton_1_sig <= Q1 and Q2 and (not Q3);

 --pushbutton 2 debounce circuit
pushbutton_2_debounce <= pushbutton_2;
process(clk)
begin
   if (clk'event and clk = '1') then
      if (reset = '1') then
         Q4 <= '0';
         Q5 <= '0';
         Q6 <= '0'; 
      else
         Q4 <= not pushbutton_2_debounce;
         Q5 <= Q4;
         Q6 <= Q5;
      end if;
   end if;
end process;
 
pushbutton_2_sig <= Q4 and Q5 and (not Q6);

--Pushbutton 3 debounce

pushbutton_3_debounce <= pushbutton_3;
process(clk)
begin
   if (clk'event and clk = '1') then
      if (reset = '1') then
         Q7 <= '0';
         Q8 <= '0';
         Q9 <= '0'; 
      else
         Q7 <= not pushbutton_3_debounce;
         Q8 <= Q7;
         Q9 <= Q8;
      end if;
   end if;
end process;
 
pushbutton_3_sig <= Q7 and Q8 and (not Q9);

process (pushbutton_1_sig, pushbutton_2_sig ,pushbutton_3_sig, clk)
 begin
if clk'event and clk = '1' then
		   if pushbutton_1_sig = '1' then
			 pll_value <= pll_value_min;
			 
			elsif pushbutton_2_sig = '1' then
			 pll_value <= pll_value_mid;
			 
			elsif pushbutton_3_sig = '1' then
			 pll_value <= pll_value_max;
			 
			elsif reconfigure_pll = '1' then
			 pll_value <= pll_value_chipscope;
	else
		pll_value <= pll_value;
		end if;
	end if;
end process;
	
process (reset,clk)
begin
if reset = '1' then 
		next_state <= s0;
elsif clk'event and clk = '1' then
case (next_state) is
	when s0 =>
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '0';
		SCLOCK_2_sig <= '0';
		if (reset = '0' and reconfigure_pll = '1') or pushbutton_1_sig = '1' or pushbutton_2_sig = '1' or pushbutton_3_sig = '1' then
		next_state <= s1;
		else
		next_state <= s0;
		end if;		
	when s1 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '0';
		SCLOCK_2_sig <= '0';
		next_state <= s2;
	when s2 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '1';
		SCLOCK_2_sig <= '0';
		next_state <= s3;
		-- First Bit don't care
	when s3 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '1';
		SCLOCK_2_sig <= '1';
		next_state <= s4;
		-- Toggle clock
	when s4 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '0';
		SCLOCK_2_sig <= '0';
		next_state <= s5;
		-- Second Bit don't care
	when s5 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '0';
		SCLOCK_2_sig <= '1';
		next_state <= s6;
		-- Toggle clock
	when s6 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '1';
		SCLOCK_2_sig <= '0';
		next_state <= s7;
		-- Third bit don't care
	when s7 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '1';
		SCLOCK_2_sig <= '1';
		next_state <= s8;
		-- toggle clock
	when s8 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(0);
		SCLOCK_2_sig <= '0';
		next_state <= s9;
		--Fourth bit N1 value
	when s9 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(0);
		SCLOCK_2_sig <= '1';
		next_state <= sA;
		-- togle clock
	when sA => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(1);
		SCLOCK_2_sig <= '0';
		next_state <= sB;
		--Fith bit N0 value
	when sB => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(1);
		SCLOCK_2_sig <= '1';
		next_state <= sC;
		--toggle clock
	when sC => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(2);
		SCLOCK_2_sig <= '0';
		next_state <= sD;
		--Sixth bit M8 value
	when sD => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(2);
		SCLOCK_2_sig <= '1';
		next_state <= sE;
		-- togle clock
	when sE => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(3);
		SCLOCK_2_sig <= '0';
		next_state <= sF;
		--Seventh bit M7 value
	when sF => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(3);
		SCLOCK_2_sig <= '1';
		next_state <= s10;
		-- togle clock
	when s10 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(4);
		SCLOCK_2_sig <= '0';
		next_state <= s11;
		--Eighth bit M6 value

	when s11 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(4);
		SCLOCK_2_sig <= '1';
		next_state <= s12;
		-- togle clock
	when s12 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(5);
		SCLOCK_2_sig <= '0';
		next_state <= s13;
		--ninth bit M5 value
	when s13 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(5);
		SCLOCK_2_sig <= '1';
		next_state <= s14;
		-- togle clock
	when s14 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(6);
		SCLOCK_2_sig <= '0';
		next_state <= s15;
		--Tenth bit M4 value
	when s15 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(6);
		SCLOCK_2_sig <= '1';
		next_state <= s16;
		-- togle clock
	when s16 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(7);
		SCLOCK_2_sig <= '0';
		next_state <= s17;
		--eleventh bit M3 value
	when s17 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(7);
		SCLOCK_2_sig <= '1';
		next_state <= s18;
		-- togle clock
	when s18 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(8);
		SCLOCK_2_sig <= '0';
		next_state <= s19;
		--twelfth bit M2 value
	when s19 => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(8);
		SCLOCK_2_sig <= '1';
		next_state <= s1A;
		-- togle clock
	when s1A => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(9);
		SCLOCK_2_sig <= '0';
		next_state <= s1B;
		--Thirtenth bit M1 value
	when s1B => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(9);
		SCLOCK_2_sig <= '1';
		next_state <= s1C;
		-- togle clock
	when s1C => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(10);
		SCLOCK_2_sig <= '0';
		next_state <= s1D;
		--fourtenth bit M0 value
	when s1D => 
		STROBE_2_sig <= '0';
		SDATA_2_sig <= pll_value(10);
		SCLOCK_2_sig <= '1';
		next_state <= s1E;
		-- togle clock

when s1E =>
		STROBE_2_sig <= '1';
		SDATA_2_sig <= '0';
		SCLOCK_2_sig <= '0';
		next_state <= s1F;
when s1F =>
		STROBE_2_sig <= '0';
		SDATA_2_sig <= '0';
		SCLOCK_2_sig <= '0';
		if reconfigure_pll = '0' or pushbutton_1_sig = '1' or pushbutton_2 = '0' or pushbutton_3 = '0'then 
		next_state <= s0;
		else
		next_state <= s1F;
		end if;
		--deassert STROBE_2_sig and stop process must deassert reconfigure pll to leave state
end case;
end if;
end process;

	

end Behavioral;
