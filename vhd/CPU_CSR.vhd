library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CSR is
    generic (
        INTERRUPT_VECTOR : waddr   := w32_zero;
        mutant           : integer := 0
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Interface de et vers la PO
        cmd         : in  PO_cs_cmd;
        it          : out std_logic;
        pc          : in  w32;
        rs1         : in  w32;
        imm         : in  W32;
        csr         : out w32;
        mtvec       : out w32;
        mepc        : out w32;

        -- Interface de et vers les IP d'interruption
        irq         : in  std_logic;
        meip        : in  std_logic;
        mtip        : in  std_logic;
        mie         : out w32;
        mip         : out w32;
        mcause      : in  w32
    );
end entity;

architecture RTL of CPU_CSR is
    -- Fonction retournant la valeur à écrire dans un csr en fonction
    -- du « mode » d'écriture, qui dépend de l'instruction
    function CSR_write (CSR        : w32;
                         CSR_reg    : w32;
                         WRITE_mode : CSR_WRITE_mode_type)
        return w32 is
        variable res : w32;
    begin
        case WRITE_mode is
            when WRITE_mode_simple =>
                res := CSR;
            when WRITE_mode_set =>
                res := CSR_reg or CSR;
            when WRITE_mode_clear =>
                res := CSR_reg and (not CSR);
            when others => null;
        end case;
        return res;
    end CSR_write;

    signal mcause_d,mip_d,mie_d,mstatus_d,mtvec_d,mepc_d,mcause_q,mip_q,mie_q,mstatus_q,mtvec_q,mepc_q,TO_CSR : w32;

begin

    process (clk,irq,cmd)
    begin
        --registres mcause,mip,mstatus,mtvec,mie,mepc
        if rising_edge(clk) then 
            if rst='0' then
                mcause_q  <= mcause_d;
                mip_q     <= mip_d;
                mstatus_q <= mstatus_d;
                mtvec_q   <= mtvec_d;
                mie_q     <= mie_d;
                mepc_q    <= mepc_d;
            else
                mcause_q  <= w32_zero;
                mip_q     <= w32_zero;
                mstatus_q <= w32_zero;
                mtvec_q   <= w32_zero;
                mepc_q    <= w32_zero;
                mie_q     <= w32_zero;
            end if;
        end if;

        if cmd.TO_CSR_Sel = TO_CSR_from_imm then
            TO_CSR <= imm;
        elsif cmd.TO_CSR_Sel = TO_CSR_from_rs1 then
            TO_CSR <= rs1;
        end if;

        --mcause
        if irq = '1' then
            mcause_d <= mcause;
        else
            mcause_d <= mcause_q;
        end if;

        --mip
        mip_d <= mip_q(31 downto 12) & meip & mip_q(10 downto 8) & mtip & mip_q(6 downto 0);

        mstatus_d <= mstatus_q;
        mepc_d    <= mepc_q;
        mtvec_d   <= mtvec_q;
        mie_d     <= mie_q;

        case cmd.CSR_we is
            --mstatus
            when CSR_mstatus =>
                mstatus_d <= CSR_write(TO_CSR,mstatus_q,cmd.CSR_WRITE_mode);
            --mepc
            when CSR_mepc =>
                if cmd.MEPC_sel = MEPC_from_pc then
                    mepc_d <= CSR_write(pc,mepc_q,cmd.CSR_WRITE_mode);
                elsif cmd.MEPC_sel = MEPC_from_csr then
                    mepc_d <= CSR_write(TO_CSR,mepc_q,cmd.CSR_WRITE_mode);
                end if;
                mepc_d(1 downto 0) <= "00";
            --mtvec
            when CSR_mtvec =>
                mtvec_d <= CSR_write(TO_CSR,mtvec_q,cmd.CSR_WRITE_mode);
                mtvec_d(1 downto 0) <= "00";
            --mie
            when CSR_mie =>
                mie_d <= CSR_write(TO_CSR,mie_q,cmd.CSR_WRITE_mode);
        
            when others =>
                null;
        end case;
        
        --mstatus_mie est définie à l'extérieur de case car elle ne dépend pas du choix de registre mstatus
        if cmd.MSTATUS_mie_set='1' then
            mstatus_d(3) <= '1';
        elsif cmd.MSTATUS_mie_reset='1' then
            mstatus_d(3) <= '0';
        end if;

    end process;

    mie <= mie_q;
    mtvec <= mtvec_q;
    mepc <= mepc_q;
    mip <= mip_q;
    it <= irq and mstatus_q(3);
    csr <= mcause_q when cmd.CSR_sel = CSR_from_mcause else mip_q when cmd.CSR_sel = CSR_from_mip else mstatus_q when cmd.CSR_sel = CSR_from_mstatus else mepc_q when cmd.CSR_sel = CSR_from_mepc else mtvec_q when cmd.CSR_sel = CSR_from_mtvec else mie_q when cmd.CSR_sel = CSR_from_mie else w32_zero;

end architecture;
