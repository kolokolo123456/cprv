library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
    signal signe,z,s   : std_logic;
    signal x,y,res_sub : unsigned(32 downto 0);

begin
    --calcul du signe
    signe <= ((not IR(12)) and (not IR(6))) or ((IR(6)) and (not IR(13)));
    x <= rs1(31) & rs1 when signe = '1' else '0' & rs1;
    y <= alu_y(31) & alu_y when signe='1' else '0' & alu_y;
    --soustraction
    res_sub <= x-y;
    z <= '1' when res_sub = 0 else '0';
    s <= res_sub(32);
    --calcul des sorties
    slt <= s;
    jcond <= (IR(14) and (IR(12) xor s)) or ((not IR(14)) and (IR(12) xor z));
end architecture;
