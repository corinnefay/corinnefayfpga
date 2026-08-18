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
		--test_led0_b       : out std_logic;
		--test_led0_g       : out std_logic
     );
end top_led_driver;
architecture behavioral of top_led_driver is
    signal color_code : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal btn0_old : std_logic:='0';
    signal btn0_rise : std_logic := '0';
   -- signal in_led0_b : std_logic := '0';
    --signal in_led0_g : std_logic :='0';
	begin
	    led_driver: entity work.led_driver(behavioral)
            generic map (
                cible => cible 
            )
            port map ( 
                clk => clk,
                resetn => resetn,
				color_code => color_code,
				update => btn0_rise,
				led_r   => led0_r,
				led_g   => led0_g,
				led_b  => led0_b
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
        --led0_g <= in_led0_g;
        --led0_b <= in_led0_b;
        --test_led0_g <= in_led0_g;
        --test_led0_b <= in_led0_b;       
		color_code <= "10" when btn1 = '1' else "11";
end behavioral;