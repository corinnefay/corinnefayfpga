library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tp_fsm is
    generic (
        cible : integer := 200000000
    );
    port ( 
		clk			: in std_logic; 
        reset		: in std_logic;
		restart     : in std_logic;
		led_r       : out std_logic;
		led_b       : out std_logic;
		led_g       : out std_logic
     );
end tp_fsm;

architecture behavioral of tp_fsm is

    type state is (blanc, rouge, bleu, vert); 
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal resetn : std_logic:='0';
    signal end_count3 : std_logic:='0';-- detection de 3 cycles comptés
    signal cpt_raz: std_logic :='0'; -- remise à zér du compteur de cycle
    signal nb_cycle: std_logic_vector (1 downto 0); 
    signal led_drive: std_logic :='0';
     
	begin
	    cpt: entity work.counter_led(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clk,
                resetn => resetn,
                cpt_raz => cpt_raz,
                cpt_hold => '0',
                cpt_count => '1',
                out_nb_cycle => nb_cycle,
                out_led_drive => led_drive
           );

        process(clk,resetn)
        begin
            if resetn = '0' then   
                current_state <= blanc;
                --cpt_count <= '0';
             elsif rising_edge(clk) then
                --cpt_count <='1';
               if restart = '1' then   
                    current_state <= blanc;
                else
                    current_state <= next_state;
                 end if;
             end if;
        end process;
        
        process(current_state, end_count3)
        begin
           next_state <= current_state;
           case current_state is
                when blanc =>
                    if end_count3 ='1' then 
                        next_state <= rouge;
                     end if;
                 when rouge =>
                    if end_count3 ='1' then 
                        next_state <= bleu;
                    end if;
                when bleu =>
                    if end_count3 ='1' then 
                        next_state <= vert;
                    end if;                        
                 when vert =>
                    if end_count3 ='1' then 
                        next_state <= rouge;
                    end if;  
                 when others =>
                    next_state <= blanc;                     
            end case;
        
        end process;
      
	   resetn <= not reset;
	   end_count3 <= '1' when to_integer(unsigned(nb_cycle))= 3
	       else '0';
	   cpt_raz <= '1' when end_count3 = '1' or restart = '1'
	       else '0';
	   led_r <= led_drive when current_state = rouge or current_state = blanc
	       else '0';
	   led_b <= led_drive when current_state = bleu or current_state = blanc
	       else '0';
	   led_g <= led_drive when current_state = vert or current_state = blanc
	       else '0';
     
 
end behavioral;