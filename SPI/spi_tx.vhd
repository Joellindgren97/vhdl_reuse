library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master_tx is
    Generic (
        CLOCK_FREQUENCY : INTEGER := 50000000;  -- Default clock frequency in Hz
        SCLK_FREQUENCY : INTEGER := 1000000;    -- Default SCLK frequency in Hz
        CPOL : STD_LOGIC := '0';                -- Default clock polarity
        CPHA : STD_LOGIC := '0'                -- Default clock phase
        -- You can adjust these defaults to match your requirements
    );
    Port (
        clk : in STD_LOGIC;               -- Clock input
        rst : in STD_LOGIC;               -- Reset input
        data_in : in STD_LOGIC_VECTOR(7 downto 0);  -- Data input (8 bits)
        ss : out STD_LOGIC;               -- Slave Select
        sclk : out STD_LOGIC;             -- Serial Clock
        mosi : out STD_LOGIC              -- Master Out Slave In (Data Out)
    );
end spi_master_tx;

architecture behav of spi_master_tx is
    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0);  -- Shift register for data
    signal data_index : INTEGER := 0;
    signal sclk_counter : INTEGER := 0;
    signal sclk_divider : INTEGER := to_integer(real(CLOCK_FREQUENCY) / (2.0 * real(SCLK_FREQUENCY)));
    signal sample_on_edge : STD_LOGIC := CPHA;  -- Adjusted based on CPHA

begin
    process(clk, rst)
    begin
        if rst = '1' then
            shift_reg <= (others => '0');
            data_index <= 0;
            sclk_counter <= 0;
            ss <= '1';  -- Deassert Slave Select
            sclk <= CPOL;  -- Initial state based on CPOL
            mosi <= '0';
        elsif rising_edge(clk) then
            if sclk_counter = 0 then
                if sclk_divider = 0 then
                    -- Shift data out on MOSI line
                    if sample_on_edge = '1' then
                        mosi <= shift_reg(7);
                        shift_reg <= shift_reg(6 downto 0) & data_in(7);
                        data_in <= data_in(6 downto 0) & '0';  -- Shift in a zero bit

                        if data_index = 7 then
                            data_index <= 0;
                        else
                            data_index <= data_index + 1;
                        end if;
                    end if;

                    -- Generate the serial clock (SCLK)
                    sclk <= not sclk;

                    -- Assert Slave Select (Active Low)
                    ss <= '0';

                    -- Reset the SCLK divider
                    sclk_divider <= to_integer(real(CLOCK_FREQUENCY) / (2.0 * real(SCLK_FREQUENCY)));
                else
                    sclk_divider <= sclk_divider - 1;
                end if;
            else
                sclk_counter <= sclk_counter + 1;
            end if;
        end if;
    end process;
end behav;