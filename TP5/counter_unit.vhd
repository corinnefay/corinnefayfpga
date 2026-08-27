library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_unit is
    generic (
       cible : integer := 200000000 
       );
    port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           end_counter : out STD_LOGIC
           );
end counter_unit;

architecture Behavioral of counter_unit is
	signal q_counter	: unsigned ( 27 downto 0):= (others => '0');
	begin
		process(clk,resetn)
		begin
			if (resetn = '0') then 
				q_counter <=(others => '0');
                end_counter <= '0';				
		 	elsif(rising_edge(clk)) then
                 if q_counter = to_unsigned(cible - 1, q_counter'length) then 
                    q_counter <= (others => '0');
                    end_counter <= '1'; 
                 else
                    q_counter <= q_counter+1;
                    end_counter <= '0';
                end if;
 			end if;
		end process;
end Behavioral;

