library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity cronometro is
    Port ( clk: in STD_LOGIC;
           btn_start : in STD_LOGIC;
           btn_reset : in STD_LOGIC;
           btn_stop : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC);
end cronometro;

architecture Behavioral of cronometro is

    signal un_sec : STD_LOGIC_VECTOR (3 downto 0);
    signal dec_sec : STD_LOGIC_VECTOR (2 downto 0);
    signal min : STD_LOGIC_VECTOR (3 downto 0);
    signal seg_min, seg_dec_sec, seg_un_sec, display : STD_LOGIC_VECTOR (6 downto 0) := "0000001";
    signal print : std_logic := '0';
    signal showed : std_logic_vector(3 downto 0);
    
begin

    div: process(clk, btn_start, btn_reset, btn_stop)

        variable count_segment : integer range 0 to 100000000 := 0;
        variable count_display : integer range 0 to 100000 := 0;
        variable to_stop :std_logic := '1';
        variable var_min :std_logic_vector(3 downto 0) := "0000";
        variable var_dec_sec :std_logic_vector(2 downto 0) := "000";
        variable var_un_sec: std_logic_vector(3 downto 0) := "0000";

    begin

        -- ativar o switch de parada
        if btn_stop = '1'then 
            to_stop := '1';
            
            -- quando o switch de parada estiver desligado e o switch de start estiver ligado
            elsif btn_start = '1' and btn_stop = '0' then 
                to_stop := '0';
            -- quando o switch de reset estiver ligado e o switch de start desligado
            elsif btn_reset = '1' and btn_start = '0'then 
                var_min := "0000";
                var_dec_sec := "000";
                var_un_sec := "0000";
                to_stop := '1';
                count_segment := 0;
    
            else null;

        end if;

        if rising_edge(clk) then

            count_display := count_display + 1;

            if count_display = 100000 then
                print <= not print; 

            end if;

            if to_stop = '0' then
                count_segment := count_segment + 1;
                
                -- quando o count_segment chega em seu valor maximo a unidade de segundo aumenta
                if count_segment = 100000000 then
                    var_un_sec := var_un_sec + "0001";

                   -- quando a unidade de segundo passa o 9 a dezena de segundo aumenta
                    if var_un_sec > "1001" then
                        var_dec_sec := var_dec_sec + "001";
                        var_un_sec := "0000";

                        -- quando a dezena de segundo passa o 5 a unidade de minuto aumenta
                        if var_dec_sec > "101" then
                            var_min := var_min+"0001";
                            var_dec_sec := "000";

                            -- volta o minuto para 0 quando o ele chega em 9
                            if var_min = "1010" then
                                var_min := "0000";

                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;

        min <= var_min;
        un_sec <= var_un_sec;
        dec_sec <= var_dec_sec;

    end process;

    cod: process(dec_sec, un_sec, min)
    begin
        --display do minuto
        case min is
            when "0000" => seg_min <= "1000000" ; -- 0
            when "0001"=> seg_min <=  "1111001";  -- 1
            when "0010" => seg_min <= "0100100"; -- 2
            when "0011" => seg_min <= "0110000"; -- 3
            when "0100" => seg_min <= "0011001"; -- 4
            when "0101" => seg_min <= "0010010"; -- 5
            when "0110" => seg_min <= "0000010"; -- 6
            when "0111" => seg_min <= "1111000"; -- 7
            when "1000" => seg_min <= "0000000"; -- 8
            when "1001" => seg_min <= "0010000"; -- 9 
            when others => seg_min <= "1111111"; -- outros
        end case;
        
        -- display dezena de segundo
        case dec_sec is         
            when "0000" => seg_dec_sec <= "1000000" ; -- 0
            when "0001"=> seg_dec_sec <=  "1111001";  -- 1
            when "0010" => seg_dec_sec <= "0100100"; -- 2
            when "0011" => seg_dec_sec <= "0110000"; -- 3
            when "0100" => seg_dec_sec <= "0011001"; -- 4
            when "0101" => seg_dec_sec <= "0010010"; -- 5 
            when others => seg_dec_sec <= "1111111"; -- outros
        end case;
        
        -- display unidade de segundo
        case un_sec is         
            when "0000" => seg_un_sec <= "1000000" ; -- 0
            when "0001"=> seg_un_sec <=  "1111001";  -- 1
            when "0010" => seg_un_sec <= "0100100"; -- 2
            when "0011" => seg_un_sec <= "0110000"; -- 3
            when "0100" => seg_un_sec <= "0011001"; -- 4
            when "0101" => seg_un_sec <= "0010010"; -- 5
            when "0110" => seg_un_sec <= "0000010"; -- 6
            when "0111" => seg_un_sec <= "1111000"; -- 7
            when "1000" => seg_un_sec <= "0000000"; -- 8
            when "1001" => seg_un_sec <= "0010000"; -- 9 
            when others => seg_un_sec <= "1111111"; -- outros 
        end case;

    end process;

    mux: process (print)  --multiplexa os displays
        variable display_select : integer range 0 to 3 := 0;

    begin
    
        if rising_edge(print) then 
            display_select := display_select + 1;

            case display_select is
                when 0 => showed <= "0111"; display <= "1111111"; dp <= '1';
                when 1 => showed <= "1011"; display <= seg_min; dp <= '0';
                when 2 => showed <= "1101"; display <= seg_dec_sec; dp <= '1';
                when 3 => showed <= "1110"; display <= seg_un_sec; dp <= '1';
                when others => null;
            end case;
      
        end if;
    end process;

    an <= showed;
    seg <= display;
    
end Behavioral;
