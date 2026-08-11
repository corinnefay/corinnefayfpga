library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_led_driver is
end tb_led_driver;

architecture behavioral of tb_led_driver is

	signal resetn      : std_logic := '0';
	signal clk         : std_logic := '0';
	signal update        : std_logic := '0';
	signal color_code : STD_LOGIC_VECTOR (1 downto 0) :="00";
	signal led_r       : std_logic := '0';
	signal led_b       : std_logic := '0';
	signal led_g       : std_logic := '0';
	signal nb_fail     : integer := 0;
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	constant cible : integer := 20;
	
	component led_driver
		port ( 
			clk			: in std_logic; 
			resetn : in STD_LOGIC;
			color_code : in STD_LOGIC_VECTOR (1 downto 0);
			update : in STD_LOGIC;
			led_r : out STD_LOGIC;
			led_g : out STD_LOGIC;
			led_b : out STD_LOGIC);
	end component;

	begin
	dut: led_driver
        port map (
            clk => clk,
            resetn => resetn,
			color_code => color_code,
            update  => update,
            led_r   => led_r,
            led_g   => led_g,
            led_b  => led_b
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;

	process
    begin   
    -- reset de debut     
       resetn <= '0';
       wait for (1*2*cible+cible)*period +1ns;     
       if led_r ='0' and led_b = '0' and led_g = '0'  then
           report " PASS : TEST reset : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST reset : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
        end if;		
    -- demarrage
       resetn <= '1';
       wait for cible*period +1ns; 
       if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST demarrage : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST demarrage : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;		
    -- led rouge
 	   wait for 2*2*cible*period;     
       color_code <="01";
       wait for 1ns; 
       if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST code led rouge sans update : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST code led rouge sans update : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '1';
       wait for 1ns; 
       if led_r ='1' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST update => 1 après code led rouge  : la led est rouge OK" severity note;
       else 
            report " FAIL : TEST update => 1  après code led rouge : la led est rouge KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '0';
       if led_r ='1' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST update => 0 pour code led rouge  : la led reste rouge OK" severity note;
       else 
            report " FAIL : TEST update => 0  pour  code led rouge : la led reste rouge KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for 2*2*cible*period;     
    -- led verte
 	   wait for 2*2*cible*period;     
       color_code <="10";
       wait for 1ns; 
       if led_r ='1' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST code led verte sans update : la led reste rouge OK" severity note;
       else 
            report " FAIL : TEST code led verte sans update : la led reste rouge KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '1';
       wait for 1ns; 
       if led_r ='0' and led_b = '0' and led_g = '1'  then
            report " PASS : TEST update => 1 après code led verte  : la led est verte OK" severity note;
       else 
            report " FAIL : TEST update => 1  après code led verte : la led est verte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '0';
       if led_r ='0' and led_b = '0' and led_g = '1'  then
            report " PASS : TEST update => 0 pour code led verte  : la led reste verte OK" severity note;
       else 
            report " FAIL : TEST update => 0  pour  code led verte : la led reste verte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for 2*2*cible*period;     
    -- led bleue
 	   wait for 2*2*cible*period;     
       color_code <="11";
       wait for 1ns; 
       if led_r ='0' and led_b = '0' and led_g = '1'  then
            report " PASS : TEST code led bleue sans update : la led reste verte OK" severity note;
       else 
            report " FAIL : TEST code led bleue sans update : la led reste verte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '1';
       wait for 1ns; 
       if led_r ='0' and led_b = '1' and led_g = '0'  then
            report " PASS : TEST update => 1 après code led bleue  : la led est bleue OK" severity note;
       else 
            report " FAIL : TEST update => 1  après code led bleue : la led est bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '0';
       if led_r ='0' and led_b = '1' and led_g = '0'  then
            report " PASS : TEST update => 0 pour code led bleue  : la led reste bleue OK" severity note;
       else 
            report " FAIL : TEST update => 0  pour  code led bleue : la led reste bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for 2*2*cible*period;     
    -- led off
 	   wait for 2*2*cible*period;     
       color_code <="00";
       wait for 1ns; 
       if led_r ='0' and led_b = '1' and led_g = '0'  then
            report " PASS : TEST code led off sans update : la led reste bleue OK" severity note;
       else 
            report " FAIL : TEST code led off sans update : la led reste bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '1';
       wait for 1ns; 
       if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST update => 1 après code led off  : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST update => 1  après code led off : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '0';
       if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST update => 0 pour code led off  : la led reste eteinte OK" severity note;
       else 
            report " FAIL : TEST update => 0  pour  code led pff : la led reste eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for 2*2*cible*period;     
    -- reset pendant que led rouge
 	   wait for 2*2*cible*period;     
       color_code <="01";
       wait for 1ns; 
       if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST code led rouge sans update : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST code led rouge sans update : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       update <= '1';
       wait for 1ns; 
       if led_r ='1' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST update => 1 après code led rouge  : la led est rouge OK" severity note;
       else 
            report " FAIL : TEST update => 1  après code led rouge : la led est rouge KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
	   wait for 2*2*cible*period;     
       resetn <= '0';
       wait for 1ns; 
       if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST resetn => 0  : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST resent => 0  : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for 2*2*cible*period;     
        report " Nombre de test FAIL : " & integer'image(nb_fail)  severity note; 
    wait;
    
	end process;
	
	
end behavioral;