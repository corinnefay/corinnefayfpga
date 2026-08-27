library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_2clk_long is
end tb_top_2clk_long;

architecture behavioral of tb_top_2clk_long is

	signal resetn      : std_logic := '0';
	signal resetn1      : std_logic := '0';
	signal clka         : std_logic := '0';
	signal clkb         : std_logic := '0';
	signal led0_r       : std_logic := '0';
	signal led0_b       : std_logic := '0';
	signal led0_g       : std_logic := '0';
	signal led1_r       : std_logic := '0';
	signal led1_b       : std_logic := '0';
	signal led1_g       : std_logic := '0';
	signal nb_fail1     : integer := 0;
	signal nb_fail2     : integer := 0;
	signal nb_fail3     : integer := 0;
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hpa : time := 2 ns;      --demi periode de 2ns
	constant perioda : time := 2*hpa;  --periode de 4ns, soit une frequence de 250MHz
	constant hpb : time := 10 ns;      --demi periode de 10ns
	constant periodb : time := 2*hpb;  --periode de 20ns, soit une frequence de 50MHz
	constant cible : integer := 60;
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

	component top_2clk_long is
    generic (
        cible : integer := cible
    );
    port (
		    clka   : in std_logic; 
			clkb   : in std_logic;
			resetn : in STD_LOGIC;
			led0_r : out STD_LOGIC;
			led0_g : out STD_LOGIC;
			led0_b : out STD_LOGIC;
			led1_r : out STD_LOGIC;
			led1_g : out STD_LOGIC;
			led1_b : out STD_LOGIC);
	end component;

	begin
	dut: top_2clk_long
        port map (
            clka => clka,
            clkb => clkb,
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
		wait for hpa;
		clka <= not clka;
	end process;
	process
    begin
		wait for hpb;
		clkb <= not clkb;
	end process;

	process
    begin   
    -- reset de debut     
       resetn <= '0';
 
     -- le demarrage sera lance dans le process de led1 car c'est lui le plus lent 
     -- les autres process attendent le resetn pour continuer
        wait until rising_edge (resetn1);       
        resetn <= '1';
           
    -- on attend un peu plus de 7 cycle de 10 clignotements de led0     
 	    wait for 72*2*cible*perioda;   
    -- reset   
       resetn <= '0';

    -- le demarrage sera lance dans le process de led1 car c'est lui le plus lent 
    -- les autres process attndent le resetn pour continuer
        wait until rising_edge (resetn1);       
        resetn <= '1';
        
        wait for 3*2*cible*perioda;     
 	      
        nb_fail1 <= nb_fail1 + nb_fail2 + nb_fail3;
        wait for 1ns;        
        report " Nombre de test FAIL : " & integer'image(nb_fail1)  severity note; 
        wait;
	end process;
    -- test sur led0
	process
        variable nb_fail2i     : integer := 0;
        variable nb_allum_a    : integer := 0;
    begin
       wait for 2*cible*perioda +1ns;     
       if led0_r ='0' and led0_b = '0' and led0_g = '0' then
           report " PASS : TEST reset : led0 est eteinte OK" severity note;
       else 
            report " FAIL : TEST reset :led0 est eteinte KO " severity error;
            nb_fail2 <= nb_fail2 + 1;
       end if;	 
        -- on attend la fin du reset 
        wait until rising_edge (resetn); 
        wait for 1ns; 
        if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
            report " PASS : TEST demarrage : led0 est eteinte OK" severity note;
        else 
            report " FAIL : TEST demarrage : led0 est eteinte KO " severity error;
            nb_fail2 <= nb_fail2 + 1;
        end if;	
        -- on attend le premier allumage de la led0  
    	wait until rising_edge(led0_r) for perioda; 
    	if led0_r = '0' then 
            report " FAIL  LED0 ne s'allume pas au demarrage " severity note;
            nb_fail2 <= nb_fail2+1;
    	else 
            wait for 1ns;
           -- on boucle sur tous les elements du tableau de sequence 
            for j in color_sequence'range loop
                for k in 0 to 9 loop
                    if led0_r ='0' and led0_b = '1' and led0_g = '0' then
                            if color_sequence(j)= bleu then 
                                nb_allum_a := nb_allum_a +1;
                            else
                                --report " FAIL  LED0 bleue eteinte pour le cycle "  & integer'image(k) severity note;
                                nb_fail2i := nb_fail2i+1;
                            end if;
                    elsif led0_r ='0' and led0_b = '0' and led0_g = '1' then
                            if color_sequence(j)= vert then
                                nb_allum_a := nb_allum_a +1;
                            else 
                                --report " FAIL  LED0 verte eteinte pour le cycle "  & integer'image(k) severity note;
                                nb_fail2i := nb_fail2i+1;
                            end if;          
                    elsif led0_r ='1' and led0_b = '0' and led0_g = '0' then
                            if color_sequence(j)= rouge then 
                                nb_allum_a := nb_allum_a +1;
                            else
                                --report " FAIL  LED0 rouge eteinte pour le cycle "  & integer'image(k) severity note;
                                nb_fail2i := nb_fail2i+1;
                            end if; 
                    else
                        --report " FAIL  LED0 error pour le cycle "  & integer'image(k) severity note;
                            nb_fail2i := nb_fail2i+1;
                    end if;	
                    wait for 2*cible*perioda; 
                end loop;
                if nb_fail2i = 0 and nb_allum_a= 10 then 
                    report " PASS LED0 allumee " & integer'image(nb_allum_a) & "  fois pour la sequence "  & color_led_type'image(color_sequence(j)) severity note;
                else 
                    report " FAIL LED0 allumee " & integer'image(nb_allum_a) & " fois pour la sequence "  & color_led_type'image(color_sequence(j)) severity note;
                    nb_fail2 <= nb_fail2+1;
                end if;
                nb_fail2i := 0;
                nb_allum_a := 0;
            end loop;
         end if;
        -- on attend le prochain reset  
        wait until falling_edge (resetn);
        wait for 1ns;     
        if led0_r ='0' and led0_b = '0' and led0_g = '0' then
           report " PASS : TEST reset : la led0 est eteinte OK" severity note;
        else 
            report " FAIL : TEST reset : la led0 est eteinte KO " severity error;
            nb_fail2 <= nb_fail2 + 1;
        end if;		
        -- on attend le prochain demarrage
        wait until rising_edge (resetn);
        wait for 1ns; 
        if led0_r ='0' and led0_b = '0' and led0_g = '0' then
            report " PASS : TEST demarrage : la led0 est eteinte OK" severity note;
        else 
            report " FAIL : TEST demarrage : la led0 est eteinte KO " severity error;
            nb_fail2 <= nb_fail2 + 1;
        end if;	
        wait for perioda ; 
        if led0_r ='1' and led0_b = '0' and led0_g = '0' then
            report " PASS : TEST demarrage : la led0 est rouge apres 1 periode clka OK" severity note;
        else 
            report " FAIL : TEST demarrage : la led0 est rouge apres 1 periode clka KO " severity error;
            nb_fail2 <= nb_fail2 + 1;
        end if;	      
        wait;
    end process;
    
	-- test sur led1
	process
        variable nb_fail3i    : integer := 0;
        variable nb_allum_b   : integer := 0;
    begin
        wait for 2*cible*periodb +1ns;     
        if led1_r ='0' and led1_b = '0' and led1_g = '0' then
            report " PASS : TEST reset : led1 est eteinte OK" severity note;
        else 
            report " FAIL : TEST reset :led1 est eteinte KO " severity error;
            nb_fail3 <= nb_fail3 + 1;
        end if;	 
        wait for periodb +1ns;     
        -- le reset est lance ici car c'est le proces le plus lent. 
        -- les autres process attendent le resetn pour continuer
        resetn1 <= '1';
        wait for 1ns; 
        resetn1 <= '0';
        
        if led1_r ='0' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : led1 est eteinte OK" severity note;
        else 
            report " FAIL : TEST demarrage : led1 est eteinte KO " severity error;
            nb_fail3 <= nb_fail3 + 1;
        end if;	
        -- on attend le premier allumage de la led1  qui doit commencer ds la premiere periode de clkb
    	wait until rising_edge(led1_r) for periodb; 
    	if led1_r = '0' then 
            report " FAIL  LED1 ne s'allume pas au demarrage " severity note;
            nb_fail3 <= nb_fail3+1;
    	else 
            wait for 1ns;
           -- on boucle sur tous les elements du tableau de sequence 
            for l in color_sequence'range loop
                for m in 0 to 1 loop
                    if led1_r ='0' and led1_b = '1' and led1_g = '0' then
                            if color_sequence(l)= bleu then 
                                nb_allum_b := nb_allum_b +1;
                            else
                                --report " FAIL  LED1 bleue eteinte pour le cycle "  & integer'image(k) severity note;
                                nb_fail3i := nb_fail3i+1;
                            end if;
                    elsif led1_r ='0' and led1_b = '0' and led1_g = '1' then
                            if color_sequence(l)= vert then 
                                nb_allum_b := nb_allum_b +1;
                            else
                                --report " FAIL  LED1 verte eteinte pour le cycle "  & integer'image(k) severity note;
                                nb_fail3i := nb_fail3i+1;
                            end if;          
                    elsif led1_r ='1' and led1_b = '0' and led1_g = '0' then
                            if color_sequence(l)= rouge then 
                                nb_allum_b := nb_allum_b +1;
                            else
                                --report " FAIL  LED1 rouge eteinte pour le cycle "  & integer'image(k) severity note;
                                nb_fail3i := nb_fail3i+1;
                            end if; 
                    else
                        --report " FAIL  LED1 error pour le cycle "  & integer'image(k) severity note;
                            nb_fail3i := nb_fail3i+1;
                    end if;	
                    wait for 2*cible*periodb; 
                end loop;
                if nb_fail3i = 0 and nb_allum_b = 2 then 
                    report " PASS LED1 allumee 2 fois pour la sequence "  & color_led_type'image(color_sequence(l)) severity note;
                else 
                    report " FAIL LED1 allumee " & integer'image(nb_allum_b) & " fois pour la sequence "  & color_led_type'image(color_sequence(l)) severity note;
                    nb_fail3 <= nb_fail3+1;
                end if;
                nb_fail3i := 0;
                nb_allum_b := 0;
            end loop;
        end if;
        -- on attend le prochain reset  
        wait until falling_edge (resetn);
        wait for 1ns;     
        if led1_r ='0' and led1_b = '0' and led1_g = '0' then
           report " PASS : TEST reset : la led1 est eteinte OK" severity note;
        else 
            report " FAIL : TEST reset : la led1 est eteinte KO " severity error;
            nb_fail3 <= nb_fail3 + 1;
        end if;		
        -- le reset est lance ici car c'est le proces le plus lent. 
        -- les autres process attendent le resetn pour continuer
        wait for 3*cible*periodb;
        resetn1 <= '1';
        wait for 1ns; 
        resetn1 <= '0';
        if led1_r ='0' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : la led1 est eteinte OK" severity note;
        else 
            report " FAIL : TEST demarrage : la led1 est eteinte KO " severity error;
            nb_fail3 <= nb_fail3 + 1;
        end if;	
        wait for periodb ; 
        if led1_r ='1' and led1_b = '0' and led1_g = '0'  then
            report " PASS : TEST demarrage : la led1 est rouge apres 1 periode clkb OK" severity note;
        else 
            report " FAIL : TEST demarrage : la led1 est rouge apres 1 periode clkb KO " severity error;
            nb_fail3 <= nb_fail3 + 1;
        end if;	   
        wait;
    end process;   
end behavioral;