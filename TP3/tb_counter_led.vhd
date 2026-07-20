
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_counter_led is
end tb_counter_led;

architecture Behavioral of tb_counter_led is
    signal clk         : std_logic := '0';
    signal resetn      : std_logic := '0';
    signal cpt_raz     : std_logic := '0';    
    signal cpt_hold    : std_logic := '0';    
    signal cpt_count   : std_logic := '0';
    signal nb_cycle   : std_logic_vector(1 downto 0 ) := (others => '0'); 
    signal led_drive   : std_logic := '0';  
    signal nb_fail     : integer := 0; 
    -- Les constantes suivantes permette de defparaminir la frequence de l horloge 
    constant hp : time := 5 ns;     
	constant period : time := 2*hp; 
	
    constant cible : integer := 20;
	
   component counter_led 
	   generic(
	       cible: integer
	       );
        port ( 
           clk      : in std_logic;
           resetn   : in std_logic;
           cpt_raz  : in std_logic;
           cpt_hold : in std_logic;
           cpt_count : in std_logic;
           out_nb_cycle : out std_logic_vector(1 downto 0 );
           out_led_drive : out std_logic 
           );
   end component;
	
begin
   uut: counter_led
   	   generic map(
	       cible => cible
	       )
        port map(
         clk => clk,       
         resetn => resetn,      
         cpt_raz => cpt_raz,
         cpt_hold => cpt_hold,
         cpt_count => cpt_count,
         out_nb_cycle => nb_cycle,
         out_led_drive => led_drive
         );
 	--horloge
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;
         
    process
    begin
        wait for 20ns;
        -- TEST reset
        resetn <='0';
        wait for 1*period + 1ns; 
        if nb_cycle ="00" and led_drive = '0' then
            report " PASS : TEST RESET (resetn = 0) >>  nb_cycle =00 and led_drive = 0 OK  " severity note;
        else 
             report " FAIL : TEST RESET (resetn = 0) >>  nb_cycle =00 and led_drive = 0 OK " severity error;
             nb_fail <= nb_fail + 1;
        end if;
        wait for 3*period + 1ns; 
        -- TEST levée du reset
        resetn <='1';
        wait for (2*2*cible+cible)*period -1ns;  
        if nb_cycle ="00" and led_drive = '1' then
            report " PASS : TEST LEVEE RESET (resetn = 1) >>  nb_cycle =00 and led_drive = 1 après 2.5 cycle de comptage OK  " severity note;
        else 
             report " FAIL : TEST LEVEE RESET (resetn = 1) >>  nb_cycle =00 and led_drive = 1 après 2.5 cycle de comptage KO " severity error;
             nb_fail <= nb_fail + 1;
        end if;
        wait for 3*2*cible*period+1ns; 
        -- TEST debut de comptage de cycle il va reprendre avec la led allumée en debut de cycle  
        cpt_count <='1';
        ----attente d'un comptage jusqu'a 3 et led allumée
        wait for (3*2*cible)*period+1ns;  
        if nb_cycle ="11" and led_drive = '1' then
            report " PASS : Comptage jusqu'a 3 >>  nb_cycle =11 and led_drive = 1 OK" severity note;
        else 
             report " FAIL : Comptage jusqu'a 3>>  nb_cycle =11 and led_drive = 1 KO" severity error;
             nb_fail <= nb_fail + 1;
       end if;
        wait for 2*2*cible*period+30ns;  
        -- TEST remise a zéro du cycle en cours de comptage avec une LED allumée
        cpt_raz <= '1';
        wait for period + 1ns; 
         if nb_cycle ="00"  then
            report " PASS : TEST RAZ (cpt_raz = 1) >>  nb_cycle =00  OK" severity note;
        else 
             report " FAIL : TEST RAZ(cpt_raz = 1) >>  nb_cycle =00  KO" severity error;
            nb_fail <= nb_fail + 1;
        end if;
        -- TEST reprise du comptage après remise a zéro
        wait for 2*2*cible*period+1ns;  
        cpt_raz <= '0';
        wait for 2*2*cible*period+1ns;  
        if nb_cycle ="10"  then
            report " PASS : Comptage jusqu'a 2 apres RAZ >>  nb_cycle =10  OK"  severity note;
        else 
             report " FAIL : Comptage jusqu'a 2 apres RAZ >>  nb_cycle =10  KO" severity error;
             nb_fail <= nb_fail + 1;
        end if;
        -- TEST maintien de la valeur de compteur 
        wait for 1*2*cible*period+1ns;  
         cpt_hold <= '1';
        wait for 1*2*cible*period+1ns;  
        if nb_cycle ="11"  then
            report " PASS : TEST HOLD >>  nb_cycle =11  OK" severity note;
        else 
             report " FAIL : TEST HOLD >>  nb_cycle =11 K0"  severity error;
             nb_fail <= nb_fail + 1;
        end if;
        wait for 3*period + 2ns; 
        -- test reprise de comptage après hold
        cpt_hold <= '0';
        wait for 2*2*cible*period+1ns;  
        if nb_cycle ="01" then
            report " PASS : Comptage jusqu'a 1 apres HOLD" severity note;
        else 
             report " FAIL : Comptage jusqu'a 1 apres HOLD" severity error;
             nb_fail <= nb_fail + 1;
       end if;
        wait for 2*2*cible*period+1ns;  
       -- test de priorité des commandes 
        cpt_hold <= '1';
        wait for 2*2*cible*period+1ns;  
        if nb_cycle ="11" then
            report " PASS : Comptage bloqué a 3 " severity note;
        else 
             report " FAIL : Comptage bloqué a 3 " severity error;
            nb_fail <= nb_fail + 1;
        end if;
        cpt_raz <= '1';
        wait for 2*2*cible*period+1ns;  
         if nb_cycle ="00" then
            report " PASS : TEST priorité RAZ sur HOLD >>  nb_cycle =00   " severity note;
        else 
             report " FAIL : TEST priorité RAZ sur HOLD >>  nb_cycle =00 " severity error;
            nb_fail <= nb_fail + 1;
        end if;
        cpt_raz <= '0';
        wait for 2*2*cible*period+1ns;  
        if nb_cycle ="00" then
            report " PASS : HOLD maintenue aprés RAZ" severity note;
        else 
             report " FAIL : HOLD maintenue aprés RAZ" severity error;
            nb_fail <= nb_fail + 1;
        end if;
        cpt_hold <= '0';
        wait for 2*2*cible*period+1ns;  
        if nb_cycle ="10" then
            report " PASS : reprise Comptage jusqu'a 2 apres HOLD et RAZ " severity note;
        else 
             report " FAIL : reprise Comptage jusqu'a 2 apres HOLD et RAZ" severity error;
            nb_fail <= nb_fail + 1;
        end if;
        cpt_count <='0';
        wait for 2*2*cible*period+ns;  
        if nb_cycle ="10" then
            report " PASS : arret du Comptage à 2 , le 2 est maintenu " severity note;
        else 
             report " FAIL : arret du Comptage à 2" severity error;
            nb_fail <= nb_fail + 1;
        end if;
  	    report " Nombre de test FAIL : " & integer'image(nb_fail)  severity note; 
        resetn <='0';
        wait for 2*2*cible*period+ns;  
        if nb_cycle ="00" and led_drive ='0'then
            report " PASS : test du resetn " severity note;
        else 
             report " FAIL : test du resetn" severity error;
            nb_fail <= nb_fail + 1;
        end if;
  	    report " Nombre de test FAIL : " & integer'image(nb_fail)  severity note; 
         wait;

    end process;

end Behavioral;
