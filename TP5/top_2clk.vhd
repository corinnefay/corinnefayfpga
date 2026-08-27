library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity top_2clk is
    generic (
        cible : integer := 100000000
    );
    port ( 
		clka			: in std_logic; 
		clkb			: in std_logic; 
        resetn		: in std_logic;
		led0_r       : out std_logic;
		led0_b       : out std_logic;
		led0_g       : out std_logic;
		led1_r       : out std_logic;
		led1_b       : out std_logic;
		led1_g       : out std_logic
     );
end top_2clk;

architecture behavioral of top_2clk is
    type state is (rouge, bleu, vert); 
    signal current_state : state; 
    signal next_state : state; 
    signal color_code : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal end_cycle_onoff_a : std_logic:='0';
    signal end_cycle_offon_a : std_logic:='0';
    signal end_cycle_onoff_b : std_logic:='0';
    signal end_cycle_offon_b : std_logic:='0';
    signal nb_cycle : unsigned (3 downto 0) := (others => '0');
    signal end_count10 : std_logic:='0';
    signal led_r : std_logic:='0';
    signal led_b : std_logic:='0';
    signal led_g : std_logic:='0';
   

    begin
	    led_driver_a: entity work.led_driver(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clka,
                resetn => resetn,
				color_code => color_code,
				update => end_cycle_offon_a,
                end_cycle_offon => end_cycle_offon_a,
                end_cycle_onoff => end_cycle_onoff_a,
				led_r => led0_r,
				led_g => led0_g,
				led_b => led0_b
            );
        led_driver_b: entity work.led_driver(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clkb,
                resetn => resetn,
				color_code => color_code,
				update => end_cycle_offon_a,
                end_cycle_offon => end_cycle_offon_b,
                end_cycle_onoff => end_cycle_onoff_b,
				led_r => led1_r,
				led_g => led1_g,
				led_b => led1_b
            );    
        process(clka,resetn)
        begin
            if resetn = '0' then   
                nb_cycle <= (others => '0');
            elsif rising_edge(clka) then
                end_count10<= '0';
                if end_cycle_onoff_a = '1' then 
                    if nb_cycle = 9 then 
                        end_count10 <= '1'; 
                        nb_cycle <= "0000";
                    else                    
                        nb_cycle <= nb_cycle +1;
                    end if;
                end if; 
            end if;
        end process;
        
        -- color fsm
        process ( resetn, clka)
        begin
            if resetn = '0' then   
                current_state <= rouge;
            elsif rising_edge(clka) then
                    current_state <= next_state;
            end if;
        end process;
        process (current_state, end_count10)
        begin
            next_state <= current_state;
            case current_state is
                when rouge =>
                    if end_count10 = '1' then 
                        next_state <= bleu;
                     end if;
                when bleu =>
                    if end_count10 = '1' then 
                        next_state <= vert;
                    end if;
                when vert =>
                    if end_count10 = '1' then 
                        next_state <= rouge;
                    end if; 
             end case;
        end process;
        color_code <=   "01" when current_state = rouge else
                        "11" when current_state = bleu else
                        "10" when current_state = vert else
                        "00";
    end behavioral;