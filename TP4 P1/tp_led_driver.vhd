library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tp_led_driver is
    generic (
        cible : integer := 20
    );
    port ( 
		clk			: in std_logic; 
        reset		: in std_logic;
		btn         : in std_logic;
		led_r       : out std_logic;
		led_g       : out std_logic
     );
end tp_led_driver;

architecture behavioral of tp_led_driver is

    type state is (led_on,led_off);
    signal current_state : state;  
    signal next_state : state;	   
    signal resetn : std_logic:='0';
    signal end_counter: std_logic:='0';
    signal led_state : std_logic := '0';
    signal btn_sync : std_logic :='0';
    signal btn_old : std_logic:='0';
    signal btn_rise : std_logic :='0';
    signal led_state_old : std_logic:='0';
    signal led_state_fall : std_logic := '0';
    signal led_once : std_logic :='0';
    signal led_once_d : std_logic :='0';
    
        
	begin
	    cpt: entity work.counter_unit(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clk,
                resetn => resetn,
                end_counter => end_counter
            );

        process(clk,resetn)
        begin
            if resetn = '0' then   
                current_state <= led_off;
                btn_sync <= '0';
                btn_old <= '0';
                led_state_old <= '0';
                led_once <= '0';
             elsif rising_edge(clk) then
                 current_state <= next_state;
                 btn_sync <= btn;
                 btn_old <=btn_sync;
                 led_state_old <= led_state;
                 led_once <= led_once_d;
             end if;
        end process;
        process(current_state, end_counter)
        begin
           next_state <= current_state;
           case current_state is
                when led_off =>
                   if end_counter = '1' then
                        next_state <= led_on;
                   end if;
                 when led_on =>
                   if end_counter = '1' then
                        next_state <= led_off;
                   end if;
            end case;
        end process;
           resetn <= not reset;
           btn_rise <= '1' when btn_old = '0' and btn_sync = '1'else '0';
           led_state_fall <= '1' when led_state_old = '1' and led_state = '0' else '0';
           led_once_d <= '1' when btn_rise = '1' 
                    else '0' when led_state_fall = '1' 
                    else led_once;
           led_state <= '1' when current_state = led_on  else '0';
           led_r <= led_state when btn_sync = '0' else '0';
           led_g <= led_state when led_once_d = '1' else '0';
     
      
end behavioral;