library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rs232_tx is
    generic (
        CLK_FREQUENCY : integer := 50000000, -- Default clock frequency in Hz
        BAUD_RATE     : integer := 9600      -- Default baud rate in bits per second
    );
    port (
        clk     : in std_logic;                    -- Clock input
        rst     : in std_logic;                    -- Reset input
        tx_data : in std_logic_vector(7 downto 0); -- Data input (8 bits)
        tx_busy : out std_logic;                   -- Transmission busy indicator
        tx      : out std_logic                    -- RS-232 Transmit data output
    );
end rs232_tx;

architecture behav of rs232_tx is
    signal tx_reg       : std_logic_vector(9 downto 0) := "1000000000"; -- Initial start bit
    signal tx_count     : integer                      := 0;
    signal tx_shift_reg : std_logic_vector(9 downto 0);

begin
    process (clk, rst)
        variable baud_cnt : integer := 0;
    begin
        if rst = '1' then
            tx_reg       <= "1000000000"; -- Initialize to start bit
            tx_count     <= 0;
            tx_shift_reg <= (others => '0');
            tx_busy      <= '0';
        elsif rising_edge(clk) then
            if tx_count = 0 then
                tx_reg(0)      <= '0'; -- Start bit
                tx_reg(9)      <= '1'; -- Stop bit
                tx_reg(1 to 8) <= tx_data;
                tx_count       <= 10;
                tx_shift_reg   <= tx_reg;
                tx_busy        <= '1';
            else
                if baud_cnt = CLK_FREQUENCY / (2 * BAUD_RATE) - 1 then
                    tx_reg       <= tx_shift_reg;
                    tx_shift_reg <= '0' & tx_shift_reg(9 downto 1);
                    tx_count     <= tx_count - 1;
                    tx_busy      <= '1' when tx_count > 0 else
                        '0';
                    baud_cnt := 0;
                else
                    baud_cnt := baud_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    tx <= tx_reg(0); -- Output the LSB of the shift register

end behav;