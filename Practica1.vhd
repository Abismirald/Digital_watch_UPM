library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Practica1 is
    Port(
        clk : in std_logic;
        reset : in std_logic;
        segmentos: out std_Logic_vector(6 downto 0);
        selector : out std_logic_vector(3 downto 0)
        );
end Practica1;

architecture Behavioral of Practica1 is
    
    -- freq. Divider signals
    constant MaxCount: integer:= 125000000; 
    signal Counter: integer range 0 to MaxCount-1;
    signal Enable: std_logic;
    signal Enable_Seconds: std_logic;

    -- chrono constants
    constant Max9: unsigned(3 downto 0) := "1001";
    constant Max6: unsigned(3 downto 0) := "0110";

    -- chrono signals
    signal seconds: unsigned(3 downto 0);
    signal tensofseconds: unsigned(3 downto 0);
    signal minutes: unsigned(3 downto 0);
    signal tensofminutes: unsigned(3 downto 0);

    --chrono enables
    signal Enable_TensOfSeconds: std_logic;
    signal Enable_Minutes: std_logic;
    signal Enable_TensMinutes: std_logic;

    signal segundos:    std_logic_vector(3 downto 0); 
    signal dec_segundos: std_logic_vector(3 downto 0);
    signal minutos:     std_logic_vector(3 downto 0);
    signal dec_minutos: std_logic_vector(3 downto 0);
    
    --MUX signals
    signal BCD_digit:   std_logic_vector(3 downto 0);
    
    --Freq @4KHz signals
    constant Max4K: integer := 31250;
    signal counter4K: integer range 0 to Max4K-1;
    signal Enable_4K: std_logic;
    
    --Counter 0to3 singals
    signal counter_0to3: unsigned(1 downto 0); 
    constant Max0to3: unsigned(1 downto 0) := "11";
         
begin
    
    Enable <= '1';

    -- freq. Divider
    process(clk, reset)
    begin
        if(reset = '1') then
            Counter <= 0;
        elsif(clk'event and clk= '1') then
            if(Enable = '1') then --rising edge y enable signal 1
                if(Counter < MaxCount -1) then
                    Counter <= Counter + 1;
                else
                    Counter <= 0;
                end if;
            end if;
        end if;
    end process;

    Enable_Seconds <= '1' when (Counter = MaxCount -1) else '0';

    -- Counter seconds
    process(clk, reset)
    begin
        if(reset = '1')then
            seconds <= (others => '0');
        elsif(clk'event and clk= '1') then
            if(Enable_Seconds = '1') then
                if(seconds < Max9) then
                    seconds <= seconds + 1;
                else
                    seconds <= (others => '0');
                end if;
            end if;   
        end if;
    end process;

    Enable_TensOfSeconds <= '1' when (seconds = Max9 and Enable_Seconds= '1') else '0';
    
    -- Counter Tens of Seconds
    process(clk, reset)
    begin
        if(reset = '1')then
            tensofseconds <= (others => '0');
        elsif(clk'event and clk= '1') then
            if(Enable_TensOfSeconds = '1') then
                if(tensofseconds < Max6 -1) then
                    tensofseconds <= tensofseconds + 1;
                else
                    tensofseconds <= (others => '0');
                end if;
            end if;   
        end if;
    end process;    

    Enable_Minutes<='1' when (tensofseconds = Max6-1 and Enable_TensOfSeconds = '1') else '0';
    
    --Counter Minutes
    process(clk, reset)
        begin
        if(reset = '1')then
            minutes <= (others => '0');
        elsif(clk'event and clk= '1') then
            if(Enable_Minutes = '1') then
                if(minutes < Max9) then
                    minutes <= minutes + 1;
                else
                    minutes <= (others => '0');
                end if;
            end if;   
        end if;
    end process;

    Enable_TensMinutes<='1' when (minutes = Max9 and Enable_Minutes= '1') else '0';
    
    --Counter Tens of Minutes
    process(clk, reset)
    begin
        if(reset = '1')then
            tensofminutes <= (others => '0');
        elsif(clk'event and clk= '1') then
            if(Enable_TensMinutes = '1') then
                if(tensofminutes < Max6 -1) then
                    tensofminutes <= tensofminutes + 1;
                else
                    tensofminutes <= (others => '0');
                end if;
            end if;   
        end if;
    end process;

    
    segundos        <= std_logic_vector(seconds);
    dec_segundos    <= std_logic_vector(tensofseconds);
    minutos         <= std_logic_vector(minutes);
    dec_minutos     <= std_logic_vector(tensofminutes);

--------------------------------------------------------

    --Multiplexer (when else/with select)
    with counter_0to3 select -- Este tiene que ser la salida del contador de 0 a 3? 
        BCD_digit <= segundos when "00",
                     dec_segundos when "01",
                     minutos when "10",
                     dec_minutos when others;
 
    -- Decoder BCD to 7-segments
    with BCD_digit select
    segmentos <= "0000001" when "0000", -- 0
                 "1001111" when "0001", -- 1
                 "0010010" when "0010", -- 2
                 "0000110" when "0011", -- 3
                 "1001100" when "0100", -- 4
                 "0100100" when "0101", -- 5
                 "0100000" when "0110", -- 6
                 "0001111" when "0111", -- 7
                 "0000000" when "1000", -- 8
                 "0000100" when "1001", -- 9
                 "-------" when others;    
    
    -- freq div @4KHz
    process(clk, reset)
    begin
        if(reset = '1') then
            counter4K <= 0;
        elsif(clk'event and clk= '1') then
            if(Enable = '1') then 
                if(counter4K < Max4K -1) then
                    counter4K <= counter4K + 1;
                else
                    counter4K <= 0;
                end if;
            end if;
        end if;
    end process;
    
    Enable_4K <= '1' when (counter4K = Max4K -1) else '0';
    
    --counter 0 to 3 (unsigned counter)
    process(clk, reset)
    begin
        if(reset = '1') then
            counter_0to3 <= (others =>'0'); 
        elsif(clk'event and clk= '1') then
            if(Enable_4K = '1') then 
                if(counter_0to3 < Max0to3) then
                    counter_0to3 <= counter_0to3 + 1;
                else
                    counter_0to3 <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    
    -- Number selector
    with counter_0to3 select
    selector <= "0001" when "00",
                "0010" when "01",
                "0100" when "10",
                "1000" when others;
                

end Behavioral;
