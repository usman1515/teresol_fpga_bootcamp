-- //////////////////////////////////////////////////////////////////////////////
-- Company: TeReSol Pvt. Ltd
-- Engineer: Usman Siddique
--
-- Design Name:
-- Module Name: top_rca
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- //////////////////////////////////////////////////////////////////////////////////


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity top_rca is
    generic (
        DATA_WIDTH: integer := 8
    );
    port (
        i_a : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_cin : in std_logic;
        o_sum : out std_logic_vector(DATA_WIDTH-1 downto 0);
        o_cout : out std_logic
    );
end entity top_rca;

architecture Behavioral of top_rca is

begin

    INST_RCA : entity work.ripple_carry_adder
    generic map (
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        i_a     => i_a,
        i_b     => i_b,
        i_cin   => i_cin,
        o_sum   => o_sum,
        o_cout  => o_cout
    );

end architecture Behavioral;

