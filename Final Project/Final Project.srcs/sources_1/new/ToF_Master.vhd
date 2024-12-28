



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ToF_Master is
    generic(sys_clk_freq : INTEGER := 50_000_000);               --input clock speed from user logic in Hz
    Port (  clk      :in    std_logic;
            reset    :in    std_logic;
            SDA      :inout std_logic;
            SCL      :inout std_logic;
            SS       :out   std_logic;
            IRQ      :in    std_logic;
            start    :out   std_logic;
            clear    :out   std_logic;
            keys     :in    integer;
            data_out :out   integer range 0 to 34
            );
end ToF_Master;

architecture Behavioral of ToF_Master is
    component i2c_master is
        generic(
            input_clk : integer := 50_000_000; 
            bus_clk   : integer := 400_000);   
        port(
            clk       : in     std_logic;                    
            reset_n   : in     std_logic;                    
            ena       : in     std_logic;                    
            addr      : in     std_logic_vector(6 downto 0); 
            rw        : in     std_logic;                    
            data_wr   : in     std_logic_vector(7 downto 0); 
            busy      : out    std_logic;                    
            data_rd   : out    std_logic_vector(7 downto 0); 
            ack_error : buffer std_logic;                  
            sda       : inout  std_logic;                    
            scl       : inout  std_logic);                   
    end component;

    type state_type is (IDLE, INTEGRATION, PERIOD, SINGLE_SHOT, OPT_AGC, OPT_VGA, SETUP_IRQ, EMIT_CURRENT, EMIT_MULT,
                        READ_EEPROM, CALIBRATE, CLEAR_IRQ, MEASURE_SS, WAIT_IRQ, READ_DISTANCE, CALCULATE_DATA);
    signal state : state_type;

    constant ToF_addr   : std_logic_vector(6 downto 0) := "1010111";
    constant eeprom_addr: std_logic_vector(6 downto 0) := "1010000";
    type eeprom_type is array(0 to 15) of std_logic_vector(7 downto 0);
    signal eeprom_data : eeprom_type;

    signal ena       :std_logic;                    
    signal addr      :std_logic_vector(6 downto 0); 
    signal rw        :std_logic;                    
    signal data_wr   :std_logic_vector(7 downto 0); 
    signal data_rd   :std_logic_vector(7 downto 0); 
    signal busy      :std_logic;                    
    signal ack_error :std_logic;                  
    signal busy_prev :std_logic;
    signal MSB       :unsigned(7 downto 0); 
    signal LSB       :unsigned(7 downto 0); 

begin
	i2c: i2c_master
        generic map(
            input_clk => sys_clk_freq,
            bus_clk   => 100_000)
        port map(
            clk       => clk,
            reset_n   => not reset,
            ena       => ena,
            addr      => addr,
            rw        => rw,
            data_wr   => data_wr,
            busy      => busy,
            data_rd   => data_rd,
            ack_error => ack_error,
            sda       => SDA,
            scl       => SCL
        );
    process(clk)
        variable busy_cnt  : integer := 0;               --counts the i2c busy signal transistions
        variable counter   : integer := 0; --counts 100ms to wait before communicating
        variable pause_cnt : integer := 0;          --counter to execute wait periods
        variable IRQ_cnt   : integer := 0;
        variable SS_cnt    : integer := 0;
        variable calculation : real;
    begin
        if(reset = '1') then
            state <= INTEGRATION;
            ena <= '0';
            data_out <= 0;
            SS <= '1';
            start <= '0';
            clear <= '0';
        elsif (rising_edge(clk)) then
            case(state) is

            when INTEGRATION =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is
                    -- Write 0x04 to register 0x10 (Set integration time, increase over default is normal)
                    when 0 =>                               
                        ena <= '1';                -- Enable I2C transmission
                        addr <= ToF_addr;         -- ISL29501 base address
                        rw <= '0';                 -- Write command
                        data_wr <= x"10";          -- Register Address
                    when 1 =>                      -- After ACK bit is recieved from slave
                        data_wr <= x"04";          -- Write 0x04 to register 0x10
                    when 2 =>                      -- after ACK bit is recieved from slave
                        ena <= '0';                 -- Disable I2C communication           
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= PERIOD;         
                        end if;
                    when others => null;
                end case;

            when PERIOD =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is
                    -- Write 0x6E to register 0x11 (Set measurement period, default normally OK)
                    when 0 =>                                  
                        ena <= '1';                -- Enable I2C transmission
                        addr <= ToF_addr;         -- ISL29501 base address
                        rw <= '0';                 -- Write command
                        data_wr <= x"11";          -- Register Address
                    when 1 =>                      -- After ACK bit is recieved from slave
                        data_wr <= x"6E";          -- Write 0x6E to register 0x11
                    when 2 =>                      -- after ACK bit is recieved from slave       
                    ena <= '0';                 -- Disable I2C communication           
                    if(busy = '0') then
                        busy_cnt := 0;     
                        state <= SINGLE_SHOT;         
                    end if;
                    when others => null;
                end case;

            when SINGLE_SHOT=>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is        
                    -- Write 0x71 to register 0x13 (Setup single shot mode)
                    when 0 =>                                  
                        ena <= '1';                -- Enable I2C transmission
                        addr <= ToF_addr;         -- ISL29501 base address
                        rw <= '0';                 -- Write command
                        data_wr <= x"13";          -- Register Address
                    when 1 =>                      -- After ACK bit is recieved from slave
                        data_wr <= x"71";          -- Write 0x71 to register 0x13
                    when 2 =>                      -- after ACK bit is recieved from slave       
                        ena <= '0';                -- Disable I2C communication
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= OPT_AGC;         
                        end if;
                    when others => null;
                end case;

            when OPT_AGC =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is            
                    -- Write 0x22 to register 0x18 (Optimize AGC)
                    when 0 =>                                  
                        ena <= '1';                -- Enable I2C transmission             
                        addr <= ToF_addr;         -- ISL29501 base address             
                        rw <= '0';                 -- Write command           
                        data_wr <= x"18";          -- Register Address            
                    when 1 =>                     -- After ACK bit is recieved from slave            
                        data_wr <= x"22";          -- Write 0x22 to register 0x18            
                    when 12 =>                     -- after ACK bit is recieved from slave                     
                        ena <= '0';                -- Disable I2C communication       
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= OPT_VGA;         
                        end if;
                    when others => null;
                end case;

            when OPT_VGA =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is            
                    -- Write 0x22 to register 0x19  Optimize VGA
                    when 0 =>                                  
                        ena <= '1';                 -- Enable I2C transmission                        
                        addr <= ToF_addr;          -- ISL29501 base address                        
                        rw <= '0';                  -- Write command                      
                        data_wr <= x"19";           -- Register Address                       
                    when 1 =>                      -- After ACK bit is recieved from slave             
                        data_wr <= x"22";           -- Write 0x22 to register 0x19                
                    when 12 =>                      -- after ACK bit is recieved from slave                             
                        ena <= '0';                 -- Disable I2C communication  
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= SETUP_IRQ;         
                        end if;
                    when others => null;
                end case; 

            when SETUP_IRQ =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is            
                    -- Write 0x01 to register 0x60 (Setup ISL29501 to interrupt when data ready)        
                    when 0 =>                                  
                        ena <= '1';                 -- Enable I2C transmission                         
                        addr <= ToF_addr;          -- ISL29501 base address                         
                        rw <= '0';                  -- Write command                                 
                        data_wr <= x"60";           -- Register Address                                
                    when 1 =>                      -- After ACK bit is recieved from slave             
                        data_wr <= x"01";           -- Write 0x01 to register 0x60                 
                    when 2 =>                      -- after ACK bit is recieved from slave             
                        ena <= '0';                 -- Disable I2C communication
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= EMIT_MULT;         
                        end if;
                    when others => null;
                end case;   

            when EMIT_MULT =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is                   
                    -- Write 0x0F to register 0x90  (Set emitter scale multiplier)
                    when 0 =>                                  
                        ena <= '1';                 -- Enable I2C transmission                       
                        addr <= ToF_addr;          -- ISL29501 base address                           
                        rw <= '0';                  -- Write command 
                        data_wr <= x"90";           -- Register Address                                
                    when 1 =>                      -- After ACK bit is recieved from slave             
                        data_wr <= x"0F";           -- Write 0x0F to register 0x90                 
                    when 2 =>                      -- after ACK bit is recieved from slave             
                        ena <= '0';                 -- Disable I2C communication  
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= EMIT_CURRENT;         
                        end if;
                    when others => null;
                end case;     

            when EMIT_CURRENT =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is               
                    -- Write 0xFF to register 0x91 (Set emitter current, register value determined by the LED or laser)
                    when 0 =>                                  
                        ena <= '1';                 -- Enable I2C transmission                         
                        addr <= ToF_addr;          -- ISL29501 base address                         
                        rw <= '0';                  -- Write command                                 
                        data_wr <= x"91";           -- Register Address                                
                    when 1 =>                      -- After ACK bit is recieved from slave             
                        data_wr <= x"FF";           -- Write 0xFF to register 0x91                 
                    when 2 =>                      -- after ACK bit is recieved from slave             
                        ena <= '0';                 -- Disable I2C communication           
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= READ_EEPROM;         
                        end if;
                    when others => null;
                end case;

            -- Restore Factory Calibration from EEPROM
            when READ_EEPROM => 
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is
                    when 0 =>                               
                        ena <= '1';                 -- Enable I2C transmission
                        addr <= eeprom_addr;       -- EEPROM base address
                        rw <= '0';                  -- Write command
                        data_wr <= x"20";           -- Register Address
                    when 1 =>                       -- After ACK bit is recieved from slave
                        rw <= '1';                  -- Read command
                    when 2 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(0) <= data_rd;       
                        end if;   
                    when 3 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(1) <= data_rd;       
                        end if;   
                    when 4 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(2) <= data_rd;       
                        end if;                        
                    when 5 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(3) <= data_rd;       
                        end if;                   
                    when 6 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(4) <= data_rd;       
                        end if;                              
                    when 7 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(5) <= data_rd;       
                        end if;            
                    when 8 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(6) <= data_rd;       
                        end if;   
                    when 9 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(7) <= data_rd;       
                        end if; 
                    when 10 =>                      -- After read of byte is done
                        if(busy = '0') then                        
                            eeprom_data(8) <= data_rd;       
                        end if;   
                    when 11 =>                      -- After read of byte is done           
                        if(busy = '0') then                      
                            eeprom_data(9) <= data_rd;       
                        end if;   
                    when 12 =>                      -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(10) <= data_rd;       
                        end if;                        
                    when 13 =>                      -- After read of byte is done
                        if(busy = '0') then                      
                            eeprom_data(11) <= data_rd;       
                        end if;                   
                    when 14 =>                      -- After read of byte is done
                        ena <= '0';
                        if(busy = '0') then                      
                            eeprom_data(12) <= data_rd;       
                            busy_cnt := 0;
                            state <= CALIBRATE;
                        end if; 
                    when others => null;                             
                    end case;

            when CALIBRATE => 
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is            
                    when 0 =>
                        ena <= '1';                               
                        addr <= ToF_addr;           -- ISL29501 base address
                        rw <= '0';                  -- Write command
                        data_wr <= x"24";           -- Register Address
                    when 1 =>                      -- After ACK bit is recieved from slave
                        data_wr <= eeprom_data(0);
                    when 2 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(1);
                    when 3 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(2);
                    when 4 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(3);                       
                    when 5 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(4);                 
                    when 6 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(5);                          
                    when 7 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(6);        
                    when 8 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(7);
                    when 9 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(8);
                    when 10 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(9);  
                    when 11 =>                       -- After ACK bit is received from slave           
                        data_wr <= eeprom_data(10);
                    when 12 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(11);                      
                    when 13 =>                       -- After ACK bit is received from slave
                        data_wr <= eeprom_data(12);                              
                    when 14 =>
                        ena <= '0';                 -- Disable I2C communication           
                        if(busy = '0') then
                            busy_cnt := 0;     
                            state <= IDLE;         
                        end if;
                    when others => null;
                end case;
                
            when IDLE => 
                start <= '0';
                IF(pause_cnt < 50_000_000*keys) THEN 
                    pause_cnt := pause_cnt + 1; 
                    start <= '1';
                ELSE                              
                    pause_cnt := 0;               
                    state <= CLEAR_IRQ;           
                END IF;
            when CLEAR_IRQ =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is
                    -- Read 0x69 register to clear interrupts
                    when 1 =>                                  
                        ena <= '1';                -- Enable I2C transmission
                        addr <= ToF_addr;          -- ISL29501 base address
                        rw <= '0';                 -- Write command
                        data_wr <= x"69";          -- Register Address
                    when 2 =>                      -- After ACK bit is recieved from slave
                        rw <= '1';                 -- Read command
                    when 3 =>        
                        ena <= '0';                -- Disable I2C communication
                        if(busy = '0') then        
                            busy_cnt := 0;         
                            state <= MEASURE_SS;   
                        end if;
                    when others => null;
                end case;
            when MEASURE_SS =>
                SS <= '0';
                SS_cnt := SS_cnt + 1;
                if(SS_cnt >= 280000) then
                    SS <= '1';
                    SS_cnt := 0;
                    state <= WAIT_IRQ;
                end if;
            when WAIT_IRQ =>
                if(IRQ = '1') then
                    state <= READ_DISTANCE;
                end if;
            when READ_DISTANCE =>
                busy_prev <= busy;                          
                if(busy_prev = '0' and busy = '1') then 
                  busy_cnt := busy_cnt + 1;  --count after ACK bit is received
                end if;
                case busy_cnt is
                    -- Read 0x69 register to clear interrupts
                    when 0 =>                                  
                        ena <= '1';                -- Enable I2C transmission
                        addr <= ToF_addr;          -- ISL29501 base address
                        rw <= '0';                 -- Write command
                        data_wr <= x"D1";          -- Register Address
                    when 1 =>                       -- After ACK bit is recieved from slave
                        rw <= '1';                  -- Read command
                    when 2 =>                       -- After read of byte is done
                        if(busy = '0') then                      
                           MSB <= unsigned(data_rd);       
                        end if;   
                    when 3 => 
                        ena <= '0';
                        if(busy = '0') then                  
                            LSB <= unsigned(data_rd);      
                            busy_cnt := 0;
                            state <= CALCULATE_DATA;
                        end if;   
                    when others => null;
                end case;
            when CALCULATE_DATA =>
                data_out <= (to_integer(MSB)*256 + to_integer(LSB))/65536 * 33;
                state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;
