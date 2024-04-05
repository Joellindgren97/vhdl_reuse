library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rs232_rx is
    port (
        clk        : in std_logic;                    -- Clock input
        rst        : in std_logic;                    -- Reset input
        rx         : in std_logic;                    -- RS-232 Receive data input
        data_ready : out std_logic;                   -- Data ready indicator
        rx_data    : out std_logic_vector(7 downto 0) -- Received data (8 bits)
    );
end rs232_rx;

architecture behav of rs232_rx is
    signal rx_reg        : std_logic_vector(9 downto 0) := (others => '1'); -- Initialize to all 1's
    signal rx_count      : integer                      := 0;
    signal rx_data_ready : std_logic                    := '0';

begin
    process (clk, rst)
    begin
        if rst = '1' then
            rx_reg        <= (others => '1'); -- Reset the shift register
            rx_count      <= 0;
            rx_data_ready <= '0';
        elsif rising_edge(clk) then
            if rx_count = 0 then
                rx_reg(0)          <= rx;                 -- Sample the received data
                rx_reg(9)          <= rx_reg(8);          -- Shift in the stop bit
                rx_reg(8 downto 1) <= rx_reg(7 downto 0); -- Shift the data bits
                rx_count           <= 10;
                rx_data_ready      <= '0';
            else
                if rx_count = 1 then
                    rx_data_ready <= '1'; -- Data is ready after 1 clock cycle
                end if;
                rx_count <= rx_count - 1;
            end if;
        end if;
    end process;

    data_ready <= rx_data_ready;
    rx_data    <= rx_reg(7 downto 0); -- Output the received data bits

end behav;