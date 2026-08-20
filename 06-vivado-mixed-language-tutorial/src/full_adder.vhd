-- //////////////////////////////////////////////////////////////////////////////
-- Company: TeReSol Pvt. Ltd
-- Engineer: Usman Siddique
--
-- Design Name:
-- Module Name: full_adder
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



entity full_adder is
    port (
        i_a : in std_logic;
        i_b : in std_logic;
        i_cin : in std_logic;
        o_sum : out std_logic;
        o_cout : out std_logic
    );
end entity full_adder;

architecture Behavioral of full_adder is

begin

    o_sum <= i_a xor i_b xor i_cin;
    o_cout <= (i_a and i_b) or (i_a and i_cin) or (i_b and i_cin);

end architecture Behavioral;

