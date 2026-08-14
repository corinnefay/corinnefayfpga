library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_led_driver is
end tb_top_led_driver;

architecture behavioral of tb_top_led_driver is

	signal clk			: std_logic:= '0';
	signal resetn		: std_logic:= '0';
	signal btn0        : std_logic:= '0';
	signal btn1       : std_logic:= '0';
	signal led0_r       : std_logic:= '0';
	signal led0_b       : std_logic:= '0';
	signal led0_g       : std_logic:= '0';
	signal end_read       : std_logic:= '0';
	--declartion du tbleau de sequence de 13 éléments
	type btn_sequence is array(0 to 12) of std_logic;
	constant btn1_sequence : btn_sequence :=(
	   '1', -- vert
	   '0', -- bleu
	   '1', -- vert
	   '0', -- bleu
	   '0', -- bleu
	   '1', -- vert
	   '0', -- bleu
	   '1', -- vert
	   '1', -- vert
	   '0', -- bleu
	   '1', -- vert
	   '0', -- bleu
	   '1' -- vert
	   );
	-- il faut une variable de comptage pour chaque process 
	signal nb_fail  : integer :=0;
	signal nb_fail2  : integer :=0;	
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	constant cible : integer := 20;
	
	component top_led_driver
		generic (
			cible : integer := 20
		);
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
			btn0        : in std_logic;
			btn1       : in std_logic;
			led0_r       : out std_logic;
			led0_b       : out std_logic;
			led0_g       : out std_logic
		 );
	end component;

	begin
	dut: top_led_driver
        port map (
            clk => clk,
            resetn => resetn,
			btn0 => btn0,
            btn1  => btn1,
            led0_r   => led0_r,
            led0_g   => led0_g,
            led0_b  => led0_b
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
       if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
           report " PASS : TEST reset : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST reset : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
        end if;		
    -- demarrage
       resetn <= '1';
       wait for cible*period +1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
            report " PASS : TEST demarrage : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST demarrage : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for cible*period +1ns; 
    -- chargement de la fifo
	    -- on boucle sur tous les éléments du tableau de séquence 
        for i in btn1_sequence'range loop
            wait for period;   
            btn1 <= btn1_sequence(i);
            wait for period;   
            btn0 <= '1';
            wait for period;   
            btn0 <= '0';
        end loop;
        
    -- attente de la fin de lecture de la fifo pour lancer un reset
    wait until rising_edge(end_read);   
       resetn <= '0';
       wait for period +1ns;     
       if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
           report " PASS : TEST reset : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST reset : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
        end if;
	 -- redemarrage
     wait for 2*cible*period +1ns; 
       resetn <= '1';
       wait for cible*period +1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
            report " PASS : TEST demarrage : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST demarrage : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
       wait for 2*cible*period +1ns; 
    
    report " Nombre de test FAIL : " & integer'image(nb_fail+nb_fail2)  severity note; 
    wait;
    end process;
    -- nouveau process pour verifer la sortie de la fifo ( en verifiant la couleur de la LED)
	process
	begin    
	   -- on attend le premier chargement de couleur de LED ( vert selon la séquendé d&finie 
	   wait until rising_edge(led0_g); 
	   -- on boucle sur tous les éléments du tableau de séquence 
        for j in btn1_sequence'range loop
           if led0_r ='0' and led0_b = '1' and led0_g = '0' then
                if btn1_sequence(j)= '0' then 
                    report " PASS LED bleue allumée pour le cycle "  & integer'image(j) severity note;
                else 
                    report " FAIL  LED bleue eteinte pour le cycle "  & integer'image(j) severity note;
                    nb_fail2 <= nb_fail2+1;
                end if;
           elsif led0_r ='0' and led0_b = '0' and led0_g = '1' then
                if btn1_sequence(j)= '1' then 
                    report " PASS LED verte allumée pour le cycle "  & integer'image(j) severity note;
                else 
                    report " FAIL  LED verte eteinte pour le cycle "  & integer'image(j) severity note;
                    nb_fail2 <= nb_fail2+1;
                end if;          
           elsif led0_r ='1' and led0_b = '0' and led0_g = '0' then
                report " FAIL LED rouge allumée pour le cycle "  & integer'image(j) severity note;
                nb_fail2 <= nb_fail2+1;
           else
               report " FAIL error pour le cycle "  & integer'image(j) severity note;
                nb_fail2 <= nb_fail2+1;
           end if;	
           wait for 2*cible*period+1ns;   
        end loop;
       -- on signale que la lecture est terminée
       wait for 2*2*cible*period+1ns; 
       end_read <='1';  
        wait;
	end process;
	
	
end behavioral;