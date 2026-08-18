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
	signal nb_fail  : integer :=0;
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
       wait for 2*cible*period +1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
            report " PASS : TEST demarrage : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST demarrage : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
    -- appui sur btn0
   	   wait for 2*2*cible*period;     
       btn0 <= '1';
       wait for 2*period+1ns; 
       if led0_r ='0' and led0_b = '1' and led0_g = '0'  then
            report " PASS : TEST appui sur btn0 avec btn1 relaché : la led est bleue OK" severity note;
       else 
            report " FAIL : TEST appui sur btn0 avec btn1 relaché  : la led est bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
    -- appui sur btn1
   	   wait for 2*2*cible*period;     
       btn1 <= '1';
       wait for period+1ns; 
       if led0_r ='0' and led0_b = '1' and led0_g = '0'  then
            report " PASS : TEST appui sur btn1 avec btn0 appuyé : la led est bleue OK" severity note;
       else 
            report " FAIL : TEST appui sur btn1 avec btn0 appuyé  : la led est bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	  
    -- relache btn1
   	   wait for 2*2*cible*period;     
       btn1 <= '0';
       wait for period+1ns; 
       if led0_r ='0' and led0_b = '1' and led0_g = '0'  then
            report " PASS : TEST appui sur btn1 avec btn0 appuyé : la led est bleue OK" severity note;
       else 
            report " FAIL : TEST appui sur btn1 avec btn0 appuyé  : la led est bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	         
   -- relache btn0
   	   wait for 2*2*cible*period;     
       btn0 <= '0';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '1' and led0_g = '0'  then
            report " PASS : TEST relache btn0 avec btn1 relaché : la led reste bleue OK" severity note;
       else 
            report " FAIL : TEST relache btn0 avec btn1 relaché  : la led reste bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
   -- appui sur btn1
   	   wait for 2*2*cible*period;     
       btn1 <= '1';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '1' and led0_g = '0'  then
            report " PASS : TEST appui sur btn1 avec btn0 relaché : la led reste bleue OK" severity note;
       else 
            report " FAIL : TEST appui sur btn1 avec btn0 relaché  : la led reste bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	       
    -- appui sur btn0
   	   wait for 2*2*cible*period;     
       btn0 <= '1';
       wait for 2*period; 
       if led0_r ='0' and led0_b = '0' and led0_g = '1'  then
            report " PASS : TEST appui sur btn0 avec btn1 appuyé : la led est verte OK" severity note;
       else 
            report " FAIL : TEST appui sur btn0 avec btn1 appuyé  : la led est verte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	      
   -- relache btn0
       wait for 2*2*cible*period;     
       btn0 <= '0';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '1'  then
            report " PASS : TEST relache btn0 avec btn1 appuyé : la led reste verte OK" severity note;
       else 
            report " FAIL : TEST relache btn0 avec btn1 appuyé  : la led reste verte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
   -- relache btn1
   	   wait for 2*2*cible*period;     
       btn1 <= '0';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '1'  then
            report " PASS : TEST relache btn1 avec btn0 relaché : la led reste verte OK" severity note;
       else 
            report " FAIL : TEST relache btn1 avec btn0 relaché  : la led reste verte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	
    -- appui sur btn0
   	   wait for 2*2*cible*period;     
       btn0 <= '1';
       wait for 1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '1'  then
            report " PASS : TEST appui sur btn0 avec avec btn1 relaché : la led est bleue OK" severity note;
       else 
            report " FAIL : TEST appui sur btn0 avec avec btn1 relaché  : la led est bleue KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;	  
    -- resert pendant que la led est bleue         
 	   wait for 2*2*cible*period;     
       resetn <= '0';      
       wait for 1ns; 
       if led0_r ='0' and led0_b = '0' and led0_g = '0'  then
            report " PASS : TEST resetn => 0  : la led est eteinte OK" severity note;
       else 
            report " FAIL : TEST resent => 0  : la led est eteinte KO " severity error;
            nb_fail <= nb_fail + 1;
       end if;      
 
		report " Nombre de test FAIL : " & integer'image(nb_fail)  severity note; 
		wait;
	    
	end process;
	
	
end behavioral;