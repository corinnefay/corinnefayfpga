library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_1clk is
end tb_top_1clk;

architecture behavioral of tb_top_1clk is

	signal resetn      : std_logic := '0';
	signal clk         : std_logic := '0';
	signal led0_r       : std_logic := '0';
	signal led0_b       : std_logic := '0';
	signal led0_g       : std_logic := '0';
	signal led1_r       : std_logic := '0';
	signal led1_b       : std_logic := '0';
	signal led1_g       : std_logic := '0';
	signal nb_fail1     : integer := 0;
	signal nb_fail2     : integer := 0;
	signal nb_fail3     : integer := 0;
	signal nb_fail2i     : integer := 0;
	signal nb_fail3i    : integer := 0;
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	constant cible : integer := 20;
	-- definition d'une sequence de couleur pour les leds afin simplifier le test bench
    type color_led_type is (rouge, bleu, vert);
    type color_sequence_type is array (0 to 6) of color_led_type;
    constant color_sequence : color_sequence_type := (
        rouge,
        bleu,
        vert,
        rouge,
        bleu,
        vert,
        rouge
       );    

	component top_1clk is
    generic (
        cible : integer := 20
    );
    port (
		    clk			: in std_logic; 
			resetn : in STD_LOGIC;
			led0_r : out STD_LOGIC;
			led0_g : out STD_LOGIC;
			led0_b : out STD_LOGIC;
			led1_r : out STD_LOGIC;
			led1_g : out STD_LOGIC;
			led1_b : out STD_LOGIC);
	end component;

	begin
	dut: top_1clk
        port map (
            clk => clk,
            resetn => resetn,
			led0_r => led0_r,
			led0_g => led0_g,
			led0_b => led0_b,
			led1_r => led1_r,
			led1_g => led1_g,
			led1_b => led1_b
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
       wait for 2*cible*period +1ns;     
       if led0_r ='0' and led0_b = '0' and led0_g = '0' and led1_r ='0' and led1_b = '0' and led1_g = '0' then
           report " PASS : TEST reset : les leds led0 et led1 sont eteinte OK" severity note;
       else 
            report " FAIL : TEST reset :les leds led0 et led1 sont eteinte KO " severity error;
            nb_fail1 <= nb_fail1 + 1;
        end if;		
    -- demarrage
       resetn <= '1';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '0' and led1_r ='0' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : les leds led0 et led1 sont eteinte OK" severity note;
       else 
            report " FAIL : TEST demarrage : les leds led0 et led1 sont eteinte KO " severity error;
            nb_fail1 <= nb_fail1 + 1;
       end if;	
       wait for period ; 
       if led0_r ='1' and led0_b = '0' and led0_g = '0' and led1_r ='1' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : les leds led0 et led1 sont rouge apres 1 periode OK" severity note;
       else 
            report " FAIL : TEST demarrage : les leds led0 et led1 sont rouge apres 1 periode KO " severity error;
            nb_fail1 <= nb_fail1 + 1;
       end if;	      
       
 	    wait for 72*2*cible*period;   
    -- reset   
       resetn <= '0';
       wait for 2*cible*period +1ns;     
       if led0_r ='0' and led0_b = '0' and led0_g = '0' and led1_r ='0' and led1_b = '0' and led1_g = '0'  then
           report " PASS : TEST reset : les leds led0 et led1 sont eteinte OK" severity note;
       else 
            report " FAIL : TEST reset : les leds led0 et led1 sont eteinte KO " severity error;
            nb_fail1 <= nb_fail1 + 1;
        end if;		
        wait for 3*cible*period +1ns;     
    -- demarrage
       resetn <= '1';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '0' and led1_r ='0' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : les leds led0 et led1 sont eteinte OK" severity note;
       else 
            report " FAIL : TEST demarrage : les leds led0 et led1 sont eteinte KO " severity error;
            nb_fail1 <= nb_fail1 + 1;
       end if;	
        wait for period ; 
       if led0_r ='1' and led0_b = '0' and led0_g = '0' and led1_r ='1' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : les leds led0 et led1 sont rouge apres 1 periode OK" severity note;
       else 
            report " FAIL : TEST demarrage : les leds led0 et led1 sont rouge apres 1 periode KO " severity error;
            nb_fail1 <= nb_fail1 + 1;
       end if;	      
        wait for 10*2*cible*period +1ns;     
 	      
        nb_fail1 <= nb_fail1 + nb_fail2 + nb_fail3;
        report " Nombre de test FAIL : " & integer'image(nb_fail1)  severity note; 
        wait;
	end process;
    -- test sur led0
	process
    begin
    	wait until rising_edge(led0_r); 
    	wait for 1ns;
	   -- on boucle sur tous les elements du tableau de sequence 
        for j in color_sequence'range loop
            for k in 0 to 9 loop
                if led0_r ='0' and led0_b = '1' and led0_g = '0' then
                        if color_sequence(j)/= bleu then 
                            --report " FAIL  LED0 bleue eteinte pour le cycle "  & integer'image(k) severity note;
                            nb_fail2i <= nb_fail2i+1;
                        end if;
                elsif led0_r ='0' and led0_b = '0' and led0_g = '1' then
                        if color_sequence(j)/= vert then 
                            --report " FAIL  LED0 verte eteinte pour le cycle "  & integer'image(k) severity note;
                            nb_fail2i <= nb_fail2i+1;
                        end if;          
                elsif led0_r ='1' and led0_b = '0' and led0_g = '0' then
                        if color_sequence(j)/= rouge then 
                            --report " FAIL  LED0 rouge eteinte pour le cycle "  & integer'image(k) severity note;
                            nb_fail2i <= nb_fail2i+1;
                        end if; 
                else
                    --report " FAIL  LED0 error pour le cycle "  & integer'image(k) severity note;
                        nb_fail2i <= nb_fail2i+1;
                end if;	
                wait for 2*cible*period; 
            end loop;
            if nb_fail2i = 0 then 
                report " PASS LED0 allumee 10 fois pour la sequence "  & color_led_type'image(color_sequence(j)) severity note;
            else 
                report " FAIL LED0 allumee 10 fois pour la sequence "  & color_led_type'image(color_sequence(j)) severity note;
                nb_fail2 <= nb_fail2+1;
            end if;
            nb_fail2i <= 0;
        end loop;
    end process;
	-- test sur led1
	process
    begin
    	wait until rising_edge(led1_r); 
    	wait for 1ns;
	   -- on boucle sur tous les elements du tableau de sequence 
        for j in color_sequence'range loop
            for k in 0 to 9 loop
                if led1_r ='0' and led1_b = '1' and led1_g = '0' then
                        if color_sequence(j)/= bleu then 
                            --report " FAIL  LED0 bleue eteinte pour le cycle "  & integer'image(k) severity note;
                            nb_fail3i <= nb_fail3i+1;
                        end if;
                elsif led1_r ='0' and led1_b = '0' and led1_g = '1' then
                        if color_sequence(j)/= vert then 
                            --report " FAIL  LED0 verte eteinte pour le cycle "  & integer'image(k) severity note;
                            nb_fail3i <= nb_fail3i+1;
                        end if;          
                elsif led1_r ='1' and led1_b = '0' and led1_g = '0' then
                        if color_sequence(j)/= rouge then 
                            --report " FAIL  LED0 rouge eteinte pour le cycle "  & integer'image(k) severity note;
                            nb_fail3i <= nb_fail3i+1;
                        end if; 
                else
                    --report " FAIL  LED0 error pour le cycle "  & integer'image(k) severity note;
                        nb_fail3i <= nb_fail3i+1;
                end if;	
                wait for 2*cible*period; 
            end loop;
            if nb_fail3i = 0 then 
                report " PASS LED1 allumee 10 fois pour la sequence "  & color_led_type'image(color_sequence(j)) severity note;
            else 
                report " FAIL LED1 allumee 10 fois pour la sequence "  & color_led_type'image(color_sequence(j)) severity note;
                nb_fail3 <= nb_fail3+1;
            end if;
            nb_fail3i <= 0;
        end loop;
    end process;   
end behavioral;