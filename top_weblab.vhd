library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_weblab is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        buttons  : in  std_logic_vector(3 downto 0);
        switches : in  std_logic_vector(7 downto 0);
        leds     : out std_logic_vector(7 downto 0);
        segments : out std_logic_vector(7 downto 0);
        selector : out std_logic_vector(3 downto 0)
    );
end top_weblab;

architecture wrapper of top_weblab is
    
    signal aux : std_logic_vector(6 downto 0);  

begin
    practica1_i: entity work.Practica1
    port map (
        clk => clk,
        reset => reset,
        segmentos => aux,
        selector => selector
        );

-- ... pero el setup requiere 8, por lo que concatenamos un '1' al principio
    segments <= '1' & aux;

-- Ponemos el resto de salidasa 0 por si acaso...
    leds <= (others => '0');


end wrapper;
