library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity I2C_master is
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_rw      : in std_logic;                     --0=write, 1=read
        i_addr    : in std_logic_vector(7 downto 0);  --target slave address
        i_tx_data : in std_logic_vector(7 downto 0);  --data to transmitt
        o_rx_data : out std_logic_vector(7 downto 0); --data received
        o_rdy     : out std_logic;                    --1=data is available on rx_data

        io_sda : inout std_logic; --data line
        io_scl : inout std_logic  --clock line
    );
end I2C_master;

architecture behav of I2C_master is
end behav;