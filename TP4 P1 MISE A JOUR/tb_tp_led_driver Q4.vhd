library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tp_led_driver is
end tb_tp_led_driver;

architecture behavioral of tb_tp_led_driver is

	signal reset      : std_logic := '0';
	signal clk         : std_logic := '0';
	signal btn     : std_logic := '0';
	signal led_r       : std_logic := '0';
	signal led_g       : std_logic := '0';
	signal nb_fail     : integer := 0;
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	constant cible : integer := 20;
	
	component tp_led_driver
		port ( 
            clk			: in std_logic; 
            reset		: in std_logic;
            btn			: in std_logic;
            led_r       : out std_logic;
            led_g       : out std_logic			
             );
	end component;

	begin
	dut: tp_led_driver
        port map (
            clk => clk,
            reset => reset,
            btn => btn,
            led_r   => led_r,
            led_g  => led_g
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;


	process
	begin        
	    reset <= '1';
		wait for (2*2*cible+cible)*period +1ns;     
	    if led_r ='0' and led_g = '0'  then
            report " PASS : TEST reset : la led est eteinte OK" severity note;
        else 
             report " FAIL : TEST reset : la led est eteinte KO " severity error;
             nb_fail <= nb_fail + 1;
        end if;
		wait for cible*period +1ns;  		
		-- demarrage avec bouton non appuye
		reset <= '0';
		wait for period +1ns; 
        if led_r ='1' and led_g = '0' then
            report " PASS : TEST demarrage apres reset avec btn non appuye : led en rouge OK" severity note;
        else 
             report "FAIL : TEST demarrage apres reset avec btn non appuye : led en rouge KO" severity error;
             nb_fail <= nb_fail + 1;
        end if;
		wait for 4*2*cible*period +1ns;     
		-- on appuie rur le bouton
        btn <= '1';
		wait for 1*period +1ns;     
        if led_r ='0' and led_g = '1' then
            report " PASS : TEST btn appuye : led en vert sur le premier cycle d'allumage OK" severity note;
        else 
             report "FAIL : TEST btn appuye : led en vert sur le premier cycle d'allumage KO" severity error;
             nb_fail <= nb_fail + 1;
        end if;
		wait for 4*2*cible*period +1ns;     
		-- on relache le bouton
        btn <= '0';
		wait for 1*period +1ns;     
        if led_r ='1' and led_g = '0' then
            report " PASS : TEST btn relache : led en rouge OK" severity note;
        else 
             report "PASS : TEST btn relache : led en rouge KO" severity error;
             nb_fail <= nb_fail + 1;
        end if;
		wait for 4*2*cible*period +1ns;     
        
	    report " Nombre de test FAIL : " & integer'image(nb_fail)  severity note; 
		wait;
	    
	end process;
	
	
end behavioral;