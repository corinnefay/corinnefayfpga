library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity top_1clk is
    generic (
        cible : integer := 100000000
    );
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
		led0_r       : out std_logic;
		led0_b       : out std_logic;
		led0_g       : out std_logic;
		led1_r       : out std_logic;
		led1_b       : out std_logic;
		led1_g       : out std_logic
     );
end top_1clk;

architecture behavioral of top_1clk is
    type state is (rouge, bleu, vert); 
    signal current_state : state; 
    signal next_state : state; 
    signal color_code : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal end_cycle_onoff : std_logic:='0';
    signal end_cycle_offon : std_logic:='0';
    signal nb_cycle : unsigned (3 downto 0) := (others => '0');
    signal end_count10 : std_logic:='0';
    signal update : std_logic:='0';
    signal led_r : std_logic:='0';
    signal led_b : std_logic:='0';
    signal led_g : std_logic:='0';

    begin
	    led_driver: entity work.led_driver(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clk,
                resetn => resetn,
				color_code => color_code,
				update => end_cycle_offon,
                end_cycle_offon => end_cycle_offon,
                end_cycle_onoff => end_cycle_onoff,
				led_r => led_r,
				led_g => led_g,
				led_b => led_b
            );
        process(clk,resetn)
        begin
            if resetn = '0' then   
                nb_cycle <= (others => '0');
            elsif rising_edge(clk) then
                end_count10<= '0';
                if end_cycle_onoff = '1' then 
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
        process ( resetn, clk)
        begin
            if resetn = '0' then   
                current_state <= rouge;
            elsif rising_edge(clk) then
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
        led0_r <= led_r;
        led0_g <= led_g;
        led0_b <= led_b;
        led1_r <= led_r;
        led1_g <= led_g;
        led1_b <= led_b;
end behavioral;