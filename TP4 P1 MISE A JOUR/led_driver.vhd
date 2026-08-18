library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity led_driver is
    generic (
       cible : integer := 20 
       );
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           color_code : in STD_LOGIC_VECTOR (1 downto 0);
           update : in STD_LOGIC;
           led_r : out STD_LOGIC;
           led_g : out STD_LOGIC;
           led_b : out STD_LOGIC);
end led_driver;

architecture Behavioral of led_driver is
    type onoff_state is (led_on,led_off);
    signal current_onoff_state : onoff_state;  
    signal next_onoff_state : onoff_state;
    signal first_on : std_logic := '0';
    type color_state is (off,rouge,bleu,vert);
    signal led_color : color_state;  
    signal end_counter: std_logic:='0';

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
                current_onoff_state <= led_off;
                first_on <= '1';
              elsif rising_edge(clk) then
                current_onoff_state <= next_onoff_state;
                first_on <= '0';
             end if ; 
        end process;
        -- FSM ON OFF
        process(current_onoff_state, end_counter)
        begin
           next_onoff_state <= current_onoff_state;
           case current_onoff_state is
                when led_off =>
                   if end_counter = '1' or first_on = '1' then
                        next_onoff_state <= led_on;
                   end if;
                 when led_on =>
                   if end_counter = '1' then
                        next_onoff_state <= led_off;
                   end if;
            end case;
        end process;
        -- LED COLOR CONTROL
        process( clk, resetn)
        begin
             if resetn = '0' then   
                led_color <= off;
              elsif rising_edge(clk) then
                 if update = '1' then 
                   case color_code is
                        when "00" =>
                            led_color <= off; 
                        when "01" =>
                            led_color <= rouge;
                        when "10" =>
                            led_color <= vert;
                        when "11" =>
                            led_color <= bleu;
                        when others =>
                            led_color <= off;
                     end case;
                end if ; 
            end if;
        end process;
       led_r <= '1' when led_color = rouge and current_onoff_state = led_on
           else '0';
       led_b <= '1' when led_color = bleu and current_onoff_state = led_on
           else '0';
        led_g <= '1' when led_color = vert and current_onoff_state = led_on
           else '0';
end Behavioral;
