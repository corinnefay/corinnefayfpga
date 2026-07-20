library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity counter_led is
    generic (
        cible : integer := 20
    );
    Port ( clk      : in std_logic;
           resetn   : in std_logic;
           cpt_raz  : in std_logic;
           cpt_hold : in std_logic;
           cpt_count : in std_logic;
           out_nb_cycle : out std_logic_vector(1 downto 0 ) := (others => '0');
           out_led_drive : out std_logic
           );
end counter_led;

architecture Behavioral of counter_led is
    signal end_counter : std_logic := '0';
    signal led_drive : std_logic := '1';
    signal d_led_drive : std_logic := '1';
    signal nb_cycle : std_logic_vector(1 downto 0 ) := (others => '0');
    signal d_cycle : std_logic_vector(1 downto 0 ) := (others => '0');
    begin
        cpt: entity work.counter_unit(behavioral)
            generic map (
            cible => cible 
            )
            port map ( 
                clk => clk,
                resetn => resetn,
                end_counter => end_counter
           ); 
        process(clk, resetn) 
        begin    
            if resetn = '0' then 
                nb_cycle <= (others => '0');
                led_drive <= '0';
            elsif(rising_edge(clk)) then
                led_drive <= d_led_drive;
                nb_cycle <= d_cycle;
              end if ;
        end process;
        -- pour d_cycle : cpt_raz prioritaire
        --                pas d'increment si cpt_hold = '1'
        --                increment si cpt_count = '1' sur le niveau a '1' de end_counter et q_led_drive
        d_cycle <=  (others => '0') when cpt_raz = '1' else 
                    nb_cycle + 1 when cpt_count = '1' and end_counter = '1' and cpt_hold = '0' and led_drive = '1' else
                    nb_cycle ;
        -- driver de LED qui alterne à chaque fin de comptage end _counter                
        d_led_drive <= not led_drive  when end_counter = '1' else led_drive;
        -- buffers sur les sorties
        out_nb_cycle <= nb_cycle; 
        out_led_drive <= led_drive;

end Behavioral;
