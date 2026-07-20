
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity counter_unit is
    generic (
       cible : integer := 20 
       );
    port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           end_counter : out STD_LOGIC
           );
end counter_unit;

architecture Behavioral of counter_unit is
	signal d_counter	: std_logic_vector ( 27 downto 0) := (others => '0');
	signal q_counter	: std_logic_vector ( 27 downto 0):= (others => '0');
	signal comp         : std_logic := '0'; -- sortie du comparateur

	begin
		process(clk,resetn)
		begin
			if (resetn = '0') then 
				q_counter <=(others => '0');
		 	elsif(rising_edge(clk)) then
                 q_counter <= d_counter;
 			end if;
		end process;
        
		comp <= '1' when to_integer(unsigned(q_counter)) = cible -1	else '0'; -- on valide le comptage à cible -1
		d_counter <= q_counter + 1 when comp = '0' else (others => '0'); -- on remet le registre à 0 quand on a atteint la cible
		end_counter <= comp;-- rajout d'un buffer sur la sortie  

end Behavioral;

