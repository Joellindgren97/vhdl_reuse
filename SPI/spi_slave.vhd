library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity spi_slave is
    generic (
        g_data_width : integer := 16
    );
    port (
        sclk    : in std_logic;
        ss_n    : in std_logic;
        mosi    : in std_logic;
        miso    : out std_logic;
        tx_data : in std_logic_vector(g_data_width - 1 downto 0);
        rx_data : out std_logic_vector(g_data_width - 1 downto 0);
        rx_vld  : out std_logic;
        rst     : in std_logic -- Reset signal
    );
end spi_slave;

architecture rtl of spi_slave is
    signal bit_counter : integer range 0 to g_data_width             := 0;
    signal rx_buffer   : std_logic_vector(g_data_width - 1 downto 0) := (others => '0');
    signal tx_buffer   : std_logic_vector(g_data_width - 1 downto 0) := (others => '0');
begin
    -- Bit counter process
    bit_cnt_proc : process (rst, ss_n, sclk)
    begin
        if rst = '1' then
            bit_counter <= 0;
        elsif ss_n = '1' then
            bit_counter <= 0;
        elsif falling_edge(sclk) then
            bit_counter <= bit_counter + 1;
        end if;
    end process;

    -- MOSI process to receive data from master and set data valid signal
    mosi_proc : process (rst, sclk, ss_n)
    begin
        if rst = '1' then
            rx_buffer <= (others => '0');
            rx_vld    <= '0';
        elsif ss_n = '1' then
            rx_buffer <= (others => '0');
            rx_vld    <= '0';
        elsif rising_edge(sclk) then
            if bit_counter                        <= g_data_width then
                rx_buffer(g_data_width - bit_counter) <= mosi;
                if bit_counter = g_data_width then
                    rx_vld <= '1';
                else
                    rx_vld <= '0';
                end if;
            end if;
        end if;
    end process;

    -- MISO process to transmit data from reg to master
    miso_proc : process (rst, sclk, ss_n)
    begin
        if rst = '1' then
            miso <= 'Z';
        elsif ss_n = '1' then
            miso <= 'Z';
        elsif falling_edge(sclk) then
            if bit_counter <= g_data_width then
                miso           <= tx_buffer(g_data_width - 1 - bit_counter);
            end if;
        end if;
    end process;

    rx_data   <= rx_buffer;
    tx_buffer <= tx_data;
end rtl;