library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity top_led_driver is
    generic (
        cible : integer := 200000000
    );
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
		btn0        : in std_logic;
		btn1       : in std_logic;
		led0_r       : out std_logic;
		led0_b       : out std_logic;
		led0_g       : out std_logic
     );
end top_led_driver;

architecture behavioral of top_led_driver is
    signal color_code_in : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal color_code_out : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal btn0_old : std_logic:='0';
    signal btn0_rise : std_logic := '0';
    signal full : std_logic:='0';
    signal empty : std_logic := '0';	
    signal reset: std_logic := '0';
    signal end_cycle_onoff: std_logic := '0';
    signal end_cycle_offon: std_logic := '0';
    
    component led_driver_fifo
    port (
        clk   : in  std_logic;
        srst  : in  std_logic;
        din   : in  std_logic_vector(1 downto 0);
        wr_en : in  std_logic;
        rd_en : in  std_logic;
        dout  : out std_logic_vector(1 downto 0);
        full  : out std_logic;
        empty : out std_logic
    );
    end component;
    begin
	    led_driver: entity work.led_driver(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clk,
                resetn => resetn,
				color_code => color_code_out,
				update => end_cycle_offon,
				end_cycle_offon => end_cycle_offon,
				end_cycle_onoff => end_cycle_onoff,
				led_r   => led0_r,
				led_g   => led0_g,
				led_b  => led0_b
            );
        fifo : led_driver_fifo
          PORT MAP (
            clk => clk,
            srst => reset,
            din => color_code_in,
            wr_en => btn0_rise ,
            rd_en => end_cycle_onoff,
            dout => color_code_out,
            full => full,
            empty => empty
          );
        process(clk,resetn)
        begin
            if resetn = '0' then   
                btn0_old <= '0';
                btn0_rise <= '0';
              elsif rising_edge(clk) then
                btn0_old <= btn0;
                 if btn0_old = '0' and btn0 = '1' then 
                    btn0_rise <= '1';
                else 
                    btn0_rise <= '0';
                end if;               
              end if;
        end process;
        reset <= not resetn;
 		color_code_in <= "10" when btn1 = '1' else "11";
end behavioral;