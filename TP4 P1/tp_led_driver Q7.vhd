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
    signal btn_old : std_logic := '0';
    signal btn_rise : std_logic := '0';
    signal led_old : std_logic := '0';
    signal led_fall : std_logic := '0';
    signal led_once : std_logic := '0';
       
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
                btn_old <= '0';
                led_old <= '0';
             elsif rising_edge(clk) then
                 current_state <= next_state;
                 btn_old <= btn;
                 led_old <= led_state;
                 if btn_old = '0' and btn = '1' then 
                    btn_rise <= '1';
                 else 
                    btn_rise <= '0';
                 end if;
                 if led_old = '1' and led_state = '0' then 
                    led_fall <='1';
                 else 
                    led_fall <= '0';
                 end if;
                 if btn_rise = '1' then 
                    led_once <='1';
                 elsif  led_fall = '1' then 
                    led_once <= '0';
                 end if;
                 
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
           
           --btn_rise <= '1' when btn ='1' and btn_old = '0' else '0';
           --led_fall <= '1' when led_old ='1' and led_state = '0' else '0';
           
           led_state <= '1' when current_state = led_on  else '0';
           led_r <= led_state when btn = '0' else '0';
           led_g <= led_state when led_once = '1'
                    else '0';
     
      
end behavioral;