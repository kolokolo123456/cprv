library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_SUB,
        S_AUIPC,
        S_SLL,
        S_OR,
        S_ORI,
        S_AND,
        S_ANDI,
        S_XOR,
        S_XORI,
        S_SLLI,
        S_SRA,
        S_SRAI,
        S_SRL,
        S_SRLI,
        S_BEQ,--tout les branchements regroupés en BEQ
        S_SLT,
        S_SLTI, 
        S_LW1,S_LW2,S_LW3,
        S_LB1,S_LB2,S_LB3,
        S_LBU1,S_LBU2,S_LBU3,
        S_LH1,S_LH2,S_LH3,
        S_LHU1,S_LHU2,S_LHU3,
        S_SW1,S_SW2,
        S_SB1,S_SB2,
        S_SH1,S_SH2,
        S_JAL,
        S_JALR,
        S_CSRRW,
        S_CSRRS,
        S_MRET,
        S_CSRRC,
        S_CSRRCI,
        S_CSRRSI,
        S_CSRRWI
    );

    signal state_d, state_q : State_type;

begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_and;
        cmd.ALU_Y_sel         <= ALU_Y_rf_rs2;

        cmd.SHIFTER_op        <= SHIFT_rl;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.RF_SIGN_enable    <= '0';
        cmd.DATA_sel          <= DATA_from_pc;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= PC_from_pc;

        cmd.PC_X_sel          <= PC_X_cst_x00;
        cmd.PC_Y_sel          <= PC_Y_cst_x04;

        cmd.TO_PC_Y_sel       <= TO_PC_Y_cst_x04;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= AD_Y_immI;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= ADDR_from_pc;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd.cs.CSR_we            <= CSR_none;

        cmd.cs.TO_CSR_sel        <= TO_CSR_from_rs1;
        cmd.cs.CSR_sel           <= UNDEFINED;
        cmd.cs.MEPC_sel          <= UNDEFINED;

        cmd.cs.MSTATUS_mie_set   <= '0';
        cmd.cs.MSTATUS_mie_reset <= '0';

        cmd.cs.CSR_WRITE_mode    <= WRITE_mode_simple;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>
                -- On peut aussi utiliser un case, ...
                -- et ne pas le faire juste pour les branchements et auipc
                if status.IR(6 downto 0) = "0110111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ADDI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "000" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ADD;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "000" and status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SUB;

                elsif status.IR(6 downto 0) = "0010111" then
                    state_d <= S_AUIPC;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "001" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLL;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "110" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_OR;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "110" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ORI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "111" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_AND;
                    
                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ANDI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "100" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_XOR;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "100" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_XORI;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "001" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLLI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRA;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRAI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRL;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRLI;

                elsif status.IR(6 downto 0) = "1100011" and (status.IR(14 downto 12) = "000" or status.IR(14 downto 12) = "101" or status.IR(14 downto 12) = "111" or status.IR(14 downto 12) = "100" or status.IR(14 downto 12) = "110" or status.IR(14 downto 12) = "001") then
                    state_d <= S_BEQ;


                elsif status.IR(6 downto 0) = "0110011" and (status.IR(14 downto 12) = "010" or status.IR(14 downto 12) = "011") and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLT;

                elsif status.IR(6 downto 0) = "0010011" and (status.IR(14 downto 12) = "010" or status.IR(14 downto 12) = "011" ) then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLTI;

                elsif status.IR(6 downto 0) = "0000011" and status.IR(14 downto 12) = "010" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LW1;

                elsif status.IR(6 downto 0) = "0000011" and status.IR(14 downto 12) = "000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LB1;

                elsif status.IR(6 downto 0) = "0000011" and status.IR(14 downto 12) = "100" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LBU1;
                
                elsif status.IR(6 downto 0) = "0100011" and status.IR(14 downto 12) = "010" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SW1;
                
                elsif status.IR(6 downto 0) = "0100011" and status.IR(14 downto 12) = "000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SB1;
                
                elsif status.IR(6 downto 0) = "0100011" and status.IR(14 downto 12) = "001" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SH1;
                
                elsif status.IR(6 downto 0) = "0000011" and status.IR(14 downto 12) = "001" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LH1;
                
                elsif status.IR(6 downto 0) = "0000011" and status.IR(14 downto 12) = "101" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LHU1;

                elsif status.IR(6 downto 0) = "1101111" then
                    state_d <= S_JAL;

                elsif status.IR(6 downto 0) = "1100111" and status.IR(14 downto 12) = "000" then
                    state_d <= S_JALR;
                elsif status.IR(6 downto 0) = "1110011" and status.IR(14 downto 12) = "001" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_CSRRW;
                elsif status.IR(6 downto 0) = "1110011" and status.IR(14 downto 12) = "010" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_CSRRS;
                elsif status.IR = "001100000010000000000000001110011" then
                    state_d <= S_MRET;
                elsif status.IR(6 downto 0) = "1110011" and status.IR(14 downto 12) = "011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_CSRRC;
                elsif status.IR(6 downto 0) = "1110011" and status.IR(14 downto 12) = "111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_CSRRCI;
                elsif status.IR(6 downto 0) = "1110011" and status.IR(14 downto 12) = "110" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_CSRRSI;
                elsif status.IR(6 downto 0) = "1110011" and status.IR(14 downto 12) = "101" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_CSRRWI;
                else
                        state_d <= S_Error; -- Pour d´etecter les rat´es du d´ecodage
                    end if;


                -- Décodage effectif des instructions,

---------- Instructions avec immediat de type U ----------

            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
         
---------- Instructions de chargement à partir de la mémoire ----------
            when S_LW1 | S_LB1 | S_LBU1 | S_LH1 | S_LHU1 => 
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                case state_q is
                    when S_LW1 =>
                        state_d <= S_LW2;
                    when S_LB1 =>
                        state_d <= S_LB2;
                    when S_LBU1 =>
                        state_d <= S_LBU2;
                    when S_LH1 =>
                        state_d <= S_LH2;
                    when S_LHU1 =>
                        state_d <= S_LHU2;
                    when others =>
                        null;
                end case;
            
            when S_LW2 | S_LB2 | S_LBU2 | S_LH2 | S_LHU2 =>
                -- Accés mémoire
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                if state_d = S_LW2 then
                    state_d <= S_LW3;
                elsif state_d = S_LB2 then
                    state_d <= S_LB3;
                elsif state_d = S_LBU2 then
                    state_d <= S_LBU3;
                elsif state_d = S_LH2 then
                    state_d <= S_LH3;
                elsif state_d = S_LHU2 then
                    state_d <= S_LHU3;
                end if;
            
            when S_LW3 | S_LB3 | S_LBU3 | S_LH3 | S_LHU3 =>
                -- rd <- mem[(IR_31^20 ∥ IR_31...20) + rs1]
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';
                if state_d = S_LW3 then
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                elsif state_d = S_LB3 then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                    cmd.RF_SIGN_enable <= '1';
                elsif state_d = S_LBU3 then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                elsif state_d = S_LH3 then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                    cmd.RF_SIGN_enable <= '1';
                elsif state_d = S_LHU3 then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;
                state_d <= S_Pre_Fetch;

---------- Instructions de sauvegarde en mémoire ----------

            when S_SW1 | S_SB1 | S_SH1 =>
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                if state_q = S_SW1 then
                    state_d <= S_SW2;
                elsif state_q = S_SB1 then
                    state_d <= S_SB2;
                elsif state_q = S_SH1 then
                    state_d <= S_SH2;
                end if;

            when S_SW2 | S_SB2 | S_SH2 =>
                -- Accés mémoire
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                if state_d = S_SW2 then
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                elsif state_d = S_SB2 then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                elsif state_d = S_SH2 then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;
                state_d <= S_Pre_Fetch;

---------- Instructions arithmétiques et logiques ----------

            when S_ADD | S_ADDI |S_SUB =>
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- rd <- rs1 alu (rs2 or immI)
                if state_q = S_ADD then
                    cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                    cmd.ALU_op <= ALU_plus;
                elsif state_q = S_ADDI then
                    cmd.ALU_Y_sel <= ALU_Y_immI;
                    cmd.ALU_op <= ALU_plus;
                elsif state_q = S_SUB then
                    cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                    cmd.ALU_op <= ALU_minus;
                end if;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';
                -- next state
                state_d <= S_Fetch;
            
            when S_AUIPC =>
                -- incremente pc
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- rd <- immU + pc
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

            when S_SLL | S_SLLI | S_SRA | S_SRAI | S_SRL | S_SRLI =>
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- rd <- rs1 shift (rs2 or imm)
                if state_q = S_SLL then
                    cmd.SHIFTER_op <= SHIFT_ll;
                    cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                elsif state_q = S_SLLI then
                    cmd.SHIFTER_op <= SHIFT_ll;
                    cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                elsif state_q = S_SRA then
                    cmd.SHIFTER_op <= SHIFT_ra;
                    cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                elsif state_q = S_SRAI then
                    cmd.SHIFTER_op <= SHIFT_ra;
                    cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                elsif state_q = S_SRL then
                    cmd.SHIFTER_op <= SHIFT_rl;
                    cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                elsif state_q = S_SRLI then
                    cmd.SHIFTER_op <= SHIFT_rl;
                    cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                end if;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- next state
                state_d <= S_Fetch;

            when S_OR | S_ORI | S_AND | S_ANDI | S_XOR | S_XORI =>
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- rd <= rs1 log (rs2 or imm)
                if state_q = S_OR then
                    cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                    cmd.LOGICAL_op <= LOGICAL_or;
                elsif state_q = S_ORI then
                    cmd.ALU_Y_sel <= ALU_Y_immI;
                    cmd.LOGICAL_op <= LOGICAL_or;
                elsif state_q = S_AND then
                    cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                    cmd.LOGICAL_op <= LOGICAL_and;
                elsif state_q = S_ANDI then
                    cmd.ALU_Y_sel <= ALU_Y_immI;
                    cmd.LOGICAL_op <= LOGICAL_and;
                elsif state_q = S_XOR then
                    cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                    cmd.LOGICAL_op <= LOGICAL_xor;
                elsif state_q = S_XORI then
                    cmd.ALU_Y_sel <= ALU_Y_immI;
                    cmd.LOGICAL_op <= LOGICAL_xor;
                end if;
            
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
            
                -- next state
                state_d <= S_Fetch;

---------- Instructions de saut ----------

            when S_BEQ =>
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                --incrémentation conditionnelle
                if status.jcond = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';

                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            
            when S_SLT | S_SLTI =>
                    -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- rd <= rs1<rs2
                if state_q = S_SLT then
                    cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                elsif state_q = S_SLTI then
                    cmd.ALU_Y_sel <= ALU_Y_immI;
                end if;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                -- next state
                state_d <= S_Fetch;

            when S_JAL | S_JALR =>
                --rd<=pc+4    
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                --pc<=pc+cst
                cmd.PC_we <= '1';
                if state_q = S_JAL then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                    cmd.PC_sel <= PC_from_pc;
                elsif state_q = S_JALR then
                    cmd.ALU_Y_sel <= ALU_Y_immI;
                    cmd.ALU_op <= ALU_plus;
                    cmd.PC_sel <= PC_from_alu;
                end if;
                state_d <= S_Pre_Fetch;

---------- Instructions d'accès aux CSR ----------

            when S_CSRRW | S_CSRRS | S_CSRRC | S_CSRRWI | S_CSRRSI | S_CSRRCI =>
                --rd<=csr
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                --csr<=  rs1| rs1 or csr | csr and (not rs1)
                if state_q = S_CSRRW or state_q = S_CSRRS or state_q = S_CSRRC then
                    cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                    if state_q = S_CSRRS then
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                    elsif state_q = S_CSRRC then
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                    end if;
                elsif state_q = S_CSRRWI or state_q = S_CSRRSI or state_q = S_CSRRCI then
                    cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;
                    if state_q = S_CSRRSI then
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                    elsif state_q = S_CSRRCI then
                        cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                    end if;
                end if;

                if status.IR(31 downto 20)=x"300" then
                    cmd.cs.CSR_we <= CSR_mstatus;
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                elsif status.IR(31 downto 20)=x"341" then
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20)=x"305" then
                    cmd.cs.CSR_we <= CSR_mtvec;
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                elsif status.IR(31 downto 20)=x"304" then
                    cmd.cs.CSR_we <= CSR_mie;
                    cmd.cs.CSR_sel <= CSR_from_mie;
                elsif status.IR(31 downto 20)=x"342" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                elsif status.IR(31 downto 20)=x"344" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                end if;
                --next state
                state_d <= S_Pre_Fetch;

            when S_MRET =>
                --pc<=mepc
                cmd.PC_sel <= PC_from_mepc;
                cmd.PC_we <= '1';
                --mstatus(3)<=1
                cmd.cs.MSTATUS_mie_set <= '1';
                --next state
                state_d <= S_Pre_Fetch;

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
