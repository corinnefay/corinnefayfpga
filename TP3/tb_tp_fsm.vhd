library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tp_fsm is
end tb_tp_fsm;

architecture behavioral of tb_tp_fsm is

	signal reset      : std_logic := '0';
	signal clk         : std_logic := '0';
	signal restart     : std_logic := '0';
	signal led_r       : std_logic := '0';
	signal led_b       : std_logic := '0';
	signal led_g       : std_logic := '0';
	signal nb_fail     : integer := 0;
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	constant cible : integer := 20;
	
	component tp_fsm
	   generic(
	       cible: integer
	       );
		port ( 
            clk			: in std_logic; 
            reset		: in std_logic;
            restart     : in std_logic;
            led_r       : out std_logic;
            led_b       : out std_logic;
            led_g       : out std_logic			
             );
	end component;

	begin
	dut: tp_fsm
		generic map(
	       cible=> cible 
	     )
        port map (
            clk => clk,
            reset => reset,
            restart  => restart,
            led_r   => led_r,
            led_b  => led_b,
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
	    if led_r ='0' and led_b = '0' and led_g = '0'  then
            report " PASS : TEST reset : la led est eteinte OK" severity note;
        else 
             report " FAIL : TEST reset : la led est eteinte KO " severity error;
             nb_fail <= nb_fail + 1;
        end if;
		wait for cible*period +1ns;     
		-- demarrage
		reset <= '0';
		wait for cible*period +1ns; 
		for i in 1 to 3 loop     
            if led_r ='1' and led_b = '1' and led_g = '1' then
                report " PASS : TEST demarrage après reset: led en blanc OK" severity note;
            else 
                 report " FAIL : TEST demarrage après reset: led en blanc KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop;  
		-- passage au rouge
		for i in 1 to 3 loop     
            if led_r ='1' and led_b = '0' and led_g = '0' then
                report " PASS : TEST passage au rouge: led en rouge OK" severity note;
            else 
                 report " FAIL : TEST passage au rouge: led en rouge KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 
		-- passage au bleu
		for i in 1 to 3 loop     
            if led_r ='0' and led_b = '1' and led_g = '0' then
                report " PASS : TEST passage au bleu: led en bleu OK" severity note;
            else 
                 report " FAIL : TEST passage au bleu: led en bleu KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 		
		-- passage au vert
		for i in 1 to 3 loop     
            if led_r ='0' and led_b = '0' and led_g = '1' then
                report " PASS : TEST passage au vert: led en vert OK" severity note;
            else 
                 report " FAIL : TEST passage au vert: led en vert KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 		
		-- passage au rouge
		for i in 1 to 3 loop     
            if led_r ='1' and led_b = '0' and led_g = '0' then
                report " PASS : TEST passage au rouge: led en rouge OK" severity note;
            else 
                 report " FAIL : TEST passage au rouge: led en rouge KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 		
		-- test du restart
		wait for 2*cible*period +50ns;   
		restart <= '1';
		-- on passe en  blanc
		wait for 2*period +1ns; 
		for i in 1 to 4 loop     
            if led_r ='1' and led_b = '1' and led_g = '1' then
                report " PASS : TEST pendant restart: led en blanc OK" severity note;
            else 
                 report " FAIL : TEST pendant restart: led en blanc KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 
		-- test comptage après restart
		restart <= '0';
		wait for period +1ns; 
		for i in 1 to 3 loop     
            if led_r ='1' and led_b = '1' and led_g = '1' then
                report " PASS : TEST demarrage après restart: led en blanc OK" severity note;
            else 
                 report " FAIL : TEST demarrage après restart: led en blanc KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop;  
		-- passage au rouge
		for i in 1 to 3 loop     
            if led_r ='1' and led_b = '0' and led_g = '0' then
                report " PASS : TEST passage au rouge: led en rouge OK" severity note;
            else 
                 report " FAIL : TEST passage au rouge: led en rouge KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 
		-- passage au bleu
		for i in 1 to 3 loop     
            if led_r ='0' and led_b = '1' and led_g = '0' then
                report " PASS : TEST passage au bleu: led en bleu OK" severity note;
            else 
                 report " FAIL : TEST passage au bleu: led en bleu KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 		
		-- passage au vert
		for i in 1 to 3 loop     
            if led_r ='0' and led_b = '0' and led_g = '1' then
                report " PASS : TEST passage au vert: led en vert OK" severity note;
            else 
                 report " FAIL : TEST passage au vert: led en vert KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 		
		-- passage au rouge
		for i in 1 to 3 loop     
            if led_r ='1' and led_b = '0' and led_g = '0' then
                report " PASS : TEST passage au rouge: led en rouge OK" severity note;
            else 
                 report " FAIL : TEST passage au rouge: led en rouge KO" severity error;
                 nb_fail <= nb_fail + 1;
            end if;
		  wait for 2*cible*period +1ns;   
		end loop; 
		wait for 3*period +1ns;   
	    reset <= '1';
		wait for (3*2*cible+cible)*period +1ns;     
	    report " Nombre de test FAIL : " & integer'image(nb_fail)  severity note; 
		wait;
	    
	end process;
	
	
end behavioral;